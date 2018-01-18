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
import grails.validation.ValidationException
import org.apache.commons.io.FilenameUtils
import org.icescrum.components.FileUploadInfoStorage
import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.*
import org.icescrum.core.domain.preferences.ProjectPreferences
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.services.SecurityService
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.ServicesUtils

@Secured('stakeHolder() or inProject()')
class ProjectController implements ControllerErrorHandler {

    def projectService
    def sprintService
    def teamService
    def releaseService
    def springSecurityService
    def featureService
    def securityService
    def dummyService

    @Secured(["hasRole('ROLE_ADMIN')"])
    def index(String term, String filter, Boolean paginate, Integer count, Integer page, String sorting, String order) {
        def options = [cache: true]
        if (paginate) {
            if (!count) {
                count = 10
            }
            options.offset = page ? (page - 1) * count : 0
            options.max = count
            options.sort = sorting ?: 'name'
            options.order = order ?: 'asc'
        }
        def projects = Project.findAllByTermAndFilter(options, term, filter)
        def returnData = paginate ? [projects: projects, count: projects.totalCount] : projects
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['inProject()'])
    def show(long project) {
        Project _project = Project.withProject(project)
        render(status: 200, contentType: 'application/json', text: _project as JSON)
    }

    @Secured(['isAuthenticated()'])
    def save() {
        def teamParams = params.project?.remove('team')
        def projectPreferencesParams = params.project?.remove('preferences')
        def projectParams = params.remove('project')

        if (!projectParams || !teamParams) {
            returnError(code: 'todo.is.ui.no.data')
        }

        projectParams.startDate = ServicesUtils.parseDateISO8601(projectParams.startDate)
        projectParams.endDate = ServicesUtils.parseDateISO8601(projectParams.endDate)
        if (projectParams.firstSprint) {
            projectParams.firstSprint = ServicesUtils.parseDateISO8601(projectParams.firstSprint)
        }

        if (projectPreferencesParams.hidden && !ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
            projectPreferencesParams.hidden = false
        }

        if (projectParams.initialize && (projectParams.firstSprint?.before(projectParams.startDate) || projectParams.firstSprint?.after(projectParams.endDate) || projectParams.firstSprint == projectParams.endDate)) {
            returnError(code: 'is.project.error.firstSprint')
            return
        }

        def team
        def project = new Project()
        project.preferences = new ProjectPreferences()
        Project.withTransaction {
            bindData(project, projectParams, [include: ['name', 'description', 'startDate', 'endDate', 'pkey']])
            bindData(project.preferences, projectPreferencesParams, [exclude: ['archived']])
            if (!teamParams?.id) {
                team = new Team()
                bindData(team, teamParams, [include: ['name']])
                def members = teamParams.members ? teamParams.members.list('id').collect { it.toLong() } : []
                def scrumMasters = teamParams.scrumMasters ? teamParams.scrumMasters.list('id').collect { it.toLong() } : []
                def invitedMembers = teamParams.invitedMembers ? teamParams.invitedMembers.list('email') : []
                def invitedScrumMasters = teamParams.invitedScrumMasters ? teamParams.invitedScrumMasters.list('email') : []
                if (!scrumMasters && !members) {
                    returnError(code: 'is.project.error.noMember')
                    return
                }
                entry.hook(id: 'project-team-save-before')
                teamService.save(team, members, scrumMasters)
                projectService.manageTeamInvitations(team, invitedMembers, invitedScrumMasters)
            } else {
                team = Team.withTeam(teamParams.long('id'))
            }
            def productOwners = projectParams.productOwners ? projectParams.productOwners.list('id').collect { it.toLong() } : []
            def stakeHolders = projectParams.stakeHolders ? projectParams.stakeHolders.list('id').collect { it.toLong() } : []
            def invitedProductOwners = projectParams.invitedProductOwners ? projectParams.invitedProductOwners.list('email') : []
            def invitedStakeHolders = projectParams.invitedStakeHolders ? projectParams.invitedStakeHolders.list('email') : []
            projectService.save(project, productOwners, stakeHolders)
            projectService.manageProjectInvitations(project, invitedProductOwners, invitedStakeHolders)
            projectService.addTeamToProject(project, team)
            if (projectParams.initialize) {
                def release = new Release(name: "Release 1", vision: projectParams.vision, startDate: project.startDate, endDate: project.endDate)
                releaseService.save(release, project)
                sprintService.generateSprints(release, projectParams.firstSprint)
            }
        }
        flash.showAppStore = true
        render(status: 201, contentType: 'application/json', text: project as JSON)
    }

    @Secured('scrumMaster() and !archivedProject()')
    def update(long project) {
        Project _project = Project.withProject(project)
        def projectPreferencesParams = params.projectd?.remove('preferences')
        def projectParams = params.projectd
        Project.withTransaction {
            projectParams.startDate = ServicesUtils.parseDateISO8601(projectParams.startDate);
            bindData(_project, projectParams, [include: ['name', 'description', 'startDate', 'pkey', 'planningPokerGameType']])
            bindData(_project.preferences, projectPreferencesParams, [exclude: ['archived']])
            if (!projectPreferencesParams?.stakeHolderRestrictedViews) {
                _project.preferences.stakeHolderRestrictedViews = null
            }
            projectService.update(_project, _project.preferences.isDirty('hidden'), _project.isDirty('pkey') ? _project.getPersistentValue('pkey') : null)
            entry.hook(id: "project-update", model: [project: _project])
            render(status: 200, contentType: 'application/json', text: _project as JSON)
        }
    }

    @Secured(['owner()'])
    def delete(long project) {
        try {
            Project _project = Project.withProject(project)
            projectService.delete(_project)
            render(status: 200, contentType: 'application/json', text: [class: 'Project', id: project] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.project.error.not.deleted', exception: re)
        }
    }

    @Secured(['scrumMaster() and !archivedProject()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def updateTeam(long project) {
        // Param extraction
        def teamParams = params.projectd?.remove('team')
        def projectParams = params.remove('projectd')
        def productOwners = projectParams.productOwners ? projectParams.productOwners.list('id').collect { it.toLong() } : []
        def stakeHolders = projectParams.stakeHolders ? projectParams.stakeHolders.list('id').collect { it.toLong() } : []
        def invitedProductOwners = projectParams.invitedProductOwners ? projectParams.invitedProductOwners.list('email') : []
        def invitedStakeHolders = projectParams.invitedStakeHolders ? projectParams.invitedStakeHolders.list('email') : []
        assert !stakeHolders.intersect(productOwners)
        // Compute roles
        def newMembers = []
        productOwners.each { newMembers << [id: it, role: Authority.PRODUCTOWNER] }
        stakeHolders.each { newMembers << [id: it, role: Authority.STAKEHOLDER] }
        // Update project & team
        Project _project = Project.withProject(project)
        _project.withTransaction {
            def teamId = teamParams.id
            //workaround but TODO fix UI => teamID can't be null
            if (teamId != null && teamId != _project.team.id && securityService.owner(null, springSecurityService.authentication)) {
                projectService.changeTeam(_project, Team.get(teamId))
            }
            projectService.updateProjectMembers(_project, newMembers)
            projectService.manageProjectInvitations(_project, invitedProductOwners, invitedStakeHolders)
        }
        render(status: 200, contentType: 'application/json', text: _project as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def feed(long project) {
        //todo make cache
        Project _project = Project.withProject(project)
        def activities = Activity.recentProjectActivity(_project)
        activities.addAll(Activity.recentStoryActivity(_project))
        activities = activities.sort { a, b -> b.dateCreated <=> a.dateCreated }
        def builder = new FeedBuilder()
        builder.feed(description: "${_project.description ?: ''}", title: "$_project.name ${message(code: 'todo.is.ui.history')}", link: "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [project: _project.pkey])}") {
            activities.each() { a ->
                entry("${a.poster.firstName} ${a.poster.lastName} ${message(code: "is.fluxiable.${a.code}")} ${message(code: "is." + (a.code == 'taskDelete' ? 'task' : a.code == 'acceptanceTestDelete' ? 'acceptanceTest' : 'story'))} ${a.label.encodeAsHTML()}") { e ->
                    if (a.code == Activity.CODE_DELETE) {
                        e.link = "${createLink(absolute: true, controller: 'scrumOS', action: 'index', params: [project: _project.pkey])}"
                    } else {
                        e.link = "${createLink(absolute: true, uri: '/' + _project.pkey + '-' + Story.get(a.parentRef).uid)}"
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
    def available(long project, String property) {
        def result = false
        if (property == 'pkey') {
            result = request.JSON.value && request.JSON.value =~ /^[A-Z0-9]*$/ && (project ? Project.countByPkeyAndId(request.JSON.value, project) : Project.countByPkey(request.JSON.value)) == 0
        }
        render(status: 200, text: [isValid: result, value: request.JSON.value] as JSON, contentType: 'application/json')
    }

    @Secured(['scrumMaster() or productOwner()'])
    def export(long project, String format) {
        Project _project = Project.withProject(project)
        session.progress = new ProgressSupport()
        if (format == 'zip') {
            def projectName = "${_project.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}"
            ['Content-disposition': "attachment;filename=\"${projectName + '.zip'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
                response.setHeader(k, v)
            }
            response.contentType = 'application/zip'
            ApplicationSupport.exportProjectZIP(_project, response.outputStream)
        } else {
            render(text: exportProjectXML(_project), contentType: "text/xml")
        }
        session.progress.completeProgress(message(code: 'todo.is.ui.progress.complete'))
    }

    @Secured('scrumMaster()')
    def archive(long project) {
        Project _project = Project.withProject(project)
        try {
            projectService.archive(_project)
            render(status: 200, contentType: 'application/json', text: [class: 'Project', id: _project.id] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.project.error.not.archived', exception: re)
        }
    }

    @Secured("ROLE_ADMIN")
    def unArchive(long project) {
        Project _project = Project.withProject(project)
        try {
            projectService.unArchive(_project)
            render(status: 200, contentType: 'application/json', text: [class: 'Project', id: _project.id] as JSON)
        } catch (RuntimeException re) {
            returnError(code: 'is.project.error.not.archived', exception: re)
        }
    }

    @Secured(['stakeHolder() or inProject()'])
    def versions(long project) {
        Project _project = Project.withProject(project)
        render(_project.getVersions(false, true) as JSON)
    }

    // Cannot end with Flow because of f*cked up filter in SpringSecurity (AnnotationFilterInvocationDefinition.java:256)
    def flowCumulative(long project) {
        Project _project = Project.withProject(project)
        def values = projectService.cumulativeFlowValues(_project)
        def computedValues = [[key   : message(code: "is.chart.projectCumulativeflow.serie.suggested.name"),
                               values: values.collect { return [it.suggested] },
                               color : '#AAAAAA'],
                              [key   : message(code: "is.chart.projectCumulativeflow.serie.accepted.name"),
                               values: values.collect { return [it.accepted] },
                               color : '#FFCC04'],
                              [key   : message(code: "is.chart.projectCumulativeflow.serie.estimated.name"),
                               values: values.collect { return [it.estimated] },
                               color : '#FF9933'],
                              [key   : message(code: "is.chart.projectCumulativeflow.serie.planned.name"),
                               values: values.collect { return [it.planned] },
                               color : '#CC3300'],
                              [key   : message(code: "is.chart.projectCumulativeflow.serie.inprogress.name"),
                               values: values.collect { return [it.inprogress] },
                               color : '#42A9E0'],
                              [key   : message(code: "is.chart.projectCumulativeflow.serie.done.name"),
                               values: values.collect { return [it.done] },
                               color : '#009900']].reverse()
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.projectCumulativeflow.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.projectCumulativeflow.xaxis.label')]],
                       title: [text: message(code: "is.chart.projectCumulativeflow.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def velocityCapacity(long project) {
        Project _project = Project.withProject(project)
        def values = projectService.projectVelocityCapacityValues(_project)
        def computedValues = [[key   : message(code: "is.chart.projectVelocityCapacity.serie.velocity.name"),
                               values: values.collect { return [it.velocity] },
                               color : '#009900'],
                              [key   : message(code: "is.chart.projectVelocityCapacity.serie.capacity.name"),
                               values: values.collect { return [it.capacity] },
                               color : '#1C3660']]
        def options = [chart: [yDomain: [0, values.collect { [it.velocity, it.capacity].max() }.max()],
                               yAxis  : [axisLabel: message(code: 'is.chart.projectVelocityCapacity.yaxis.label')],
                               xAxis  : [axisLabel: message(code: 'is.chart.projectVelocityCapacity.xaxis.label')]],
                       title: [text: message(code: "is.chart.projectVelocityCapacity.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    @Secured('stakeHolder(#project) or inProject(#project)')
    def burnup(long project) {
        Project _project = Project.withProject(project)
        def values = projectService.projectBurnupValues(_project)
        def computedValues = [[key   : message(code: "is.chart.projectBurnUp.serie.all.name"),
                               values: values.collect { return [it.all] },
                               color : '#1C3660'],
                              [key   : message(code: "is.chart.projectBurnUp.serie.done.name"),
                               values: values.collect { return [it.done] },
                               color : '#009900']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.projectBurnUp.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.projectBurnUp.xaxis.label')]],
                       title: [text: message(code: "is.chart.projectBurnUp.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def burndown(long project) {
        Project _project = Project.withProject(project)
        def values = projectService.projectBurndownValues(_project)
        def computedValues = [[key   : message(code: 'is.chart.projectBurnDown.series.userstories.name'),
                               values: values.collect { return [it.userstories] },
                               color : '#009900'],
                              [key   : message(code: 'is.chart.projectBurnDown.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories] },
                               color : '#1F77B4'],
                              [key   : message(code: 'is.chart.projectBurnDown.series.defectstories.name'),
                               values: values.collect { return [it.defectstories] },
                               color : '#CC3300']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.projectBurnDown.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.projectBurnDown.xaxis.label')]],
                       title: [text: message(code: "is.chart.projectBurnDown.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def velocity(long project) {
        Project _project = Project.withProject(project)
        def values = projectService.projectVelocityValues(_project)
        def computedValues = [[key   : message(code: 'is.chart.projectVelocity.series.userstories.name'),
                               values: values.collect { return [it.userstories] },
                               color : '#009900'],
                              [key   : message(code: 'is.chart.projectVelocity.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories] },
                               color : '#1F77B4'],
                              [key   : message(code: 'is.chart.projectVelocity.series.defectstories.name'),
                               values: values.collect { return [it.defectstories] },
                               color : '#CC3300']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.projectVelocity.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.projectVelocity.xaxis.label')]],
                       title: [text: message(code: "is.chart.projectVelocity.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    def parkingLot(long project) {
        Project _project = Project.withProject(project)
        def values = featureService.projectParkingLotValues(_project)
        def colors = values.collect { return it.color }
        def computedValues = [[key   : message(code: "is.chart.projectParkinglot.serie.name"),
                               values: values.collect { return [it.label, it.value] }]]
        def options = [chart: [yDomain : [0, 100],
                               yAxis   : [axisLabel: message(code: 'is.chart.projectParkinglot.xaxis.label')],
                               barColor: colors],
                       title: [text: message(code: "is.chart.projectParkinglot.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured('isAuthenticated()')
    def "import"() {
        try {
            if (params.flowFilename) {
                session.progress = new ProgressSupport()
                session.import = [
                        save         : true,
                        path         : null,
                        changes      : null,
                        validate     : true,
                        changesNeeded: null
                ]
                def endOfUpload = { uploadInfo ->
                    session.import.uploadInfo = uploadInfo
                    File uploadedProject = new File(uploadInfo.filePath)
                    if (FilenameUtils.getExtension(uploadedProject.name) == 'xml') {
                        log.debug 'Export is an xml file, processing now'
                        session.import.file = uploadedProject
                        session.import.path = uploadedProject.absolutePath
                    } else if (FilenameUtils.getExtension(uploadedProject.name) == 'zip') {
                        log.debug 'Export is a zipped file, unzipping now'
                        def tmpDir = ApplicationSupport.createTempDir(FilenameUtils.getBaseName(uploadedProject.name))
                        ApplicationSupport.unzip(uploadedProject, tmpDir)
                        session.import.file = tmpDir.listFiles().find {
                            !it.isDirectory() && FilenameUtils.getExtension(it.name) == 'xml'
                        }
                        session.import.path = tmpDir.absolutePath
                    } else {
                        render(status: 400)
                        return
                    }
                    def project = projectService.importXML(session.import.file, session.import)
                    render(status: 200, contentType: 'application/json', text: (project ?: session.import.changesNeeded) as JSON)
                    //after render to be more smoothy
                    if (project) {
                        FileUploadInfoStorage.instance.remove(session.import.uploadInfo)
                        session.import = null
                    }
                }
                UtilsWebComponents.handleUpload.delegate = this
                UtilsWebComponents.handleUpload(request, params, endOfUpload, false)
            } else if (params.changes) {
                session.progress = new ProgressSupport()
                session.import.changes = params.changes
                def project = projectService.importXML(session.import.file, session.import)
                render(status: 200, contentType: 'application/json', text: (project ?: session.import.changesNeeded) as JSON)
                //after render to be more smoothy
                if (project) {
                    FileUploadInfoStorage.instance.remove(session.import.uploadInfo)
                    session.import = null
                }
            }
        } catch (ValidationException e) {
            e.printStackTrace()
            throw e
        }
    }

    private String exportProjectXML(Project project) {
        def writer = new StringWriter()
        projectService.export(writer, project)
        def projectName = "${project.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")}-${new Date().format('yyyy-MM-dd')}"
        ['Content-disposition': "attachment;filename=\"${projectName + '.xml'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
            response.setHeader(k, v)
        }
        response.contentType = 'application/octet'
        return writer.toString()
    }

    @Secured(['permitAll()'])
    def listPublic(String term, Boolean paginate, Integer page, Integer count) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def publicProjects = Project.where { preferences.hidden == false && name =~ searchTerm }.list(sort: "name")
        def userProjects = springSecurityService.currentUser ? Project.findAllByUserAndActive(springSecurityService.currentUser, null, null) : []
        def projects = publicProjects - userProjects
        if (paginate && !count) {
            count = 10
        }
        def returnData = paginate ? [projects: projects.drop(page ? (page - 1) * count : 0).take(count), count: projects.size()] : projects
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['permitAll()'])
    def listPublicWidget() {
        def publicProjects = Project.where { preferences.hidden == false }.list(sort: 'dateCreated', order: 'desc', max: 9) // TODO better sort
        request.marshaller = [
                project: [
                        include: ['currentOrNextRelease'],
                        withIds: ['backlogs']
                ]
        ]
        render(status: 200, contentType: 'application/json', text: publicProjects as JSON)
    }

    @Secured(['isAuthenticated()'])
    def listByUser(long id, String term, Boolean paginate, Integer page, Integer count) {
        if (id && id != springSecurityService.principal.id && !request.admin) {
            render(status: 403)
            return
        }
        User user = id ? User.get(id) : springSecurityService.currentUser
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def projects = projectService.getAllActiveProjectsByUser(user, searchTerm)
        if (paginate && !count) {
            count = 10
        }
        def returnedProjects = !count ? projects : projects.drop(page ? (page - 1) * count : 0).take(count)
        def light = params.light != null ? params.remove('light') : false
        if (light && light != "false") {
            lightProjectMarshaller(light)
        }
        def returnData = paginate ? [projects: returnedProjects, count: projects.size()] : returnedProjects
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['businessOwner() or portfolioStakeHolder()'])
    def listByPortfolio(long portfolio) {
        Portfolio _portfolio = Portfolio.withPortfolio(portfolio)
        render(status: 200, contentType: 'application/json', text: _portfolio.projects as JSON)
    }

    @Secured(['isAuthenticated()'])
    def listByUserAndRole(long id, String term, Boolean paginate, Integer page, Integer count, String role, Boolean create, Boolean owner) {
        if (id && id != springSecurityService.principal.id && !request.admin) {
            render(status: 403)
            return
        }
        if (!id) {
            id = springSecurityService.currentUser.id
        }
        def light = params.light != null ? params.remove('light') : false
        def permissions = [
                'productOwner': SecurityService.productOwnerPermissions,
                'scrumMaster' : SecurityService.scrumMasterPermissions,
                'teamMember'  : SecurityService.teamMemberPermissions,
                'stakeHolder' : SecurityService.stakeHolderPermissions
        ]
        def projects = listByRole(id, term, paginate, page, count, light, permissions[role], owner)
        if (create && !projects.any { it.name == term } && !Project.countByName(term)) {
            projects.add(0, [name: params.term, pkey: ''])
        }
        render(status: 200, contentType: 'application/json', text: projects as JSON)
    }

    @Secured(['stakeHolder() or inProject()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def leaveTeam(long project) {
        Project _project = Project.withProject(project)
        _project.withTransaction {
            def oldMembersByProject = [:]
            _project.team.projects.each { Project teamProject ->
                oldMembersByProject[teamProject.id] = projectService.getAllMembersProjectByRole(teamProject)
            }
            projectService.removeAllRoles(_project.team, springSecurityService.currentUser)
            oldMembersByProject.each { Long projectId, Map oldMembers ->
                projectService.manageProjectEvents(Project.get(projectId), oldMembers)
            }
        }
        render(status: 200)
    }

    @Secured(['stakeHolder() or inProject()'])
    def activities(long project) {
        Project _project = Project.withProject(project)
        def activities = Activity.recentStoryActivity(_project)
        activities.addAll(Activity.recentProjectActivity(_project))
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

    @Secured(['isAuthenticated()'])
    def add() {
        render(status: 200, template: "dialogs/new")
    }

    @Secured(['isAuthenticated()'])
    def importDialog() {
        render(status: 200, template: "dialogs/import")
    }

    @Secured(['scrumMaster() or productOwner()'])
    def exportDialog() {
        render(status: 200, template: "dialogs/export")
    }

    @Secured(['isAuthenticated()'])
    def createSample(Boolean hidden) {
        if (hidden == null) {
            hidden = true
        }
        if (!grailsApplication.config.icescrum.project.private.enable && hidden) {
            hidden = false
        }
        try {
            dummyService.createSampleProject(springSecurityService.currentUser, hidden);
        } catch (ValidationException e) {
            e.printStackTrace()
            throw e
        }
        render(status: 200);
    }

    private listByRole(long id, String term, Boolean paginate, Integer page, Integer count, def light, def role, Boolean owner = false) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def projects = Project.findAllByRole(User.get(id), role, [cache: true], false, false, owner, searchTerm).toList()
        if (paginate && !count) {
            count = 10
        }
        def returnedProjects = !count ? projects : projects.drop(page ? (page - 1) * count : 0).take(count)
        if (light && light != "false") {
            lightProjectMarshaller(light)
        }
        return paginate ? [projects: returnedProjects, count: projects.size()] : returnedProjects
    }

    private void lightProjectMarshaller(def options) {
        request.marshaller = [
                project  : [excludeAll: true, overrideInclude: true, include: ['pkey', 'name', 'portfolio']],
                portfolio: [excludeAll: true, overrideInclude: true,]
        ]
        if (options != true && options != "true") {
            request.marshaller.project.include.addAll(options.tokenize(','))
        }
    }
}