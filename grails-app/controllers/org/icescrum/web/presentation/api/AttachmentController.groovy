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
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.event.IceScrumEventType
import org.icescrum.core.error.ControllerErrorHandler

import javax.servlet.http.HttpServletResponse

class AttachmentController implements ControllerErrorHandler {

    def springSecurityService
    def attachmentableService

    @Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
    def index() {
        def attachmentable = getAttachmentableObject(params)
        if (attachmentable) {
            render(status: 200, contentType: 'application/json', text: attachmentable.attachments as JSON)
        } else {
            returnError(code: 'todo.is.ui.backlogelement.attachments.error')
        }
    }

    @Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
    def show() {
        def attachmentable = getAttachmentableObject(params)
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

    @Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
    def save() {
        def _attachmentable = getAttachmentableObject(params)
        def endOfUpload = { uploadInfo ->
            def service = grailsApplication.mainContext[params.type + 'Service']
            service.publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, _attachmentable, ['addAttachment': null])
            _attachmentable.addAttachment(springSecurityService.currentUser, new File(uploadInfo.filePath), uploadInfo.filename)
            def attachment = _attachmentable.attachments.first()
            service.publishSynchronousEvent(IceScrumEventType.UPDATE, _attachmentable, ['addedAttachment': attachment])
            def res = ['filename':attachment.filename, 'length':attachment.length, 'ext':attachment.ext, 'id':attachment.id, attachmentable:[id:_attachmentable.id, 'class':params.type]]
            render(status: 201, contentType: 'application/json', text:res as JSON)
        }
        if (_attachmentable) {
            UtilsWebComponents.handleUpload.delegate = this
            UtilsWebComponents.handleUpload(request, params, endOfUpload)
        } else {
            render(status:404)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete() {
        def attachmentable = getAttachmentableObject(params)
        if (attachmentable) {
            def attachment = attachmentable.attachments?.find{ it.id == params.long('id') }
            if (attachment){
                grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, attachmentable, ['removeAttachment':attachment])
                attachmentable.removeAttachment(attachment)
                grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, attachmentable, ['removedAttachment':null])
                render(status: 200)
            }
        }
    }

    private static getAttachmentableObject(def params) {
        def attachmentable
        long product = params.long('product')
        long attachmentableId = params.long('attachmentable')
        switch (params.type){
            case 'story':
                attachmentable = Story.getInProduct(product, attachmentableId).list()
                break
            case 'task':
                attachmentable = Task.getInProduct(product, attachmentableId)
                break
            case 'feature':
                attachmentable = Feature.getInProduct(product, attachmentableId).list()
                break
            case 'release':
                attachmentable = Release.getInProduct(product, attachmentableId).list()
                break
            case 'sprint':
                attachmentable = Sprint.getInProduct(product, attachmentableId).list()
                break
            default:
                attachmentable = null
        }
        attachmentable
    }
}