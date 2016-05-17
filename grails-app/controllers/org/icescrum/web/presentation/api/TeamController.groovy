package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority

class TeamController {

    def springSecurityService
    def productService
    def teamService
    def securityService

    @Secured('isAuthenticated()')
    def index(String term, Boolean create) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def options = [sort: "name", order: "asc", cache: true]
        def teams = request.admin ? Team.findAllByNameIlike(searchTerm, options) : Team.findAllByOwner(springSecurityService.currentUser.username, options, searchTerm)
        if (!teams.any { it.name == term } && create) {
            teams.add(0, [name: params.term, members: [], scrumMasters: []])
        }
        render(status: 200, text: teams as JSON, contentType: 'application/json')
    }

    @Secured(['stakeHolder() or inProduct()'])
    def show(long product) {
        Product _product = Product.withProduct(product)
        render(status: 200, text: _product.firstTeam as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def save() {
        def team = new Team(name: params.team.name)
        try {
            Team.withTransaction {
                teamService.save(team, null, [springSecurityService.currentUser.id])
                render(status: 200, text: team as JSON, contentType: 'application/json')
            }
        } catch (IllegalStateException ise) {
            returnError(text: message(code: ise.message))
        } catch (RuntimeException re) {
            returnError(object: team, exception: re)
        }
    }
    @Secured(['isAuthenticated()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def update(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project context (URL)
        if (!securityService.owner(team, auth) && !securityService.scrumMaster(team, auth)) {
            render(status: 403)
            return
        }
        def newMembers = []
        params.team.members?.list('id').each {
            newMembers << [id: it.toLong(), role: Authority.MEMBER]
        }
        params.team.scrumMasters?.list('id').each {
            newMembers << [id: it.toLong(), role: Authority.SCRUMMASTER]
        }
        def invitedMembers = params.team.invitedMembers?.list('email') ?: []
        def invitedScrumMasters = params.team.invitedScrumMasters?.list('email') ?: []
        try {
            def newOwnerId = params.team.owner?.id?.toLong()
            Team.withTransaction {
                if (team.name != params.team.name) {
                    team.name = params.team.name
                    if (!team.save()) {
                        returnError(object: team, exception: new RuntimeException(team.errors.toString()))
                    }
                }
                productService.updateTeamMembers(team, newMembers)
                productService.manageTeamInvitations(team, invitedMembers, invitedScrumMasters)
                if (request.admin && newOwnerId && newOwnerId != team.owner.id) {
                    def newOwner = User.get(newOwnerId)
                    securityService.changeOwner(newOwner, team)
                    team.products.each { Product product ->
                        securityService.changeOwner(newOwner, product)
                    }
                }
            }
            render(status: 200, text: team as JSON, contentType: 'application/json')
        } catch (IllegalStateException ise) {
            returnError(text: message(code: ise.message))
        } catch (RuntimeException re) {
            returnError(object: team, exception: re)
        }
    }

    @Secured('isAuthenticated()')
    def delete(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project context (URL)
        if (!securityService.owner(team, auth)) {
            render(status: 403)
            return
        }
        teamService.delete(team)
        render(status: 200, text: [id: id] as JSON)
    }

    @Secured('isAuthenticated()')
    def listByUser(String term, Integer offset) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def limit = 9
        def options = [offset: offset ?: 0, max: limit, sort: "name", order: "asc", cache: true]
        def user = springSecurityService.currentUser
        def teams = request.admin ? Team.findAllByNameIlike(searchTerm, options) : Team.findAllByOwnerOrSM(user.username, options, searchTerm)
        render(status: 200, text: teams as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def countByUser(String term) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def user = springSecurityService.currentUser
        def count = request.admin ? Team.countByNameIlike(searchTerm, [cache: true]) : Team.countByOwnerOrSM(user.username, [cache: true], searchTerm)
        def jsonCount = [count: count]
        render(status: 200, text: jsonCount as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def manage() {
        render(status: 200, template: "dialogs/list")
    }
}
