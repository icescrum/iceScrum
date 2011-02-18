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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

package org.icescrum.core.services

import org.springframework.security.access.prepost.PreAuthorize
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.domain.TimeBox
import org.icescrum.core.utils.ServicesUtils
import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsHibernateUtil
import org.icescrum.core.event.IceScrumSprintEvent
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumStoryEvent

class SprintService {

  static transactional = true

  /**
   * Declarations
   */
  def clicheService
  def taskService
  def productBacklogService
  def releaseService
  def springSecurityService
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()

  @PreAuthorize('productOwner() or scrumMaster()')
  void saveSprint(Sprint sprint, Release release) {
    if (release.state == Release.STATE_DONE)
      throw new IllegalStateException('is_workflow_sprint_release_done')

    sprint.orderNumber = (release.sprints?.size() ?: 0) + 1
    def previousSprint = release.sprints?.find { it.orderNumber == sprint.orderNumber - 1}

    // Check sprint date integrity
    if (sprint.startDate > sprint.endDate)
      throw new IllegalStateException('is_workflow_sprint_end_after_start')
    if (sprint.startDate == sprint.endDate)
      throw new IllegalStateException('is_workflow_sprint_duration')

    // Check date integrity regarding the release dates
    if (sprint.startDate < release.startDate || sprint.endDate > release.endDate)
      throw new IllegalStateException('is_workflow_sprint_release_date_out_of_bound')

    // Check date integrity regarding the previous sprint date
    if (previousSprint && sprint.startDate <= previousSprint.endDate)
      throw new IllegalStateException('is_workflow_sprint_previous_date_overlap')

    sprint.parentRelease = release

    if (!sprint.save())
      throw new RuntimeException()
    
    release.addToSprints(sprint)
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
  }
  
  /**
   * Update a sprint
   * @param sprint
   * @param uCurrent
   */
  void updateSprint(Sprint sprint,Date startDate, Date endDate) {
    // A done sprint cannot be modified
    if (sprint.state == Sprint.STATE_DONE)
      throw new IllegalStateException('is_workflow_sprint_update_done')

    // Check sprint date integrity
    if (startDate > endDate)
      throw new IllegalStateException('is_workflow_sprint_end_after_start')
    if (startDate == endDate)
      throw new IllegalStateException('is_workflow_sprint_duration')

    // If the sprint is in INPROGRESS state, cannot change the startDate
    if (sprint.state == Sprint.STATE_INPROGRESS) {
      if (sprint.startDate != startDate) {
        throw new IllegalStateException('is_workflow_sprint_inprogress_startdate')
      }
    }

    // Check date integrity regarding the release dates
    if (startDate < sprint.parentRelease.startDate || endDate > sprint.parentRelease.endDate)
      throw new IllegalStateException('is_workflow_sprint_release_date_out_of_bound')

    def previousSprint = sprint.parentRelease.sprints?.find { it.orderNumber == sprint.orderNumber - 1}
    def nextSprint = sprint.parentRelease.sprints?.find { it.orderNumber == sprint.orderNumber + 1}

    // Check date integrity regarding the previous sprint date
    if (previousSprint && startDate <= previousSprint.endDate)
      throw new IllegalStateException('is_workflow_sprint_previous_date_overlap')

    // If the end date has changed and overlap the next sprint start date,
    // the sprints coming after are shifted
    if (sprint.endDate != endDate && nextSprint && endDate >= nextSprint.startDate) {
      def deltaDays = (endDate - nextSprint.startDate) + 1
      def nextSprints = sprint.parentRelease.sprints.findAll { it.orderNumber > sprint.orderNumber }
      for (Sprint s: nextSprints) {
        s.startDate = s.startDate + deltaDays
        if (s.endDate + deltaDays <= sprint.parentRelease.endDate) {
          s.endDate = s.endDate + deltaDays
          s.save()
        } else {
          // If we have reached the release end date, we try to reduce de the sprint's duration if possible
          // if not, the sprint is deleted and the stories that were planned are dissociated and return in the backlog
          if (s.startDate >= sprint.parentRelease.endDate) {
            deleteSprint(s)
            // The deleteSprint method should automatically dissociate and delete the following sprints, so we can
            // break out the loop
            break
          } else {
            s.endDate = sprint.parentRelease.endDate
            s.save()
          }
        }
      }
    }

    sprint.startDate = startDate
    sprint.endDate = endDate
    // Finally save the sprint
    if(!sprint.save(flush:true))
      throw new RuntimeException()
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }

  /**
   * Delete a sprint from the database
   * All its stories are dissociated before actual deletion.
   * @param sprint
   */
  void deleteSprint(Sprint sprint) {
    // Cannot delete a INPROGRESS or DONE sprint
    if (sprint.state >= Sprint.STATE_INPROGRESS)
      throw new IllegalStateException('is_workflow_sprint_delete')

    def release = sprint.parentRelease
    def nextSprints = release.sprints.findAll { it.orderNumber > sprint.orderNumber }

    // Every sprints coming after this one in the release are also deleted!
    productBacklogService.dissociatedAllStories(nextSprints)
    productBacklogService.dissociatedAllStories([sprint])
    release.removeFromSprints(sprint)

    nextSprints.each {
      release.removeFromSprints(it)
      publishEvent(new IceScrumSprintEvent(it,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
    }
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
  }


  void generateSprints(Release release,Date startDate = null) {
    if (release.state == Release.STATE_DONE)
      throw new IllegalStateException('is_workflow_sprint_release_done')

    int daysBySprint = release.parentProduct.preferences.estimatedSprintsDuration
    Date firstDate
    Date lastDate = release.endDate
    int nbSprint = 0
    long day = (24 * 60 * 60 * 1000)

    firstDate = startDate?:new Date(release.startDate.time)
    if (release.sprints?.size() >= 1) {
      // Search for the last sprint end date
      release.sprints.each { s ->
        if (s.endDate.after(firstDate))
          firstDate.time = s.endDate.time
        if (s.orderNumber > nbSprint)
          nbSprint = s.orderNumber
      }
      firstDate.time += day 
    }

    // If the release has a end date, the number of of sprint depends
    // of the total number of days available
    int totalDays = (int) ((lastDate.time - firstDate.time) / day)
    int nbSprints = Math.floor(totalDays / daysBySprint)
    nbSprints = Math.floor((totalDays - (nbSprints - 1)) / daysBySprint)
    Sprint newSprint

    for (int i = 0; i < nbSprints; i++) {
      Date endDate = new Date(firstDate.time + (day * (daysBySprint - 1)))
      
      newSprint = new Sprint(
              orderNumber: (++nbSprint),
              goal: 'Generated Sprint',
              startDate: (Date) firstDate.clone(),
              endDate: endDate,
              parentRelease: release
      )
      release.addToSprints(newSprint)
      if(!newSprint.save())
        throw new RuntimeException()

      firstDate.time = endDate.time + day
      publishEvent(new IceScrumSprintEvent(newSprint,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
    }
  }

  /**
   * Sprint activation
   * @param _sprint
   * @param uCurrent
   * @param pb
   */
  void activeSprint(Sprint sprint) {
    // Release of the sprint is not the activated release
    if (sprint.parentRelease.state != Release.STATE_INPROGRESS)
      throw new IllegalStateException('is_workflow_sprint_activate_release_inactivated')

    // If there is a sprint opened before, throw an workflow error
    int lastSprintClosed = -1
    Sprint s = sprint.parentRelease.sprints.find {
      if(it.state == Sprint.STATE_DONE)
        lastSprintClosed = it.orderNumber
      it.state == Sprint.STATE_INPROGRESS
    }
    if(s)
      throw new IllegalStateException('is_workflow_sprint_already_activated')

    // There is (in the release) sprints before 'sprint' which are not closed
    if (sprint.orderNumber != 1 && sprint.orderNumber > lastSprintClosed + 1)
      throw new IllegalStateException('is_workflow_sprint_not_closed_before')

    def autoCreateTaskOnEmptyStory = sprint.parentRelease.parentProduct.preferences.autoCreateTaskOnEmptyStory
    def user = null
    if (autoCreateTaskOnEmptyStory)
      user = User.get(springSecurityService.principal.id)

    sprint.stories?.each { pbi ->
      pbi.state = Story.STATE_INPROGRESS
      if (autoCreateTaskOnEmptyStory && pbi.tasks?.size() == 0){
        def emptyTask = new Task(name:pbi.name,state:Task.STATE_WAIT,description: pbi.description,creator:user,backlog:sprint)
        pbi.addToTasks(emptyTask).save()
        emptyTask.save()
      }
      pbi.save()
    }

    sprint.state = Sprint.STATE_INPROGRESS
    sprint.activationDate = new Date()

    sprint.stories.each {
      it.inProgressDate = new Date()
      publishEvent(new IceScrumStoryEvent(it,this.class,User.get(springSecurityService.principal?.id),IceScrumStoryEvent.EVENT_INPROGRESS))
    }

    //retrieve last done definition if no done definition in the current sprint
    if (sprint.orderNumber != 1 && !sprint.doneDefinition){
      def previousSprint = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber - 1,sprint.parentRelease)
      if (previousSprint.doneDefinition){
        sprint.doneDefinition = previousSprint.doneDefinition
      }
    }

    if(!sprint.save()){
      throw new RuntimeException()
    }

    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumSprintEvent.EVENT_ACTIVATED))

    // Create a cliché
    clicheService.createSprintCliche(sprint, new Date(),Cliche.TYPE_ACTIVATION)
    clicheService.createOrUpdateDailyTasksCliche(sprint)
  }

  void closeSprint(Sprint sprint) {
    // The sprint must be in the state "INPROGRESS"
    if(sprint.state != Sprint.STATE_INPROGRESS)
      throw new IllegalStateException('is_workflow_sprint_close_not_activated')

    Double sum = (Double) sprint.stories?.sum { pbi ->
      if (pbi.state == Story.STATE_DONE)
        pbi.effort.doubleValue()
      else
        0
    } ?: 0

    def nextSprint = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease,sprint.orderNumber + 1)
    if (nextSprint){
      //Move not finished urgent task to next sprint
      sprint.tasks?.findAll{it.type == Task.TYPE_URGENT && it.state != Task.STATE_DONE}?.each{
        it.backlog = nextSprint
        it.state = Task.STATE_WAIT
        it.inProgressDate = null
        if(!it.save()){
          throw new RuntimeException()
        }
      }
      productBacklogService.associateStories(nextSprint,sprint.stories.findAll {it.state != Story.STATE_DONE})
    }else{
      productBacklogService.dissociatedAllStories([sprint])
    }

    sprint.velocity = sum
    sprint.state = Sprint.STATE_DONE
    sprint.closeDate = new Date()

    if(!sprint.save(flush:true)){
      throw new RuntimeException()
    }
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumSprintEvent.EVENT_CLOSED))
    // Create cliché
    clicheService.createSprintCliche(sprint, new Date(),Cliche.TYPE_CLOSE)
    clicheService.createOrUpdateDailyTasksCliche(sprint)
  }

  boolean changeRank(Sprint sprint, Story movedItem, int rank) {
    if (movedItem.rank != rank) {
      if (movedItem.rank > rank) {
        sprint.stories.each {it ->
          if (it.rank >= rank && it.rank <= movedItem.rank && it != movedItem) {
            it.rank = it.rank + 1
            it.save()
          }
        }
      } else {
        sprint.stories.each {it ->
          if (it.rank <= rank && it.rank >= movedItem.rank && it != movedItem) {
            it.rank = it.rank - 1
            it.save()
          }
        }
      }
      movedItem.rank = rank
      if (movedItem.save())
        return true
      else
        return false
    } else {
      return false
    }
  }

  void updateDoneDefinition(Sprint sprint) {
    if(!sprint.save()){
      throw new RuntimeException()
    }
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumSprintEvent.EVENT_UPDATED_DONE_DEFINITION))
  }

  void updateRetrospective(Sprint sprint) {
    if(!sprint.save()){
      throw new RuntimeException()
    }
    publishEvent(new IceScrumSprintEvent(sprint,this.class,User.get(springSecurityService.principal?.id),IceScrumSprintEvent.EVENT_UPDATED_RETROSPECTIVE))
  }

  def sprintBurndownHoursValues(Sprint sprint) {
    def values = []
    def lastDaycliche = sprint.activationDate
    def maxHours = null

    clicheService.createOrUpdateDailyTasksCliche(sprint)

    sprint.cliches?.sort{a,b -> a.datePrise <=> b.datePrise}?.eachWithIndex {cliche,index ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          lastDaycliche = cliche.datePrise
          def currentRemaining = xmlRoot."${Cliche.REMAINING_HOURS}".toInteger()
          if (maxHours < currentRemaining){
            maxHours = currentRemaining
          }
          if ((ServicesUtils.isDateWeekend(lastDaycliche) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche))
            values << [
                  remainingHours: currentRemaining,
                  label: "${g.formatDate(date:lastDaycliche,formatName:'is.date.format.short')}"
            ]
        }
    }
    if (Sprint.STATE_INPROGRESS == sprint.state){
      def nbDays = sprint.endDate - lastDaycliche
      nbDays.times{
        if ((ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )))
            values << [
                  remainingHours: null,
                  label: "${g.formatDate(date:lastDaycliche + ( it + 1 ),formatName:'is.date.format.short')}"
            ]
      }
    }
    if (!values.isEmpty()){
      values.first()?.idealHours = maxHours
      values.last()?.idealHours = 0
    }
    return values
  }

  def sprintBurnupTasksValues(Sprint sprint) {
    def values = []
    def lastDaycliche = sprint.activationDate

    clicheService.createOrUpdateDailyTasksCliche(sprint)

    sprint.cliches?.sort{a,b -> a.datePrise <=> b.datePrise}?.eachWithIndex { cliche,index ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          lastDaycliche = cliche.datePrise
          if ((ServicesUtils.isDateWeekend(lastDaycliche) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche))
            values << [
                    tasksDone: xmlRoot."${Cliche.TASKS_DONE}".toInteger(),
                    tasks: xmlRoot."${Cliche.TOTAL_TASKS}".toInteger(),
                    label: "${g.formatDate(date:lastDaycliche,formatName:'is.date.format.short')}"
            ]
        }
    }

    if (Sprint.STATE_INPROGRESS == sprint.state){
      def nbDays = sprint.endDate - lastDaycliche
      nbDays.times{
        if ((ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )))
            values << [
                  tasksDone:null,
                  tasks:null,
                  label: "${g.formatDate(date:lastDaycliche + ( it + 1 ),formatName:'is.date.format.short')}"
            ]
      }
    }
    return values
  }

  def sprintBurnupStoriesValues(Sprint sprint) {
    def values = []
    def lastDaycliche = sprint.activationDate

    clicheService.createOrUpdateDailyTasksCliche(sprint)

    sprint.cliches?.sort{a,b -> a.datePrise <=> b.datePrise}?.eachWithIndex { cliche,index ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          lastDaycliche = cliche.datePrise
          if ((ServicesUtils.isDateWeekend(lastDaycliche) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche))
            values << [
                    storiesDone: xmlRoot."${Cliche.STORIES_DONE}".toInteger(),
                    stories: xmlRoot."${Cliche.TOTAL_STORIES}".toInteger(),
                    label: "${g.formatDate(date:lastDaycliche,formatName:'is.date.format.short')}"
            ]
        }
    }

    if (Sprint.STATE_INPROGRESS == sprint.state){
      def nbDays = sprint.endDate - lastDaycliche
      nbDays.times{
        if ((ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )) && !sprint.parentRelease.parentProduct.preferences.hideWeekend) || !ServicesUtils.isDateWeekend(lastDaycliche + ( it + 1 )))
           values << [
                    storiesDone: null,
                    stories: null,
                    label: "${g.formatDate(date:lastDaycliche + ( it + 1 ),formatName:'is.date.format.short')}"
            ]
      }
    }

    return values
  }

  def copyRecurrentTasksFromPreviousSprint(Sprint sprint){
    if (sprint.orderNumber == 1){
      throw new IllegalStateException('is.sprint.copyRecurrentTasks.error.no.sprint.before')
    }
    if (sprint.state == Sprint.STATE_DONE){
      throw new IllegalStateException('is.sprint.copyRecurrentTasks.error.sprint.done')
    }
    def lastsprint = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease,sprint.orderNumber - 1)
    def tasks = lastsprint.tasks.findAll{it.type == Task.TYPE_RECURRENT}

    if (!tasks){
      throw new IllegalStateException('is.sprint.copyRecurrentTasks.error.no.recurrent.tasks')
    }

    tasks.each {it ->
      def tmp = new Task()
      tmp.properties = it.properties
      tmp.creationDate = new Date()
      tmp.state = Task.STATE_WAIT
      tmp.backlog = sprint
      tmp.responsible = null
      tmp.participants = null
      tmp.inProgressDate = null
      tmp.doneDate = null
      sprint.addToTasks(tmp)
    }
    if (!sprint.save()){
      throw new RuntimeException()
    }
  }

  @Transactional(readOnly = true)
  def unMarshallSprint(NodeChild sprint, Product p = null){
    try {
      def activationDate = null
      if (sprint.activationDate?.text() && sprint.activationDate?.text() != "")
        activationDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.activationDate.text())?:null
      if (!activationDate && sprint.state.text().toInteger() >= Sprint.STATE_INPROGRESS){
        activationDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.startDate.text())
      }

      def closeDate = null
      if (sprint.closeDate?.text() && sprint.closeDate?.text() != "")
        closeDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.closeDate.text())?:null
      if (!closeDate && sprint.state.text().toInteger() == Sprint.STATE_INPROGRESS){
        closeDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.endDate.text())
      }

      def s = new Sprint(
              retrospective:sprint.retrospective.text(),
              doneDefinition:sprint.doneDefinition.text(),
              activationDate:activationDate,
              closeDate:closeDate,
              state:sprint.state.text().toInteger(),
              resource:(sprint.resource.text().isNumber())?sprint.resource.text().toInteger():null,
              velocity:(sprint.velocity.text().isNumber())?sprint.velocity.text().toDouble():0d,
              dailyWorkTime:(sprint.dailyWorkTime.text().isNumber())?sprint.dailyWorkTime.text().toDouble():8d,
              capacity:(sprint.capacity.text().isNumber())?sprint.capacity.text().toDouble():0d,
              startDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.startDate.text()),
              endDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(sprint.endDate.text()),
              orderNumber:sprint.orderNumber.text().toInteger(),
              description:sprint.description.text()?:'',
              goal:sprint.goal?.text()?:'',
      )

      sprint.cliches.cliche.each{
          def c = clicheService.unMarshallCliche(it)
          ((TimeBox)s).addToCliches(c)
      }

      if (p){
         sprint.stories.story.each{
          productBacklogService.unMarshallProductBacklog(it,p,s)
         }

         sprint.tasks.task.each{
          def t = taskService.unMarshallTask(it,p)
          s.addToTasks(t)
         }
      }
      return s
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }
  }
}