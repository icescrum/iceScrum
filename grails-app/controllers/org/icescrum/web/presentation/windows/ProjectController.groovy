/*
 * Copyright (c) 2015 Kagilum SAS.
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

package org.icescrum.web.presentation.windows

import com.sun.syndication.io.SyndFeedOutput
import feedsplugin.FeedBuilder
import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityUtils
import grails.plugin.springsecurity.annotation.Secured
import groovy.xml.MarkupBuilder
import org.apache.commons.io.FilenameUtils
import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.*
import org.icescrum.core.domain.preferences.ProductPreferences
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.ServicesUtils

@Secured('stakeHolder() or inProduct()')
class ProjectController implements ControllerErrorHandler {

    def productService
    def sprintService
    def teamService
    def releaseService
    def springSecurityService
    def featureService
    def securityService
    def templateService

    @Secured(["hasRole('ROLE_ADMIN')"])
    def index(String term, String filter, Boolean paginate, Integer count, Integer page, String sorting, String order) {
        def options = [cache: true]
        if (paginate) {
            options.offset = page ? (page - 1) * count : 0
            options.max = count ?: 10
            options.sort = sorting ?: 'name'
            options.order = order ?: 'asc'
        }
        def projects = Product.findAllByTermAndFilter(options, term, filter)
        def returnData = paginate ? [projects: projects, count: projects.totalCount] : projects
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def show(long product) {
        Product _product = Product.withProduct(product)
        render(status: 200, contentType: 'application/json', text: _product as JSON)
    }

    @Secured(['isAuthenticated()'])
    def save() {
        def teamParams = params.product?.remove('team')
        def productPreferencesParams = params.product?.remove('preferences')
        def productParams = params.remove('product')

        if (!productParams || !teamParams) {
            returnError(code: 'todo.is.ui.no.data')
        }

        productParams.startDate = ServicesUtils.parseDateISO8601(productParams.startDate)
        productParams.endDate = ServicesUtils.parseDateISO8601(productParams.endDate)
        if (productParams.firstSprint) {
            productParams.firstSprint = ServicesUtils.parseDateISO8601(productParams.firstSprint)
        }

        if (productPreferencesParams.hidden && !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
            productPreferencesParams.hidden = false
        }

        if (productParams.initialize && (productParams.firstSprint?.before(productParams.startDate) || productParams.firstSprint?.after(productParams.endDate) || productParams.firstSprint == productParams.endDate)) {
            returnError(code: 'is.product.error.firstSprint')
            return
        }

        def team
        def product = new Product()
        product.preferences = new ProductPreferences()
        Product.withTransaction {
            bindData(product, productParams, [include: ['name', 'description', 'startDate', 'endDate', 'pkey']])
            bindData(product.preferences, productPreferencesParams, [exclude: ['archived']])
            if (!teamParams?.id) {
                team = new Team()
                bindData(team, teamParams, [include: ['name']])
                def members = teamParams.members ? teamParams.members.list('id').collect { it.toLong() } : []
                def scrumMasters = teamParams.scrumMasters ? teamParams.scrumMasters.list('id').collect { it.toLong() } : []
                def invitedMembers = teamParams.invitedMembers ? teamParams.invitedMembers.list('email') : []
                def invitedScrumMasters = teamParams.invitedScrumMasters ? teamParams.invitedScrumMasters.list('email') : []
                if (!scrumMasters && !members) {
                    returnError(code: 'is.product.error.noMember')
                    return
                }
                teamService.save(team, members, scrumMasters)
                productService.manageTeamInvitations(team, invitedMembers, invitedScrumMasters)
            } else {
                team = Team.withTeam(teamParams.long('id'))
            }
            def productOwners = productParams.productOwners ? productParams.productOwners.list('id').collect { it.toLong() } : []
            def stakeHolders = productParams.stakeHolders ? productParams.stakeHolders.list('id').collect { it.toLong() } : []
            def invitedProductOwners = productParams.invitedProductOwners ? productParams.invitedProductOwners.list('email') : []
            def invitedStakeHolders = productParams.invitedStakeHolders ? productParams.invitedStakeHolders.list('email') : []
            productService.save(product, productOwners, stakeHolders)
            productService.manageProductInvitations(product, invitedProductOwners, invitedStakeHolders)
            productService.addTeamToProduct(product, team)
            if (productParams.initialize) {
                def release = new Release(name: "Release 1", vision: productParams.vision, startDate: product.startDate, endDate: product.endDate)
                releaseService.save(release, product)
                sprintService.generateSprints(release, productParams.firstSprint)
            }
            def story = new Story(type: Story.TYPE_DEFECT, backlog: product)
            templateService.save(new Template(name: message(code: 'is.ui.sandbox.story.template.default.defect')), story)
            story.delete()
        }
        render(status: 201, contentType: 'application/json', text: product as JSON)
    }

    @Secured('scrumMaster() and !archivedProduct()')
    def update(long product) {
        Product _product = Product.withProduct(product)
        def productPreferencesParams = params.productd?.remove('preferences')
        def productParams = params.productd
        Product.withTransaction {
            productParams.startDate = ServicesUtils.parseDateISO8601(productParams.startDate);
            bindData(_product, productParams, [include: ['name', 'description', 'startDate', 'pkey', 'planningPokerGameType']])
            bindData(_product.preferences, productPreferencesParams, [exclude: ['archived']])
            if (!productPreferencesParams?.stakeHolderRestrictedViews) {
                _product.preferences.stakeHolderRestrictedViews = null
            }
            productService.update(_product, _product.preferences.isDirty('hidden'), _product.isDirty('pkey') ? _product.getPersistentValue('pkey') : null)
            entry.hook(id: "project-update", model: [product: _product])
            render(status: 200, contentType: 'application/json', text: _product as JSON)
        }
    }

    @Secured(['owner()'])
    def delete(long product) {
        try {
            Product _product = Product.withProduct(product)
            productService.delete(_product)
            render(status: 200, contentType: 'application/json', text: [class: 'Product', id: product] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.product.error.not.deleted', exception: re)
        }
    }

    @Secured(['scrumMaster() and !archivedProduct()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def updateTeam(long product) {
        // Param extraction
        def teamParams = params.productd?.remove('team')
        def productParams = params.remove('productd')
        def productOwners = productParams.productOwners ? productParams.productOwners.list('id').collect { it.toLong() } : []
        def stakeHolders = productParams.stakeHolders ? productParams.stakeHolders.list('id').collect { it.toLong() } : []
        def invitedProductOwners = productParams.invitedProductOwners ? productParams.invitedProductOwners.list('email') : []
        def invitedStakeHolders = productParams.invitedStakeHolders ? productParams.invitedStakeHolders.list('email') : []
        assert !stakeHolders.intersect(productOwners)
        // Compute roles
        def newMembers = []
        productOwners.each { newMembers << [id: it, role: Authority.PRODUCTOWNER] }
        stakeHolders.each { newMembers << [id: it, role: Authority.STAKEHOLDER] }
        // Update product & team
        Product _product = Product.withProduct(product)
        _product.withTransaction {
            def teamId = teamParams.id
            if (teamId != _product.firstTeam.id && securityService.owner(null, springSecurityService.authentication)) {
                productService.changeTeam(_product, Team.get(teamId))
            }
            productService.updateProductMembers(_product, newMembers)
            productService.manageProductInvitations(_product, invitedProductOwners, invitedStakeHolders)
        }
        render(status: 200, contentType: 'application/json', text: _product as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def feed(long product) {
        //todo make cache
        Product _product = Product.withProduct(product)
        def activities = Activity.recentProductActivity(_product)
        activities.addAll(Activity.recentStoryActivity(_product))
        activities = activities.sort { a, b -> b.dateCreated <=> a.dateCreated }
        def builder = new FeedBuilder()
        builder.feed(description: "${_product.description ?: ''}", title: "$_product.name ${message(code: 'is.ui.project.activity.title')}", link: "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [product: _product.pkey])}") {
            activities.each() { a ->
                entry("${a.poster.firstName} ${a.poster.lastName} ${message(code: "is.fluxiable.${a.code}")} ${message(code: "is." + (a.code == 'taskDelete' ? 'task' : a.code == 'acceptanceTestDelete' ? 'acceptanceTest' : 'story'))} ${a.label.encodeAsHTML()}") { e ->
                    if (a.code == Activity.CODE_DELETE) {
                        e.link = "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [product: _product.pkey])}"
                    } else {
                        e.link = "${createLink(absolute: true, uri: '/' + _product.pkey + '-' + Story.get(a.parentRef).uid)}"
                    }
                    e.publishedDate = a.dateCreated
                }
            }
        }
        def feed = builder.makeFeed(FeedBuilder.TYPE_RSS, FeedBuilder.DEFAULT_VERSIONS[FeedBuilder.TYPE_RSS])
        def outFeed = new SyndFeedOutput()
        render(contentType: 'text/xml', text: outFeed.outputString(feed))
    }

    @Secured(['permitAll()'])
    def available(long product, String property) {
        def result = false
        //test for name
        if (property == 'name') {
            result = request.JSON.value && (product ? Product.countByNameAndIdNotEqual(request.JSON.value, product) : Product.countByName(request.JSON.value)) == 0
            //test for pkey
        } else if (property == 'pkey') {
            result = request.JSON.value && request.JSON.value =~ /^[A-Z0-9]*$/ && (product ? Product.countByPkeyAndId(request.JSON.value, product) : Product.countByPkey(request.JSON.value)) == 0
        }
        render(status: 200, text: [isValid: result, value: request.JSON.value] as JSON, contentType: 'application/json')
    }

    @Secured(['scrumMaster() or productOwner()'])
    def export(long product) {
        Product _product = Product.withProduct(product)
        session.progress = new ProgressSupport()
        if (params.zip) {
            def projectName = "${_product.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}"
            ['Content-disposition': "attachment;filename=\"${projectName + '.zip'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
                response.setHeader(k, v)
            }
            response.contentType = 'application/zip'
            ApplicationSupport.exportProductZIP(_product, response.outputStream)
        } else {
            render(text: exportProductXML(_product), contentType: "text/xml")
        }
        session.progress.completeProgress(message(code: 'todo.is.ui.progress.complete'))
    }

    @Secured('scrumMaster()')
    def archive(long product) {
        Product _product = Product.withProduct(product)
        try {
            productService.archive(_product)
            render(status: 200, contentType: 'application/json', text: [class: 'Product', id: _product.id] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.product.error.not.archived', exception: re)
        }
    }

    @Secured("ROLE_ADMIN")
    def unArchive(long product) {
        Product _product = Product.withProduct(product)
        try {
            productService.unArchive(_product)
            render(status: 200, contentType: 'application/json', text: [class: 'Product', id: _product.id] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.product.error.not.archived', exception: re)
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def versions(long product) {
        Product _product = Product.withProduct(product)
        render(_product.getVersions(false, true) as JSON)
    }

    // Cannot end with Flow because of f*cked up filter in SpringSecurity (AnnotationFilterInvocationDefinition.java:256)
    def flowCumulative(long product) {
        Product _product = Product.withProduct(product)
        def values = productService.cumulativeFlowValues(_product)
        def computedValues = [[key   : message(code: "is.chart.productCumulativeflow.serie.suggested.name"),
                               values: values.collect { return [it.suggested] },
                               color : '#AAAAAA'],
                              [key   : message(code: "is.chart.productCumulativeflow.serie.accepted.name"),
                               values: values.collect { return [it.accepted] },
                               color : '#FFCC04'],
                              [key   : message(code: "is.chart.productCumulativeflow.serie.estimated.name"),
                               values: values.collect { return [it.estimated] },
                               color : '#FF9933'],
                              [key   : message(code: "is.chart.productCumulativeflow.serie.planned.name"),
                               values: values.collect { return [it.planned] },
                               color : '#CC3300'],
                              [key   : message(code: "is.chart.productCumulativeflow.serie.inprogress.name"),
                               values: values.collect { return [it.inprogress] },
                               color : '#42A9E0'],
                              [key   : message(code: "is.chart.productCumulativeflow.serie.done.name"),
                               values: values.collect { return [it.done] },
                               color : '#009900']].reverse()
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productCumulativeflow.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productCumulativeflow.xaxis.label')]],
                       title: [text: message(code: "is.chart.productCumulativeflow.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def velocityCapacity(long product) {
        Product _product = Product.withProduct(product)
        def values = productService.productVelocityCapacityValues(_product)
        def computedValues = [[key   : message(code: "is.chart.productVelocityCapacity.serie.velocity.name"),
                               values: values.collect { return [it.capacity] },
                               color : '#009900'],
                              [key   : message(code: "is.chart.productVelocityCapacity.serie.capacity.name"),
                               values: values.collect { return [it.velocity] },
                               color : '#1C3660']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productVelocityCapacity.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productVelocityCapacity.xaxis.label')]],
                       title: [text: message(code: "is.chart.productVelocityCapacity.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    @Secured('stakeHolder(#product) or inProduct(#product)')
    def burnup(long product) {
        Product _product = Product.withProduct(product)
        def values = productService.productBurnupValues(_product)
        def computedValues = [[key   : message(code: "is.chart.productBurnUp.serie.all.name"),
                               values: values.collect { return [it.all] },
                               color : '#1C3660'],
                              [key   : message(code: "is.chart.productBurnUp.serie.done.name"),
                               values: values.collect { return [it.done] },
                               color : '#009900']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productBurnUp.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productBurnUp.xaxis.label')]],
                       title: [text: message(code: "is.chart.productBurnUp.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def burndown(long product) {
        Product _product = Product.withProduct(product)
        def values = productService.productBurndownValues(_product)
        def computedValues = [[key   : message(code: 'is.chart.productBurnDown.series.userstories.name'),
                               values: values.collect { return [it.userstories] },
                               color : '#009900'],
                              [key   : message(code: 'is.chart.productBurnDown.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories] },
                               color : '#1F77B4'],
                              [key   : message(code: 'is.chart.productBurnDown.series.defectstories.name'),
                               values: values.collect { return [it.defectstories] },
                               color : '#CC3300']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productBurnDown.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productBurnDown.xaxis.label')]],
                       title: [text: message(code: "is.chart.productBurnDown.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def velocity(long product) {
        Product _product = Product.withProduct(product)
        def values = productService.productVelocityValues(_product)
        def computedValues = [[key   : message(code: 'is.chart.productVelocity.series.userstories.name'),
                               values: values.collect { return [it.userstories] },
                               color : '#009900'],
                              [key   : message(code: 'is.chart.productVelocity.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories] },
                               color : '#1F77B4'],
                              [key   : message(code: 'is.chart.productVelocity.series.defectstories.name'),
                               values: values.collect { return [it.defectstories] },
                               color : '#CC3300']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productVelocity.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productVelocity.xaxis.label')]],
                       title: [text: message(code: "is.chart.productVelocity.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def parkingLot(long product) {
        Product _product = Product.withProduct(product)
        def values = featureService.productParkingLotValues(_product)
        def computedValues = [[key   : message(code: "is.chart.productParkinglot.serie.name"),
                               values: values.collect { return [it.label, it.value] }]]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.productParkinglot.xaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.productParkinglot.yaxis.label')]],
                       title: [text: message(code: "is.chart.productParkinglot.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured('isAuthenticated()')
    def "import"() {
        if (params.flowFilename) {
            session.import = [:]
            session.progress = new ProgressSupport()

            def endOfUpload = { uploadInfo ->
                def path
                def xmlFile
                File uploadedProject = new File(uploadInfo.filePath)
                if (FilenameUtils.getExtension(uploadedProject.name) == 'xml') {
                    log.debug 'Export is an xml file, processing now'
                    xmlFile = uploadedProject
                    path = uploadedProject.absolutePath
                } else if (FilenameUtils.getExtension(uploadedProject.name) == 'zip') {
                    log.debug 'Export is a zipped file, unzipping now'
                    def tmpDir = ApplicationSupport.createTempDir(FilenameUtils.getBaseName(uploadedProject.name))
                    ApplicationSupport.unzip(uploadedProject, tmpDir)
                    xmlFile = tmpDir.listFiles().find {
                        !it.isDirectory() && FilenameUtils.getExtension(it.name) == 'xml'
                    }
                    path = tmpDir.absolutePath
                } else {
                    render(status: 400)
                    return
                }
                def product = productService.parseXML(xmlFile, session.progress)
                def changes = productService.validate(product, session.progress)
                session.import.product = product
                session.import.path = path
                render(status: 200, contentType: 'application/json', text: changes as JSON)
            }

            UtilsWebComponents.handleUpload.delegate = this
            UtilsWebComponents.handleUpload(request, params, endOfUpload)

        } else if (session.import) {
            def product = session.import.product
            def path = session.import.path
            if (params.changes) {
                def team = product.teams[0]
                if (params.changes?.team?.name) {
                    team.name = params.changes.team.name
                }
                if (params.changes?.users) {
                    team.members?.each {
                        if (params.changes.users."${it.uid}") {
                            it.username = params.changes.users."${it.uid}"
                        }
                    }
                    team.scrumMasters?.each {
                        if (params.changes.users."${it.uid}") {
                            it.username = params.changes.users."${it.uid}"
                        }
                    }
                    product.productOwners?.each {
                        if (params.changes.users."${it.uid}") {
                            it.username = params.changes.users."${it.uid}"
                        }
                    }
                }
            }

            def erase = params.boolean('changes.erase') ?: false
            product.pkey = !erase && params.changes?.product?.pkey != null ? params.changes.product.pkey : product.pkey
            product.name = !erase && params.changes?.product?.name != null ? params.changes.product.name : product.name

            def changes = productService.validate(product, session.progress, erase)
            if (!changes) {
                try {
                    productService.saveImport(product, path, erase)
                    render(status: 200, contentType: 'application/json', text: product as JSON)
                } catch (RuntimeException e) {
                    returnError(code: 'is.import.error', exception: e)
                }
            } else {
                session.import.product = product
                session.import.path = path
                render(status: 200, contentType: 'application/json', text: changes as JSON)
                if (log.infoEnabled) log.info(changes)
            }
        } else {
            render(status: 500)
        }
    }

    private String exportProductXML(Product product) {
        def writer = new StringWriter()
        def builder = new MarkupBuilder(writer)
        builder.mkp.xmlDeclaration(version: "1.0", encoding: "UTF-8")
        builder.export(version: meta(name: "app.version")) {
            product.xml(builder)
        }
        def projectName = "${product.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}"
        ['Content-disposition': "attachment;filename=\"${projectName + '.xml'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
            response.setHeader(k, v)
        }
        response.contentType = 'application/octet'
        return writer.toString()
    }

    @Secured(['permitAll()'])
    def listPublic(String term, Integer offset) {
        if (!offset) {
            offset = 0
        }
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def limit = 9
        def publicProjects = Product.where { preferences.hidden == false && name =~ searchTerm }.list(sort: "name")
        def userProjects = Product.findAllByUserAndActive(springSecurityService.currentUser, null, null)
        def projects = publicProjects - userProjects
        def projectsAndTotal = [projects: projects.drop(offset).take(limit), total: projects.size()]
        render(status: 200, contentType: 'application/json', text: projectsAndTotal as JSON)
    }

    @Secured(['isAuthenticated()'])
    def listByUser(String term, Integer offset) {
        if (!offset) {
            offset = 0
        }
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def limit = 9
        def projects = productService.getAllActiveProductsByUser(springSecurityService.currentUser, searchTerm)
        def projectsAndTotal = [projects: projects.drop(offset).take(limit), total: projects.size()]
        render(status: 200, contentType: 'application/json', text: projectsAndTotal as JSON)
    }

    @Secured(['stakeHolder() or inProduct()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def leaveTeam(long product) {
        Product _product = Product.withProduct(product)
        _product.withTransaction {
            def oldMembersByProduct = [:]
            _product.firstTeam.products.each { Product teamProduct ->
                oldMembersByProduct[teamProduct.id] = productService.getAllMembersProductByRole(teamProduct)
            }
            productService.removeAllRoles(_product.firstTeam, springSecurityService.currentUser)
            oldMembersByProduct.each { Long productId, Map oldMembers ->
                productService.manageProductEvents(Product.get(productId), oldMembers)
            }
        }
        render(status: 200)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def activities(long product) {
        Product _product = Product.withProduct(product)
        def activities = Activity.recentStoryActivity(_product)
        activities.addAll(Activity.recentProductActivity(_product))
        activities = activities.sort { a, b -> b.dateCreated <=> a.dateCreated }
        render(status: 200, text: activities as JSON, contentType: 'application/json')
    }

    @Secured(['isAuthenticated()'])
    def edit() {
        render(status: 200, template: "dialogs/edit")
    }

    @Secured(['isAuthenticated()'])
    def editMembers() {
        render(status: 200, template: "dialogs/editMembers")
    }

    @Secured(['permitAll()'])
    def listModal() {
        render(status: 200, template: "dialogs/list")
    }

    @Secured(['isAuthenticated()'])
    def add() {
        render(status: 200, template: "dialogs/new")
    }

    @Secured(['isAuthenticated()'])
    def importDialog() {
        render(status: 200, template: "dialogs/import")
    }

    @Secured(['isAuthenticated()'])
    def exportDialog() {
        render(status: 200, template: "dialogs/export")
    }
}
