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
package org.icescrum.web.presentation.api

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
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.error.ControllerErrorHandler
import org.springframework.mail.MailException
import org.springframework.security.acls.domain.BasePermission

class UserController implements ControllerErrorHandler{

    def userService
    def securityService
    def grailsApplication
    def springSecurityService

    @Secured(["hasRole('ROLE_ADMIN')"])
    def index(String term, String filter, Boolean paginate, Integer count, Integer page, String sorting, String order) {
        def options = [cache: true]
        if (paginate) {
            options.offset = page ? (page - 1) * count : 0
            options.max = count ?: 10
            options.sort = sorting ?: 'firstName'
            options.order = order ?: 'asc'
        }
        def users
        def userCount
        if (filter == "enabled") {
            users = term ? User.findUsersLikeAndEnabled(false, term, true, options) : User.findAllByEnabled(true, options)
            if (paginate) {
                userCount = term ? User.countUsersLikeAndEnabled(false, term, true, [cache: true]) : User.countByEnabled(true)
            }
        } else if (filter == "disabled") {
            users = term ? User.findUsersLikeAndEnabled(false, term, false, options) : User.findAllByEnabled(false, options)
            if (paginate) {
                userCount = term ? User.countUsersLikeAndEnabled(false, term, false, [cache: true]) : User.countByEnabled(false)
            }
        } else {
            users = term ? User.findUsersLike(term, false, true, options) : User.list(options)
            if (paginate) {
                userCount = term ? User.countUsersLike(false, term, [cache: true]) : User.count()
            }
        }
        def returnData = paginate ? [users: users, count: userCount] : users
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def show(long id) {
        User user = User.withUser(id)
        render(status: 200, contentType: 'application/json', text: user as JSON)
    }

    @Secured(["!isAuthenticated() or hasRole('ROLE_ADMIN')"])
    def save() {
        if (!params.user) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        if ((params.user.confirmPassword || params.user.password != "") && (params.user.confirmPassword != params.user.password)) {
            returnError(code: 'is.user.error.password.check')
            return
        }
        def user = new User()
        User.withTransaction {
            user.preferences = new UserPreferences()
            bindData(user, this.params, [include: ['username', 'firstName', 'lastName', 'email', 'password']], "user")
            bindData(user.preferences, (Map) this.params.user, [include: ['language', 'filterTask', 'activity']], "preferences")
            userService.save(user, params.user.token)
        }
        render(status: 201, contentType: 'application/json', text: user as JSON)
    }

    @Secured('isAuthenticated()')
    def update(long id) {
        User user = User.withUser(id)
        if (user.id != springSecurityService.principal.id && !request.admin) {
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
                    render(status: 200, contentType: 'application/json', text: user as JSON)
                }
                UtilsWebComponents.handleUpload.delegate = this
                UtilsWebComponents.handleUpload(request, params, endOfUpload)
            }
            return;
        }
        if (!params.user) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        if ((params.user.confirmPassword || params.user.password != "") && (params.user.confirmPassword != params.user.password)) {
            returnError(code: 'is.user.error.password.check')
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
            if (request.admin && params.user.username != user.username) {
                user.username = params.user.username
            }
            bindData(user, params, [include: ['firstName', 'lastName', 'email', 'notes']], "user")
            if (params.user.preferences) {
                bindData(user.preferences, params.user.preferences as Map, [include: ['language', 'filterTask', 'activity']], "") // Preferences using as Map for REST & HTTP support
            }
            entry.hook(id: "${controllerName}-${actionName}", model: [user: user, props: props])
            userService.update(user, props)
        }
        render(status: 200, contentType: 'application/json', text: user as JSON)
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
                redirect(url: "https://secure.gravatar.com/avatar/" + user.email.encodeAsMD5())
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
        def users = User.findUsersLike(value ?: '', false, showDisabled, [max: 9])
        def enableInvitation = grailsApplication.config.icescrum.registration.enable && grailsApplication.config.icescrum.invitation.enable
        if (!users && invit && GenericValidator.isEmail(value) && enableInvitation) {
            users << [id: null, email: value]
        }
        render(status: 200, contentType: 'application/json', text: users as JSON)
    }

    @Secured(['isAuthenticated()'])
    def openProfile() {
        def user = springSecurityService.currentUser
        render(status: 200, template: 'dialogs/profile', model: [user: user, projects: grailsApplication.config.icescrum.alerts.enable ? Project.findAllByRole(user, [BasePermission.WRITE, BasePermission.READ], [cache: true, max: 11], true, false) : null])
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
        render(status: 200, contentType: 'application/json', text: user as JSON)
    }

    @Secured(['!isAuthenticated()'])
    def retrieve() {
        if (!params.user?.username) {
            render(status: 200, template: 'dialogs/retrieve')
        } else {
            def user = User.findWhere(username: params.user.username)
            if (!user || !user.enabled || user.accountExternal) {
                def code = !user ? 'is.user.error.not.exist' : (!user.enabled ? 'is.dialog.login.error.disabled' : 'is.user.error.externalAccount')
                returnError(code: code)
            } else {
                try {
                    User.withTransaction {
                        userService.resetPassword(user)
                        render(status: 200, contentType: 'application/json', text: [text: message(code: 'is.dialog.retrieve.success', args: [user.email])] as JSON)
                    }
                } catch (MailException e) {
                    returnError(code: 'is.mail.error', exception: e)
                } catch (RuntimeException re) {
                    returnError(text: re.message, exception: re)
                } catch (Exception e) {
                    returnError(code: 'is.mail.error', exception: e)
                }
            }
        }
    }

    @Secured('isAuthenticated()')
    def menu(long id, String menuId, String position, boolean hidden) {
        User user = springSecurityService.currentUser
        if (id != user.id) {
            render(status: 403)
            return
        }
        if (!menuId && !position) {
            returnError(code: 'is.user.preferences.error.menu')
            return
        }
        try {
            userService.menu(user, menuId, position, hidden ?: false)
            render(status: 200)
        } catch (RuntimeException e) {
            returnError(code: 'is.user.preferences.error.menu', exception: e)
        }
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

    @Secured(['isAuthenticated()'])
    def activities(long id) {
        User user = springSecurityService.currentUser
        if (id != user.id) {
            render(status: 403)
            return
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

    @Secured(['isAuthenticated()'])
    def unreadActivitiesCount(long id) {
        User user = springSecurityService.currentUser
        if (id != user.id) {
            render(status: 403)
            return

        }
        def unreadActivities = Activity.storyActivities(user).findAll {
            def activity = it[0]
            activity.dateCreated > user.preferences.lastReadActivities
        }
        render(status: 200, text: [unreadActivitiesCount: unreadActivities.size()] as JSON, contentType: 'application/json')
    }

    def invitationEmail(String token) {
        def enableInvitation = grailsApplication.config.icescrum.registration.enable && grailsApplication.config.icescrum.invitation.enable
        Invitation invitation = Invitation.findByToken(token)
        if (!invitation || !enableInvitation) {
            throw new ObjectNotFoundException(token, 'Invitation') // TODO manage error independently
        }
        render(status: 200, text: [email: invitation.email] as JSON, contentType: 'application/json')
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
}
