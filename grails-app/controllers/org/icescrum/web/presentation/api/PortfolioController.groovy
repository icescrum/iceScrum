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
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler

@Secured('isAuthenticated()')
class PortfolioController implements ControllerErrorHandler {

    def portfolioService
    def springSecurityService

    @Secured('isAuthenticated()')
    def save() {
        def portfolioParams = params.portfolio
        Portfolio portfolio = new Portfolio()
        def projects = Project.withProjects(portfolioParams.projects, 'id', springSecurityService.currentUser)
        Portfolio.withTransaction {
            bindData(portfolio, portfolioParams, [include: ['fkey', 'name', 'description']])
            def businessOwners = portfolioParams.businessOwners ? portfolioParams.businessOwners.list('id').collect { it.toLong() } : []
            def stakeholders = portfolioParams.stakeHolders ? portfolioParams.stakeHolders.list('id').collect { it.toLong() } : []
            def invitedBusinessOwners = portfolioParams.invitedBusinessOwners ? portfolioParams.invitedBusinessOwners.list('email') : []
            def invitedStakeHolders = portfolioParams.invitedStakeHolders ? portfolioParams.invitedStakeHolders.list('email') : []
            portfolioService.save(portfolio, projects, businessOwners ? User.getAll(businessOwners) : null, stakeholders ? User.getAll(stakeholders) : null)
            portfolioService.managePortfolioInvitations(portfolio, invitedBusinessOwners, invitedStakeHolders)
            render(status: 201, text: portfolio as JSON, contentType: 'application/json')
        }
    }

    @Secured('businessOwner()')
    def update(long portfolio) {
        def portfolioParams = params.portfoliod
        Portfolio _portfolio = Portfolio.withPortfolio(portfolio)
        def projects = Project.withProjects(portfolioParams.projects, 'id', springSecurityService.currentUser)
        def businessOwners = portfolioParams.businessOwners != null ? portfolioParams.businessOwners.list('id').collect { it.toLong() } : null
        def stakeholders = portfolioParams.stakeHolders != null ? portfolioParams.stakeHolders.list('id').collect { it.toLong() } : null
        businessOwners = businessOwners != null ? User.getAll(businessOwners) : null
        stakeholders = stakeholders != null ? User.getAll(stakeholders) : null
        Project.withTransaction {
            bindData(_portfolio, portfolioParams, [include: ['name', 'description', 'fkey']])
            portfolioService.update(_portfolio, projects, businessOwners, stakeholders)
            entry.hook(id: "portfolio-update", model: [portfolio: _portfolio])
            render(status: 200, contentType: 'application/json', text: _portfolio as JSON)
        }
    }

    @Secured('businessOwner()')
    def delete(long portfolio) {
        Portfolio _portfolio = Portfolio.withPortfolio(portfolio)
        portfolioService.delete(_portfolio)
        withFormat {
            html {
                render(status: 200, text: [id: portfolio] as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }

    @Secured('isAuthenticated()')
    def available(long portfolio, String property) {
        def result = false
        if (property == 'fkey') {
            result = request.JSON.value && request.JSON.value =~ /^[A-Z0-9]*$/ && (portfolio ? Portfolio.countByFkeyAndId(request.JSON.value, portfolio) : Portfolio.countByFkey(request.JSON.value)) == 0
        }
        render(status: 200, text: [isValid: result, value: request.JSON.value] as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def add() {
        render(status: 200, template: "dialogs/new")
    }

    @Secured(['isAuthenticated()'])
    def edit() {
        render(status: 200, template: "dialogs/edit")
    }
}
