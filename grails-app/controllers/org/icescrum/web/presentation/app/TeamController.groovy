package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority

@Secured('isAuthenticated()')
class TeamController {

    def springSecurityService
    def productService
    def teamService
    def securityService

    @Secured('isAuthenticated()')
    def search(String term, Boolean create) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def teams = request.admin ? Team.findAllByNameLike(searchTerm, options) : Team.findAllByOwner(springSecurityService.currentUser.username, [sort: "name", order: "asc", cache:true], searchTerm)
        if (!teams.any { it.name == term } && create) {
            teams.add(0, [name: params.term, members: [], scrumMasters: []])
        }
        withFormat{
            html {
                render(status:200, text:teams as JSON, contentType:'application/json')
            }
            json { renderRESTJSON(text:teams) }
            xml  { renderRESTXML(text:teams) }
        }
    }

    @Secured('isAuthenticated()')
    def listByUser(String term, Integer offset) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def limit = 4
        def options = [offset: offset ?: 0, max: limit, sort: "name", order: "asc", cache:true]
        def user = springSecurityService.currentUser
        def total = request.admin ? Team.countByNameLike(searchTerm, [cache:true]) : Team.countByOwnerOrSM(user.username, [cache:true], searchTerm)
        def teams = request.admin ? Team.findAllByNameLike(searchTerm, options) : Team.findAllByOwnerOrSM(user.username, options, searchTerm)
        def teamsAndTotal = [teams: teams, total: total]
        withFormat{
            html {
                render(status:200, text:teamsAndTotal as JSON, contentType:'application/json')
            }
            json { renderRESTJSON(text:teamsAndTotal) }
            xml  { renderRESTXML(text:teamsAndTotal) }
        }
    }

    @Secured(['isAuthenticated()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def update(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project context (URL)
        if (!securityService.owner(team, auth) && !securityService.scrumMaster(team, auth)){
            render(status:403)
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
                        returnError(object:team, exception: new RuntimeException(team.errors.toString()))
                    }
                }
                productService.updateTeamMembers(team, newMembers)
                productService.manageTeamInvitations(team, invitedMembers, invitedScrumMasters)
                if (request.admin && newOwnerId && newOwnerId != team.owner.id){
                    def newOwner = User.get(newOwnerId)
                    securityService.changeOwner(newOwner, team)
                    team.products.each { Product product ->
                        securityService.changeOwner(newOwner, product)
                    }
                }
            }
            render(status:200, text:team as JSON, contentType:'application/json')
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
        if (!securityService.owner(team, auth)){
            render(status:403)
            return
        }
        teamService.delete(team)
        render(status: 200)
    }

    @Secured('isAuthenticated()')
    def save() {
        def team = new Team(name: params.team.name)
        try {
            Team.withTransaction {
                teamService.save(team, null, [springSecurityService.currentUser.id])
                render(status:200, text:team as JSON, contentType:'application/json')
            }
        } catch (IllegalStateException ise) {
            returnError(text: message(code: ise.message))
        } catch (RuntimeException re) {
            returnError(object: team, exception: re)
        }
    }

    @Secured('isAuthenticated()')
    def manage() {
        render(status:200, template: "dialogs/list")
    }
}
