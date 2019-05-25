/*
 * Copyright (c) 2019 Kagilum SAS
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
 * Authors: Vincent Barrier (vbarrier@kagilum.com)
 *
 */

package org.icescrum.web.presentation

import org.icescrum.core.domain.Hook
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport

@Secured('isAuthenticated()')
class HookController implements ControllerErrorHandler {

    def hookService
    def beforeInterceptor = [action: this.&checkBeforeAction]

    private checkBeforeAction() {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        if (workspace) { // Case workspace
            if (!request."in${workspace.name.capitalize()}") { // Must be inWorkspace
                render(status: 403)
                return false
            }
        } else if (!request.admin) { // Global hooks request to be admin
            render(status: 403)
            return false
        } else if (!grailsApplication.config.icescrum.hooks.enable) { // And it must be set in admin
            render(status: 503)
            return false
        }
    }

    def index() {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        def hooks = Hook.findAllByWorkspaceIdAndWorkspaceType(workspace?.object?.id, workspace?.name)
        render(status: 200, contentType: 'application/json', text: hooks as JSON)
    }

    def save() {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        Hook hook = new Hook()
        Hook.withTransaction {
            bindData(hook, params.hook, [include: ['url', 'events', 'enabled', 'ignoreSsl', 'secret']])
            hook.workspaceId = workspace?.object?.id
            hook.workspaceType = workspace?.name
            hookService.save(hook)
        }
        render(status: 201, contentType: 'application/json', text: hook as JSON)
    }

    def show(long id) {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspace?.object?.id, workspace?.name)
        if (hook) {
            render(status: 200, contentType: 'application/json', text: hook as JSON)
        } else {
            render(status: 404)
        }
    }

    def update(long id) {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspace?.object?.id, workspace?.name)
        if (hook) {
            bindData(hook, params.hook, [include: ['url', 'events', 'enabled', 'ignoreSsl', 'secret']])
            hookService.update(hook)
            render(status: 200, contentType: 'application/json', text: hook as JSON)
        } else {
            render(status: 404)
        }
    }

    def delete(long id) {
        def workspace = ApplicationSupport.getCurrentWorkspace(params)
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspace?.object?.id, workspace?.name)
        if (hook) {
            hookService.delete(hook, true)
            withFormat {
                html {
                    render(status: 200, contentType: 'application/json', text: [id: id, workspaceId: workspace?.object?.id] as JSON)
                }
                json {
                    render(status: 204)
                }
            }
        } else {
            render(status: 404)
        }
    }
}