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

import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpSession
import org.apache.commons.fileupload.ProgressListener
import org.icescrum.core.support.ProgressSupport

class AjaxProgressListener implements ProgressListener {

    static final String STATUS_UPLOADING = "UPLOADING"
    static final String STATUS_FAILED = "FAILED"
    static final String STATUS_DONE = "DONE"
    
	private HttpSession session = null
    String fileID = null

    public AjaxProgressListener(HttpServletRequest request) {
        this.session = request.session
        fileID = request.getParameter("X-Progress-ID")?:null

        if(fileID && session){
          ProgressSupport ps = (ProgressSupport)this.session[AjaxMultipartResolver.progressAttrName(fileID)]
          if (!ps) {
              ps = new ProgressSupport()
              session[AjaxMultipartResolver.progressAttrName(fileID)] = ps
          }
        }
     }

	void update(long pBytesRead, long pContentLength, int pItems){
        if(!fileID || !session) return
        if(pBytesRead == pContentLength)
          ((ProgressSupport)session[AjaxMultipartResolver.progressAttrName(fileID)]).completeProgress("100%")
        else {
          def val = (pBytesRead * 100 / pContentLength).toInteger()
          ((ProgressSupport)session[AjaxMultipartResolver.progressAttrName(fileID)]).updateProgress(val,"${val}%")
        }
	}

  void error(String label = null){
    ((ProgressSupport)session[AjaxMultipartResolver.progressAttrName(fileID)]).progressError(label)
  }
}