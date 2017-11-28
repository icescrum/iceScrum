/*
 * Copyright (c) 2017 Kagilum SAS
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Portfolio
import org.icescrum.core.error.ControllerErrorHandler

@Secured('isAuthenticated()')
class PortfolioController implements ControllerErrorHandler {

    def portfolioService
    def securityService
    def springSecurityService

    @Secured('isAuthenticated()')
    def save() {
        def portfolioParams = params.portfolio
        Portfolio portfolio = new Portfolio()
        Portfolio.withTransaction {
            bindData(portfolio, portfolioParams, [include: ['fkey']])
            portfolioService.save(portfolio)
            render(status: 201, text: portfolio as JSON, contentType: 'application/json')
        }
    }

    @Secured('isAuthenticated()')
    def delete(long id) {
        Portfolio portfolio = Portfolio.withPortfolio(id)
        if (!securityService.owner(portfolio, springSecurityService.authentication)) { // Cannot check by annotation/request because we are not in a project workspace (URL)
            render(status: 403)
            return
        }
        portfolioService.delete(portfolio)
        withFormat {
            html {
                render(status: 200, text: [id: id] as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }
}
