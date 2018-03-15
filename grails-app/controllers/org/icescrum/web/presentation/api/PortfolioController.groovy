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
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.utils.DateUtils

@Secured('isAuthenticated()')
class PortfolioController implements ControllerErrorHandler {

    def portfolioService
    def springSecurityService

    @Secured(["hasRole('ROLE_ADMIN')"])
    def index(String term, Boolean paginate, Integer count, Integer page, String sorting, String order) {
        def options = [cache: true]
        if (paginate) {
            if (!count) {
                count = 10
            }
            options.offset = page ? (page - 1) * count : 0
            options.max = count
            options.sort = sorting ?: 'name'
            options.order = order ?: 'asc'
        }
        def portfolios = Portfolio.findAllByTerm(options, term)
        def returnData = paginate ? [portfolios: portfolios, count: portfolios.totalCount] : portfolios
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['businessOwner() or portfolioStackHolder()'])
    def show(long portfolio) {
        Portfolio _portfolio = Portfolio.withPortfolio(portfolio)
        render(status: 200, contentType: 'application/json', text: _portfolio as JSON)
    }

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
        def projects = Project.withProjects(portfolioParams.projects, 'id', request.admin ? null : springSecurityService.currentUser)
        def businessOwners = portfolioParams.businessOwners ? User.getAll(portfolioParams.businessOwners.list('id').collect { it.toLong() }) : []
        def stakeholders = portfolioParams.stakeHolders ? User.getAll(portfolioParams.stakeHolders.list('id').collect { it.toLong() }) : []
        def invitedBusinessOwners = portfolioParams.invitedBusinessOwners ? portfolioParams.invitedBusinessOwners.list('email') : []
        def invitedStakeHolders = portfolioParams.invitedStakeHolders ? portfolioParams.invitedStakeHolders.list('email') : []
        Portfolio.withTransaction {
            bindData(_portfolio, portfolioParams, [include: ['name', 'description', 'fkey']])
            portfolioService.update(_portfolio, projects, businessOwners, stakeholders)
            portfolioService.managePortfolioInvitations(_portfolio, invitedBusinessOwners, invitedStakeHolders)
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
            result = request.JSON.value && request.JSON.value =~ /^[A-Z0-9]*[A-Z]+[A-Z0-9]*$/ && (portfolio ? Portfolio.countByFkeyAndId(request.JSON.value, portfolio) : Portfolio.countByFkey(request.JSON.value)) == 0
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

    @Secured(['businessOwner() or portfolioStackHolder()'])
    def listByUser(long id, String term, Boolean paginate, Integer page, Integer count) {
        if (id && id != springSecurityService.principal.id && !request.admin) {
            render(status: 403)
            return
        }
        User user = id ? User.get(id) : springSecurityService.currentUser
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def portfolios = portfolioService.getAllPortfoliosByUser(user, searchTerm)
        if (paginate && !count) {
            count = 10
        }
        def returnedPortfolios = !count ? portfolios : portfolios.drop(page ? (page - 1) * count : 0).take(count)
        def light = params.light != null ? params.remove('light') : false
        if (light && light != "false") {
            def properties = light == "true" || light instanceof Boolean ? null : light.tokenize(',')
            returnedPortfolios = returnedPortfolios.collect {
                def p = [id: it.id, fkey: it.fkey, name: it.name]
                properties?.each { property ->
                    p."$property" = it."$property"
                }
                return p
            }
        }
        def returnData = paginate ? [portfolios: returnedPortfolios, count: portfolios.size()] : returnedPortfolios
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    def synchronizedProjects() {
        List<Project> projects = Project.withProjects(params, 'projects')
        Date today = new Date()
        // Flatten all the release and sprint dates for each project in order, starting from today
        def projectDatesEntries = projects.collect { Project project ->
            List<Date> dates = []
            List<Release> releases = project.releases.findAll { it.endDate > today }.sort { it.orderNumber }
            releases.each { Release release ->
                dates << [release.startDate, today].max() // If we are in the middle of a release, we take today instead of release start date
                dates << release.endDate
                List<Sprint> sprints = release.sprints.findAll { it.endDate > today }.sort { it.orderNumber }
                sprints.each { Sprint sprint ->
                    dates << [sprint.startDate, today].max() // If we are in the middle of a sprint, we take today instead of release start date
                    dates << sprint.endDate
                }
            }
            return [project: project, dates: dates.collect { DateUtils.getMidnightDate(it) }.sort()]
        }
        // Avoid treating projects that don't have dates
        projectDatesEntries = projectDatesEntries.findAll { entry ->
            return entry.dates.size() > 0
        }
        // Ditch the dates where we don't have dates for all TODO do better
        def minNbDates = projectDatesEntries.collect { entry -> entry.dates.size() }.min()
        projectDatesEntries = projectDatesEntries.each { entry ->
            entry.dates = entry.dates.take(minNbDates)
        }
        // Grouped projects having same dates
        def groupedEntries = projectDatesEntries.groupBy { entry -> entry.dates }.values()
        def returnData = [text: '']
        if (groupedEntries.size()) {
            if (groupedEntries.size() == 1) {
                if (groupedEntries[0].size() > 1) {
                    String lastDate = groupedEntries[0][0].dates.last().format(message(code: 'is.date.format.short'))
                    returnData.text = message(code: 'is.ui.portfolio.sync.ok', args: [lastDate])
                    returnData.status = 'success'
                }
            } else {
                groupedEntries.remove(groupedEntries.max { it.size() })
                String projectNames = groupedEntries.collect { entries ->
                    return entries.collect { entry -> entry.project.name }
                }.flatten().join(', ')
                returnData.text = message(code: 'is.ui.portfolio.sync.ko', args: [projectNames])
                returnData.status = 'warning'
            }
        }
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }
}