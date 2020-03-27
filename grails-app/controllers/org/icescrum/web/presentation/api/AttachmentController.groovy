/*
* Copyright (c) 2014 Kagilum.
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
*/
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.User
import org.icescrum.core.domain.WorkspaceType
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.security.WorkspaceSecurity
import org.icescrum.plugins.attachmentable.domain.Attachment

import javax.servlet.http.HttpServletResponse

@Secured('permitAll()')
class AttachmentController implements ControllerErrorHandler, WorkspaceSecurity {

    def springSecurityService
    def attachmentableService
    def attachmentService

    def index(long workspace, String workspaceType, Long attachmentable, String type) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def _attachmentable = attachmentService.withAttachmentable(workspace, workspaceType, attachmentable, type)
        if (_attachmentable) {
            render(status: 200, contentType: 'application/json', text: _attachmentable.attachments.collect {
                Attachment attachment -> attachmentService.getRenderableAttachment(attachment, _attachmentable)
            } as JSON)
        } else {
            returnError(code: 'todo.is.ui.backlogelement.attachments.error')
        }
    }

    def show(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Attachment attachment = attachmentService.withAttachment(workspace, workspaceType, id)
        if (attachment.url) {
            redirect(url: "${attachment.url}")
            return
        } else {
            File file = attachmentableService.getFile(attachment)
            if (file.exists()) {
                String filename = attachment.filename
                ['Content-disposition': "attachment;filename=\"$filename\"", 'Cache-Control': 'private', 'Pragma': ''].each { k, v ->
                    response.setHeader(k, v)
                }
                response.contentType = attachment.contentType
                response.outputStream << file.newInputStream()
                return
            }
        }
        response.status = HttpServletResponse.SC_NOT_FOUND
    }

    def save(long workspace, String workspaceType, Long attachmentable, String type) {
        if (!checkPermission(
                project: '((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def _attachmentable = attachmentService.withAttachmentable(workspace, workspaceType, attachmentable, type)
        def endOfUpload = { uploadInfo ->
            def attachment = attachmentService.save(_attachmentable, ((User) springSecurityService.currentUser), uploadInfo)
            render(status: 201, contentType: 'application/json', text: attachmentService.getRenderableAttachment(attachment) as JSON)
        }
        if (_attachmentable) {
            if (params.url) {
                endOfUpload(params)
            } else {
                UtilsWebComponents.handleUpload.delegate = this
                UtilsWebComponents.handleUpload(request, params, endOfUpload)
            }
        } else {
            render(status: 404)
        }
    }

    def update(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'productOwner() or scrumMaster()',
                portfolio: 'businessOwner()'
        )) {
            return
        }
        Attachment.withTransaction {
            def attachment = attachmentService.withAttachment(workspace, workspaceType, id)
            attachmentService.update(attachment, [name: params.attachment.name])
            render(status: 200, contentType: 'application/json', text: attachmentService.getRenderableAttachment(attachment) as JSON)
        }
    }

    def delete(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'productOwner() or scrumMaster()',
                portfolio: 'businessOwner()'
        )) {
            return
        }
        Attachment.withTransaction {
            def attachment = attachmentService.withAttachment(workspace, workspaceType, id)
            if ((workspaceType == WorkspaceType.PROJECT && !request.productOwner && !request.scrumMaster || workspaceType == WorkspaceType.PORTFOLIO && !request.businessOwner) && attachment.posterId != springSecurityService.currentUser.id) {
                render(status: 403)
                return
            }
            attachmentService.delete(attachment)
            render(status: 204)
        }
    }
}
