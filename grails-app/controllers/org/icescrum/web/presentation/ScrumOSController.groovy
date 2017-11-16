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
import org.icescrum.core.domain.Project
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
    def securityService
    def grailsApplication
    def uiDefinitionService
    def springSecurityService

    def index() {
        def user = springSecurityService.currentUser
        def userProjects = user ? projectService.getAllActiveProjectsByUser(user) : []
        def projectsLimit = 9
        def browsableProjectsCount = request.admin ? Project.count() : ProjectPreferences.countByHidden(false, [cache: true])
        def model = [user                  : user,
                     lang                  : RCU.getLocale(request).toString().substring(0, 2),
                     browsableProjectsExist: browsableProjectsCount > 0,
                     moreProjectsExist     : userProjects?.size() > projectsLimit,
                     projectFilteredsList  : userProjects.take(projectsLimit)]
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        if (workspace) {
            workspace.indexScrumOS.delegate = this
            workspace.indexScrumOS(workspace, user, securityService, springSecurityService)
            model."$workspace.name" = workspace.object
        }
        render(status: 200, view: 'index', model: model)
    }

    def about() {
        def aboutFile = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about.xml")
        render(status: 200, template: "about/index", model: [server        : servletContext.getServerInfo(),
                                                             versionNumber : g.meta([name: 'app.version']),
                                                             about         : new XmlSlurper().parse(aboutFile),
                                                             configLocation: grailsApplication.config.grails.config.locations instanceof List ? grailsApplication.config.grails.config.locations.join(', ') : ''])
    }

    def textileParser(String data) {
        render(text: ServicesUtils.textileToHtml(data))
    }

    def isSettings(Long project) {
        List projectMenus = []
        List menus = []
        Map workspace = ApplicationSupport.getCurrentWorkspace(params)
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
                if (windowDefinition.workspace == 'project') {
                    projectMenus << [id: windowDefinitionId, title: windowDefinition.id == 'project' ? message(code: 'is.ui.project') : message(code: menu.title)]
                }
            }
        }
        render(status: 200, template: 'isSettings', model: [project        : project ? Project.get(project) : null,
                                                            user           : springSecurityService.currentUser,
                                                            roles          : securityService.getRolesRequest(false),
                                                            i18nMessages   : messageSource.getAllMessages(RCU.getLocale(request)),
                                                            resourceBundles: grailsApplication.config.icescrum.resourceBundles,
                                                            menus          : menus,
                                                            workspace      : workspace?.name ?: '',
                                                            defaultView    : workspace ? menus.sort { it.position }[0]?.id : 'home',
                                                            serverURL      : ApplicationSupport.serverURL(),
                                                            projectMenus   : projectMenus])
    }

    def saveImage(String image, String title) {
        if (!image) {
            render(status: 404)
            return
        }
        title = URLDecoder.decode(title)
        image = URLDecoder.decode(image)
        image = image.substring(image.indexOf("base64,") + "base64,".length(), image.length())
        response.contentType = 'image/png'
        ['Content-disposition': "attachment;filename=\"${title + '.png'}\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
            response.setHeader(k, v)
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
}
