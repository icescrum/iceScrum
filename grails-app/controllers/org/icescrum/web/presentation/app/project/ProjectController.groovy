/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugin.fluxiable.Activity
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.preferences.ProductPreferences
import org.icescrum.core.domain.preferences.TeamPreferences
import org.icescrum.core.support.ProgressSupport
import org.icescrum.web.support.MenuBarSupport
import org.springframework.security.access.AccessDeniedException
import org.icescrum.core.domain.*
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import grails.plugin.springcache.annotations.Cacheable


@Secured('stakeHolder() or inProduct()')
class ProjectController {

  static ui = true

  static final id = 'project'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.project', id, true, 1)
  static window = [title: 'is.ui.project', help: 'is.ui.project.help', toolbar: true, init: 'dashboard']

  def productService
  def sprintService
  def teamService
  def releaseService
  def springSecurityService
  def featureService
  def securityService

  def index = {
    chain(controller: 'scrumOS', action: 'index', params: params)
  }

  static ReleaseStateBundle = [
          (Release.STATE_WAIT):'is.release.state.wait',
          (Release.STATE_INPROGRESS):'is.release.state.inprogress',
          (Release.STATE_DONE):'is.release.state.done'
  ]

  //@Cacheable('activitiesFeed')
  def feed = {
    def currentProduct = Product.get(params.product)

    def activities = Story.recentActivity(currentProduct)
    activities.addAll(Product.recentActivity(currentProduct))
    activities = activities.sort {a, b -> b.dateCreated <=> a.dateCreated}

    render(feedType: "rss", feedVersion: "2.0") {  node ->
      node.title = "$currentProduct.name ${message(code: 'is.ui.project.activity.title')}"
      node.link = "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [product: currentProduct.pkey])}"
      node.description = "${currentProduct.description ?: ''}"
      activities.each() { a ->
        entry("${a.poster.firstName} ${a.poster.lastName} ${message(code: "is.fluxiable.${a.code}")} ${message(code: "is.story")} ${a.cachedLabel.encodeAsHTML()}") {e ->
          if (a.code != Activity.CODE_DELETE)
            e.link = "${is.createScrumLink(absolute: true, controller: 'backlogElement', id: a.cachedId)}"
          else
            e.link = "${is.createScrumLink(absolute: true, controller: 'project')}"
          e.publishedDate = a.dateCreated
        }
      }
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def edit = {
    def currentProduct = Product.get(params.product)
    render(template: "dialogs/edit", model: [id: id, product: currentProduct])
  }

  @Secured('productOwner() or scrumMaster()')
  def editPractices ={
    def currentProduct = Product.get(params.product)
    def estimationSuitSelect = [(PlanningPokerGame.FIBO_SUITE): message(code: "is.estimationSuite.fibonacci"), (PlanningPokerGame.INTEGER_SUITE): message(code: "is.estimationSuite.integer")]
    def privateOption = !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable)
    if(SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
      privateOption = false
    }
    render(template: "dialogs/editPractices", model: [id: id, product: currentProduct, estimationSuitSelect: estimationSuitSelect, privateOption:privateOption])

  }

  @Secured('productOwner() or scrumMaster()')
  def update = {

    def msg
    def currentProduct = Product.get(params.long('productd.id'))
    if (params.long('productd.version') != currentProduct.version) {
      msg = message(code: 'is.stale.object', args: [message(code: 'is.product')])
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def reloadSprintBacklog = false
    def reloadProductBacklog = false

    if (params.productd.preferences){
      if (currentProduct.preferences.displayUrgentTasks != params.productd.preferences.displayUrgentTasks || currentProduct.preferences.displayRecurrentTasks != params.productd.preferences?.displayRecurrentTasks) {
        reloadSprintBacklog = true
      }

      if (currentProduct.planningPokerGameType != params.productd.planningPokerGameType){
        reloadProductBacklog = true
      }
    }

    //Oui pas une faute de frappe c'est bien productd pour pas confondra avec params.product ..... notre id de product
    currentProduct.properties = params.productd
    if(params.productd.preferences?.hidden && !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
      currentProduct.preferences.hidden = true
    }

    try {
      productService.updateProduct(currentProduct)
    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: message(code: ise.getMessage()))
      return
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: currentProduct)]] as JSON)
      return
    }
    render(status: 200, contentType: 'application/json', text: [name: currentProduct.name, notice: message(code: 'is.product.updated')] as JSON)
    pushOthers "${params.product}-product"
    if (reloadSprintBacklog)
      push "${params.product}-sprintBacklog"
    if (reloadProductBacklog)
      push "${params.product}-productBacklog"
  }

  @Secured('isAuthenticated()')
  def openWizard = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    def product = new Product()
    def countPlusUn = Product.count() + 1
    product.name = "${message(code: "is.product.template.name")} ${countPlusUn}"
    product.pkey = "PROJ${countPlusUn}"
    product.startDate = new Date()
    product.endDate = new Date() + 90
    product.preferences = new ProductPreferences()
    def estimationSuitSelect = [(PlanningPokerGame.FIBO_SUITE): message(code: "is.estimationSuite.fibonacci"), (PlanningPokerGame.INTEGER_SUITE): message(code: "is.estimationSuite.integer")]

    def privateOption = !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable)
    if(SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
      privateOption = false
    }

    render(template: "dialogs/wizard", model: [id: id, product: product, estimationSuitSelect: estimationSuitSelect,privateOption:privateOption])
  }

  @Secured('isAuthenticated()')
  def save = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    if (!params.product) return
    def product = new Product()
    product.preferences = new ProductPreferences()
    params.product.startDate = new Date().parse(message(code:'is.date.format.short'), params.product.startDate)
    params.product.endDate = new Date().parse(message(code:'is.date.format.short'), params.product.endDate)
    params.firstSprint = new Date().parse(message(code:'is.date.format.short'), params.firstSprint)

    product.properties = params.product

    if(params.product.preferences.hidden && !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
      currentProduct.preferences.hidden = true
    }

    if (params.firstSprint.after(product.endDate)) {
      def msg = message(code: 'is.product.error.firstSprint')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    if (params.firstSprint.after(product.endDate) || params.firstSprint == product.endDate) {
      def msg = message(code: 'is.product.error.firstSprint')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def team
    Product.withTransaction { status ->
      try {
        if (params.int('team.newTeam') == 1) {
          team = new Team()
          team.preferences = new TeamPreferences()
          team.properties = params.team
          teamService.saveTeam team, params.userid, springSecurityService.principal?.id
        }

        productService.saveProduct(product, User.get(springSecurityService.principal.id))

        if (params.int('team.newTeam') == 1)
          productService.addTeamsToProduct product, [team.id]
        else {
          productService.addTeamsToProduct(product, params.teamid in String ? [params.teamid] : params.teamid)
        }

        def release = new Release(name: "R1",
                startDate: product.startDate,
                endDate: product.endDate)
        releaseService.saveRelease(release, product)
        sprintService.generateSprints(release, params.firstSprint)
        flash.message = "is.product.saved.redirect"
        render(text: jq.jquery(null, "document.location='${createLink(controller: 'scrumOS', params: [product: product.pkey])}#project';"))
      } catch (IllegalStateException ise) {
        render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        status.setRollbackOnly()
        return
      } catch (RuntimeException re) {
        status.setRollbackOnly()
        re.printStackTrace()
        render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: product) + renderErrors(bean: team)]] as JSON)
        return
      }
    }
  }

  def projectDetails = {
    if (!params.currentProduct) {
      params.currentProduct = Product.get(params.product)
    }
    render(template: "dialogs/details", model: [id: id, currentProduct: params.currentProduct])
  }

  def dashboard = {
    def currentProduct = Product.get(params.product)
    def sprint = Sprint.findCurrentOrLastSprint(currentProduct.id).list()[0]
    def release = Release.findCurrentOrNextRelease(currentProduct.id).list()[0]
    def activities = Story.recentActivity(currentProduct)
    activities.addAll(Product.recentActivity(currentProduct))
    activities = activities.sort {a, b -> b.dateCreated <=> a.dateCreated}
    render template: 'window/dashboard',
            model: [product: currentProduct,
                    activities: activities,
                    sprint: sprint,
                    release:release,
                    lang:RCU.getLocale(request).toString().substring(0,2),
                    id:id
            ]
  }

  def productCumulativeFlowChart = {
    def currentProduct = Product.get(params.product)
    def values = productService.cumulativeFlowValues(currentProduct)
    if (values.size() > 0) {
      render(template: 'charts/productCumulativeFlowChart', model: [
              id: id,
              withButtonBar:(params.withButtonBar != null)?params.withButtonBar:true,
              suggested: values.suggested as JSON,
              accepted: values.accepted as JSON,
              estimated: values.estimated as JSON,
              planned: values.planned as JSON,
              inprogress: values.inprogress as JSON,
              done: values.done as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def productVelocityCapacityChart = {
    def currentProduct = Product.get(params.product)
    def values = productService.productVelocityCapacityValues(currentProduct)
    if (values.size() > 0) {
      render(template: 'charts/productVelocityCapacityChart', model: [
              id: id,
              withButtonBar:(params.withButtonBar != null)?params.withButtonBar:true,
              capacity: values.capacity as JSON,
              velocity: values.velocity as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def productBurnupChart = {
    def currentProduct = Product.get(params.product)
    def values = productService.productBurnupValues(currentProduct)
    if (values.size() > 0) {
      render(template: 'charts/productBurnupChart', model: [
              id: id,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              all: values.all as JSON,
              done: values.done as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def productBurndownChart = {
    def currentProduct = Product.get(params.product)
    def values = productService.productBurndownValues(currentProduct)
    if (values.size() > 0) {
      render(template: 'charts/productBurndownChart', model: [
              id: id,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              userstories: values.userstories as JSON,
              technicalstories: values.technicalstories as JSON,
              defectstories: values.defectstories as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def productVelocityChart = {
    def currentProduct = Product.get(params.product)
    def values = productService.productVelocityValues(currentProduct)
    if (values.size() > 0) {
      render(template: 'charts/productVelocityChart', model: [
              id: id,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              userstories: values.userstories as JSON,
              technicalstories: values.technicalstories as JSON,
              defectstories: values.defectstories as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def productParkingLotChart = {
    def currentProduct = Product.get(params.product)
    def values = featureService.productParkingLotValues(currentProduct)
    def indexF = 1
    def valueToDisplay = []
    values.value?.each {
      def value = []
      value << it.toString()
      value << indexF
      valueToDisplay << value
      indexF++
    }
    if (valueToDisplay.size() > 0)
      render(template: '../feature/charts/productParkinglot', model: [
                id: id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                values: valueToDisplay as JSON,
                featuresNames: values.label as JSON])
    else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def exportProject = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    if (params.status) {
      render(status: 200, contentType: 'application/json', text: session.progress as JSON)
    } else if (params.get) {
      def product = Product.get(params.product)
      try {
        session.progress = new ProgressSupport()
        session.progress.updateProgress(0, message(code: 'is.export.start'))
        response.setHeader "Content-disposition", "attachment; filename=${product.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}.xml"
        render(contentType: 'text/xml', template: '/export/xml/product', model: [object: product, deep: true, root: true])
        session.progress?.completeProgress(message(code: 'is.export.complete'))
      } catch (Exception e) {
        e.printStackTrace()
        session.progress.progressError(message(code: 'is.export.error'))
      }
    } else {
      render(template: 'dialogs/export', model: [id: id])
    }
  }

  @Secured('isAuthenticated()')
  def importProject = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    def user = User.load(springSecurityService.principal.id)
    if (params.cancel) {
      session.tmpP = null
      session.progress = null
      render(status: 200)
      return
    }
    else if (params.file) {
      def uploadedProject = null
      params.file.split(':')?.with {
        if (session.uploadedFiles[it[0]])
          uploadedProject = new File(session.uploadedFiles[it[0]])
      }
      if (uploadedProject) {
        session.progress = new ProgressSupport()
        session.tmpP = productService.parseXML(uploadedProject, session.progress)
      }
    }
    else if (params.status) {
      if (session.progress)
        render(status: 200, contentType: 'application/json', text: session.progress as JSON)
      else
        render(status: 200)
      return
    }
    else {
      session.progress = null
    }

    if (session.tmpP) {
      def unValidableErrors = this.validateImport()
      if (unValidableErrors) {
        session.tmpP = null
        session.progress = null
        render(status: 400, contentType: 'application/json', text: [notice: [text: unValidableErrors, type: 'error']] as JSON)
        return

      } else {
        def importMustChangeValues = session.tmpP.hasErrors() ?: (true in session.tmpP.teams*.hasErrors()) ?: (true in session.tmpP.getAllUsers()*.hasErrors())
        render(template: 'dialogs/import', model: [
                id: id,
                user: user,
                product: session.tmpP,
                importMustChangeValues: importMustChangeValues,
                teamsErrors: session.tmpP.teams.findAll {it.hasErrors()},
                usersErrors: session.tmpP.getAllUsers().findAll {it.hasErrors()}
        ])
      }
    } else {
      render(template: 'dialogs/import', model: [id: id, user: user])
    }
  }

  @Secured('isAuthenticated()')
  def saveImport = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    if (!session.tmpP) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.import.error.no.backup']] as JSON)
      return
    }

    if (params.team?.name) {
      session.tmpP.teams.each {
        if (params.team.name."${it.idFromImport}") {
          it.name = params.team.name."${it.idFromImport}"
        }
      }
    }

    if (params.user?.username) {
      session.tmpP.teams.each {
        it.members.each {it2 ->
          if (params.user.username."${it2.idFromImport}") {
            it2.username = params.user.username."${it2.idFromImport}"
          }
        }
        it.scrumMasters.each {it2 ->
          if (params.user.username."${it2.idFromImport}") {
            it2.username = params.user.username."${it2.idFromImport}"
          }
        }
      }
    }

    if (params.productOwner?.username) {
      session.tmpP.productOwners.each {
        if (params.productOwner.username."${it.idFromImport}") {
          it.username = params.productOwner.username."${it.idFromImport}"
        }
      }
    }

    def erasableByUser = false
    if (params.productd?.int('erasableByUser')) {
      erasableByUser = params.productd?.int('erasableByUser') ? true : false
    }
    session.tmpP.erasableByUser = erasableByUser
    if (!erasableByUser && params.productd?.pkey != null && params.productd?.name != null) {
      session.tmpP.pkey = params.productd.pkey
      session.tmpP.name = params.productd.name
    }
    def errors = this.validateImport(true, erasableByUser)
    if (errors) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: errors]] as JSON)
      return
    }

    Product.withTransaction { status ->
      try {
        productService.saveImportedProduct(session.tmpP, params.productd?.name)
      } catch (IllegalStateException ise) {
        status.setRollbackOnly()
        render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        return
      }
      catch (RuntimeException e) {
        status.setRollbackOnly()
        e.printStackTrace()
        render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.import.error')]] as JSON)
        return
      }
      def link = g.createLink(action: 'index', controller: 'scrumOS', params: [product: session.tmpP.pkey])
      render(text: jq.jquery(null, "\$('#dialog').dialog('close');" + is.notice(text: message(code: "is.dialog.importProject.success"), after_close: "function(){document.location='${link}#project';}", delay: '500')))
      session.tmpP = null
    }
  }

  private def validateImport(def full = false, def erasableByUser = false) {

    def p = session.tmpP
    productService.validateProduct(p, session.progress)
    def beansErrors = null

      if (p.hasErrors()) {
      if (full && !erasableByUser) {
        beansErrors = renderErrors(bean: p)
        log.info("Product validation error (${p.name}): " + p.errors)
      }

      def pass = true
      p.errors.each {
        if (it.getFieldError().getField() != 'name' && it.getFieldError().getField() != 'pkey') {
          pass = false

        }
      }

      if (!pass) {
        beansErrors = renderErrors(bean: session.tmpP)
      } else if (p.errors) {
        log.info("Product validation with warning (${p.name}): " + p.errors)
      } else {
        log.info("Product validation (full=false) passed (${p.name})")
      }
    } else {
      log.info("Product validation passed (${p.name})")
    }

    p.getAllUsers().each {
      if (it.hasErrors()) {
        if (full) {
          beansErrors = (beansErrors ?: '') + renderErrors(bean: it)
          log.info("User validation error (${it.username}): " + it.errors)
        }
        else if (it.errors.getErrorCount() >= 1 && (it.errors.getFieldError().getField() != 'username' || it.username == '')) {
          beansErrors = (beansErrors ?: '') + renderErrors(bean: it)
          log.info("User validation passed with warning (${it.username}): " + it.errors)
        } else {
          log.info("User validation (full=false) passed (${it.username})")
        }
      } else {
        log.info("User validation passed (${it.username})")
      }
    }

    p.teams.each {
      if (it.hasErrors()) {
        if (full) {
          beansErrors = (beansErrors ?: '') + renderErrors(bean: it)
          log.info("Team validation error (${it.name}): " + it.errors)
        }
        else if (it.errors.getErrorCount() >= 1 && (it.errors.getFieldError().getField() != 'name' || it.name == '')) {
          beansErrors = (beansErrors ?: '') + renderErrors(bean: it)
          log.info("Team validation passed with warning (${it.name}): " + it.errors)
        }
        else {
          log.info("Team validation (full=false) passed (${it.name})")
        }
      } else {
        log.info("Team validation passed (${it.name})")
      }
    }
    return beansErrors
  }

  /**
   * Export the project elements in multiple format (PDF, DOCX, RTF, ODT)
   */
  def print = {
    def currentProduct = Product.get(params.product)
    def values
    def chart = null

    if (params.locationHash) {
      chart = processLocationHash(params.locationHash.decodeURL()).action
    }

    switch (chart) {
      case 'productCumulativeFlowChart':
        values = productService.cumulativeFlowValues(currentProduct)
        break
      case 'productBurnupChart':
        values = productService.productBurnupValues(currentProduct)
        break
      case 'productBurndownChart':
        values = productService.productBurndownValues(currentProduct)
        break
      case 'productParkingLotChart':
        values = featureService.productParkingLotValues(currentProduct)
        break
      case 'productVelocityChart':
        values = productService.productVelocityValues(currentProduct)
        break
      case 'productVelocityCapacityChart':
        values = productService.productVelocityCapacityValues(currentProduct)
        break
      default:
        chart = 'timeline'
        values = [
                [
                        releaseStateBundle: ReleaseStateBundle,
                        releases: currentProduct.releases,
                        productCumulativeFlowChart: productService.cumulativeFlowValues(currentProduct),
                        productBurnupChart: productService.productBurnupValues(currentProduct),
                        productBurndownChart: productService.productBurndownValues(currentProduct),
                        productParkingLotChart: featureService.productParkingLotValues(currentProduct),
                        productVelocityChart: productService.productVelocityValues(currentProduct),
                        productVelocityCapacityChart: productService.productVelocityCapacityValues(currentProduct)
                ]
        ]
        break
    }

    if (values.size() <= 0) {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    } else if (params.get) {
      session.progress = new ProgressSupport()
      session.progress.updateProgress(99, message(code: 'is.report.processing'))
      def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+(chart?:'timeline')+'-'+(g.formatDate(value:new Date(),formatName:'is.date.file'))
      try {
        chain(controller: 'jasper',
                action: 'index',
                model: [data: values],
                params: [
                        locale: User.get(springSecurityService.principal.id).preferences.language,
                        _format: params.format,
                        _name: message(code: 'is.ui.project'),
                        _file: chart ?: 'timeline',
                        _name: fileName,
                        'labels.projectName': currentProduct.name,
                        SUBREPORT_DIR: grailsApplication.config.jasper.dir.reports + File.separator + 'subreports' + File.separator
                ]
        )
        session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch (Exception e) {
        e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    } else if (params.status) {
      render(status: 200, contentType: 'application/json', text: session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id])
    }
  }

  @Secured('owner()')
  def delete = {
    if (!params.product) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.exist')]] as JSON)

    }
    assert params.product

    def product = Product.get(params.product)
    try {
      productService.deleteProduct(product)
      pushOthers "${params.product}-product-delete"
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.deleted')]] as JSON)
    }
  }

  /**
   * Parse the location hash string passed in argument
   * @param locationHash
   * @return A Map
   */
  private processLocationHash(String locationHash) {
    def data = locationHash.split('/')
    return [
            controller: data[0].replace('#', ''),
            action: data.size() > 1 ? data[1] : null
    ]
  }

  @Secured('permitAll')
  def browse = {
    render template: 'dialogs/browse'
  }

  @Secured('permitAll')
  def browseList = {
    def max = 7

    def total
    def products
    products = productService.getByTermProductList(params.term ?: '', [offset: params.int('offset') ?: 0, max: max, sort: "name", order: "asc", cache: true])
    total = productService.getByTermProductList(params.term ?: '', null).size()

    def results = []
    products?.each {
      results << [id: it.id, label: it.name.encodeAsHTML(),
              image: resource(dir: is.currentThemeImage(), file: 'choose/default.png')
      ]
    }

    render template: "/components/browserColumn", plugin: 'icescrum-core-webcomponents', model: [name: 'project-browse', max: max, total: total, term: params.term, offset: params.int('offset') ?: 0, browserCollection: results, actionDetails: 'browseDetails']
  }

  @Secured('permitAll')
  def browseDetails = {
    def product = Product.get(params.id)

    if (!product) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.exist')]] as JSON)
      return
    }

    if (product.preferences.hidden && !securityService.inProduct(product, springSecurityService.authentication)) {
      throw new AccessDeniedException('denied')
    }

    render template: "dialogs/browseDetails", model: [product: product]
  }
}
