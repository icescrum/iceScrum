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

import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.springframework.security.access.prepost.PreAuthorize
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat

import org.icescrum.core.support.ProgressSupport
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.services.SprintService
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumReleaseEvent
import org.icescrum.core.domain.User

/**
 *
 * La classe ReleaseService controle les operations concernant la Release
 * demandees par les pages web (release.jspx & releaseform.jspx) Elle joue le
 * role de "Facade" entre le ReleaseViewer et le ReleaseDao
 *
 */

class ReleaseService {
  final static long DAY = 1000 * 60 * 60 * 24

  static transactional = true

  def productService
  def productBacklogService
  def clicheService
  def springSecurityService
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()
  

  @PreAuthorize('productOwner(#product) or scrumMaster()')
  void saveRelease(Release release, Product product) {
    release.parentProduct = product

    // Check data integrity
    if (release.endDate == null) {
      throw new IllegalStateException('is.release.error.no.endDate')
    } else if (release.startDate.after(release.endDate)) {
      throw new IllegalStateException('is.release.error.startDate.before.endDate')
    } else if (release.startDate == null) {
      throw new IllegalStateException('is.release.error.no.startDate')
    } else if (release.startDate == release.endDate) {
      throw new IllegalStateException('is.release.error.startDate.equals.endDate')
    } else if (release.startDate.before(product.startDate)) {
      throw new IllegalStateException('is.release.error.startDate.before.productStartDate')
    } else {
      Release _r = productService.getLastRelease(product)
      if (_r != null && _r.endDate.after(release.startDate)) {
        throw new IllegalStateException('is.release.error.startDate.before.previous')
      }
    }
    release.state = Release.STATE_WAIT
    // If this is the first release of the product, it is automatically activated
    if (product.releases?.size() <= 0 || product.releases == null) {
      release.state = Release.STATE_INPROGRESS
    }
    release.orderNumber = (product.releases?.size() ?: 0) + 1

    if (!release.save())
      throw new RuntimeException()
    publishEvent(new IceScrumReleaseEvent(release,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
    product.addToReleases(release)
    product.endDate = release.endDate
  }

  @PreAuthorize('productOwner(#pb) or scrumMaster()')
  void updateRelease(Release _release, Product pb, Date startDate = null, Date endDate = null) {

    if (!startDate) {
      startDate = _release.startDate
    }

    if (!endDate) {
      endDate = _release.endDate
    }

    if (_release.state == Release.STATE_DONE)
      throw new IllegalStateException('is.release.error.state.done')

    // Check sprint date integrity
    if (startDate > endDate)
      throw new IllegalStateException('is.release.error.startDate.before.endDate')
    if (startDate == endDate)
      throw new IllegalStateException('is.release.error.startDate.equals.endDate')
    if (startDate.before(pb.startDate)) {
      throw new IllegalStateException('is.release.error.startDate.before.productStartDate')
    }
    int ind = pb.releases.asList().indexOf(_release)

    // Check that the start date is after the previous release end date
    if (ind > 0) {
      Release _previous = pb.releases.asList()[ind - 1]
      if (_previous.endDate.after(startDate)) {
        throw new IllegalStateException('is.release.error.startDate.before.previous')
      }
    }

    def sprintService = (SprintService) ApplicationHolder.application.mainContext.getBean('sprintService');

    if (_release.startDate != startDate && startDate >= _release.startDate) {
      if (!_release.sprints.isEmpty()) {
        def firstSprint = _release.sprints.asList().first()
        //we update the first sprint and next sprints in release if needed
        if (firstSprint.startDate < startDate && firstSprint.state >= Sprint.STATE_INPROGRESS){
          throw new IllegalStateException('is.release.error.endDate.before.inprogress.sprint')
        }
        if (firstSprint.startDate < startDate) {
          sprintService.updateSprint(firstSprint,startDate,(startDate + (firstSprint.endDate - firstSprint.startDate)))
        }
      }
    }

    // If there are sprints that are out of the bound of the release's dates
    // we reduce the time alocated to the sprints or delete them if there is not enough time.
    if (_release.endDate != endDate && endDate <= _release.endDate) {
      if (!_release.sprints.isEmpty()) {
        // Retrieve the sprints that are out of the bound of the dates interval
        def tooHighSprint = _release.sprints.findAll {it.startDate >= endDate}
        if (tooHighSprint) {
          // Those sprints are deleted and their stories return in the backlog
          for (Sprint s: tooHighSprint) {
            sprintService.deleteSprint(s)
          }
        }

        // Check for a sprint that can be reduced
        def sprintToReduce = _release.sprints.find {it.endDate > endDate}
        if (sprintToReduce && sprintToReduce.state < Sprint.STATE_INPROGRESS) {
          sprintToReduce.endDate = endDate
          sprintService.updateSprint(sprintToReduce,sprintToReduce.startDate,endDate)
        } else if(sprintToReduce && sprintToReduce.state >= Sprint.STATE_INPROGRESS){
          throw new IllegalStateException('is.release.error.endDate.before.inprogress.sprint')
        }
      }
    }

    // Check that the end date is before the next release start date
    if (ind < pb.releases.size() - 1) {
      Release _next = pb.releases.asList()[ind + 1]
      if (_next.startDate <= (endDate)) {
        if (!_release.save())
          throw new RuntimeException()
        _next.startDate = endDate + 1
        _next.endDate = _next.endDate + 1
        //We update all releases after
        this.updateRelease(_next, pb)
        if (!_next.sprints.isEmpty()) {
          def firstSprint = _next.sprints.asList().first()
          //we update the first sprint and next sprints in release if needed
          if (firstSprint.startDate < _next.startDate) {
            sprintService.updateSprint(firstSprint,_next.startDate,firstSprint.endDate)
          }
        }
        return
      }
    }

    _release.endDate = endDate
    _release.startDate = startDate
    if (!_release.save(flush:true))
      throw new RuntimeException()
    publishEvent(new IceScrumReleaseEvent(_release,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }

  void updateVision(Release release) {
    if (!release.save()) {
      throw new RuntimeException()
    }
    publishEvent(new IceScrumReleaseEvent(release,this.class,User.get(springSecurityService.principal?.id),IceScrumReleaseEvent.EVENT_UPDATED_VISION))
  }


  def nextSprintActivable(Release release) {

    if (release.state == Release.STATE_INPROGRESS) {
      def sp = release.sprints?.find {it.state == Sprint.STATE_INPROGRESS}
      if (sp)
        return null
      sp = release.sprints?.find {it.state == Sprint.STATE_WAIT}
      if (sp)
        return sp.orderNumber
      return null
    }

    def pb = release.parentProduct
    def currentRelease = pb.releases.find {it.state == Release.STATE_INPROGRESS}
    if (currentRelease) {
      if (currentRelease.sprints) {
        def sp = currentRelease.sprints.find {it.state == Sprint.STATE_INPROGRESS || it.state == Sprint.STATE_WAIT}
        if (sp)
          return null
        else if (release.orderNumber == currentRelease.orderNumber + 1)
          return 1
      } else {
        return null
      }
    }

    def lastRelClose = 0
    pb.releases.eachWithIndex { r, i ->
      if (r.state == Release.STATE_DONE)
        lastRelClose = i + 1
    }
    if (pb.releases.asList().indexOf(release) == lastRelClose) {
      return 1
    } else {
      return null
    }
  }

  @PreAuthorize('productOwner(#pb) or scrumMaster()')
  void activeRelease(Release _rel, Product pb) {
    def relActivated = false
    def lastRelClose = 0
    pb.releases.eachWithIndex { r, i ->
      if (r.state == Release.STATE_INPROGRESS)
        relActivated = true
      else if (r.state == Release.STATE_DONE)
        lastRelClose = r.orderNumber
    }
    if (relActivated)
      throw new IllegalStateException('is.release.error.already.active')
    if (_rel.state != Release.STATE_WAIT)
      throw new IllegalStateException('is.release.error.not.state.wait')
    if (_rel.orderNumber != lastRelClose + 1)
      throw new IllegalStateException('is.release.error.not.next')
    if (_rel.sprints.size() <= 0)
      throw new IllegalStateException('is.release.error.no.sprint')
    _rel.state = Release.STATE_INPROGRESS
    if(!_rel.save())
      throw new RuntimeException()
    publishEvent(new IceScrumReleaseEvent(_rel,this.class,User.get(springSecurityService.principal?.id),IceScrumReleaseEvent.EVENT_ACTIVATED))
  }

  @PreAuthorize('productOwner(#pb) or scrumMaster()')
  void closeRelease(Release _rel, Product pb) {
    if (_rel.sprints.size() == 0 || _rel.sprints.any { it.state != Sprint.STATE_DONE })
      throw new IllegalStateException('is.release.error.sprint.not.done')
    _rel.state = Release.STATE_DONE

    def velocity = _rel.sprints.sum { it.velocity }
    velocity = (velocity / _rel.sprints.size())
    _rel.releaseVelocity = velocity

    def lastDate = _rel.sprints.asList().last().endDate
    _rel.endDate = lastDate

    if (_rel.orderNumber == pb.releases.size()) {
      pb.endDate = lastDate
    }

    if (!_rel.save())
      throw new RuntimeException()
    publishEvent(new IceScrumReleaseEvent(_rel,this.class,User.get(springSecurityService.principal?.id),IceScrumReleaseEvent.EVENT_CLOSED))
  }

  @PreAuthorize('productOwner(#p) or scrumMaster()')
  void deleteRelease(Release re, Product p) {
    if (re.state == Release.STATE_INPROGRESS || re.state == Release.STATE_DONE)
      throw new IllegalStateException("is.release.error.not.deleted")

    def nextReleases = p.releases.findAll { it.orderNumber > re.orderNumber }

    productBacklogService.dissociatedAllStories(re.sprints)
    p.removeFromReleases(re)

    publishEvent(new IceScrumReleaseEvent(re,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))

    nextReleases.each {
      productBacklogService.dissociatedAllStories(it.sprints)
      p.removeFromReleases(it)
      publishEvent(new IceScrumReleaseEvent(it,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
    }
    p.endDate = p.releases?.min {it.orderNumber}?.endDate ?: null
  }


  def releaseBurndownValues(Release release) {
    def values = []
    Cliche.findAllByParentTimeBoxAndType(release, Cliche.TYPE_ACTIVATION,[sort:"datePrise", order:"asc"])?.each { it ->
      def xmlRoot = new XmlSlurper().parseText(it.data)
      if (xmlRoot) {
        values << [
                label: xmlRoot."${Cliche.SPRINT_ID}".toString(),
                userstories: xmlRoot."${Cliche.FUNCTIONAL_STORY_PRODUCT_REMAINING_POINTS}".toInteger(),
                technicalstories: xmlRoot."${Cliche.TECHNICAL_STORY_PRODUCT_REMAINING_POINTS}".toInteger(),
                defectstories: xmlRoot."${Cliche.DEFECT_STORY_PRODUCT_REMAINING_POINTS}".toInteger()
        ]
      }
    }
    return values
  }

  @Transactional(readOnly = true)
  def unMarshallRelease(NodeChild release, Product p = null, ProgressSupport progress){
    try {
      def r = new Release(
              state:release.state.text().toInteger(),
              releaseVelocity:(release.releaseVelocity.text().isNumber())?release.releaseVelocity.text().toDouble():0,
              name:release.name.text(),
              startDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(release.startDate.text()),
              endDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(release.endDate.text()),
              orderNumber:release.orderNumber.text().toInteger(),
              description:release.description.text(),
              vision:release.vision.text(),
              goal:release.goal?.text()?:'',
      )

      release.cliches.cliche.each{
          def c = clicheService.unMarshallCliche(it)
          r.addToCliches(c)
      }

      if (p){
         def sprintService = (SprintService) ApplicationHolder.application.mainContext.getBean('sprintService');
          release.sprints.sprint.eachWithIndex{ it, index ->
              def s = sprintService.unMarshallSprint(it,p)
              r.addToSprints(s)
              progress?.updateProgress((release.sprints.sprint.size() * (index+1) / 100).toInteger(),g.message(code:'is.parse', args:[g.message(code:'is.sprint')]))
          }
          p.addToReleases(r)
      }
      return r  
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      progress?.progressError(g.message(code:'is.parse.error', args:[g.message(code:'is.sprint')]))
      throw new RuntimeException(e)
    }
  }
}