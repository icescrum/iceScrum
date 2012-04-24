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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */
package org.icescrum.web.presentation.app

import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import grails.plugin.fluxiable.Activity
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.support.ApplicationSupport
import org.springframework.mail.MailException
import grails.plugin.springcache.annotations.Cacheable

class UserController {

    static final id = 'user'

    def userService
    def securityService
    def springSecurityService
    def productService
    def grailsApplication
    def notificationEmailService

    @Cacheable(cache = 'applicationCache', keyGenerator="localeKeyGenerator")
    def register = {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
            render(status: 403)
            return
        }
        def localeAccept = request.getHeader("accept-language")?.split(",")
        if (localeAccept)
            localeAccept = localeAccept[0]?.split("-")

        def locale = params.lang ?: null
        if (localeAccept?.size() > 0) {
            locale = params.lang ?: localeAccept[0].toString()
        }
        if (locale)
            RCU.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
        render(template: 'window/register', model: [user: new User()])
    }


    @Secured('isAuthenticated()')
    @Cacheable(cache = 'userCache', keyGenerator = 'userKeyGenerator')
    def openProfile = {
        render(template: 'dialogs/profile', model: [user: User.get(springSecurityService.principal.id)], id: id)
    }

    def save = {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
            render(status: 403)
            return
        }
        if ((params.confirmPassword || params.password) && (params.confirmPassword != params.password)) {
            returnError(text: message(code: 'is.user.error.password.check'))
            return
        }
        def user = new User()
        user.preferences = new UserPreferences()
        user.properties = params
        try {
            userService.save(user)
        } catch (IllegalStateException e) {
            returnError(exception: e)
            return
        } catch (RuntimeException e) {
            if(user.errors.hasErrors())
                returnError(object:user, exception:e)
            else
                returnError(exception:e)
            return
        }
        render(status: 200, contentType: 'application/json', text: [lang: user.preferences.language, username: user.username] as JSON)
    }

    @Secured('isAuthenticated()')
    def update = {
        if (params.long('user.id') != springSecurityService.principal.id) {
            returnError(text: message(code: 'is.stale.object', args: [message(code: 'is.user')]))
            return
        }
        withUser('user.id') { User currentUser ->
            if ((params.confirmPassword || params.user.password) && (params.confirmPassword != params.user.password)) {
                returnError(text: message(code: 'is.user.error.password.check'))
                return
            }
            if (params.long('user.version') != currentUser.version) {
                returnError(text: message(code: 'is.stale.object', args: [message(code: 'is.user')]))
                return
            }

            def pwd = null
            if (params.user.password.trim() != '') {
                pwd = params.user.password
            } else {
                params.user.password = currentUser.password
            }

            def gravatar = ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)
            File avatar = null
            def scale = true
            if (!gravatar){
                if (params.avatar) {
                    "${params.avatar}"?.split(":")?.each {
                        if (session.uploadedFiles[it])
                            avatar = new File((String) session.uploadedFiles[it])
                    }
                }
                if (params."avatar-selected") {
                    def file = grailsApplication.parentContext.getResource(is.currentThemeImage().toString() + 'avatars/' + params."avatar-selected").file
                    if (file.exists()) {
                        avatar = file
                        scale = false
                    }
                }
            }

            def forceRefresh = (params.user.preferences.language != currentUser.preferences.language)
            params.remove('user.username')
            currentUser.properties = params.user
            userService.update(currentUser, pwd, (gravatar ? null : avatar?.canonicalPath), scale)

            def link = (params.product) ? createLink(controller: 'scrumOS', params: [product: params.product]) : createLink(uri: '/')
            def name = currentUser.firstName + ' ' + currentUser.lastName

            render(status: 200, contentType: 'application/json',
                    text: [name: name.encodeAsHTML().encodeAsJavaScript(),
                            forceRefresh: forceRefresh,
                            refreshLink: link ?: null,
                            updateAvatar: gravatar ?: createLink(action: 'avatar', id: currentUser.id),
                            userid: currentUser.id,
                            notice: forceRefresh ? message(code: "is.user.updated.refreshLanguage") : message(code: "is.user.updated")
                    ] as JSON)
        }
    }

    def previewAvatar = {
        if (session.uploadedFiles[params.fileID]) {
            def avatar = new File((String) session.uploadedFiles[params.fileID])
            OutputStream out = response.getOutputStream()
            out.write(avatar.bytes)
            out.close()
        } else {
            render(status: 404)
        }
    }


    @Secured('isAuthenticated()')
    def profile = {

        def user = User.findByUsername(params.id)
        if (!user) {
            def jqCode = jq.jquery(null, "\$.icescrum.renderNotice('${message(code: 'is.user.error.not.exist')}','error');");
            render(status: 400, text: jqCode);
            return
        }
        def permalink = createLink(absolute: true, mapping: "profile", id: params.id)
        def stories = Story.findAllByCreator(user, [order: 'desc', sort: 'lastUpdated', max: 150])
        def activities = Activity.findAllByPoster(user, [order: 'desc', sort: 'dateCreated', max: 15, cache:false])
        def tasks = Task.findAllByResponsibleAndState(user, Task.STATE_BUSY, [order: 'desc', sort: 'lastUpdated'])
        def inProgressTasks = tasks.size()

        def currentAuth = springSecurityService.authentication
        def pId
        tasks = tasks.findAll {
            pId = it.backlog.parentRelease.parentProduct.id
            securityService.stakeHolder(pId, currentAuth, false) || securityService.inProduct(pId, currentAuth)
        }

        stories = stories.findAll {
            pId = it.backlog.id
            securityService.stakeHolder(pId, currentAuth, false) || securityService.inProduct(pId, currentAuth)
        }

        //Refactor using SpringSecurity ACL on all domains
        def taskDeletePattern = 'taskDelete'
        def taskPattern = 'task'
        def deletePattern = 'delete'
        activities = activities.findAll {
            if (it.code == taskDeletePattern) {
                pId = Story.get(it.cachedId)?.backlog
            } else if (it.code.startsWith(taskPattern)) {
                pId = Task.get(it.cachedId)?.backlog?.parentRelease?.parentProduct
            } else if (it.code == deletePattern) {
                pId = Product.get(it.cachedId)
            } else {
                pId = Story.get(it.cachedId)?.backlog
            }
            securityService.stakeHolder(pId, currentAuth, false) || securityService.inProduct(pId, currentAuth)
        }


        render template: 'window/profile', model: [permalink: permalink,
                user: user,
                inProgressTasks: inProgressTasks,
                stories: stories,
                activities: activities,
                tasks: tasks
        ]
    }

    @Secured('isAuthenticated()')
    def profileURL = {
        redirect(url: is.createScrumLink(controller: 'user', action: 'profile', id: params.id))
    }

    def avatar = {
        def user = User.load(params.id)
        if (user) {
            if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)){
                def avat = new File(grailsApplication.config.icescrum.images.users.dir.toString() + user.id + '.png')
                if (!avat.exists()) {
                    avat = grailsApplication.parentContext.getResource("/${is.currentThemeImage()}avatars/avatar.png").file
                }
                OutputStream out = response.getOutputStream()
                out.write(avat.bytes)
                out.close()
            }
        }
        render(status: 404)
    }

    @Cacheable(cache = 'applicationCache', keyGenerator="localeKeyGenerator")
    def retrieve = {
        def activated = ApplicationSupport.booleanValue(grailsApplication.config.icescrum.login.retrieve.enable)
        if (!activated) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.login.retrieve.not.activated')]] as JSON)
            return
        }

        if (!params.text) {
            render(template: 'dialogs/retrieve')
            return
        }

        def user = User.findByUsername(params.text)

        if (!user) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.user.not.exist')]] as JSON)
            return
        }
        User.withTransaction { status ->
            try {
                userService.resetPassword(user)
            } catch (MailException e) {
                status.setRollbackOnly()
                if (log.debugEnabled) e.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.mail.error')]] as JSON)
                return
            } catch (RuntimeException re) {
                if (log.debugEnabled) re.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: re.getMessage())]] as JSON)
                return
            } catch (Exception e) {
                status.setRollbackOnly()
                if (log.debugEnabled) e.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.mail.error')]] as JSON)
                return
            }
            render(status: 200, contentType: 'application/json', text: [text: message(code: 'is.dialog.retrieve.success', args: [user.email])] as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def changeMenuOrder = {
        if (!params.id && !params.position) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.user.preferences.error.menuBar')]] as JSON)
            return
        }

        def currentUser = User.get(springSecurityService.principal.id)
        String id = "${params.id}".split("_")[1]
        String position = params.position
        try {
            userService.changeMenuOrder(currentUser, id, position, params.boolean('hidden') ?: false)
            render(status: 200)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.user.preferences.error.menuBar')]] as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def findUsers = {
        def users
        def results = []
        users = org.icescrum.core.domain.User.findUsersLike(params.term ?: '',false).list()
        users?.each {
            results << [id: it.id,
                        name: "$it.firstName $it.lastName",
                        avatar: is.avatar([user:it,link:true]),
                        activity: "${it.preferences.activity ?: ''}"]
        }

        render(results as JSON)
    }

    def displayAvatar = {
        def user = [id:params.id, email:params.email]
        render is.avatar(user:user)
    }
}
