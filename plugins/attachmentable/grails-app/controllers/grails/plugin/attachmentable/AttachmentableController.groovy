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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 *
 */
package grails.plugin.attachmentable

import grails.converters.JSON
import javax.servlet.http.HttpServletResponse

class AttachmentableController {

  def attachmentableService

  def download = {
    Attachment attachment = Attachment.get(params.id as Long)
    if (attachment) {
        File file = attachmentableService.getFile(attachment)

        if (file.exists()) {
            String filename = attachment.filename
            ['Content-disposition': "attachment;filename=\"$filename\"",'Cache-Control': 'private','Pragma': ''].each {k, v ->
                response.setHeader(k, v)
            }
            response.contentType = attachment.contentType
            response.outputStream << file.newInputStream()
            return
        }
    }
    response.status = HttpServletResponse.SC_NOT_FOUND
  }
}
