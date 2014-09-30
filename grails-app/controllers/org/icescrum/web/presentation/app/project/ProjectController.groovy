/*
 * Copyright (c) 2014 Kagilum SAS.
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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.domain.preferences.ProductPreferences
import org.icescrum.core.domain.preferences.TeamPreferences
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.support.ProgressSupport

import org.icescrum.core.utils.BundleUtils

import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import grails.plugin.fluxiable.Activity
import grails.plugin.cache.Cacheable
import grails.plugin.springsecurity.annotation.Secured
import grails.plugin.springsecurity.SpringSecurityUtils
import org.springframework.security.access.AccessDeniedException
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import feedsplugin.FeedBuilder
import com.sun.syndication.io.SyndFeedOutput
import org.codehaus.groovy.grails.web.util.StreamCharBuffer
import org.apache.commons.io.FilenameUtils
import java.text.DecimalFormat

@Secured('stakeHolder() or inProduct()')
class ProjectController {

    def productService
    def sprintService
    def teamService
    def releaseService
    def springSecurityService
    def featureService
    def securityService
    def attachmentableService

    def index() {
        chain(controller: 'scrumOS', action: 'index', params: params)
    }

    @Cacheable('projectCache') //, keyGenerator = 'localeKeyGenerator')
    def feed() {
        cache validFor: 300
        withProduct{ Product product ->
            def activities = Story.recentActivity(product)
            activities.addAll(Product.recentActivity(product))
            activities = activities.sort {a, b -> b.dateCreated <=> a.dateCreated}

            def builder = new FeedBuilder()
            builder.feed(description: "${product.description?:''}",title: "$product.name ${message(code: 'is.ui.project.activity.title')}", link: "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [product: product.pkey])}") {
              activities.each() { a ->
                    entry("${a.poster.firstName} ${a.poster.lastName} ${message(code: "is.fluxiable.${a.code}")} ${message(code: "is." + (a.code == 'taskDelete' ? 'task' : a.code == 'acceptanceTestDelete' ? 'acceptanceTest' : 'story'))} ${a.cachedLabel.encodeAsHTML()}") {e ->
                        if (a.code != Activity.CODE_DELETE)
                            e.link = "${is.createScrumLink(absolute: true, controller: 'story', id: a.cachedId)}"
                        else
                            e.link = "${is.createScrumLink(absolute: true, controller: 'project')}"
                        e.publishedDate = a.dateCreated
                    }
                }
            }
            def feed = builder.makeFeed(FeedBuilder.TYPE_RSS,FeedBuilder.DEFAULT_VERSIONS[FeedBuilder.TYPE_RSS])
            def outFeed = new SyndFeedOutput()
            render(contentType: 'text/xml', text:outFeed.outputString(feed))
        }
    }

    @Secured('owner() or scrumMaster()')
    def edit() {
        withProduct{ Product product ->
            def privateOption = !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable)
            if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                privateOption = false
            }
            def menuTagLib = grailsApplication.mainContext.getBean('org.icescrum.core.taglib.MenuTagLib')
            def possibleViews = menuTagLib.getMenuBarFromUiDefinitions(false)

            def dialog = g.render(template: "dialogs/edit",
                                  model: [product: product,
                                          privateOption: privateOption,
                                          possibleViews: possibleViews,
                                          restrictedViews:product.preferences.stakeHolderRestrictedViews?.split(',')])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
        }
    }

    @Secured('(owner() or scrumMaster()) and !archivedProduct()')
    def editPractices() {
        withProduct{ Product product ->
            def estimationSuitSelect = [(PlanningPokerGame.FIBO_SUITE) : message(code: "is.estimationSuite.fibonacci"),
                                        (PlanningPokerGame.INTEGER_SUITE) : message(code: "is.estimationSuite.integer"),
                                        (PlanningPokerGame.CUSTOM_SUITE) : message(code: "is.estimationSuite.custom")]
            def dialog = g.render(template: "dialogs/editPractices", model: [product: product, estimationSuitSelect: estimationSuitSelect])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
        }
    }

    @Secured('(owner() or scrumMaster()) and !archivedProduct()')
    def update() {
        withProduct('productd.id'){ Product product ->
            def msg
            if (params.long('productd.version') != product.version) {
                msg = message(code: 'is.stale.object', args: [message(code: 'is.product')])
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
                return
            }
            //Oui pas une faute de frappe c'est bien productd pour pas confondra avec params.product ..... notre id de product
            boolean hasHiddenChanged = product.preferences.hidden != params.productd.preferences.hidden
            product.properties = params.productd
            if(!params.productd.preferences?.stakeHolderRestrictedViews){
                product.preferences.stakeHolderRestrictedViews = null
            }
            try {
                productService.update(product, hasHiddenChanged, product.isDirty('pkey') ? product.getPersistentValue('pkey'): null)
                entry.hook(id:"${controllerName}-${actionName}", model:[product:product])
            } catch (IllegalStateException ise) {
                returnError(exception:ise)
                return
            } catch (RuntimeException re) {
                returnError(exception:re, object:product)
                return
            }
            render(status: 200, contentType: 'application/json', text:product as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def add() {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)) {
            if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                render(status: 403)
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
        if (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.default)) {
            product.preferences.hidden = true
        }
        def estimationSuitSelect = [(PlanningPokerGame.FIBO_SUITE): message(code: "is.estimationSuite.fibonacci"), (PlanningPokerGame.INTEGER_SUITE): message(code: "is.estimationSuite.integer")]

        def privateOption = !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable)
        if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
            privateOption = false
        }
        render(status:200, template: "dialogs/new", model: [product: product,
                                                               estimationSuitSelect: estimationSuitSelect,
                                                               privateOption: privateOption,
                                                               user:springSecurityService.currentUser,
                                                               rolesLabels: BundleUtils.roles.values().collect {v -> message(code: v)},
                                                               rolesKeys: BundleUtils.roles.keySet().asList()])
    }

    @Secured('isAuthenticated()')
    def save() {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)) {
            if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                render(status: 403)
                return
            }
        }

        if (!params.product) return
        def product = new Product()
        product.preferences = new ProductPreferences()
        params.product.startDate = new Date().parse(message(code: 'is.date.format.short'), params.product.startDate)
        params.product.endDate = new Date().parse(message(code: 'is.date.format.short'), params.product.endDate)
        params.firstSprint = new Date().parse(message(code: 'is.date.format.short'), params.firstSprint)

        product.properties = params.product

        if (params.product.preferences.hidden && !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
            product.preferences.hidden = true
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

        def team = null
        Product.withTransaction { status ->
            try {
                team = new Team()
                team.name = params.product.name+" team "+new Date().toTimestamp()
                team.preferences = new TeamPreferences()
                team.properties = params.team

                def members  = []
                def productOwners = []
                def scrumMasters  = []
                def stakeHolders = []
                params.members?.each{ k,v ->
                    switch(params.role."${k}"){
                        case Authority.MEMBER.toString():
                            members.add(v.toLong())
                            break;
                        case Authority.SCRUMMASTER.toString():
                            scrumMasters.add(v.toLong())
                            break;
                        case Authority.PRODUCTOWNER.toString():
                            productOwners.add(v.toLong())
                            break;
                        case Authority.STAKEHOLDER.toString():
                            stakeHolders.add(v.toLong())
                            break;
                        case Authority.PO_AND_SM.toString():
                            scrumMasters.add(v.toLong())
                            productOwners.add(v.toLong())
                            break;
                    }
                }

                if (!scrumMasters && !members && !productOwners){
                    render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.noMember')]] as JSON)
                    return
                }

                teamService.save team, members, scrumMasters
                productService.save(product, productOwners, stakeHolders)
                productService.addTeamsToProduct product, [team.id]

                def release = new Release(name: "R1",
                        startDate: product.startDate,
                        vision: params.vision,
                        endDate: product.endDate)
                releaseService.save(release, product)
                sprintService.generateSprints(release, params.firstSprint)
                render(status:200, contentType: 'application/json', text:product as JSON)

            } catch (IllegalStateException ise) {
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
                status.setRollbackOnly()
                return
            } catch (RuntimeException re) {
                status.setRollbackOnly()
                if (log.debugEnabled) re.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: product) + renderErrors(bean: team)]] as JSON)
                return
            }
        }
    }

    def dashboard() {
        withProduct{ Product product ->
            def sprint = Sprint.findCurrentOrLastSprint(product.id).list()[0]
            def release = Release.findCurrentOrNextRelease(product.id).list()[0]
            def activities = Story.recentActivity(product)
            activities.addAll(Product.recentActivity(product))
            activities = activities.sort {a, b -> b.dateCreated <=> a.dateCreated}

            render template: 'window/view',
                    model: [product: product,
                            activities: activities,
                            sprint: sprint,
                            release: release,
                            user: springSecurityService.currentUser,
                            lang: RCU.getLocale(request).toString().substring(0, 2)]
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'releasesKeyGenerator')
    def productCumulativeFlowChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = productService.cumulativeFlowValues(product)
            if (values.size() > 0) {
                def rendered = g.render(template: 'charts/productCumulativeFlowChart', model: [
                        suggested: values.suggested as JSON,
                        accepted: values.accepted as JSON,
                        estimated: values.estimated as JSON,
                        planned: values.planned as JSON,
                        inprogress: values.inprogress as JSON,
                        done: values.done as JSON,
                        labels: values.label as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productCumulativeflow.title')],rendered) : rendered, status:200)
            } else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'releasesKeyGenerator')
    def productVelocityCapacityChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = productService.productVelocityCapacityValues(product)
            if (values.size() > 0) {
                def rendered = g.render(template: 'charts/productVelocityCapacityChart', model: [
                        modal: params.modal,
                        capacity: values.capacity as JSON,
                        velocity: values.velocity as JSON,
                        labels: values.label as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productVelocityCapacity.title')],rendered) : rendered, status:200)
            } else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'releasesKeyGenerator')
    def productBurnupChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = productService.productBurnupValues(product)
            if (values.size() > 0) {
                def rendered = g.render(template: 'charts/productBurnupChart', model: [
                        all: values.all as JSON,
                        done: values.done as JSON,
                        labels: values.label as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productBurnUp.title')],rendered) : rendered, status:200)
            } else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'releasesKeyGenerator')
    def productBurndownChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = productService.productBurndownValues(product)
            if (values.size() > 0) {
                def rendered = g.render(template: 'charts/productBurndownChart', model: [
                        userstories: values.userstories as JSON,
                        technicalstories: values.technicalstories as JSON,
                        defectstories: values.defectstories as JSON,
                        labels: values.label as JSON,
                        userstoriesLabels: values*.userstoriesLabel as JSON,
                        technicalstoriesLabels: values*.technicalstoriesLabel as JSON,
                        defectstoriesLabels: values*.defectstoriesLabel as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productBurnDown.title')],rendered) : rendered, status:200)
            } else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'releasesKeyGenerator')
    def productVelocityChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = productService.productVelocityValues(product)
            if (values.size() > 0) {
                def rendered = g.render(template: 'charts/productVelocityChart', model: [
                        userstories: values.userstories as JSON,
                        technicalstories: values.technicalstories as JSON,
                        defectstories: values.defectstories as JSON,
                        labels: values.label as JSON,
                        userstoriesLabels: values*.userstoriesLabel as JSON,
                        technicalstoriesLabels: values*.technicalstoriesLabel as JSON,
                        defectstoriesLabels: values*.defectstoriesLabel as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productVelocity.title')],rendered) : rendered, status:200)
            } else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Cacheable("projectCache") //, keyGenerator= 'featuresKeyGenerator')
    def productParkingLotChart() {
        params.modal = params.boolean('modal')
        withProduct{ Product product ->
            def values = featureService.productParkingLotValues(product)
            def indexF = 1
            def valueToDisplay = []
            values.value?.each {
                def value = []
                value << new DecimalFormat("#.##").format(it).toString()
                value << indexF
                valueToDisplay << value
                indexF++
            }
            if (valueToDisplay.size() > 0){
                def rendered = g.render(template: '../feature/charts/productParkinglot', model: [
                        values: valueToDisplay as JSON,
                        featuresNames: values.label as JSON,
                        controllerName: params.controllerName ?: controllerName])
                render(text:params.modal ? is.modal([button:[[shortcut:[key:'CTRL+S', title:message(code:'is.button.save.as.image')],text:'<span class="glyphicon glyphicon-save"></span>', class:'save-chart', color:'info']],size:'xxl', title:message(code:'is.chart.productParkinglot.title')],rendered) : rendered, status:200)
            }
            else {
                def msg = message(code: 'is.chart.error.no.values')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            }
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def export() {
        withProduct{ Product product ->
            if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable)) {
                if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    render(status: 403)
                    return
                }
            }

            withFormat {
                html {
                    if (params.status) {
                        render(status: 200, contentType: 'application/json', text: session.progress as JSON)
                    }
                    else if (params.get) {
                        session.progress.updateProgress(0, message(code: 'is.export.start'))
                        exportProduct(product, true)
                        session.progress?.completeProgress(message(code: 'is.export.complete'))
                    } else {
                        session.progress = new ProgressSupport()
                        def dialog = g.render(template: 'dialogs/export')
                        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                    }
                }
                xml {
                    if (params.zip){
                        exportProduct(product, false)
                    }else{
                        render(contentType: 'text/xml', template: '/project/xml', model: [object: product, deep: true, root: true], encoding: 'UTF-8')
                    }
                }
            }
        }
    }

    @Secured('isAuthenticated()')
    def importProject() {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable)) {
            if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                render(status: 403)
                return
            }
        }

        def user = User.load(springSecurityService.principal.id)
        if (params.cancel) {
            session['import'] = null
            session.progress = null
            render(status: 200)
            return
        }
        else if (params.file) {
            File uploadedProject = null
            "${params.file}".split(":")?.with {
                if (session.uploadedFiles[it[0]])
                    uploadedProject = new File((String) session.uploadedFiles[it[0]])
            }
            if (uploadedProject) {
                session.progress = new ProgressSupport()
                session['import'] = [:]
                if (FilenameUtils.getExtension(uploadedProject.name) == 'xml'){
                    if (log.debugEnabled){ log.debug 'Export is an xml file, processing now' }
                    session['import']?.product = productService.parseXML(uploadedProject, session.progress)
                    session['import']?.path = uploadedProject.absolutePath
                } else if (FilenameUtils.getExtension(uploadedProject.name) == 'zip'){
                    if (log.debugEnabled){ log.debug 'Export is a zipped file, unzipping now' }
                    def tmpDir = ApplicationSupport.createTempDir(FilenameUtils.getBaseName(uploadedProject.name))
                    ApplicationSupport.unzip(uploadedProject,tmpDir)
                    def xmlFile = tmpDir.listFiles().find { !it.isDirectory() && FilenameUtils.getExtension(it.name) == 'xml' }
                    if (xmlFile){
                        session['import']?.path = tmpDir.absolutePath
                        session['import']?.product = productService.parseXML(xmlFile, session.progress)
                    }else{
                        session.progress.progressError(message(code:'is.error'))    
                    }
                }
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

        if (session['import']) {
            def unValidableErrors = this.validateImport()
            if (unValidableErrors) {
                session['import'] = null
                session.progress = null
                render(status: 400, contentType: 'application/json', text: [notice: [text: unValidableErrors, type: 'error']] as JSON)
                return

            } else {
                def importMustChangeValues = session['import'].product.hasErrors() ?: (true in session['import'].product.teams*.hasErrors()) ?: (true in session['import'].product.getAllUsers()*.hasErrors())
                def dialog = g.render(template: 'dialogs/import', model: [
                        user: user,
                        product: session['import'].product,
                        importMustChangeValues: importMustChangeValues,
                        teamsErrors: session['import'].product.teams.findAll {it.hasErrors()},
                        usersErrors: session['import'].product.getAllUsers().findAll {it.hasErrors()}
                ])
                render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            }
        } else {
            def dialog = g.render(template: 'dialogs/import', model: [user: user])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def saveImport() {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable)) {
            if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                render(status: 403)
                return
            }
        }

        if (!session['import']) {
            returnError(text:message(code:'is.import.error.no.backup'))
            return
        }

        if (params.team?.name) {
            session['import'].product.teams.each {
                if (params.team.name."${it.uid}") {
                    it.name = params.team.name."${it.uid}"
                }
            }
        }

        if (params.user?.username) {
            session['import'].product.teams.each {
                it.members?.each {it2 ->
                    if (params.user.username."${it2.uid}") {
                        it2.username = params.user.username."${it2.uid}"
                    }
                }
                it.scrumMasters?.each {it2 ->
                    if (params.user.username."${it2.uid}") {
                        it2.username = params.user.username."${it2.uid}"
                    }
                }
            }
            session['import'].product.productOwners?.each {
                if (params.user.username."${it.uid}") {
                    it.username = params.user.username."${it.uid}"
                }
            }
        }

        def erasableByUser = false
        if (params.productd?.int('erasableByUser')) {
            erasableByUser = params.productd?.int('erasableByUser') ? true : false
        }
        session['import'].product.erasableByUser = erasableByUser
        if (!erasableByUser && params.productd?.pkey != null && params.productd?.name != null) {
            session['import'].product.pkey = params.productd.pkey
            session['import'].product.name = params.productd.name
        }
        def errors = this.validateImport(true, erasableByUser)
        if (errors) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: errors]] as JSON)
            return
        }

        Product.withTransaction { status ->
            try {
                productService.saveImport(session['import'].product, params.productd?.name, session['import'].path)
            } catch (IllegalStateException ise) {
                status.setRollbackOnly()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
                return
            }
            catch (RuntimeException e) {
                status.setRollbackOnly()
                if (log.debugEnabled) e.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.import.error')]] as JSON)
                return
            }
            render(status:200, contentType:'application/json', text:session['import'].product as JSON)
            session['import'] = null
        }
    }

    private def validateImport(def full = false, def erasableByUser = false) {

        def p = session['import'].product
        productService.validate(p, session.progress)
        def beansErrors = null

        if (p.hasErrors()) {
            log.info("Product validation error (${p.name}): " + p.errors)
            if (full && !erasableByUser) {
                beansErrors = renderErrors(bean: p)
            }

            def pass = true
            p.errors.each {
                if (it.getFieldError().getField() != 'name' && it.getFieldError().getField() != 'pkey') {
                    pass = false

                }
            }

            if (!pass) {
                beansErrors = renderErrors(bean: session['import'].product)
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
    def print() {
        withProduct{ Product product ->
            def data
            def chart = null

            if (params.locationHash) {
                chart = processLocationHash(params.locationHash.decodeURL()).action
            }

            switch (chart) {
                case 'productCumulativeFlowChart':
                    data = productService.cumulativeFlowValues(product)
                    break
                case 'productBurnupChart':
                    data = productService.productBurnupValues(product)
                    break
                case 'productBurndownChart':
                    data = productService.productBurndownValues(product)
                    break
                case 'productParkingLotChart':
                    data = featureService.productParkingLotValues(product)
                    break
                case 'productVelocityChart':
                    data = productService.productVelocityValues(product)
                    break
                case 'productVelocityCapacityChart':
                    data = productService.productVelocityCapacityValues(product)
                    break
                default:
                    chart = 'timeline'
                    data = [
                            [
                                    releaseStateBundle: BundleUtils.releaseStates,
                                    releases: product.releases,
                                    productCumulativeFlowChart: productService.cumulativeFlowValues(product),
                                    productBurnupChart: productService.productBurnupValues(product),
                                    productBurndownChart: productService.productBurndownValues(product),
                                    productParkingLotChart: featureService.productParkingLotValues(product),
                                    productVelocityChart: productService.productVelocityValues(product),
                                    productVelocityCapacityChart: productService.productVelocityCapacityValues(product)
                            ]
                    ]
                    break
            }

            if (data.size() <= 0) {
                returnError(text:message(code: 'is.report.error.no.data'))
            } else if (params.get) {
                outputJasperReport(chart ?: 'timeline', params.format, data, product.name, ['labels.projectName': product.name])
            } else if (params.status) {
                render(status: 200, contentType: 'application/json', text: session.progress as JSON)
            } else {
                session.progress = new ProgressSupport()
                def dialog = g.render(template: '/scrumOS/report')
                render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
            }
        }
    }

    @Secured('owner()')
    def delete() {
        withProduct{ Product product ->
            def id = product.id
            try {
                productService.delete(product)
                render(status: 200, contentType: 'application/json', text:[class:'Product',id:id] as JSON)
            } catch (RuntimeException re) {
                if (log.debugEnabled) re.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.deleted')]] as JSON)
            }
        }
    }

    @Secured('owner() or scrumMaster()')
    def archive() {
        withProduct{ Product product ->
            try {
                productService.archive(product)
                render(status: 200, contentType: 'application/json', text:[class:'Product',id:product.id] as JSON)
            } catch (RuntimeException re) {
                if (log.debugEnabled) re.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.archived')]] as JSON)
            }
        }
    }

    @Secured("hasRole('ROLE_ADMIN')")
    def unArchive() {
        withProduct{ Product product ->
            try {
                productService.unArchive(product)
                render(status: 200, contentType: 'application/json', text:[class:'Product',id:product.id] as JSON)
            } catch (RuntimeException re) {
                if (log.debugEnabled) re.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.product.error.not.archived')]] as JSON)
            }
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
    @Cacheable('applicationCache') //, keyGenerator = 'localeKeyGenerator')
    def browse() {
        def dialog = g.render(template: 'dialogs/browse')
        render(status:200, contentType: 'application/json', text: [dialog:dialog] as JSON)
    }

    @Secured('permitAll')
    def browseList() {

        def term = '%'+params.term+'%' ?: '';
        def options = [offset:params.int('offset') ?: 0, max: 9, sort: "name", order: "asc", cache:true]
        def currentUser = springSecurityService.currentUser

        def products = securityService.admin(springSecurityService.authentication) ? Product.findAllByNameIlike(term, options) : Product.searchPublicAndMyProducts(currentUser,term,options)
        def total =  securityService.admin(springSecurityService.authentication) ? Product.countByNameIlike(term, [cache:true]) : Product.countPublicAndMyProducts(currentUser,term,[cache:true])[0]

        def results = []
        products?.each {
            results << [id: it.id, label: it.name.encodeAsHTML(),
                    image: asset.assetPath(src:'images/default.png')
            ]
        }

        render template: "/components/browserColumn", plugin: 'icescrum-core', model: [name: 'project-browse', max: 9, total: total, term: params.term, offset: params.int('offset') ?: 0, browserCollection: results, actionDetails: 'browseDetails']
    }

    @Secured('permitAll')
    @Cacheable('projectCache') //, keyGenerator = 'projectKeyGenerator')
    def browseDetails() {
        withProduct('id'){ Product product ->
            if (!securityService.owner(product, springSecurityService.authentication)){
                if ((product.preferences.hidden && !securityService.inProduct(product, springSecurityService.authentication))) {
                    throw new AccessDeniedException('denied')
                }
            }
            render template: "dialogs/browseDetails", model: [product: product]
        }
    }

    def printPostits() {
        withProduct{ Product product ->
            def stories1 = []
            def stories2 = []
            def first = 0
            def stories = Story.findAllByBacklog(product, [sort: 'state', order: 'asc'])
            if (!stories) {
                returnError(text:message(code: 'is.report.error.no.data'))
                return
            } else if (params.get) {
                stories.each {
                    def testsByState = it.countTestsByState()
                    def story = [
                            name: it.name,
                            id: it.uid,
                            effort: it.effort,
                            state: message(code: BundleUtils.storyStates[it.state]),
                            description: is.storyDescription([story: it, displayBR: true]),
                            notes: wikitext.renderHtml([markup: 'Textile'], it.notes).decodeHTML(),
                            type: message(code: BundleUtils.storyTypes[it.type]),
                            suggestedDate: it.suggestedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.suggestedDate]) : null,
                            acceptedDate: it.acceptedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.acceptedDate]) : null,
                            estimatedDate: it.estimatedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.estimatedDate]) : null,
                            plannedDate: it.plannedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.plannedDate]) : null,
                            inProgressDate: it.inProgressDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.inProgressDate]) : null,
                            doneDate: it.doneDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: product.preferences.timezone, date: it.doneDate ?: null]) : null,
                            rank: it.rank ?: null,
                            sprint: it.parentSprint?.orderNumber ? g.message(code: 'is.release') + " " + it.parentSprint.parentRelease.orderNumber + " - " + g.message(code: 'is.sprint') + " " + it.parentSprint.orderNumber : null,
                            creator: it.creator.firstName + ' ' + it.creator.lastName,
                            feature: it.feature?.name ?: null,
                            dependsOn: it.dependsOn?.name ? it.dependsOn.uid + " " + it.dependsOn.name : null,
                            permalink:createLink(absolute: true, mapping: "shortURL", params: [product: product.pkey], id: it.uid),
                            featureColor: it.feature?.color ?: null,
                            nbTestsTocheck: testsByState[AcceptanceTestState.TOCHECK],
                            nbTestsFailed: testsByState[AcceptanceTestState.FAILED],
                            nbTestsSuccess: testsByState[AcceptanceTestState.SUCCESS]
                    ]
                    if (first == 0) {
                        stories1 << story
                        first = 1
                    } else {
                        stories2 << story
                        first = 0
                    }

                }
                outputJasperReport('stories', params.format, [[product: product.name, stories1: stories1 ?: null, stories2: stories2 ?: null]], product.name)
            } else if (params.status) {
                render(status: 200, contentType: 'application/json', text: session?.progress as JSON)
            } else {
                session.progress = new ProgressSupport()
                def dialog = g.render(template: '/scrumOS/report')
                render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
            }
        }
    }

    def versions() {
        withProduct { Product product ->
            withFormat{
                html {
                    def versions = product.getVersions(false, true)
                    render versions.collect{ [id:it, text:it] } as JSON
                }
                json { renderRESTJSON(text:product.versions) }
                xml  { renderRESTXML(text:product.versions) }
             }
        }
    }

    private exportProduct(Product product, boolean withProgress){

        def projectName = "${product.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}"
        def tempdir = System.getProperty("java.io.tmpdir");
        tempdir = (tempdir.endsWith("/") || tempdir.endsWith("\\")) ? tempdir : tempdir + System.getProperty("file.separator")
        def xml = new File(tempdir + projectName + '.xml')
        try {
            StreamCharBuffer xmlFile = g.render(contentType: 'text/xml', template: '/project/xml', model: [object: product, deep: true, root: true], encoding: 'UTF-8')
            xml.withWriter('UTF-8'){ out ->
                xmlFile.writeTo(out)
            }
            def files = []

            product.stories*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }
            product.actors*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }
            product.features*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }
            product.releases*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }
            product.sprints*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }
            product.attachments.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }

            def tasks = []
            product.releases*.each{ it.sprints*.each{ s -> tasks.addAll(s.tasks) } }
            tasks*.attachments.findAll{ it.size() > 0 }?.each{ it?.each{ att -> files << attachmentableService.getFile(att) } }

            ['Content-disposition': "attachment;filename=\"${projectName+'.zip'}\"",'Cache-Control': 'private','Pragma': ''].each {k, v ->
                response.setHeader(k, v)
            }
            response.contentType = 'application/zip'
            ApplicationSupport.zipExportFile(response.outputStream, files, xml, 'attachments')
        } catch (Exception e) {
            if (log.debugEnabled)
                e.printStackTrace()
            if (withProgress)
                session.progress.progressError(message(code: 'is.export.error'))
        } finally {
            xml.delete()
        }
    }

    @Secured('inProduct()')
    def addDocument() {
        withProduct { Product product ->
            def dialog = g.render(template:'/attachment/dialogs/documents', model:[bean:product, destController:'project'])
            render status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON
        }
    }

    @Secured('inProduct()')
    def attachments() {
        withProduct { Product product ->
            def keptAttachments = params.list('product.attachments')
            def addedAttachments = params.list('attachments')
            def attachments = manageAttachments(product, keptAttachments, addedAttachments)
            render status: 200, contentType: 'application/json', text: attachments as JSON
        }
    }
}
