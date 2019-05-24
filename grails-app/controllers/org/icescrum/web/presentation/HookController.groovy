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

@Secured('isAuthenticated()')
class HookController implements ControllerErrorHandler {

    def hookService
    def beforeInterceptor = [action: this.&checkBeforeAction]

    private checkBeforeAction() {
        if (params.workspaceType && params.workspaceId) { // Case workspace
            if (!request."in${params.workspaceType.capitalize()}") { // Must be inWorkspace
                render(status: 403)
                return false
            }
        } else if (params.workspaceType || params.workspaceId) { // Both or nothing
            render(status: 503)
            return false
        } else if (!request.admin) { // Global hooks request to be admin
            render(status: 403)
            return false
        } else if (!grailsApplication.config.icescrum.hooks.enable) { // And it must be set in admin
            render(status: 503)
            return false
        }
    }

    def index(long workspaceId, String workspaceType) {
        def hooks = Hook.findAllByWorkspaceIdAndWorkspaceType(workspaceId, workspaceType)
        render(status: 200, contentType: 'application/json', text: hooks as JSON)
    }

    def save(long workspaceId, String workspaceType) {
        Hook hook = new Hook()
        Hook.withTransaction {
            bindData(hook, params.hook, [include: ['url', 'events', 'enabled', 'ignoreSsl']])
            hook.workspaceId = workspaceId
            hook.workspaceType = workspaceType
            hookService.save(hook)
        }
        render(status: 201, contentType: 'application/json', text: hook as JSON)
    }

    def show(long id, long workspaceId, String workspaceType) {
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspaceId, workspaceType)
        if (hook) {
            render(status: 200, contentType: 'application/json', text: hook as JSON)
        } else {
            render(status: 404)
        }
    }

    def update(long id, long workspaceId, String workspaceType) {
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspaceId, workspaceType)
        if (hook) {
            bindData(hook, params.hook, [include: ['url', 'events', 'enabled']])
            hookService.update(hook)
            render(status: 200, contentType: 'application/json', text: hook as JSON)
        } else {
            render(status: 404)
        }
    }

    def delete(long id, long workspaceId, String workspaceType) {
        def hook = Hook.findByIdAndWorkspaceIdAndWorkspaceType(id, workspaceId, workspaceType)
        if (hook) {
            hookService.delete(hook, true)
            render(status: 204)
        } else {
            render(status: 404)
        }
    }
}