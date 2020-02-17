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
import org.icescrum.core.error.BusinessException
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.event.IceScrumEventType
import org.icescrum.core.security.WorkspaceSecurity
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.plugins.attachmentable.domain.Attachment

import javax.servlet.http.HttpServletResponse

@Secured('permitAll()')
class AttachmentController implements ControllerErrorHandler, WorkspaceSecurity {

    def springSecurityService
    def attachmentableService

    def index() {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def attachmentable = ApplicationSupport.getAttachmentableObject(params)
        if (attachmentable) {
            render(status: 200, contentType: 'application/json', text: attachmentable.attachments as JSON)
        } else {
            returnError(code: 'todo.is.ui.backlogelement.attachments.error')
        }
    }

    def show() {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def attachmentable = ApplicationSupport.getAttachmentableObject(params)
        if (attachmentable) {
            def attachment = attachmentable.attachments?.find { it.id == params.long('id') }
            if (attachment) {
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
            }
        }
        response.status = HttpServletResponse.SC_NOT_FOUND
    }

    def save() {
        if (!checkPermission(
                project: '((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def attachmentable = ApplicationSupport.getAttachmentableObject(params)
        def endOfUpload = { uploadInfo ->
            def service = grailsApplication.mainContext[params.type + 'Service']
            service.publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, attachmentable, ['addAttachment': null])
            Attachment attachment
            if (uploadInfo.filePath) {
                File attachmentFile = new File(uploadInfo.filePath)
                if (!attachmentFile.length()) {
                    throw new BusinessException(code: 'todo.is.ui.backlogelement.attachments.error.empty')
                }
                attachment = attachmentable.addAttachment(springSecurityService.currentUser, attachmentFile, uploadInfo.filename)
            } else {
                attachment = attachmentable.addAttachment(springSecurityService.currentUser, uploadInfo, uploadInfo.name)
            }
            attachment.provider = uploadInfo instanceof Map ? uploadInfo.provider : null
            service.publishSynchronousEvent(IceScrumEventType.UPDATE, attachmentable, ['addedAttachment': attachment])
            render(status: 201, contentType: 'application/json', text: attachment as JSON)
        }
        if (attachmentable) {
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

    def update() {
        if (!checkPermission(
                project: 'productOwner() or scrumMaster()',
                portfolio: 'businessOwner()'
        )) {
            return
        }
        def attachmentable = ApplicationSupport.getAttachmentableObject(params)
        if (attachmentable) {
            Attachment.withTransaction {
                Attachment attachment = attachmentable.attachments?.find { it.id == params.long('id') }
                if (attachment && params.attachment.name && attachment.name != params.attachment.name) {
                    attachment.name = params.attachment.name
                    attachment.inputName = attachment.filename
                    attachment.save()
                    render(status: 200, contentType: 'application/json', text: attachment as JSON)
                }
            }
        }
    }

    def delete() {
        if (!checkPermission(
                project: 'productOwner() or scrumMaster()',
                portfolio: 'businessOwner()'
        )) {
            return
        }
        def attachmentable = ApplicationSupport.getAttachmentableObject(params)
        if (attachmentable) {
            def attachment = attachmentable.attachments?.find { it.id == params.long('id') }
            if (attachment) {
                grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, attachmentable, ['removeAttachment': attachment])
                attachmentable.removeAttachment(attachment)
                grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, attachmentable, ['removedAttachment': null])
                render(status: 204)
            }
        }
    }
}
