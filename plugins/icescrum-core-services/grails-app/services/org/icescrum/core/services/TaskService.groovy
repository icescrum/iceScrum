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

import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Sprint

import org.icescrum.core.domain.TimeBox
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.springframework.context.ApplicationContext
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat

import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.event.IceScrumTaskEvent

class TaskService {


  static transactional = true

  def clicheService
  def productService
  def springSecurityService
  def securityService

  private boolean checkTaskEstimation(Task task){
     // Check if the estimation is numeric
    if(task.estimation){
      try {
        task.estimation = Integer.valueOf(task.estimation)
      } catch (NumberFormatException e) {
        throw new RuntimeException('is.task.error.estimation.number')
      }
    }

    if (task.estimation != null && task.estimation < 0)
      throw new IllegalStateException('is.task.error.negative.estimation')

    return true
  }

  void saveTask(Task task, TimeBox sprint, User user) {
    checkTaskEstimation(task)

    // If the estimation is equals to zero, drop it
    if (task.estimation == 0)
      task.estimation = null

    task.creator = user
    task.backlog = sprint
    task.rank = (((Sprint)sprint).tasks.findAll{it.type == task.type && it.parentStory == task.parentStory}?.size()?:0)+1

    if (!task.save()) {
      throw new RuntimeException()
    }
    clicheService.createOrUpdateDailyTasksCliche(task.backlog)
    task.addActivity(user, 'taskSave', task.name)
    publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_CREATED))
  }

  void saveStoryTask(Task task, Story story, User user) {
    task.parentStory = story
    def currentProduct = (Product)story.backlog
    if (currentProduct.preferences.assignOnCreateTask){
      task.responsible = user
    }
    saveTask(task, story.parentSprint, user)
  }

  void saveRecurrentTask(Task task, Sprint sprint, User user){
    task.type = Task.TYPE_RECURRENT
    def currentProduct = (Product)sprint.parentRelease.parentProduct
    if (currentProduct.preferences.assignOnCreateTask){
      task.responsible = user
    }

    saveTask(task, sprint, user)
  }

  void saveUrgentTask(Task task, Sprint sprint, User user){
    task.type = Task.TYPE_URGENT
    def currentProduct = (Product)sprint.parentRelease.parentProduct
    if (currentProduct.preferences.assignOnCreateTask){
      task.responsible = user
    }
    saveTask(task,sprint, user)
  }

  /**
   * An update with a Task changing its parentStory
   * @param task
   * @param user
   * @param product
   * @param story
   */
  void changeTaskStory(Task task, Story story, User user, Product product){
    if(task.parentStory.id != story.id){
      task.parentStory = story
      updateTask(task, user, product)
    }
  }

  /**
   * An update with a Task changing its type (URGENT/RECURRENT)
   * @param task
   * @param user
   * @param product
   * @param type
   */
  void changeTaskType(Task task, int type, User user, Product product){
    task.type = type
    updateTask(task, user, product)
  }

  /**
   * Transforms a Sprint Task into a Story Task
   * @param task
   * @param story
   * @param user
   * @param product
   */
  def sprintTaskToStoryTask(Task task, Story story, User user){
    task.type = null
    task.parentStory = story
    saveTask(task, task.backlog ,user)
    return task
  }
  /**
   * Transforms a Story Task into a Sprint Task
   * @param task
   * @param type
   * @param user
   * @param product
   */
  def storyTaskToSprintTask(Task task, int type, User user){
    def story = task.parentStory
    story.removeFromTasks(task)
    task.parentStory = null
    task.type = type
    saveTask(task, task.backlog, user)
    story.addActivity(user, (type == Task.TYPE_URGENT ? 'taskAssociateUrgent' : 'taskAssociateRecurrent'), task.name)
    return task
  }

  /**
   * Update a Task
   * @param task
   * @param user
   * @param product
   */
  void updateTask(Task task, User user, Product product, boolean force = false) {
    checkTaskEstimation(task)

    // TODO add check : if SM or PO, always allow
    if (force || (task.responsible && task.responsible.id.equals(user.id)) || task.creator.id.equals(user.id) || securityService.productOwner(product,springSecurityService.authentication) || securityService.scrumMaster(null,springSecurityService.authentication)) {
      if (task.estimation == 0) {
        task.state = Task.STATE_DONE
        task.doneDate = new Date()
      } else if (task.state == Task.STATE_DONE) {
        task.estimation = 0
        task.blocked = false
        task.doneDate = new Date()
      }

      if (task.state >= Task.STATE_BUSY && !task.inProgressDate){
          task.inProgressDate = new Date()
          if (!task.isDirty('blocked'))
            task.blocked = false
          else{
            if(task.blocked){
              publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_STATE_BLOCKED))
            }
          }
      }

      if (task.state < Task.STATE_BUSY && task.inProgressDate)
          task.inProgressDate = null

      if (!task.save()) {
        throw new RuntimeException()
      } else {
        if(task.state == Task.STATE_DONE) {
          task.addActivity(user, 'taskFinish', task.name)
          publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_STATE_DONE))
        }
      }

      if(!task.type && product.preferences.autoDoneStory && task.state == Task.STATE_DONE) {
        ApplicationContext ctx = (ApplicationContext)ApplicationHolder.getApplication().getMainContext();
        ProductBacklogService service = (ProductBacklogService) ctx.getBean("productBacklogService");

        Story s = Story.get(task.parentStory.id)
        if(!s.tasks.any { it.state != Task.STATE_DONE }){
          service.declareAsDone(s)
        }
      }
      clicheService.createOrUpdateDailyTasksCliche(task.backlog)
      publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_UPDATED))
    }
  }

  /**
   * Assign a collection of task to a peculiar user
   * @param tasks
   * @param user
   * @param p
   * @return
   */
  boolean assignToTasks(Collection<Task> tasks, User user, Product p) {
    tasks.each {
      it.responsible = user
      updateTask(it, user, p)
    }
    return true
  }

  /**
   * Unassign a collection of task to a peculiar user
   * @param tasks
   * @param user
   * @param p
   * @return
   */
  boolean unAssignToTasks(Collection<Task> tasks, User user, Product p) {
    tasks.each {
      if (it.responsible.id != user.id)
       throw new IllegalStateException('is.task.error.unassign.not.responsible')
      if (it.state == Task.STATE_DONE)
       throw new IllegalStateException('is.task.error.unassign.done')
      it.responsible = null
      it.state = Task.STATE_WAIT
      updateTask(it, user, p, true)
    }
    return true
  }

  void deleteTask(Task task, User user, Product product){
    if (task.state == Task.STATE_DONE && !securityService.scrumMaster(null,springSecurityService.authentication)){
      throw new IllegalStateException('is.task.error.delete.not.scrumMaster')
    }
    if (task.responsible && task.responsible.id.equals(user.id) || task.creator.id.equals(user.id) || securityService.productOwner(product,springSecurityService.authentication) || securityService.scrumMaster(null,springSecurityService.authentication)) {
      task.removeAllAttachments()
      def sprint = task.backlog
      if(task.parentStory){
        task.parentStory.addActivity(user, 'taskDelete', task.name)
        task.parentStory.removeFromTasks(task)
      }
     sprint.removeFromTasks(task)
     task.delete()
     clicheService.createOrUpdateDailyTasksCliche(sprint)
     publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_DELETED))
    }
  }

  void cloneTask(Task task, User user, Product product, def clonedState = Task.STATE_WAIT){
    if (task.state != Task.STATE_DONE){
      throw new IllegalStateException('is.task.error.cloned.state.not.done')
    }

    def clonedTask = new Task(
            name:task.name+'_1',
            rank:(((Sprint)task.backlog).tasks.findAll{it.type == task.type && it.parentStory == task.parentStory}?.size()?:0)+1,
            state:clonedState,
            creator:user,
            description: task.description,
            notes:task.notes,
            dateCreated:new Date(),
            backlog:task.backlog,
            parentStory:task.parentStory?:null,
            type:task.type
    )
    task.participants.each {
      clonedTask.addToParticipants(it)
    }

    clonedTask.validate()

    def i = 1
    while(clonedTask.hasErrors()){
      if (clonedTask.errors.getFieldError('name')){
        i += 1
        clonedTask.name = task.name+'_'+i
        clonedTask.validate()
      }else{
        throw new RuntimeException()
      }
    }

    if(!clonedTask.save()){
       throw new RuntimeException()
    }
    clicheService.createOrUpdateDailyTasksCliche(task.backlog)
    publishEvent(new IceScrumTaskEvent(task,this.class,user,IceScrumTaskEvent.EVENT_CREATED))
  }


  /**
   * Delete a collection of tasks
   * @param tasks
   * @param _pbi
   * @param user
   * @param pb
   * @return
   */
  boolean deleteTasks(Collection<Task> tasks, Story _pbi, User user, Product pb) {
    tasks.each {
      deleteTask(it, user, pb)
    }
    return true
  }

  /**
   * Delete a map of tasks
   * @param pbiTotasks
   * @param user
   * @param pb
   * @return
   */
  boolean deleteTasks(Map pbiTotasks, User user, Product pb) {
    def pbiMap
    pbiTotasks.keySet().each { pbi ->
      pbiMap = (Map) pbiTotasks.get(pbi)
      pbiMap.each { task ->
        deleteTask((Task)task, user, pb)
      }
    }
    return true
  }

  /**
   * Change the state of a task
   * @param t
   * @param u
   * @param i
   * @return
   */
  void changeState(Task t, Integer state, User u, Product p) {

    if(t.responsible == null && p.preferences.assignOnBeginTask && state >= Task.STATE_BUSY) {
      t.responsible = u
    }

    if (t.type == Task.TYPE_URGENT
            && state == Task.STATE_BUSY
            && t.state != Task.STATE_BUSY
            && p.preferences.limitUrgentTasks != 0
            && p.preferences.limitUrgentTasks == ((Sprint)t.backlog).tasks?.findAll{it.type == Task.TYPE_URGENT && it.state == Task.STATE_BUSY}?.size())
    {
      throw new IllegalStateException('is.task.error.limitTasksUrgent')
    }

    if((t.responsible && u.id.equals(t.responsible.id)) || u.id.equals(t.creator.id) || securityService.productOwner(p,springSecurityService.authentication) || securityService.scrumMaster(null,springSecurityService.authentication)){
      if (state == Task.STATE_BUSY && t.state != Task.STATE_BUSY) {
        t.addActivity(u, 'taskInprogress', t.name)
        publishEvent(new IceScrumTaskEvent(t,this.class,u,IceScrumTaskEvent.EVENT_STATE_IN_PROGRESS))
      } else if(state == Task.STATE_WAIT && t.state != Task.STATE_WAIT){
        t.addActivity(u, 'taskWait', t.name)
        publishEvent(new IceScrumTaskEvent(t,this.class,u,IceScrumTaskEvent.EVENT_STATE_WAIT))
      }
      t.state = state
      updateTask(t, u, p)
    }
  }

  /**
   * Assign a User to a Task
   * @param task
   * @param user
   * @return
   */
  boolean assignToTask(Task task, User user) {
    task.responsible = user
    task.save()
    return true
  }

  /**
   * When a unfinished story is removed from a sprint,
   * if it has finished tasks, those are moved to the sprint's pseudo-story
   * @param pbis
   * @param storyThisSprint
   */
  void moveFinishTasks(List pbis, Story storyThisSprint) {
    pbis.each { Story story ->
      // When the unfinished story is removed
      if (!storyThisSprint.equals(story) && story.state.equals(Story.STATE_INPROGRESS)) {
        for (int i = 0; i < story.tasks.size(); i++) {
          def task = story.tasks.toList()[i]
          // if finished tasks are found, they are moved to the storyThisSprint pbi
          if (task.state.equals(Task.STATE_DONE)) {
            storyThisSprint.addToTasks(task)
            task.save()
            story.tasks.remove(task)
            i--
          }
        }
      }
    }
  }

  boolean changeRank(Task movedItem, int rank) {
    def container
    if (movedItem.parentStory){
      container = movedItem.parentStory

    }else{
      container = movedItem.backlog
    }

    if (movedItem.rank != rank) {
      if (movedItem.rank > rank) {
        container.tasks.findAll{it.type == movedItem.type && it.state == movedItem.state}.each {it ->
          if (it.rank >= rank && it.rank <= movedItem.rank && it != movedItem) {
            it.rank = it.rank + 1
            it.save()
          }
        }
      } else {
        container.tasks.findAll{it.type == movedItem.type && it.state == movedItem.state}.each {it ->
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

  @Transactional(readOnly = true)
  def unMarshallTask(NodeChild task, Product p = null){
    try {
      def inProgressDate = null
      if (task.inProgressDate?.text() && task.inProgressDate?.text() != "")
        inProgressDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(task.inProgressDate.text())?:null

      def doneDate = null
      if (task.doneDate?.text() && task.doneDate?.text() != "")
        doneDate = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(task.doneDate.text())?:null

      def t = new Task(
              type:(task.type.text().isNumber())?task.type.text().toInteger():null,
              description:task.description.text(),
              notes:task.notes.text(),
              estimation:(task.estimation.text().isNumber())?task.estimation.text().toInteger():null,
              rank:task.rank.text().toInteger(),
              name:task.name.text(),
              doneDate:doneDate,
              inProgressDate:inProgressDate,
              state:task.state.text().toInteger(),
              creationDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(task.creationDate.text()),
              blocked:task.blocked.text()?.toBoolean()?:false
      )

      if (task.creator?.@id != '' && p){
        def u = ((User)p.getAllUsers().find{
                                        def id = it.idFromImport?:it.id
                                        id == task.creator.@id.text().toInteger()}
                                      )?:null
        if (u)
          t.creator = u
        else
          t.creator = p.productOwners.first()
      }

      if (task.responsible?.@id != ''  && p){
        def u = ((User)p.getAllUsers().find{
                                        def id = it.idFromImport?:it.id
                                        id == task.responsible.@id?.toInteger()}
                                      )?:null
        if (u)
          t.responsible = u
        else
          t.responsible = p.productOwners.first()
      }
      return t
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }

  }
}