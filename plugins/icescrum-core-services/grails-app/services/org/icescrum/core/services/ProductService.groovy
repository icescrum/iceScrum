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

import grails.plugin.springcache.key.CacheKeyBuilder
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.icescrum.core.domain.preferences.ProductPreferences
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.access.annotation.Secured
import org.springframework.security.access.prepost.PostFilter
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.transaction.annotation.Transactional

import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.support.XMLConverterSupport
import org.icescrum.core.domain.Story
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumProductEvent

/**
 * ProductService is a transactional class, that manage operations about
 * ProducBacklog, requested by web pages (Product.jspx & Productform.jspx)
 */
class ProductService {

  def springcacheService
  def springSecurityService
  def securityService

  def teamService
  def actorService
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()

  static transactional = true


  @PostFilter("stakeHolder(filterObject) or inProduct(filterObject)")
  List getProductList(params) {
      return Product.list(params ?: [cache: true])
  }

  @PostFilter("stakeHolder(filterObject) or inProduct(filterObject)")
  List getByTermProductList(term,params) {
      return Product.findAllByNameIlike('%'+term+'%',params)
  }

  @PostFilter("inProduct(filterObject) and !hasRole('ROLE_ADMIN')")
  List getByMemberProductList() {
      return Product.list(cache: true)
  }

  void saveProduct(Product _product, User u) {
    if (!_product.endDate == null)
      throw new IllegalStateException("is.product.error.no.endDate")
    if (_product.startDate > _product.endDate)
      throw new IllegalStateException('is.product.error.startDate')
    if (_product.startDate == _product.endDate)
      throw new IllegalStateException('is.product.error.duration')
    if (!_product.planningPokerGameType in [0, 1])
      throw new IllegalStateException("is.product.error.no.estimationSuite")

    _product.orderNumber = (Product.count() ?: 0) + 1

    if (!_product.save())
      throw new RuntimeException()
    securityService.secureDomain(_product)
    securityService.createProductOwnerPermissions(u, _product)
    publishEvent(new IceScrumProductEvent(_product,this.class,u,IceScrumEvent.EVENT_CREATED))
  }

  void saveImportedProduct(Product _product, String name) {
    if (!_product.endDate == null)
      throw new IllegalStateException("is.product.error.no.endDate")
    if (_product.startDate > _product.endDate)
      throw new IllegalStateException('is.product.error.startDate')
    if (_product.startDate == _product.endDate)
      throw new IllegalStateException('is.product.error.duration')
    if (!_product.planningPokerGameType in [0, 1])
      throw new IllegalStateException("is.product.error.no.estimationSuite")
    _product.orderNumber = (Product.count() ?: 0) + 1

    if (_product.erasableByUser && _product.name == name) {
      def p = Product.findByName(_product.name)
      securityService.unsecureDomain(p)
      p.delete(flush: true)
    }

    try {
      _product.teams.each { t ->
        if (t.id == null)
          teamService.saveImportedTeam(t)
      }

      def productOwners = _product.productOwners

      productOwners?.each {
        if (it.id == null)
          it.save()
      }

      if (!_product.save()) {
        throw new RuntimeException()
      }
      securityService.secureDomain(_product)

      if (productOwners){
        productOwners?.eachWithIndex{it,index ->
           securityService.createProductOwnerPermissions(it, _product)
        }
        securityService.changeOwner(productOwners.first(),_product)
      }else{
        def u = User.get(springSecurityService.principal.id)
        securityService.createProductOwnerPermissions(u, _product)
        securityService.changeOwner(u,_product)
      }
      publishEvent(new IceScrumProductEvent(_product,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
    } catch (Exception e) {
      throw new RuntimeException(e)
    }
  }

  void addTeamsToProduct(Product _product, teamIds) {
    if (!_product)
      throw new IllegalStateException('Product must not be null')

    if (!teamIds)
      throw new IllegalStateException('Product must have at least one team')


    log.debug teamIds
    for (team in Team.getAll(teamIds*.toLong())) {
      if (team)
        _product.addToTeams(team)
        publishEvent(new IceScrumProductEvent(_product,team,this.class,User.get(springSecurityService.principal?.id),IceScrumProductEvent.EVENT_TEAM_ADDED))
    }

    if (!_product.save())
      throw new IllegalStateException('Product not saved')

    springcacheService.flush(SecurityService.CACHE_OPENPRODUCTTEAM)
    springcacheService.flush(SecurityService.CACHE_PRODUCTTEAM)

  }


  void updateProduct(Product _product) {
    if (!_product.name?.trim()) {
      throw new IllegalStateException("is.product.error.no.name")
    }
    if (!_product.planningPokerGameType in [0, 1]) {
      throw new IllegalStateException("is.product.error.no.estimationSuite")
    }
    if (!_product.save(flush:true)) {
      throw new RuntimeException()
    }
    removeInCache(SecurityService.CACHE_STAKEHOLDER, _product.id)
    publishEvent(new IceScrumProductEvent(_product,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }


  Release getLastRelease(Product p) {
    return p.releases?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
  }

  @PreAuthorize("stakeHolder(#productId) or inProduct(#productId)")
  Product openProduct(Long productId) {
    Product.get(productId)
  }


  def cumulativeFlowValues(Product product) {
    def values = []
    product.releases?.sort{a,b -> a.orderNumber <=> b.orderNumber}?.each {
      Cliche.findAllByParentTimeBoxAndType(it, Cliche.TYPE_ACTIVATION,[sort:"datePrise", order:"asc"])?.each { cliche ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          values << [
                  suggested: xmlRoot."${Cliche.SUGGESTED_STORIES}".toInteger(),
                  accepted: xmlRoot."${Cliche.ACCEPTED_STORIES}".toInteger(),
                  estimated: xmlRoot."${Cliche.ESTIMATED_STORIES}".toInteger(),
                  planned: xmlRoot."${Cliche.PLANNED_STORIES}".toInteger(),
                  inprogress: xmlRoot."${Cliche.INPROGRESS_STORIES}".toInteger(),
                  done: xmlRoot."${Cliche.FINISHED_STORIES}".toInteger(),
                  label: xmlRoot."${Cliche.SPRINT_ID}".toString()
          ]
        }
      }
    }
    return values
  }

  def productBurnupValues(Product product) {
    def values = []
    product.releases?.sort{a,b -> a.orderNumber <=> b.orderNumber}?.each {
      Cliche.findAllByParentTimeBoxAndType(it, Cliche.TYPE_ACTIVATION,[sort:"datePrise", order:"asc"])?.each { cliche ->

        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {

          def a = xmlRoot."${Cliche.PRODUCT_BACKLOG_POINTS}".toInteger()
          def b = xmlRoot."${Cliche.PRODUCT_REMAINING_POINTS}".toInteger()
          def c = a - b

          values << [
                  all: xmlRoot."${Cliche.PRODUCT_BACKLOG_POINTS}".toInteger(),
                  done: c,
                  label: xmlRoot."${Cliche.SPRINT_ID}".toString()
          ]
        }
      }
    }
    return values
  }

  def productBurndownValues(Product product) {
    def values = []
    product.releases?.sort{a,b -> a.orderNumber <=> b.orderNumber}?.each {
      Cliche.findAllByParentTimeBoxAndType(it, Cliche.TYPE_ACTIVATION,[sort:"datePrise", order:"asc"])?.each { cliche ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          values << [
                  label: xmlRoot."${Cliche.SPRINT_ID}".toString(),
                  userstories: xmlRoot."${Cliche.FUNCTIONAL_STORY_PRODUCT_REMAINING_POINTS}".toInteger(),
                  technicalstories: xmlRoot."${Cliche.TECHNICAL_STORY_PRODUCT_REMAINING_POINTS}".toInteger(),
                  defectstories: xmlRoot."${Cliche.DEFECT_STORY_PRODUCT_REMAINING_POINTS}".toInteger()
          ]
        }
      }
    }
    return values
  }

  def productVelocityValues(Product product) {
    def values = []
    product.releases?.sort{a,b -> a.orderNumber <=> b.orderNumber}?.each {
      Cliche.findAllByParentTimeBoxAndType(it, Cliche.TYPE_CLOSE,[sort:"datePrise", order:"asc"])?.each { cliche ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          values << [
                  userstories: xmlRoot."${Cliche.FUNCTIONAL_STORY_VELOCITY}".toInteger(),
                  defectstories: xmlRoot."${Cliche.DEFECT_STORY_VELOCITY}".toInteger(),
                  technicalstories: xmlRoot."${Cliche.TECHNICAL_STORY_VELOCITY}".toInteger(),
                  label: xmlRoot."${Cliche.SPRINT_ID}".toString()
          ]
        }
      }
    }
    return values
  }

  def productVelocityCapacityValues(Product product) {
    def values = []
    def capacity = 0, label = ""
    product.releases?.sort{a,b -> a.orderNumber <=> b.orderNumber}?.each {
      Cliche.findAllByParentTimeBox(it,[sort:"datePrise", order:"asc"])?.each { cliche ->
        def xmlRoot = new XmlSlurper().parseText(cliche.data)
        if (xmlRoot) {
          if (cliche.type == Cliche.TYPE_ACTIVATION) {
            capacity = xmlRoot."${Cliche.SPRINT_CAPACITY}".toInteger()
            label = xmlRoot."${Cliche.SPRINT_ID}".toString()
          }
          if (cliche.type == Cliche.TYPE_CLOSE) {
            values << [
                    capacity: capacity,
                    velocity: xmlRoot."${Cliche.SPRINT_VELOCITY}".toInteger(),
                    label: label
            ]

          }
        }
      }
    }
    return values
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void beProductOwner(Product p) {
    if (p.preferences.lockPo)
      throw new AccessDeniedException('')

    def u = User.get(springSecurityService.principal.id)
    securityService.createProductOwnerPermissions u, p
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void dontBeProductOwner(Product p) {
    if (p.preferences.lockPo)
      throw new AccessDeniedException('')

    def u = User.get(springSecurityService.principal.id)
    securityService.deleteProductOwnerPermissions u, p
  }

  private removeInCache(String cacheName, _key) {
    def cache = springcacheService.getOrCreateCache(cacheName)
    def key = new CacheKeyBuilder().append(_key).toCacheKey()
    cache.remove(key)
  }

  @Transactional(readOnly = true)
  Product unMarshallProduct(NodeChild product, ProgressSupport progress = null) {
    try {
      def p = new Product(
              name: product.name.text(),
              pkey: product.pkey.text(),
              description: product.description.text(),
              startDate: new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(product.startDate.text()),
              endDate: new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(product.endDate.text())
      )
      p.preferences = new ProductPreferences(
              hidden: product.preferences.hidden.text().toBoolean(),
              assignOnBeginTask: product.preferences.assignOnBeginTask.text().toBoolean(),
              assignOnCreateTask: product.preferences.assignOnCreateTask.text().toBoolean(),
              lockPo: product.preferences.lockPo.text().toBoolean(),
              autoCreateTaskOnEmptyStory: product.preferences.autoCreateTaskOnEmptyStory.text().toBoolean(),
              autoDoneStory: product.preferences.autoDoneStory.text().toBoolean(),
              newTeams: product.preferences.newTeams.text().toBoolean(),
              url: product.preferences.url?.text() ?: null,
              noEstimation: product.preferences.noEstimation.text().toBoolean(),
              limitUrgentTasks: product.preferences.limitUrgentTasks.text().toInteger(),
              estimatedSprintsDuration: product.preferences.estimatedSprintsDuration.text().toInteger(),
              displayUrgentTasks: product.preferences.displayUrgentTasks.text().toBoolean(),
              displayRecurrentTasks: product.preferences.displayRecurrentTasks.text().toBoolean(),
              hideWeekend: product.preferences.hideWeekend.text()?.toBoolean()?:false,
              releasePlanningHour:product.preferences.releasePlanningHour.text()?:"9:00",
              sprintPlanningHour:product.preferences.sprintPlanningHour.text()?:"9:00",
              dailyMeetingHour:product.preferences.dailyMeetingHour.text()?:"11:00",
              sprintReviewHour:product.preferences.sprintReviewHour.text()?:"14:00",
              sprintRetrospectiveHour:product.preferences.sprintRetrospectiveHour.text()?:"16:00"
      )

      Product pExist = (Product) Product.findByPkey(p.pkey)
      if (pExist && securityService.productOwner(pExist,springSecurityService.authentication)) {
        p.erasableByUser = true
      }

      product.teams.team.eachWithIndex { it, index ->
        def t = teamService.unMarshallTeam(it, p, progress)
        p.addToTeams(t)
        progress?.updateProgress((product.teams.team.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.team')]))
      }

      def productOwnersList = []
      product.productOwners.user.eachWithIndex {productOwner, index ->
        User u = (User) p?.getAllUsers()?.find {it.idFromImport == productOwner.@id.text().toInteger()} ?: null
        if (!u) {
          u = User.findByUsernameAndEmail(productOwner.username.text(), productOwner.email.text())
          if (!u) {
            def userService = (UserService) ApplicationHolder.application.mainContext.getBean('userService');
            u = userService.unMarshallUser(productOwner)
          }
        }
        productOwnersList << u
      }
      p.productOwners = productOwnersList

      def featureService = (FeatureService) ApplicationHolder.application.mainContext.getBean('featureService');
      product.features.feature.eachWithIndex { it, index ->
        def f = featureService.unMarshallFeature(it)
        p.addToFeatures(f)
        progress?.updateProgress((product.features.feature.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.feature')]))
      }

      product.actors.actor.eachWithIndex { it, index ->
        def a = actorService.unMarshallActor(it)
        p.addToActors(a)
        progress?.updateProgress((product.actors.actor.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.actor')]))
      }

      def productBacklogService = (ProductBacklogService) ApplicationHolder.application.mainContext.getBean('productBacklogService');
      product.stories.story.eachWithIndex { it, index ->
        productBacklogService.unMarshallProductBacklog(it, p)
        progress?.updateProgress((product.stories.story.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.story')]))
      }

      def stories = p.stories.findAll{it.state == Story.STATE_ACCEPTED || it.state == Story.STATE_ESTIMATED}.sort({ a, b -> a.rank <=> b.rank } as Comparator)
      stories.eachWithIndex {it,index ->
        it.rank = index + 1
      }

      def releaseService = (ReleaseService) ApplicationHolder.application.mainContext.getBean('releaseService');
      product.releases.release.eachWithIndex { it, index ->
        releaseService.unMarshallRelease(it, p, progress)
        progress?.updateProgress((product.releases.release.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.release')]))
      }

      return p
    } catch (Exception e) {
      if (log.debugEnabled) e.printStackTrace()
      progress?.progressError(g.message(code: 'is.parse.error', args: [g.message(code: 'is.product')]))
      throw new RuntimeException(e)
    }
  }

  @Transactional(readOnly = true)
  def parseXML(File x,ProgressSupport progress = null) {
    def prod = new XmlSlurper().parse(x)

    progress?.updateProgress(0, g.message(code: 'is.parse', args: [g.message(code: 'is.product')]))

    XMLConverterSupport converter = new XMLConverterSupport(prod)
    if (converter.needConversion){
      prod = converter.convert()
    }

    progress?.updateProgress(5, g.message(code: 'is.parse', args: [g.message(code: 'is.product')]))
    def Product p
    try {
      p = this.unMarshallProduct(prod, progress)
    } catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      progress?.progressError(g.message(code: 'is.parse.error', args: [g.message(code: 'is.product')]))
      return
    }
    progress.completeProgress(g.message(code: 'is.validate.complete'))
    return p
  }

  @Transactional(readOnly = true)
  def validateProduct(Product p, ProgressSupport progress = null) {
    try {
      Product.withNewSession {
        p.teams.eachWithIndex { team, index ->
          team.validate()
          progress?.updateProgress((p.teams.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.validate', args: [g.message(code: 'is.team')]))
          team.members.eachWithIndex { member, index2 ->
            member.validate()
            progress?.updateProgress((team.members.size() * (index2 + 1) / 100).toInteger(), g.message(code: 'is.validate', args: [g.message(code: 'is.user')]))
          }
        }
        p.validate()
        progress?.updateProgress(100, g.message(code: 'is.validate', args: [g.message(code: 'is.product')]))
      }
    } catch (Exception e) {
      if (log.debugEnabled) e.printStackTrace()
      progress?.progressError(g.message(code: 'is.validate.error', args: [g.message(code: 'is.product')]))
    }
  }

  def deleteProduct(Product p) {
    p.delete(flush:true)
    securityService.unsecureDomain p
    publishEvent(new IceScrumProductEvent(p,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
  }
}