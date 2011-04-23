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
 * Authors: Vincent Barrier (vbarrier@kagilum.com)
 *  Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */

package org.icescrum.web.presentation

import grails.converters.JSON

class ErrorsController {

  def springSecurityService

  def error403 = {
    if(!springSecurityService.isLoggedIn())
      redirect(action:'error401')
    else if (springSecurityService.isAjax(request))
      render(status: 403, text: [error: message(code: 'is.error.denied')])
    else
      redirect(controller: 'login', action:'index')
  }
  def error401 = {
    if (springSecurityService.isAjax(request))
      render(status: 401, text:'')
    else{
      render(template:'error401', status: 401, model:[ref:params.ref])
    }
  }

  def fakeError = {
    
  }

  def handleDatabase = {
        render(status:500, contentType:'application/json', text:[error:message(code: 'is.error.database')] as JSON)
  }

  def handleMemory = {
        render(status:500, contentType:'application/json', text:[error:message(code: 'is.error.permgen')] as JSON)
  }

}
