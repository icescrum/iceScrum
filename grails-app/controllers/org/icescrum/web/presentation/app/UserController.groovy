/*
 * Copyright (c) 2014 Kagilum SAS
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

import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.filefilter.WildcardFileFilter
import org.apache.commons.validator.GenericValidator
import org.icescrum.components.FileUploadInfo
import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.Activity
import org.springframework.security.acls.domain.BasePermission
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.support.ApplicationSupport
import org.springframework.mail.MailException

class UserController {

    def userService
    def securityService
    def springSecurityService
    def grailsApplication

    @Secured(["hasRole('ROLE_ADMIN')"])
    def show() {
        redirect(action:'index', params:params)
    }

    @Secured(["hasRole('ROLE_ADMIN')"])
    def list() {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        def users = User.getAll()
        withFormat {
            json { renderRESTJSON(text:users) }
            xml  { renderRESTXML(text:users) }
        }
    }

    @Secured(["!isAuthenticated()"])
    def save() {
        if (!params.user){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        if (!request.admin && (params.user.confirmPassword  || params.user.password != "") && (params.user.confirmPassword != params.user.password)) {
            returnError(text: message(code: 'is.user.error.password.check'))
            return
        }
        def user = new User()
        try {
            User.withTransaction {
                user.preferences = new UserPreferences()
                bindData(user, this.params, [include:['username','firstName','lastName','email', 'password']], "user")
                bindData(user.preferences, (Map)this.params.user, [include:['language', 'filterTask', 'activity']], "preferences")
                userService.save(user)
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: user as JSON }
                json { renderRESTJSON(text:user, status:201) }
                xml  { renderRESTXML(text:user, status:201) }
            }
        } catch (RuntimeException e) {
            returnError(object:user, exception:e)
        }
    }

    @Secured('isAuthenticated()')
    def update(long id) {
        User user = User.withUser(id)

        // profile is personal
        if ((user.id != springSecurityService.principal.id || request.format in ['json','xml']) && !request.admin){
            render(status:403)
            return
        }

        Map props = [:]
        if(params.flowIdentifier){
            User.withTransaction {
                def endOfUpload = {FileUploadInfo uploadInfo ->
                    def uploadedAvatar = new File(uploadInfo.filePath)
                    props.avatar = uploadedAvatar.canonicalPath
                    props.scale = true
                    userService.update(user, props)
                    withFormat {
                        html { render status: 200, contentType: 'application/json', text: user as JSON }
                        json { renderRESTJSON(text:user) }
                        xml  { renderRESTXML(text:user) }
                    }
                }
                UtilsWebComponents.handleUpload.delegate = this
                UtilsWebComponents.handleUpload(request, params, endOfUpload)
            }
            return;
        }

        if (!params.user){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }

        if (!request.admin && ((params.confirmPassword  || params.user.password != "") && (params.confirmPassword != params.user.password))) {
            returnError(text: message(code: 'is.user.error.password.check'))
            return
        }

        User.withTransaction {
            if (params.user.password?.trim() != ''){
                props.pwd = params.user.password
            }
            if(params.user.avatar && !(params.user.avatar in ['gravatar', 'custom'])){
                if (params.user.avatar instanceof String){
                    params.user.avatar = params.user.avatar.split("/")?.last()
                    props.avatar = getAssetAvatarFile(params.user.avatar)
                    props.scale = false
                } else if (params.user.avatar){
                    def uploadedAvatar = request.getFile('user.avatar')
                    props.avatar = new File(grailsApplication.config.icescrum.images.users.dir, "${user.id}.${FilenameUtils.getExtension(uploadedAvatar.originalFilename)}")
                    props.scale = true
                    uploadedAvatar.transferTo(props.avatar)
                }
                if (props.avatar){
                    props.avatar = props.avatar.canonicalPath
                }
            } else if (params.user.avatar == 'gravatar'){
                props.avatar = null
            }
            if (params.user.preferences && params.user.preferences['emailsSettings']){
                props.emailsSettings = [onStory:params.remove('user.preferences.emailsSettings.onStory'),
                                        autoFollow:params.remove('user.preferences.emailsSettings.autoFollow'),
                                        onUrgentTask:params.remove('user.preferences.emailsSettings.onUrgentTask')]
            }
            bindData(user, params, [include:['firstName','lastName','email']], "user")
            //preferences using as Map for REST & HTTP support
            if (params.user.preferences){
                bindData(user.preferences, params.user.preferences as Map, [include:['language', 'filterTask', 'activity']], "")
            }
            entry.hook(id:"${controllerName}-${actionName}", model:[user:user, props:props])
            userService.update(user, props)
        }

        withFormat {
            html { render status: 200, contentType: 'application/json', text: user as JSON }
            json { renderRESTJSON(text:user) }
            xml  { renderRESTXML(text:user) }
        }
    }

    @Secured(['!isAuthenticated()'])
    def register() {
        render(status:200, contentType: 'application/json', template: 'dialogs/register')
    }

    def avatar(long id) {
        User user = User.withUser(id)
        File[] files = new File(grailsApplication.config.icescrum.images.users.dir.toString()).listFiles((FilenameFilter)new WildcardFileFilter("${user.id}.*"))
        def avatar = files ? files[0] : null
        if (!avatar?.exists()){
            if (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)){
                redirect url:"https://secure.gravatar.com/avatar/" + user.email.encodeAsMD5()
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
        if (!users && invit && GenericValidator.isEmail(value)){
            users << [id:null, firstName:value.split('@')[0], lastName:'', email:value]
        }
        withFormat{
            html { render(status:200, contentType:'application/json', text: users as JSON) }
            json { renderRESTJSON(text:users) }
            xml  { renderRESTXML(text:users) }
        }
    }

    @Secured(['isAuthenticated()'])
    def openProfile() {
        def user = springSecurityService.currentUser
        render(status:200, template: 'dialogs/profile', model: [user: user, projects:grailsApplication.config.icescrum.alerts.enable ? Product.findAllByRole(user, [BasePermission.WRITE,BasePermission.READ] , [cache:true, max:11], true, false) : null])
    }

    @Secured('isAuthenticated()')
    def index(long id) {
        User user = User.withUser(id)
        withFormat {
            html {
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
            json {
                renderRESTJSON(text:user)
            }
            xml  {
                renderRESTXML(text:user)
            }
        }
    }

    //fake save method to force authentication when using rest service (with admin
    @Secured("hasRole('ROLE_ADMIN')")
    def forceRestSave() {
        forward(action:'save', params:params)
    }

    @Secured(['permitAll()'])
    def current() {
        def user = [user:springSecurityService.currentUser?.id ? springSecurityService.currentUser : 'null',
                    roles:[
                            productOwner:request.productOwner,
                            scrumMaster:request.scrumMaster,
                            teamMember:request.teamMember,
                            stakeHolder:request.stakeHolder
                    ]]
        withFormat{
            html { render(status:200, contentType:'application/json', text: user as JSON) }
            json { renderRESTJSON(text:user) }
            xml  { renderRESTXML(text:user) }
        }
    }

    @Secured(['!isAuthenticated()'])
    def retrieve() {
        if (!params.user?.username) {
            render(status:200, template: 'dialogs/retrieve')
        } else {
            def user = User.findWhere(username:params.user.username)
            if (!user || !user.enabled || user.accountExternal) {
                def code = !user ? 'is.user.error.not.exist' : (!user.enabled ? 'is.dialog.login.error.disabled' : 'is.user.error.externalAccount')
                returnError(text:message(code: code))
            }
            else
            {
                User.withTransaction { status ->
                    try {
                        userService.resetPassword(user)
                        render(status: 200, contentType: 'application/json', text: [text: message(code: 'is.dialog.retrieve.success', args: [user.email])] as JSON)
                    } catch (MailException e) {
                        status.setRollbackOnly()
                        returnError(text:message(code: 'is.mail.error'), exception:e)
                    } catch (RuntimeException re) {
                        returnError(text:re.getMessage(), exception:re)
                    } catch (Exception e) {
                        status.setRollbackOnly()
                        returnError(text:message(code: 'is.mail.error'), exception:e)
                    }
                }
            }
        }
    }

    @Secured('isAuthenticated()')
    def menuBar() {
        if (!params.id && !params.position) {
            returnError(text:message(code: 'is.user.preferences.error.menuBar'))
            return
        }
        String id = "${params.id}".split("_")[1]
        String position = params.position
        try {
            userService.menuBar(springSecurityService.currentUser, id, position, params.boolean('hidden') ?: false)
            render(status: 200)
        } catch (RuntimeException e) {
            returnError(text:message(code: 'is.user.preferences.error.menuBar'), exception:e)
        }
    }

    @Secured('isAuthenticated()')
    def profileURL() {
        redirect(url: is.createScrumLink(controller: 'user', action: 'profile', id: params.id))
    }

    @Secured(['permitAll()'])
    def available(String property) {
        def result = false
        //test for username
        if (property == 'username'){
            result = request.JSON.value && User.countByUsername(request.JSON.value) == 0
            //test for email
        } else if (property == 'email'){
            result = request.JSON.value && User.countByEmail(request.JSON.value) == 0
        }
        render(status:200, text:[isValid: result, value:request.JSON.value] as JSON, contentType:'application/json')
    }

    private File getAssetAvatarFile(String avatarFileName) {
        avatarFileName = "assets/avatars/${avatarFileName}"
        if (!grailsApplication.warDeployed) {
            avatarFileName = "../grails-app/${avatarFileName}"
        }
        return grailsApplication.parentContext.getResource(avatarFileName).file
    }
}
