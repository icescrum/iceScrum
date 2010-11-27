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

import groovy.xml.StreamingMarkupBuilder
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.TimeBox

class ClicheService {

  static transactional = true

  void addCliche(Cliche b, TimeBox t) {
    t.addToCliches(b)
    if(!b.save()){
      throw new RuntimeException(b.errors)
    }
  }

  void deleteAllCliche(TimeBox t) {
    def cliches = t.cliches
    cliches.each {
      t.removeFromCliches(it)
    }
  }

  void deleteCliche(Cliche c, TimeBox t) {
    t.removeFromCliches(c)
  }

  /**
   * Closure analysing effort from a PBI list and returning a map containing the data retrieved
   * @param pbis The list of pbis to analyse
   * @param inLoop A optional closure, to process additional instructions during the pbi analysing loop
   * (the current pbi is passed in argument of the closure each time). If not null, the closure is called as the
   * first instruction of the loop.
   * @return A map containing the result of the analyse.
   * Index availables in the map : compteurUS, compteurDefect, compteurTechnical,
   * compteurUSFinish, compteurDefectFinish, compteurTechnicalFinish
   */
  def computeDataOnType = { stories, Closure inLoop = null ->
    def cUS = 0
    def cDefect = 0
    def cTechnical = 0
    def cUSDone = 0
    def cDefectDone = 0
    def cTechnicalDone = 0
    stories.each { story ->
      inLoop?.call(story)
      // A story with 0 point of velocity doesn't need to be added
      // Moreover, the pseudo-story, with -999 pt of velocity, won't be added
      if(story.effort > 0) {
        switch(story.type){
          case Story.TYPE_USER_STORY:
            cUS += story.effort
            if(story.state == Story.STATE_DONE)
                cUSDone += story.effort
            break
          case Story.TYPE_DEFECT:
            cDefect += story.effort
            if(story.state == Story.STATE_DONE)
                cDefectDone += story.effort
            break
          case Story.TYPE_TECHNICAL_STORY:
            cTechnical += story.effort
            if(story.state == Story.STATE_DONE)
                cTechnicalDone += story.effort
            break
          default:
            break
        }
      }
    }
    [compteurUS:cUS,
            compteurDefect:cDefect,
            compteurTechnical:cTechnical,
            compteurUSFinish:cUSDone,
            compteurDefectFinish:cDefectDone,
            compteurTechnicalFinish:cTechnicalDone
    ]
  }

  void createSprintCliche(Sprint s, Date d, int type) {
    // Retrieve the current release and the current sprint
    Release r = s.parentRelease
    Product p = r.parentProduct
    // Browse the stories and add their estimated velocity to the corresponding counter
    def currentSprintData = computeDataOnType(s.stories)

    //****************************************************
    // Remaining release points
    //****************************************************
    // Retrieve all the PBI of the release
    List<Story> allItemsInRelease = Story.storiesByRelease(r).list()
    def allItemsReleaseData = computeDataOnType(allItemsInRelease)

    //****************************************************
    // Product Backlog points + Remaining product points
    //****************************************************
    def allItemsProductData = computeDataOnType(p.stories)

    //****************************************************
    // Total number of stories by state
    //****************************************************
    int done = 0
    int inprogress = 0
    int planned = 0
    int estimated = 0
    int accepted = 0
    int suggested = 0

    p.stories.each { pbi ->
      switch (pbi.state) {
        case Story.STATE_DONE:
          done++
          break
        case Story.STATE_INPROGRESS:
          inprogress++
          break
        case Story.STATE_PLANNED:
          planned++
          break
        case Story.STATE_ESTIMATED:
          estimated++
          break
        case Story.STATE_ACCEPTED:
          accepted++
          break
        case Story.STATE_SUGGESTED:
          suggested++
          break
        default:
          break
      }
    }

    def unresolvedImpediments = p.impediments.findAll {it.state != Impediment.SOLVED }?.size() ?: 0

    def clicheData = {
      cliche{

        "${Cliche.SPRINT_ID}"("R${r.orderNumber}S${s.orderNumber}")

        if (type == Cliche.TYPE_ACTIVATION){
          // Activation Date
          "${Cliche.ACTIVATION_DATE}"(s.activationDate)
          // Capacity
          "${Cliche.SPRINT_CAPACITY}"(currentSprintData['compteurUS'] + currentSprintData['compteurTechnical'] +currentSprintData['compteurDefect'])
          "${Cliche.FUNCTIONAL_STORY_CAPACITY}"(currentSprintData['compteurUS'])
          "${Cliche.TECHNICAL_STORY_CAPACITY}"(currentSprintData['compteurTechnical'])
          "${Cliche.DEFECT_STORY_CAPACITY}"(currentSprintData['compteurDefect'])
        }

        if (type == Cliche.TYPE_CLOSE){
          // Close Date
          "${Cliche.CLOSE_DATE}"(s.closeDate)
          // Capacity
          "${Cliche.SPRINT_VELOCITY}"(currentSprintData['compteurUS'] + currentSprintData['compteurTechnical'] +currentSprintData['compteurDefect'])
          "${Cliche.FUNCTIONAL_STORY_VELOCITY}"(currentSprintData['compteurUS'])
          "${Cliche.TECHNICAL_STORY_VELOCITY}"(currentSprintData['compteurTechnical'])
          "${Cliche.DEFECT_STORY_VELOCITY}"(currentSprintData['compteurDefect'])
        }

        // Product points
        "${Cliche.FUNCTIONAL_STORY_BACKLOG_POINTS}"(allItemsProductData['compteurUS'])
        "${Cliche.TECHNICAL_STORY_BACKLOG_POINTS}"(allItemsProductData['compteurTechnical'])
        "${Cliche.DEFECT_STORY_BACKLOG_POINTS}"(allItemsProductData['compteurDefect'])
        "${Cliche.PRODUCT_BACKLOG_POINTS}"(allItemsProductData['compteurUS'] + allItemsProductData['compteurTechnical'] + allItemsProductData['compteurDefect'])

        // Remaining backlog points
        def srp = allItemsProductData['compteurUS'] - allItemsProductData['compteurUSFinish']
        def trp = allItemsProductData['compteurTechnical'] - allItemsProductData['compteurTechnicalFinish']
        def drp = allItemsProductData['compteurDefect'] - allItemsProductData['compteurDefectFinish']
        "${Cliche.FUNCTIONAL_STORY_PRODUCT_REMAINING_POINTS}"(srp)
        "${Cliche.TECHNICAL_STORY_PRODUCT_REMAINING_POINTS}"(trp)
        "${Cliche.DEFECT_STORY_PRODUCT_REMAINING_POINTS}"(drp)
        "${Cliche.PRODUCT_REMAINING_POINTS}"(srp + trp + drp)

        // Release remaining points
        "${Cliche.FUNCTIONAL_STORY_RELEASE_REMAINING_POINTS}"(allItemsReleaseData['compteurUS'] - allItemsReleaseData['compteurUSFinish'])
        "${Cliche.TECHNICAL_STORY_RELEASE_REMAINING_POINTS}"(allItemsReleaseData['compteurTechnical'] - allItemsReleaseData['compteurTechnicalFinish'])
        "${Cliche.DEFECT_STORY_RELEASE_REMAINING_POINTS}"(allItemsReleaseData['compteurDefect'] - allItemsReleaseData['compteurDefectFinish'])

        // Stories points by states
        "${Cliche.FINISHED_STORIES}"(done)
        "${Cliche.INPROGRESS_STORIES}"(inprogress)
        "${Cliche.PLANNED_STORIES}"(planned)
        "${Cliche.ESTIMATED_STORIES}"(estimated)
        "${Cliche.ACCEPTED_STORIES}"(accepted)
        "${Cliche.SUGGESTED_STORIES}"(suggested)

        // Impediments
        "${Cliche.UNRESOLVED_IMPEDIMENTS}"(unresolvedImpediments)

        // Sprint Resource
        "${Cliche.SPRINT_RESOURCES}"(s.resource)


      }
    }
    StreamingMarkupBuilder xmlBuilder = new StreamingMarkupBuilder()

    Cliche c = new Cliche(
            type:type,
            datePrise:d,
            data:xmlBuilder.bind(clicheData).toString()
    )
    addCliche(c, r)
  }

   void createOrUpdateDailyTasksCliche(Sprint s) {

     if (s.state == Sprint.STATE_WAIT){
       return
     }
    //****************************************************
    // Total tasks by state
    //****************************************************
    int done = 0
    int inprogress = 0
    int wait = 0

    int recurrent = 0
    int urgent = 0
    int story = 0

    int remainingHours = 0
     s.tasks.each{ task ->

      def use = true
      if (task.parentStory && task.parentStory.parentSprint?.id != s.id){
        use = false
      }

      if (use){
          switch (task.state) {
          case Task.STATE_DONE:
            done++
            break
          case Task.STATE_BUSY:
            inprogress++
            break
          case Task.STATE_WAIT:
            wait++
            break
          default:
            break
        }
        switch (task.type) {
          case Task.TYPE_RECURRENT:
            recurrent++
            break
          case Task.TYPE_URGENT:
            urgent++
            break
          default:
            story++
            break
        }
        remainingHours += task.estimation?:0  
      }
    }

    int storiesDone = 0
    int storiesInProgress = 0
    s.stories.each{ storyd ->
       switch (storyd.state) {
          case Story.STATE_DONE:
            storiesDone++
            break
          case Story.STATE_INPROGRESS:
            storiesInProgress++
            break
       }
    }

    def clicheData = {
      cliche{
        //Total stories
        "${Cliche.TOTAL_STORIES}"(storiesDone+storiesInProgress)

        //Stories by state
        "${Cliche.STORIES_INPROGRESS}"(storiesInProgress)
        "${Cliche.STORIES_DONE}"(storiesDone)

        //Total tasks
        "${Cliche.TOTAL_TASKS}"(wait+inprogress+done)

        // Tasks by states
        "${Cliche.TASKS_WAIT}"(wait)
        "${Cliche.TASKS_INPROGRESS}"(inprogress)
        "${Cliche.TASKS_DONE}"(done)

        // Tasks by type
        "${Cliche.TASKS_SPRINT}"(recurrent+urgent)
        "${Cliche.TASKS_RECURRENT}"(recurrent)
        "${Cliche.TASKS_URGENT}"(urgent)
        "${Cliche.TASKS_STORY}"(story)

        //daily remainingHours
        "${Cliche.REMAINING_HOURS}"(remainingHours)

      }
    }
    StreamingMarkupBuilder xmlBuilder = new StreamingMarkupBuilder()

    def d = new Date()

    def lastCliche = null
    if (s.cliches?.size()){
      lastCliche = s.cliches.asList().last()  
    }

    if (lastCliche){
      def days = d - lastCliche.datePrise
      if (days < 1){
        lastCliche.data = xmlBuilder.bind(clicheData).toString()
        lastCliche.save()
        return
      }else{
        for(def i = 1;i < days;i++){
          Cliche c = new Cliche(type:Cliche.TYPE_DAILY,datePrise:lastCliche.datePrise + i,data:lastCliche.data)
          addCliche(c, s)
        }
      }
    }

    Cliche c = new Cliche(type:Cliche.TYPE_DAILY,datePrise:d,data:xmlBuilder.bind(clicheData).toString())
    addCliche(c, s)
   }

  @Transactional(readOnly = true)
   def unMarshallCliche(NodeChild cliche){
     def c  = new Cliche(
             type:cliche.type.text().toInteger(),
             datePrise:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(cliche.datePrise.text()),
             data:cliche.data.text()
     )
     
     return c
   }
}