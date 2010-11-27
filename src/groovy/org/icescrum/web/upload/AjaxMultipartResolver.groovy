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

package org.icescrum.web.upload

import org.springframework.web.multipart.commons.CommonsMultipartResolver

import org.apache.commons.fileupload.servlet.ServletFileUpload

import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartException

import javax.servlet.http.HttpServletRequest

import org.apache.commons.fileupload.FileUploadBase
import org.springframework.web.multipart.MaxUploadSizeExceededException
import org.apache.commons.fileupload.FileUploadException
import org.apache.commons.fileupload.FileItem

import org.icescrum.web.upload.AjaxProgressListener
import org.springframework.web.multipart.commons.CommonsFileUploadSupport.MultipartParsingResult

class AjaxMultipartResolver extends CommonsMultipartResolver{
	
	private HttpServletRequest request

    @Override
	public MultipartHttpServletRequest resolveMultipart(HttpServletRequest request)
    														throws MultipartException{
	    try{
    		this.request = request
    		return super.resolveMultipart(request)

	    }catch(Exception ex){
	        throw(ex)
	    }
		
	}

    static String progressAttrName(String fileID){
      return "UPLOAD-"+fileID
    }

    @Override
    protected MultipartParsingResult parseRequest(final HttpServletRequest req) {
        String encoding = determineEncoding(req)
        ServletFileUpload fileUpload = prepareFileUpload(encoding)
        fileUpload.progressListener = new AjaxProgressListener(req)
        MultipartParsingResult result = null
        try {
            List<FileItem> items = fileUpload.parseRequest(req)
            result = parseFileItems(items, encoding)
        } catch (FileUploadBase.SizeLimitExceededException e) {
          ((AjaxProgressListener)fileUpload.progressListener).error("File size error (max: ${fileUpload.getSizeMax()})")
            throw new MaxUploadSizeExceededException(fileUpload.getSizeMax(), e)
        } catch (FileUploadException e) {
            ((AjaxProgressListener)fileUpload.progressListener).error("Stream ended unexpectedly")
            throw new MultipartException('Could not parse multipart servlet request',e)
        }
        return result
    }
	
}