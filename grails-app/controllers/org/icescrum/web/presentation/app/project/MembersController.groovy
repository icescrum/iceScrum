/*
0 * Copyright (c) 2015 Kagilum
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

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User

@Secured('isAuthenticated()')
class MembersController {

    def springSecurityService
    def productService
    def teamService
    def securityService

    @Secured(['inProduct() or stakeHolder()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def leaveTeam = {
        def product = Product.get(params.product)
        def user = springSecurityService.currentUser
        def team = Team.get(product.firstTeam.id)
        def currentMembers = productService.getAllMembersProduct(product)
        try {
            def found = currentMembers.find { it.id == user.id }
            def u = User.get(found.id)
            productService.removeAllRoles(product, team, u, false)
            render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
        } catch (e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: team)]] as JSON)
        }
    }

    def getTeamEntries = {
        def user = springSecurityService.currentUser
        def teams = request.admin ? Team.list() : Team.findAllByOwner(user.username, null)
        def teamEntries = teams.collect { team -> [id: team.id, text: team.name] }
        render(status: 200, contentType: 'application/json', text: teamEntries as JSON)
    }

    def getTeamMembers = {
        def memberEntries = teamService.getTeamMembersEntries(params.long('id'))
        render(status: 200, contentType: 'application/json', text: memberEntries as JSON)
    }

    def browse = {
        def dialog = g.render(template: 'dialogs/browse')
        render(status:200, contentType: 'application/json', text: [dialog:dialog] as JSON)
    }

    def browseList = {
        User user = (User) springSecurityService.currentUser
        def term = params.term ? '%' + params.term.trim().toLowerCase() + '%' : '%%';
        def limit = 9
        def options = [offset:params.int('offset') ?: 0, max: limit, sort: "name", order: "asc", cache:true]
        def teams = request.admin ? Team.findAllByNameLike(term, options) : Team.findAllByOwner(user.username, options, term)
        def total = request.admin ? Team.countByNameLike(term, [cache:true]) : Team.countByOwner(user.username, [cache:true], term)[0]
        def results = []
        teams?.each {
            results << [id: it.id, label: it.name.encodeAsHTML(), image: resource(dir: is.currentThemeImage(), file: 'choose/default.png')]
        }
        render template: "/components/browserColumn",
               plugin: 'icescrum-core',
               model: [name: 'team-browse',
                       max: limit,
                       total: total,
                       term: params.term,
                       offset: params.int('offset') ?: 0,
                       browserCollection: results,
                       actionDetails: 'browseDetails',
                       onSuccess: "attachOnDomUpdate(jQuery('#form-team'));"]
    }

    def browseDetails = {
        withTeam { Team team ->
            def owner = team.owner
            if (!request.admin && owner != springSecurityService.currentUser){
                render(status:403)
                return
            }
            def memberEntries = teamService.getTeamMembersEntries(team.id)
            def possibleOwners = memberEntries.clone()
            if (!possibleOwners*.id.contains(owner.id)){
                possibleOwners.add([name: owner.firstName+' '+owner.lastName,
                                    activity:owner.preferences.activity?:'&nbsp;',
                                    id: owner.id,
                                    avatar:is.avatar(user:owner,link:true)])
            }
            render template: "dialogs/browseDetails", model: [team: team,
                                                              possibleOwners: possibleOwners,
                                                              memberEntries: memberEntries]
        }
    }

    def update = {
        withTeam { Team team ->
            def owner = team.owner
            if (!request.admin && owner != springSecurityService.currentUser){
                render(status:403)
                return
            }
            def newMembers = params.members.collect { k, v -> [id: v.toLong(), role: params.role[v].toInteger() ]}
            def newOwnerId = params.team.owner?.toLong()
            Team.withTransaction {
                if (team.name != params.team.name) {
                    team.name = params.team.name
                    if (!team.save()) {
                        returnError(object:team, exception: new RuntimeException(team.errors.toString()))
                    }
                }
                productService.updateTeamMembers(team, newMembers)
                if (newOwnerId && newOwnerId != team.owner.id){
                    securityService.changeOwner(User.get(newOwnerId), team)
                }
            }
            render(status: 200)
        }
    }

    def delete = {
        withTeam { Team team ->
            def owner = team.owner
            if (!request.admin && owner != springSecurityService.currentUser){
                render(status:403)
                return
            }
            teamService.delete(team)
            render(status: 200)
        }
    }
}
