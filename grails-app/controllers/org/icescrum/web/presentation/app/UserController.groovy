/*
 * Copyright (c) 2015 Kagilum SAS
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
package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.filefilter.WildcardFileFilter
import org.apache.commons.validator.GenericValidator
import org.hibernate.ObjectNotFoundException
import org.icescrum.components.FileUploadInfo
import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.Activity
import org.icescrum.core.domain.Invitation
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.ui.UiDefinition
import org.springframework.mail.MailException
import org.springframework.security.acls.domain.BasePermission

class UserController {

    def userService
    def menuBarSupport
    def securityService
    def grailsApplication
    def uiDefinitionService
    def springSecurityService

    @Secured(["hasRole('ROLE_ADMIN')"])
    def index() {
        def users = User.getAll()
        withFormat {
            html { render status: 200, contentType: 'application/json', text: users as JSON }
            json { renderRESTJSON(text: users) }
            xml { renderRESTXML(text: users) }
        }
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def show(long id) {
        User user = User.withUser(id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: user as JSON }
            json { renderRESTJSON(text: user) }
            xml { renderRESTXML(text: user) }
        }
    }

    @Secured(["!isAuthenticated()"])
    def save() {
        if (!params.user) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        if (!request.admin && (params.user.confirmPassword || params.user.password != "") && (params.user.confirmPassword != params.user.password)) {
            returnError(text: message(code: 'is.user.error.password.check'))
            return
        }
        def user = new User()
        try {
            User.withTransaction {
                user.preferences = new UserPreferences()
                bindData(user, this.params, [include: ['username', 'firstName', 'lastName', 'email', 'password']], "user")
                bindData(user.preferences, (Map) this.params.user, [include: ['language', 'filterTask', 'activity']], "preferences")
                userService.save(user, params.user.token)
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: user as JSON }
                json { renderRESTJSON(text: user, status: 201) }
                xml { renderRESTXML(text: user, status: 201) }
            }
        } catch (RuntimeException e) {
            returnError(object: user, exception: e)
        }
    }

    @Secured('isAuthenticated()')
    def update(long id) {
        User user = User.withUser(id)
        // profile is personal
        if ((user.id != springSecurityService.principal.id || request.format in ['json', 'xml']) && !request.admin) {
            render(status: 403)
            return
        }
        Map props = [:]
        if (params.flowIdentifier) {
            User.withTransaction {
                def endOfUpload = { FileUploadInfo uploadInfo ->
                    def uploadedAvatar = new File(uploadInfo.filePath)
                    props.avatar = uploadedAvatar.canonicalPath
                    props.scale = true
                    userService.update(user, props)
                    withFormat {
                        html { render status: 200, contentType: 'application/json', text: user as JSON }
                        json { renderRESTJSON(text: user) }
                        xml { renderRESTXML(text: user) }
                    }
                }
                UtilsWebComponents.handleUpload.delegate = this
                UtilsWebComponents.handleUpload(request, params, endOfUpload)
            }
            return;
        }
        if (!params.user) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        if (!request.admin && (params.user.confirmPassword || params.user.password != "") && (params.user.confirmPassword != params.user.password)) {
            returnError(text: message(code: 'is.user.error.password.check'))
            return
        }
        User.withTransaction {
            if (params.user.password?.trim() != '') {
                props.pwd = params.user.password
            }
            if (params.user.avatar && !(params.user.avatar in ['gravatar', 'custom'])) {
                if (params.user.avatar instanceof String) {
                    params.user.avatar = params.user.avatar.split("/")?.last()
                    props.avatar = getAssetAvatarFile(params.user.avatar)
                    props.scale = false
                } else if (params.user.avatar) {
                    def uploadedAvatar = request.getFile('user.avatar')
                    props.avatar = new File(grailsApplication.config.icescrum.images.users.dir, "${user.id}.${FilenameUtils.getExtension(uploadedAvatar.originalFilename)}")
                    props.scale = true
                    uploadedAvatar.transferTo(props.avatar)
                }
                if (props.avatar) {
                    props.avatar = props.avatar.canonicalPath
                }
            } else if (params.user.avatar == 'gravatar') {
                props.avatar = null
            }
            if (params.user.preferences && params.user.preferences['emailsSettings']) {
                props.emailsSettings = [onStory: params.remove('user.preferences.emailsSettings.onStory'),
                                        autoFollow: params.remove('user.preferences.emailsSettings.autoFollow'),
                                        onUrgentTask: params.remove('user.preferences.emailsSettings.onUrgentTask')]
            }
            bindData(user, params, [include: ['firstName', 'lastName', 'email', 'notes']], "user")
            //preferences using as Map for REST & HTTP support
            if (params.user.preferences) {
                bindData(user.preferences, params.user.preferences as Map, [include: ['language', 'filterTask', 'activity']], "")
            }
            entry.hook(id: "${controllerName}-${actionName}", model: [user: user, props: props])
            userService.update(user, props)
        }
        withFormat {
            html { render status: 200, contentType: 'application/json', text: user as JSON }
            json { renderRESTJSON(text: user) }
            xml { renderRESTXML(text: user) }
        }
    }

    @Secured(['!isAuthenticated()'])
    def register() {
        render(status: 200, template: 'dialogs/register')
    }

    def avatar(long id) {
        def avatar
        User user
        if (id) {
            user = User.withUser(id)
            File[] files = new File(grailsApplication.config.icescrum.images.users.dir.toString()).listFiles((FilenameFilter) new WildcardFileFilter("${user.id}.*"))
            avatar = files ? files[0] : null
        }
        if (!avatar?.exists()) {
            if (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable && user)) {
                redirect url: "https://secure.gravatar.com/avatar/" + user.email.encodeAsMD5()
                return
            }
            avatar = getAssetAvatarFile("avatar.png")
        }
        OutputStream out = response.getOutputStream()
        out.write(avatar.bytes)
        out.close()
    }

    @Secured(['isAuthenticated()'])
    def search(String value, boolean showDisabled, boolean invit) {
        def users = User.findUsersLike(value ?: '', false, showDisabled, [:])
        def enableInvitation = grailsApplication.config.icescrum.registration.enable && grailsApplication.config.icescrum.invitation.enable
        if (!users && invit && GenericValidator.isEmail(value) && enableInvitation) {
            users << Invitation.getUserMock(value)
        }
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: users as JSON) }
            json { renderRESTJSON(text: users) }
            xml { renderRESTXML(text: users) }
        }
    }

    @Secured(['isAuthenticated()'])
    def openProfile() {
        def user = springSecurityService.currentUser
        render(status: 200, template: 'dialogs/profile', model: [user: user, projects: grailsApplication.config.icescrum.alerts.enable ? Product.findAllByRole(user, [BasePermission.WRITE, BasePermission.READ], [cache: true, max: 11], true, false) : null])
    }

    //fake save method to force authentication when using rest service (with admin
    @Secured("hasRole('ROLE_ADMIN')")
    def forceRestSave() {
        forward(action: 'save', params: params)
    }

    @Secured(['permitAll()'])
    def current() {
        def user = [user: springSecurityService.currentUser?.id ? springSecurityService.currentUser : 'null',
                    roles: securityService.getRolesRequest(true)]
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: user as JSON) }
            json { renderRESTJSON(text: user) }
            xml { renderRESTXML(text: user) }
        }
    }

    @Secured(['!isAuthenticated()'])
    def retrieve() {
        if (!params.user?.username) {
            render(status: 200, template: 'dialogs/retrieve')
        } else {
            def user = User.findWhere(username: params.user.username)
            if (!user || !user.enabled || user.accountExternal) {
                def code = !user ? 'is.user.error.not.exist' : (!user.enabled ? 'is.dialog.login.error.disabled' : 'is.user.error.externalAccount')
                returnError(text: message(code: code))
            } else {
                User.withTransaction { status ->
                    try {
                        userService.resetPassword(user)
                        render(status: 200, contentType: 'application/json', text: [text: message(code: 'is.dialog.retrieve.success', args: [user.email])] as JSON)
                    } catch (MailException e) {
                        status.setRollbackOnly()
                        returnError(text: message(code: 'is.mail.error'), exception: e)
                    } catch (RuntimeException re) {
                        returnError(text: re.getMessage(), exception: re)
                    } catch (Exception e) {
                        status.setRollbackOnly()
                        returnError(text: message(code: 'is.mail.error'), exception: e)
                    }
                }
            }
        }
    }

    @Secured('isAuthenticated()')
    def menu(String id, String position, boolean hidden) {
        if (!id && !position) {
            returnError(text: message(code: 'is.user.preferences.error.menuBar'))
            return
        }
        try {
            userService.menu((User) springSecurityService.currentUser, id, position, hidden ?: false)
            render(status: 200)
        } catch (RuntimeException e) {
            returnError(text: message(code: 'is.user.preferences.error.menuBar'), exception: e)
        }
    }

    @Secured('permitAll()')
    def menus() {
        def menus = []
        uiDefinitionService.getDefinitions().each { String uiDefinitionId, UiDefinition uiDefinition ->
            def menuBar = uiDefinition.menuBar
            if (menuBar?.spaceDynamicBar) {
                menuBar.show = menuBarSupport.spaceDynamicBar(uiDefinitionId, menuBar.defaultVisibility, menuBar.defaultPosition, uiDefinition.space, uiDefinition.window.init)
            }
            def show = menuBar?.show
            if (show in Closure) {
                show.delegate = delegate
                show = show()
            }
            if (show) {
                menus << [title: message(code: menuBar?.title),
                          id: uiDefinitionId,
                          shortcut: "ctrl+" + (menus.size() + 1),
                          icon: uiDefinition.icon,
                          position: show instanceof Map ? show.pos.toInteger() ?: 1 : 1,
                          visible: show.visible]
            }
        }
        render(status: 200, text:menus as JSON)
    }

    @Secured(['permitAll()'])
    def available(String property) {
        def result = false
        //test for username
        if (property == 'username') {
            result = request.JSON.value && User.countByUsername(request.JSON.value) == 0
            //test for email
        } else if (property == 'email') {
            result = request.JSON.value && User.countByEmail(request.JSON.value) == 0
        }
        render(status: 200, text: [isValid: result, value: request.JSON.value] as JSON, contentType: 'application/json')
    }

    def activities(long id) {
        User user = springSecurityService.currentUser
        if (id != user.id) {
            render(status: 403)
        }
        def activitiesAndStories = Activity.storyActivities(user).take(15).collect {
            def activity = it[0]
            def story = it[1]
            def project = story.backlog
            [
                activity: activity,
                story: [uid: story.uid, name: story.name],
                project: [pkey: project.pkey, name: project.name],
                notRead: activity.dateCreated > user.preferences.lastReadActivities
            ]
        }
        user.preferences.lastReadActivities = new Date()
        render(status: 200, text: activitiesAndStories as JSON, contentType: 'application/json')
    }

    def unreadActivitiesCount(long id) {
        User user = springSecurityService.currentUser
        if (id != user.id) {
            render(status: 403)
        }
        def unreadActivities = Activity.storyActivities(user).findAll {
            def activity = it[0]
            activity.dateCreated > user.preferences.lastReadActivities
        }
        render(status: 200, text: [unreadActivitiesCount: unreadActivities.size()] as JSON, contentType: 'application/json')
    }

    private File getAssetAvatarFile(String avatarFileName) {
        def avatarPath
        if (grailsApplication.warDeployed) {
            def avatar = g.assetPath(src: 'avatars/' + avatarFileName) as String
            def baseName = FilenameUtils.getBaseName(avatar)
            def extension = FilenameUtils.getExtension(avatar)
            avatarPath = "assets/avatars/${baseName}.${extension}"
        } else {
            avatarPath = "../grails-app/${avatarFileName}"
        }
        return grailsApplication.parentContext.getResource(avatarPath).file
    }

    def invitationUserMock(String token) {
        def enableInvitation = grailsApplication.config.icescrum.registration.enable && grailsApplication.config.icescrum.invitation.enable
        def invitation = Invitation.findByToken(token)
        if (!invitation || !enableInvitation) {
            throw new ObjectNotFoundException(token, 'Invitation') // TODO manage error independently
        }
        render(status: 200, text: invitation.userMock as JSON, contentType: 'application/json')
    }
}
