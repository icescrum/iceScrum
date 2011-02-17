/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

package org.icescrum.core.services

import grails.plugin.fluxiable.Activity
import org.springframework.security.access.prepost.PreAuthorize

import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.event.IceScrumStoryEvent

class ProductBacklogService {
  def productService
  def taskService
  def springSecurityService
  def clicheService
  def featureService
  def attachmentableService
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()

  static transactional = true

  void saveStory(Story story, Product p, User u, Sprint s = null) {

    if (!story.effort)
      story.effort = null

    story.backlog = p
    story.creator = u

    if (story.textAs != '') {
      def actor = Actor.findByBacklogAndName(p, story.textAs)
      if (actor) {
        story.actor = actor
      }
    }

    story.state = Story.STATE_SUGGESTED
    story.suggestedDate = new Date()

    if (story.state < Story.STATE_ACCEPTED && story.effort >= 0)
      null;
    //return ITEM_NOT_VALIDATE
    else if (story.effort > 0) {
      story.state = Story.STATE_ESTIMATED
      story.estimatedDate = new Date()
    }

    if (story.save()) {
      story.addFollower(u)
      story.addActivity(u, Activity.CODE_SAVE, story.name)
      publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_CREATED))
    } else {
      throw new RuntimeException()
    }
  }

  void deleteStory(Story _item, Product p,boolean history = true) {
    _item.removeAllAttachments()
    _item.removeLinkByFollow(_item.id)
    _item.delete()
    p.removeFromStories(_item)
    p.save()
    if (history){
      def u = User.get(springSecurityService.principal?.id)
      p.addActivity(u, Activity.CODE_DELETE, _item.name)
      publishEvent(new IceScrumStoryEvent(_item,this.class,u,IceScrumStoryEvent.EVENT_DELETED))
    }
    if (_item.state != Story.STATE_SUGGESTED)
        resetRank(p, _item.rank)
  }

  @PreAuthorize('productOwner() or scrumMaster()')
  void updateStory(Story story, Sprint sp = null) {
    if (story.textAs != '' && story.actor?.name != story.textAs) {
      def actor = Actor.findByBacklogAndName(story.backlog, story.textAs)
      if (actor) {
        story.actor = actor
      } else {
        story.actor = null
      }
    } else if (story.textAs == '' && story.actor) {
      story.actor = null
    }

    if (!sp && !story.parentSprint && (story.state == Story.STATE_ACCEPTED || story.state == Story.STATE_ESTIMATED)) {
      if (story.effort != null) {
        story.state = Story.STATE_ESTIMATED
        story.estimatedDate = new Date()
      }
      if (story.effort == null) {
        story.state = Story.STATE_ACCEPTED
        story.estimatedDate = null
      }
    } else if (story.parentSprint && story.parentSprint.state == Sprint.STATE_WAIT) {
      story.parentSprint.capacity = story.parentSprint.stories.sum { it.effort }
    }
    if (!story.save()) {
      throw new RuntimeException()
    } else {
      def u = User.get(springSecurityService.principal?.id)
      story.addActivity(u, Activity.CODE_UPDATE, story.name)
      publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_UPDATED))
    }
  }

  /**
   * Estimate a story (set the effort value)
   * @param story
   * @param estimation
   */
  @PreAuthorize('teamMember() or scrumMaster()')
  void estimateStory(Story story, estimation) {
    def oldState = story.state
    if (story.state < Story.STATE_ACCEPTED || story.state == Story.STATE_DONE)
      throw new IllegalStateException('is.story.error.estimated')
    if (!(estimation instanceof Number) && (estimation instanceof String && !estimation.isNumber())) {
      story.state = Story.STATE_ACCEPTED
      story.effort = null
      story.estimatedDate = null
    } else {
      story.state = Story.STATE_ESTIMATED
      story.effort = estimation.toInteger()
      story.estimatedDate = new Date()
    }
    if (story.save()){
      def u = User.get(springSecurityService.principal?.id)
      story.addActivity(u, Activity.CODE_UPDATE, story.name)
      if (oldState != story.state && story.state == Story.STATE_ESTIMATED)
        publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_ESTIMATED))
      else if(oldState != story.state && story.state == Story.STATE_ACCEPTED)
        publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_ACCEPTED))
    }
    else{
      throw new RuntimeException()
    }
  }

  @PreAuthorize('productOwner(#p) or scrumMaster(#p)')
  void associateStories(Sprint sprint, Collection<Story> stories){
    stories.each {
      this.associateStory(sprint, it)
    }
  }

  /**
   * Associate a story in a sprint
   * @param sprint The targeted sprint
   * @param story The story to associate
   * @param user The user performing the action
   */
  @PreAuthorize('productOwner(#p) or scrumMaster(#p)')
  void associateStory(Sprint sprint, Story story) {
    // It is possible to associate a story if it is at least in the "ESTIMATED" state and not in the "DONE" state
    // It is not possible to associate a story in a "DONE" sprint either
    if (sprint.state == Sprint.STATE_DONE)
      throw new IllegalStateException('is.sprint.error.associate.done')
    if (story.state < Story.STATE_ESTIMATED)
      throw new IllegalStateException('is.sprint.error.associate.story.noEstimated')
    if (story.state == Story.STATE_DONE)
      throw new IllegalStateException('is.sprint.error.associate.story.done')

    // If the story was already in a sprint, it is dissociated beforehand
    if (story.parentSprint != null) {
      resetRank(story.parentSprint, story.rank)
      //Shift to next Sprint (no delete tasks)
      dissociateStory(story.parentSprint, story, false)
    }

    def user = User.get(springSecurityService.principal?.id)

    // Change the story state
    if (sprint.state == Sprint.STATE_INPROGRESS) {
      story.state = Story.STATE_INPROGRESS
      story.inProgressDate = new Date()
      if (!story.plannedDate)
        story.plannedDate = story.inProgressDate

      def autoCreateTaskOnEmptyStory = sprint.parentRelease.parentProduct.preferences.autoCreateTaskOnEmptyStory
      if (autoCreateTaskOnEmptyStory)
      if (autoCreateTaskOnEmptyStory && !story.tasks){
        def emptyTask = new Task(name:story.name,state:Task.STATE_WAIT,description: story.description,creator:user,backlog:sprint)
        story.addToTasks(emptyTask).save()
        emptyTask.save()
      }

      clicheService.createOrUpdateDailyTasksCliche(sprint)
    } else {
      story.state = Story.STATE_PLANNED
      story.plannedDate = new Date()
    }

    // Shift the other story rank
    resetRank(story.backlog, story.rank)

    // Change the story rank in the sprint (placed at the end)
    story.rank = (sprint.stories.findAll {it.state != Story.STATE_DONE}?.size() ?: 0) + 1

    story.tasks.findAll {it.state == Task.STATE_WAIT}.each{
      it.backlog = sprint
    }

    if(!story.save())
      throw new RuntimeException()

    sprint.addToStories(story)

    // Calculate the velocity of the sprint
    if (sprint.state == Sprint.STATE_WAIT)
      sprint.capacity = sprint.stories.sum { it.effort }
    sprint.save()

    if (story.state == Story.STATE_INPROGRESS)
      publishEvent(new IceScrumStoryEvent(story,this.class,user,IceScrumStoryEvent.EVENT_INPROGRESS))
    else
      publishEvent(new IceScrumStoryEvent(story,this.class,user,IceScrumStoryEvent.EVENT_PLANNED))
  }

  /**
   * Dissociate the specified backlog item from the specified sprint
   * @param _sprint
   * @param pbi
   * @return
   */
  void dissociateStory(Sprint _sprint, Story pbi, Boolean deleteTasks = true) {
    if (pbi.state != Story.STATE_DONE) {
      _sprint.removeFromStories(pbi)
      pbi.parentSprint = null

      if (_sprint.state == Sprint.STATE_WAIT)
        _sprint.capacity = _sprint.stories?.sum { it.effort } ?: 0

      if (_sprint.state == Sprint.STATE_INPROGRESS){
        def tasks = pbi.tasks.asList()
        def u = User.get(springSecurityService.principal?.id)
        for(task in tasks){
          if (task.state == Task.STATE_DONE){
            taskService.storyTaskToSprintTask(task,Task.TYPE_URGENT,u)
          }else{
            if (!deleteTasks){
              task.state = Task.STATE_WAIT
              task.inProgressDate = null
            }else{
              taskService.deleteTask(task,u,pbi.backlog)
            }
          }
        }
      }
      pbi.state = Story.STATE_ESTIMATED
      if(!pbi.save())
        throw new RuntimeException()
      setRank(pbi, 1)

      publishEvent(new IceScrumStoryEvent(pbi,this.class,User.get(springSecurityService.principal?.id),IceScrumStoryEvent.EVENT_UNPLANNED))
    } else {
      throw new IllegalStateException('is.sprint.error.dissociate.story.done')
    }
  }

  /**
   * Dissociate all backlog items from todo sprints
   * @param spList
   * @param state (optional) If this argument is specified, dissociate only the sprint with the specified state
   */
  void dissociatedAllStories(Collection<Sprint> sprintList, Integer sprintState = null) {
    def spList = sprintList
    spList.sort { sp1, sp2 -> sp2.orderNumber <=> sp1.orderNumber }.each { sp ->
      if ((!sprintState) || (sprintState && sp.state == sprintState)) {
        def stories = sp.stories.findAll { pbi ->
          pbi.state != Story.STATE_DONE
        }.sort {st1, st2 -> st2.rank <=> st1.rank }
        stories.each {
          dissociateStory(sp, it)
        }
        // Recalculate the sprint estimated velocity (capacite)
        if (sp.state == sp.STATE_WAIT)
          sp.capacity = sp.stories?.sum { it.effort } ?: 0
      }
    }
  }

  void autoPlan(Release release, Double capacity) {
    int nbPoints = 0
    int nbSprint = 0
    def product = release.parentProduct
    def sprints = release.sprints.findAll { it.state == Sprint.STATE_WAIT }.sort { it.orderNumber }.asList()
    int maxSprint = sprints.size()

    // Get the list of PBI that have been estimated
    Collection<Story> itemsList = product.stories.findAll { it.state == Story.STATE_ESTIMATED }.sort { it.rank };

    Sprint currentSprint = null

    // Associate pbi in each sprint
    for (Story pbi: itemsList) {

      if ((nbPoints + pbi.effort) > capacity || currentSprint == null) {

        nbPoints = 0
        if (nbSprint < maxSprint) {

          currentSprint = sprints[nbSprint++]
          nbPoints += currentSprint.capacity
          while (nbPoints + pbi.effort > capacity && currentSprint.capacity > 0) {

            nbPoints = 0
            if (nbSprint < maxSprint) {
              currentSprint = sprints[nbSprint++]
              nbPoints += currentSprint.capacity
            }
            else {
              nbSprint++
              break;
            }

          }

          if (nbSprint > maxSprint) {
            break
          }

          this.associateStory(currentSprint, pbi)
          nbPoints += pbi.effort

        } else {
          break
        }
      } else {

        this.associateStory(currentSprint, pbi)
        nbPoints += pbi.effort

      }

    }
  }

  void setRank(Story story, int rank) {
    story?.backlog?.stories?.findAll {it.state == Story.STATE_ACCEPTED || it.state == Story.STATE_ESTIMATED}?.each { pbi ->
      if (pbi.rank >= rank) {
        pbi.rank++
        pbi.save()
      }
    }
    story.rank = rank
    if(!story.save())
      throw new RuntimeException()
  }

  @PreAuthorize('productOwner(#p) or scrumMaster(#p)')
  boolean changeRank(Product product, Story movedItem, int rank) {

    //For re-init corrupted rank
    if (movedItem.rank <= 0){
      def stories = product.stories.findAll{it.state == Story.STATE_ACCEPTED || it.state == Story.STATE_ESTIMATED}.sort({ a, b -> a.rank <=> b.rank } as Comparator)
      stories.eachWithIndex {it,index ->
        it.rank = index + 1
        it.save()
      }
    }


    if (movedItem.rank != rank) {
      if (movedItem.rank > rank) {
        Story.findAllAcceptedOrEstimated(product.id).list(order: 'asc', sort: 'rank').each {it ->
          if (it.rank >= rank && it.rank <= movedItem.rank && it != movedItem) {
            it.rank = it.rank + 1
            it.save()
          }
        }
      } else {
        Story.findAllAcceptedOrEstimated(product.id).list(order: 'asc', sort: 'rank').each {it ->
          if (it.rank <= rank && it.rank >= movedItem.rank && it != movedItem) {
            it.rank = it.rank - 1
            it.save()
          }
        }
      }
      movedItem.rank = rank
      return movedItem.save()
    } else {
      return false
    }
  }

  void resetRank(Product product, int newPbiRank) {
    product.stories.findAll {it.state == Story.STATE_ACCEPTED || it.state == Story.STATE_ESTIMATED}.each { pbi ->
      if (pbi.rank > newPbiRank) {
        pbi.rank--
        pbi.save()
      }
    }
  }

  void resetRank(Sprint sprint, int newPbiRank) {
    sprint.stories.each { pbi ->
      if (pbi.rank > newPbiRank) {
        pbi.rank--
        pbi.save()
      }
    }
  }

  @PreAuthorize('productOwner()')
  void acceptStoryToProductBacklog(Story pbi) {
    if (pbi.state == Story.STATE_SUGGESTED) {
      pbi.rank = Story.findAllAcceptedOrEstimated(pbi.backlog.id).list().size() + 1
      pbi.state = Story.STATE_ACCEPTED
      pbi.acceptedDate = new Date()
      if (((Product)pbi.backlog).preferences.noEstimation) {
        pbi.estimatedDate = new Date()
        pbi.effort = 1
        pbi.state = Story.STATE_ESTIMATED
      }
      if (pbi.save()){
        def u = User.get(springSecurityService.principal?.id)
        pbi.addActivity(u, 'acceptAs', pbi.name)
        publishEvent(new IceScrumStoryEvent(pbi,this.class,u,IceScrumStoryEvent.EVENT_ACCEPTED))
      }
    } else
      throw new IllegalStateException('is.story.error.not.state.suggested')
  }

  @PreAuthorize('productOwner()')
  void acceptStoryToFeature(Story pbi) {
    if (pbi.state == Story.STATE_SUGGESTED) {
      def user = User.get(springSecurityService.principal?.id)
      def feature = new Feature(pbi.properties)
      feature.description = (feature.description?:'')+' '+getTemplateStory(pbi)
      featureService.saveFeature(feature,(Product)pbi.backlog)
      pbi.attachments.each{ attachment ->
        feature.addAttachment(pbi.creator,attachmentableService.getFile(attachment),attachment.filename)
      }
      feature.addActivity(user, 'acceptAs', feature.name)
      publishEvent(new IceScrumStoryEvent(feature,this.class,user,IceScrumStoryEvent.EVENT_ACCEPTED_AS_FEATURE))
      this.deleteStory(pbi,(Product)pbi.backlog,false)
    } else
      throw new IllegalStateException('is.story.error.not.state.suggested')
  }

  @PreAuthorize('productOwner()')
  void acceptStoryToUrgentTask(Story pbi) {
    if (pbi.state == Story.STATE_SUGGESTED) {
      def task = new Task(pbi.properties)

      task.state = Task.STATE_WAIT
      task.description = (task.description?:'')+' '+getTemplateStory(pbi)

      def sprint = (Sprint)Sprint.findCurrentSprint(pbi.backlog.id).list()[0]
      if (sprint){
        taskService.saveUrgentTask(task,sprint,pbi.creator)
        pbi.attachments.each{ attachment ->
          task.addAttachment(pbi.creator,attachmentableService.getFile(attachment),attachment.filename)
        }
        pbi.comments.each {
          comment ->
          task.notes = (task.notes?:'') + '\n --- \n ' + comment.body  + '\n --- \n '
        }
        this.deleteStory(pbi,(Product)pbi.backlog,false)
        publishEvent(new IceScrumStoryEvent(task,this.class,User.get(springSecurityService.principal?.id),IceScrumStoryEvent.EVENT_ACCEPTED_AS_TASK))
      }else{
        throw new IllegalStateException('is.story.error.notacceptedAsUrgentTask')
      }
    } else
      throw new IllegalStateException('is.story.error.not.state.suggested')
  }

  private String getTemplateStory(Story story) {
    def textStory = ''
    def tempTxt = [story.textAs, story.textICan, story.textTo]*.trim()
    if (tempTxt != ['null', 'null', 'null'] && tempTxt != ['', '', ''] && tempTxt != [null, null, null]) {
      textStory += g.message(code: 'is.story.template.as') + ' '
      textStory += (story.actor?.name ?: story.textAs ?: '') + ', '
      textStory += g.message(code: 'is.story.template.ican') + ' '
      textStory += (story.textICan ?: '') + ' '
      textStory += g.message(code: 'is.story.template.to') + ' '
      textStory += (story.textTo ?: '')
    }
    textStory
  }


  @PreAuthorize('inProduct()')
  void declareAsDone(Story story) {
    declareAsDone([story])
  }

  @PreAuthorize('productOwner()')
  void declareAsUnDone(Story story) {
    declareAsUnDone([story])
  }

  @PreAuthorize('productOwner()')
  void declareAsDone(Collection<Story> stories) {
    stories.each { story ->

      if (story.parentSprint.state != Sprint.STATE_INPROGRESS){
        throw new IllegalStateException('is.sprint.error.declareAsDone.state.not.inProgress')
      }

      if (story.state != Story.STATE_INPROGRESS){
        throw new IllegalStateException('is.story.error.declareAsDone.state.not.inProgress')
      }

      story.state = Story.STATE_DONE
      story.doneDate = new Date()
      story.parentSprint.velocity += story.effort

      //Move story to last rank in sprint
      changeRank((Product)story.backlog, story, story.parentSprint.stories.size() + 1)

      if (story.save()){
        def u = User.get(springSecurityService.principal?.id)
        story.addActivity(u, 'done', story.name)
        publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_DONE))
      }
      else
        throw new RuntimeException()

      // Set all tasks to done (and pbi's estimation to 0)
      story.tasks?.each { t ->
        t.state = Task.STATE_DONE
        t.estimation = 0
        t.doneDate = new Date()
        if (!t.save())
          throw new RuntimeException()
      }
    }
    if (stories)
      clicheService.createOrUpdateDailyTasksCliche(stories[0]?.parentSprint)
  }

  @PreAuthorize('productOwner()')
  void declareAsUnDone(Collection<Story> stories) {
    stories.each { story ->

      if (story.state != Story.STATE_DONE){
        throw new IllegalStateException('is.story.error.declareAsUnDone.state.not.done')
      }

      if (story.parentSprint.state != Sprint.STATE_INPROGRESS){
        throw new IllegalStateException('is.sprint.error.declareAsUnDone.state.not.inProgress')
      }

      story.state = Story.STATE_INPROGRESS
      story.inProgressDate = new Date()
      story.doneDate = null
      story.parentSprint.velocity -= story.effort

      //Move story to last rank of in progress stories in sprint
      changeRank((Product)story.backlog, story, story.parentSprint.stories.findAll{it.state == Story.STATE_INPROGRESS}.size() + 1)

      if (story.save()){
        def u = User.get(springSecurityService.principal?.id)
        story.addActivity(u,'undone', story.name)
        publishEvent(new IceScrumStoryEvent(story,this.class,u,IceScrumStoryEvent.EVENT_UNDONE))
      }
      else
        throw new RuntimeException()
    }
    if (stories)
      clicheService.createOrUpdateDailyTasksCliche(stories[0]?.parentSprint)
  }

  void associateFeature(Feature feature, Story story) {
    story.feature = feature
    if(!story.save())
      throw new RuntimeException()
  }

  void dissociateFeature(Story story) {
    story.feature = null
    if(!story.save())
      throw new RuntimeException()
  }

  void cloneStory(Story story){

    def clonedStory = new Story(
            name:story.name+'_1',
            state:Story.STATE_SUGGESTED,
            description: story.description,
            notes:story.notes,
            dateCreated:new Date(),
            type:story.type,
            textAs:story.textAs,
            textICan:story.textICan,
            textTo:story.textTo,
            backlog:story.backlog,
            affectVersion:story.affectVersion,
            origin:story.name,
            feature:story.feature,
            actor:story.actor
    )

    clonedStory.validate()
    def i = 1
    while(clonedStory.hasErrors()){
      if (clonedStory.errors.getFieldError('name')){
        i += 1
        clonedStory.name = story.name+'_'+i
        clonedStory.validate()
      }else{
        throw new RuntimeException()
      }
    }
    saveStory(clonedStory, story.backlog, User.get(springSecurityService.principal.id))
  }

  @Transactional(readOnly = true)
  def unMarshallProductBacklog(NodeChild story,Product p = null, Sprint sp = null){
    try{
       def acceptedDate = null
        if (story.acceptedDate?.text() && story.acceptedDate?.text() != "")
          acceptedDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.acceptedDate.text())?:null

        def estimatedDate = null
        if (story.estimatedDate?.text() && story.estimatedDate?.text() != "")
          estimatedDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.estimatedDate.text())?:null

        def plannedDate = null
        if (story.plannedDate?.text() && story.plannedDate?.text() != "")
          plannedDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.plannedDate.text())?:null

        def inProgressDate = null
        if (story.inProgressDate?.text() && story.inProgressDate?.text() != "")
          inProgressDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.inProgressDate.text())?:null

        def doneDate = null
        if (story.doneDate?.text() && story.doneDate?.text() != "")
          doneDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.doneDate.text())?:null

        def s = new Story(
                name:story.name.text(),
                description:story.description.text(),
                notes:story.notes.text(),
                creationDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.creationDate.text()),
                effort:story.effort.text().isEmpty()?null:story.effort.text().toInteger(),
                value:story.value.text().isEmpty()?null:story.value.text().toInteger(),
                rank:story.rank.text().toInteger(),
                state:story.state.text().toInteger(),
                suggestedDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(story.suggestedDate.text()),
                acceptedDate:acceptedDate,
                estimatedDate:estimatedDate,
                plannedDate:plannedDate,
                inProgressDate:inProgressDate,
                doneDate:doneDate,
                type:story.type.text().toInteger(),
                executionFrequency:story.executionFrequency.text().toInteger(),
                textAs:story.textAs.text(),
                textICan:story.textICan.text(),
                textTo:story.textTo.text(),
                affectVersion:story.affectVersion.text(),
                origin:story.origin.text()
        )

        if (!story.feature?.@id?.isEmpty() && p){
          def f = p.features.find{ def id = it.idFromImport?:it.id
                                   id == story.feature.@id.text().toInteger()
                                 }?:null
          if (f){
            f.addToStories(s)
          }
        }

        if (!story.actor?.@id?.isEmpty() && p){
          def a = p.actors.find{ def id = it.idFromImport?:it.id
                                 id == story.actor.@id.text().toInteger()
                               }?:null
          if (a){
            a.addToStories(s)
          }
        }

        if (!story.creator?.@id?.isEmpty() && p){
          def u = null
          if (story.creator.@id.text().isNumber())
            u = (User)p.getAllUsers().find{ def id = it.idFromImport?:it.id
                                               id == story.creator.@id.text().toInteger()
                                             }?:null
          if (u)
            s.creator = u
          else
            s.creator = p.productOwners.first()
        }


        story.tasks.task.each{
          def t = taskService.unMarshallTask(it,p)
          if (sp){
            t.backlog = sp
          }
          s.addToTasks(t)
        }

        if (p){
           p.addToStories(s)
        }

        if(sp){
          sp.addToStories(s)
        }

        return s
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }
  }

}