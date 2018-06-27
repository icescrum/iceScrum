package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.error.ControllerErrorHandler

class TeamController implements ControllerErrorHandler {

    def springSecurityService
    def projectService
    def teamService
    def securityService

    @Secured('isAuthenticated()')
    def index(String term, Boolean create) {
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%';
        def options = [sort: "name", order: "asc", cache: true]
        def teams = request.admin ? Team.findAllByNameIlike(searchTerm, options) : Team.findAllByOwner(springSecurityService.currentUser.username, options, searchTerm)
        if (create && !teams.any { it.name == term } && !Team.countByName(term)) {
            teams.add(0, [name: params.term, members: [], scrumMasters: []])
        }
        render(status: 200, text: teams as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def show(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project workspace (URL)
        if (!securityService.owner(team, auth) && !securityService.scrumMaster(team, auth)) {
            render(status: 403)
            return
        }
        render(status: 200, text: team as JSON, contentType: 'application/json')
    }

    @Secured(['stakeHolder() or inProject()'])
    def showByProject(long project) {
        Project _project = Project.withProject(project)
        render(status: 200, text: _project.team as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def save() {
        def team = new Team(name: params.team.name)
        Team.withTransaction {
            entry.hook(id: 'team-save-before')
            teamService.save(team, null, [springSecurityService.currentUser.id])
            entry.hook(id: 'team-save')
            render(status: 201, text: team as JSON, contentType: 'application/json')
        }
    }

    @Secured(['isAuthenticated()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def update(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project workspace (URL)
        if (!securityService.owner(team, auth) && !securityService.scrumMaster(team, auth)) {
            render(status: 403)
            return
        }
        def teamParams = params.team
        def newMembers = []
        if (teamParams.scrumMasters) {
            teamParams.scrumMasters.list('id').each {
                newMembers << [id: it.toLong(), role: Authority.SCRUMMASTER]
            }
        }
        if (teamParams.members) {
            teamParams.members.list('id').each {
                def userId = it.toLong()
                if (!newMembers.find { it.id == userId }) {
                    newMembers << [id: userId, role: Authority.MEMBER]
                }
            }
        }
        def invitedMembers = teamParams.invitedMembers ? teamParams.invitedMembers.list('email') : []
        def invitedScrumMasters = teamParams.invitedScrumMasters ? teamParams.invitedScrumMasters.list('email') : []
        def newOwnerId = teamParams.owner?.id?.toLong()
        Team.withTransaction {
            entry.hook(id: 'team-update-before')
            if (team.name != teamParams.name) {
                team.name = teamParams.name
                team.save()
            }
            projectService.updateTeamMembers(team, newMembers)
            projectService.manageTeamInvitations(team, invitedMembers, invitedScrumMasters)
            if (request.admin && newOwnerId && newOwnerId != team.owner.id) {
                def newOwner = User.get(newOwnerId)
                securityService.changeOwner(newOwner, team)
                team.projects.each { Project project ->
                    securityService.changeOwner(newOwner, project)
                }
            }
            entry.hook(id: 'team-update')
        }
        render(status: 200, text: team as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def delete(long id) {
        Team team = Team.withTeam(id)
        def auth = springSecurityService.authentication
        // Cannot check by annotation/request because we are not in a project workspace (URL)
        if (!securityService.owner(team, auth)) {
            render(status: 403)
            return
        }
        teamService.delete(team)
        withFormat {
            html {
                render(status: 200, text: [id: id] as JSON)
            }
            json {
                render(status: 204)
            }
        }
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
