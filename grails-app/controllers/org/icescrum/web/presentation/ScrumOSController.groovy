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

package org.icescrum.web.presentation

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Portfolio
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.ProjectPreferences
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.ui.WindowDefinition
import org.icescrum.core.utils.ServicesUtils
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import sun.misc.BASE64Decoder

class ScrumOSController implements ControllerErrorHandler {

    def messageSource
    def servletContext
    def projectService
    def portfolioService
    def securityService
    def grailsApplication
    def uiDefinitionService
    def springSecurityService

    def index() {
        def user = springSecurityService.currentUser
        def workspaces = []
        def portfolioEnabled = grailsApplication.config.icescrum.workspaces.portfolio && grailsApplication.config.icescrum.workspaces.portfolio.enabled(grailsApplication)
        if (portfolioEnabled) {
            def userPortfolios = user ? portfolioService.getAllPortfoliosByUser(user) : []
            workspaces.addAll(userPortfolios)
        }
        def userProjects = user ? projectService.getAllActiveProjectsByUser(user) : []
        workspaces.addAll(userProjects)
        def workspacesLimit = 9
        def browsableProjectsCount = request.admin ? Project.count() : ProjectPreferences.countByHidden(false, [cache: true])
        def model = [user                    : user,
                     lang                    : RCU.getLocale(request).toString().take(2),
                     browsableWorkspacesExist: browsableProjectsCount > 0,
                     moreWorkspacesExist     : workspaces?.size() > workspacesLimit,
                     portfolioEnabled        : portfolioEnabled,
                     workspacesFilteredsList : workspaces.take(workspacesLimit)]
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        if (workspace) {
            workspace.indexScrumOS.delegate = this
            def carryOn = workspace.indexScrumOS(workspace, user, securityService, springSecurityService) && workspace.enabled
            if (!carryOn) {
                forward(action: springSecurityService.isLoggedIn() ? 'error403' : 'error401', controller: 'errors')
                return
            }
            model."$workspace.name" = workspace.object
            model.workspace = workspace
        }
        render(status: 200, view: 'index', model: model)
    }

    def about() {
        def aboutFile = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about.xml")
        render(status: 200, template: "about/index", model: [server        : servletContext.getServerInfo(),
                                                             versionNumber : g.meta([name: 'app.version']),
                                                             maxMemory     : ApplicationSupport.getJavaMaxMemory(),
                                                             serverUrl     : ApplicationSupport.serverURL(),
                                                             about         : new XmlSlurper().parse(aboutFile),
                                                             configLocation: grailsApplication.config.grails.config.locations instanceof List ? grailsApplication.config.grails.config.locations.join(', ') : ''])
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def connections() {
        render(status: 200, contentType: 'application/json', text: [maxUsers          : grailsApplication.config.icescrum.atmosphere.maxUsers,
                                                                    liveUsers         : grailsApplication.config.icescrum.atmosphere.liveUsers,
                                                                    maxUsersDate      : grailsApplication.config.icescrum.atmosphere.maxUsersDate,
                                                                    maxConnections    : grailsApplication.config.icescrum.atmosphere.maxConnections,
                                                                    maxConnectionsDate: grailsApplication.config.icescrum.atmosphere.maxConnectionsDate,
                                                                    liveConnections   : grailsApplication.config.icescrum.atmosphere.liveConnections] as JSON)
    }

    def textileParser(String data) {
        render(text: ServicesUtils.textileToHtml(data))
    }

    def isSettings() {
        List projectMenus = []
        List menus = []
        Map workspace = ApplicationSupport.getCurrentWorkspace(params) // The workspace id must be in the params
        uiDefinitionService.getWindowDefinitions().each { String windowDefinitionId, WindowDefinition windowDefinition ->
            def menu = windowDefinition.menu
            if (menu) {
                if (ApplicationSupport.isAllowed(windowDefinition, params)) {
                    def menuPositions = ApplicationSupport.menuPositionFromUserPreferences(windowDefinition) ?: [visible: menu.defaultVisibility, pos: menu.defaultPosition]
                    menus << [title   : message(code: menu.title instanceof Closure ? menu.getTitle()(workspace?.object) : menu.title),
                              id      : windowDefinitionId,
                              icon    : windowDefinition.icon,
                              position: menuPositions.pos.toInteger(),
                              visible : menuPositions.visible]
                    menus.sort { it.position }.eachWithIndex { menuEntry, index ->
                        menuEntry.shortcut = 'ctrl+' + (index + 1)
                    }
                }
                if (windowDefinition.workspace == 'project' && windowDefinition.id != 'project') {
                    projectMenus << [id: windowDefinitionId, title: message(code: menu.title)]
                }
            }
        }
        render(status: 200, template: 'isSettings', model: [workspace      : workspace?.object,
                                                            user           : springSecurityService.currentUser,
                                                            roles          : securityService.getRolesRequest(false),
                                                            i18nMessages   : messageSource.getAllMessages(RCU.getLocale(request)),
                                                            resourceBundles: grailsApplication.config.icescrum.resourceBundles,
                                                            menus          : menus,
                                                            defaultView    : workspace ? menus.sort { it.position }[0]?.id : 'home',
                                                            serverURL      : ApplicationSupport.serverURL(),
                                                            projectMenus   : projectMenus])
    }

    def saveImage(String image, String title) {
        if (!image) {
            render(status: 404)
            return
        }
        title = URLDecoder.decode(title, 'UTF-8')
        image = URLDecoder.decode(image, 'UTF-8')
        image = image.substring(image.indexOf("base64,") + "base64,".length(), image.length())
        response.contentType = 'image/png'
        if (!params.view) {
            ['Content-disposition': "attachment;filename=\"${title + '.png'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
                response.setHeader(k, v)
            }
        }
        response.outputStream << new BASE64Decoder().decodeBuffer(image)
    }

    def version() {
        render(status: '200', text: g.meta([name: 'app.version']))
    }

    def progress() {
        if (session.progress) {
            render(status: 200, contentType: "application/json", text: session.progress as JSON)
            //we already sent the error so reset progress
            if (session.progress.error || session.progress.complete) {
                session.progress = null
            }
        } else {
            render(status: 404)
        }
    }

    def languages() {
        // TODO re-enable real locale management
        //def i18n
        //if (grailsApplication.warDeployed) {
        //    i18n = grailsAttributes.getApplicationContext().getResource("WEB-INF/grails-app/i18n/").getFile().toString()
        //} else {
        //    i18n = "$BuildSettingsHolder.settings.baseDir/grails-app/i18n"
        //}
        //new File(i18n).eachFile {
        //    def arr = it.name.split("[_.]")
        //    if (arr[1] != 'svn' && arr[1] != 'properties' && arr[0].startsWith('messages')) {
        //        locales << (arr.length > 3 ? new Locale(arr[1], arr[2]) : arr.length > 2 ? new Locale(arr[1]) : new Locale(""))
        //    }
        //}
        // End TODO
        Map locales = [['en'], ['en', 'US'], ['fr'], ['es'], ['zh'], ['pt'], ['pt', 'BR']].collect { list ->
            return list.size() == 2 ? new Locale(list[0], list[1]) : new Locale(list[0])
        }.collectEntries { locale ->
            [(locale.toString()): locale.getDisplayName(locale).capitalize()]
        }
        render(status: 200, contentType: 'application/json', text: locales as JSON)
    }

    def timezones() {
        def timezones = TimeZone.availableIDs.sort().findAll {
            it.matches("^(Africa|America|Asia|Atlantic|Australia|Europe|Indian|Pacific)/.*")
        }.collectEntries {
            TimeZone timeZone = TimeZone.getTimeZone(it)
            def offset = timeZone.rawOffset
            def offsetSign = offset < 0 ? '-' : '+'
            Integer hour = Math.abs(offset / (60 * 60 * 1000))
            Integer min = Math.abs(offset / (60 * 1000)) % 60
            def calendar = Calendar.instance
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, min)
            return [(it): "$timeZone.ID (UTC$offsetSign${String.format('%tR', calendar)})"]
        }
        render(status: 200, contentType: 'application/json', text: timezones as JSON)
    }

    @Secured(['isAuthenticated()'])
    def add() {
        render(status: 200, template: "dialogs/new")
    }

    @Secured(['permitAll()'])
    def warnings() {
        def warnings = grailsApplication.config.icescrum.warnings.collect { it ->
            [id: it.id, icon: it.icon, title: message(it.title), message: message(it.message), hideable: it.hideable, silent: it.silent]
        }
        render(status: 200, contentType: 'application/json', text: warnings as JSON)
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def hideWarning(String warningId) {
        render(status: 200, contentType: 'application/json', text: ApplicationSupport.toggleSilentWarning(warningId) as JSON)
    }

    @Secured(['permitAll()'])
    def robots() {
        render(status: 200, contentType: 'text/plain', text: 'User-agent: *\nDisallow: /')
    }

    @Secured(['permitAll()'])
    def browserconfig() {
        def content = """<?xml version="1.0" encoding="utf-8"?>
        <browserconfig>
            <msapplication>
                <tile>
                    <square150x150logo src="${assetPath(src: "browser/mstile-150x150.png")}"/>
                    <TileColor>#da532c</TileColor>
                </tile>
            </msapplication>
        </browserconfig>
        """
        render(status: 200, contentType: 'text/xml', text: content)
    }

    @Secured(['permitAll()'])
    def listModal() {
        render(status: 200, template: "dialogs/list")
    }

    @Secured(['isAuthenticated()'])
    def workspacesListByUser(long id, String term, Boolean paginate, Integer page, Integer count, String workspaceType) {
        if (id && id != springSecurityService.principal.id && !request.admin) {
            render(status: 403)
            return
        }
        User user = id ? User.get(id) : springSecurityService.currentUser
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def workspaces = []
        if (!workspaceType || workspaceType == 'portfolio') {
            workspaces.addAll(portfolioService.getAllPortfoliosByUser(user, searchTerm))
        }
        if (!workspaceType || workspaceType == 'project') {
            workspaces.addAll(projectService.getAllActiveProjectsByUser(user, searchTerm))
        }
        if (paginate && !count) {
            count = 10
        }
        def projects, portfolios = []
        def returnedWorkspaces = !count ? workspaces : workspaces.drop(page ? (page - 1) * count : 0).take(count)
        def light = params.light != null ? params.remove('light') : false
        if (light && light != "false") {
            def properties = light == "true" || light instanceof Boolean ? null : light.tokenize(',')
            returnedWorkspaces = returnedWorkspaces.each {
                if (it instanceof Project) {
                    def p = [id: it.id, pkey: it.pkey, name: it.name, portfolio: it.portfolio ? [id: it.portfolio.id] : null]
                    properties?.each { property ->
                        if (it.hasProperty(property)) {
                            p."$property" = it."$property"
                        }
                    }
                    projects << p

                } else {
                    def p = [id: it.id, fkey: it.fkey, name: it.name]
                    properties?.each { property ->
                        if (it.hasProperty(property)) {
                            p."$property" = it."$property"
                        }
                    }
                    portfolios << p
                }
            }
        } else {
            projects = returnedWorkspaces.findAll { it instanceof Project }
            portfolios = returnedWorkspaces.findAll { it instanceof Portfolio }
        }
        def returnData = paginate ? [projects: projects, portfolios: portfolios, count: workspaces.size()] : [projects: projects, portfolios: portfolios]
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }
}
