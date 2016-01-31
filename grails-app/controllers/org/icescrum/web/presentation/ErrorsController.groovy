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
 * Authors: Vincent Barrier (vbarrier@kagilum.com)
 *
 */

package org.icescrum.web.presentation

import grails.converters.JSON

class ErrorsController {

    def springSecurityService

    def error403() {
        if (springSecurityService.isAjax(request))
            render(status: 403, text: [error: message(code: 'is.error.denied')])
        else{
            render(status: 403, view: '403.gsp', model:[homeUrl:grailsApplication.config.grails.serverURL, supportEmail:grailsApplication.config.icescrum.alerts.errors.to])
        }
    }

    def error404() {
        if (springSecurityService.isAjax(request))
            render(status: 404)
        else {
            render(status: 404, view: '404.gsp', model:[homeUrl:grailsApplication.config.grails.serverURL, supportEmail:grailsApplication.config.icescrum.alerts.errors.to])
        }
    }

    def error401() {
        if (springSecurityService.isAjax(request))
            render(status: 401)
        else {
            render(status: 401, view: '401.gsp', model:[ref: params.ref])
        }
    }

    def fakeError() {

    }

    def browserNotSupported() {

    }

    def database() {
        render(status: 500, contentType: 'application/json', text: [error: message(code: 'is.error.database')] as JSON)
    }

    def memory() {
        render(status: 500, contentType: 'application/json', text: [error: message(code: 'is.error.memory')] as JSON)
    }
}
