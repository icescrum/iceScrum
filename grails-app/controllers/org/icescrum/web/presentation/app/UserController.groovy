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
import grails.plugin.springcache.annotations.CacheFlush

class UserController {

    static final id = 'user'
    static ui = true

    def userService
    def securityService
    def springSecurityService
    def grailsApplication
    def notificationEmailService

    static window = [title: 'is.user', toolbar: false, init: 'profile']

    @Cacheable(cache = 'applicationCache', keyGenerator="localeKeyGenerator")
    def register = {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
            render(status: 403)
            return
        }
        def localeAccept = request.getHeader("accept-language")?.split(",")[0]?.split("-")
        def locale = params.lang ?: null
        if (localeAccept?.size() > 0) {
            locale = params.lang ?: localeAccept[0].toString()
        }
        if (locale)
            RCU.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
        render(template: 'window/register', model: [user: new User()])
    }


    @Secured('isAuthenticated()')
    @Cacheable(cache = 'profileCache', cacheResolver = 'userCacheResolver')
    def openProfile = {
        render(template: 'dialogs/profile', model: [user: User.get(springSecurityService.principal.id)], id: id)
    }


    def save = {
        if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
            render(status: 403)
            return
        }
        if (params.confirmPassword || params.password) {
            if (params.confirmPassword != params.password) {
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.user.error.password.check')]] as JSON)
                return
            }
        }

        def user = new User()
        user.preferences = new UserPreferences()
        user.properties = params
        def msg
        try {
            userService.save(user)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
            return
        } catch (RuntimeException re) {
            if (log.debugEnabled) re.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: user)]] as JSON)
            return
        }
        render(status: 200, contentType: 'application/json', text: [lang: user.preferences.language, username: user.username] as JSON)
    }

    @Secured('isAuthenticated()')
    @CacheFlush(caches = 'profileCache', cacheResolver = 'userCacheResolver')
    def update = {
        def msg
        if (params.long('user.id') != springSecurityService.principal.id) {
            msg = message(code: 'is.stale.object', args: [message(code: 'is.user')])
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        if (params.confirmPassword || params.user.password) {
            if (params.confirmPassword != params.user.password) {
                msg = message(code: 'is.user.error.password.check')
                render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
                return
            }
        }

        def currentUser = User.get(springSecurityService.principal.id)

        if (params.long('user.version') != currentUser.version) {
            msg = message(code: 'is.stale.object', args: [message(code: 'is.user')])
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def pwd = null
        if (params.user.password.trim() != '')
            pwd = params.user.password
        else
            params.user.password = currentUser.password

        def gravatar = grailsApplication.config.icescrum.gravatar

        File avatar = null
        def scale = true
        if (!gravatar){
            if (params.avatar) {
                "${params.avatar}"?.split(":")?.each {
                    if (session.uploadedFiles[it[0]])
                        avatar = new File((String) session.uploadedFiles[it[0]])
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

        def forceRefresh = false
        if (params.user.preferences.language != currentUser.preferences.language) {
            forceRefresh = true
        }
        params.remove('user.username')
        currentUser.properties = params.user
        try {
            userService.update(currentUser, pwd, (gravatar ? null : avatar?.canonicalPath), scale)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
            return
        } catch (RuntimeException re) {
            if (log.debugEnabled) re.printStackTrace()
            if (re.getMessage())
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: re.getMessage())]] as JSON)
            else
                render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: currentUser)]] as JSON)
            return
        }
        def link
        if (params.product)
            link = createLink(controller: 'scrumOS', params: [product: params.product])
        else
            link = createLink(uri: '/')

        def name = currentUser.firstName + ' ' + currentUser.lastName

        render(status: 200, contentType: 'application/json',
                text: [name: name.encodeAsHTML().encodeAsJavaScript(),
                        forceRefresh: forceRefresh,
                        refreshLink: link ?: null,
                        updateAvatar: gravatar ?: createLink(action: 'avatar', id: currentUser.id),
                        userid: currentUser.id,
                        notice: forceRefresh ? message(code: "is.user.updated.refreshLanguage") : message(code: "is.user.updated")
                ] as JSON)
        return
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
        def activities = Activity.findAllByPoster(user, [order: 'desc', sort: 'dateCreated', max: 15])
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
            securityService.stakeHolder(pId, currentAuth) || securityService.inProduct(pId, currentAuth)
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
            if (grailsApplication.config.icescrum.gravatar){

            }else{
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
    @CacheFlush(caches = 'userMenuCache', cacheResolver = 'userProjectCacheResolver')
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
}
