/*
 * Copyright (c) 2011 Kagilum
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
 *
 */

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority

@Secured('isAuthenticated() and (stakeHolder() or inProduct() or owner())')
class MembersController {

    def springSecurityService
    def productService

    def edit = {
        def product = Product.get(params.product)
        def memberEntries = getTeamMembersEntries(product.firstTeam.id)
        def dialog = g.render(template: "dialogs/members", model: [product: product, team: product.firstTeam, memberEntries: memberEntries])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    @Secured(['(owner() or scrumMaster()) and !archivedProduct()', 'RUN_AS_PERMISSIONS_MANAGER'])
    def update = {
        def teamId = params.long('team.id')
        try {
            Team.withTransaction {
                def product = Product.get(params.product)
                Team team
                if (teamId != product.firstTeam.id) {
                    product.removeFromTeams(product.firstTeam)
                    team = Team.get(teamId)
                    product.addToTeams(team)
                } else {
                    team = product.firstTeam
                }
                def currentMembers = productService.getAllMembersProduct(product)
                def idmembers = []
                params.members?.each { k, v ->
                    def u = User.get(v.toLong())
                    def found = currentMembers.find { it.id == u.id }
                    if (found) {
                        if (found.role.toString() != params.role."${k}") {
                            productService.changeRole(product, team, u, Integer.parseInt(params.role."${k}"))
                        }
                    } else {
                        productService.addRole(product, team, u, Integer.parseInt(params.role."${k}"))
                    }
                    idmembers << u.id
                }
                def commons = currentMembers*.id.intersect(idmembers)
                def difference = currentMembers*.id.plus(commons)
                difference.removeAll(commons)
                difference?.each {
                    def found = currentMembers.find { it2 -> it == it2.id }
                    def u = User.get(found.id)
                    productService.removeAllRoles(product, team, u)
                }
                render(status: 200)
            }
        } catch (RuntimeException re) {
            if (log.debugEnabled) re.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.saved')]] as JSON)
        }
    }

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

    @Secured('isAuthenticated()')
    def getTeamEntries = {
        def user = springSecurityService.currentUser
        def teams = request.admin ? Team.list() : Team.findAllByOwner(user.username, null)
        def teamEntries = teams.collect { team -> [id: team.id, text: team.name] }
        render(status: 200, contentType: 'application/json', text: teamEntries as JSON)
    }

    @Secured('isAuthenticated()')
    def getTeamMembers = {
        def memberEntries = getTeamMembersEntries(params.long('id'))
        render(status: 200, contentType: 'application/json', text: memberEntries as JSON)
    }

    private getTeamMembersEntries (Long teamId) {
        def memberEntries = []
        def addEntry = { User user, int role ->
            memberEntries << [name: user.firstName + ' ' + user.lastName,
                              activity: user.preferences.activity ?: '&nbsp;',
                              id: user.id,
                              avatar: is.avatar(user: user, link: true),
                              role: role]
        }
        if (teamId) {
            Team team = Team.get(teamId)
            def scrumMastersIds = team.scrumMasters*.id
            team.members?.each { User member ->
                int role = scrumMastersIds?.contains(member.id) ? Authority.SCRUMMASTER : Authority.MEMBER
                addEntry(member, role)
            }
        } else {
            addEntry(springSecurityService.currentUser, Authority.SCRUMMASTER)
        }
        memberEntries.sort { a, b -> b.role <=> a.role ?: a.name <=> b.name }
    }
}
