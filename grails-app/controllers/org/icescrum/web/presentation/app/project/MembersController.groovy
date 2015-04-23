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
    def teamService

    def edit = {
        def product = Product.get(params.product)
        def memberEntries = getTeamMembersEntries(product.firstTeam.id)
        def dialog = g.render(template: "dialogs/members", model: [product: product, team: product.firstTeam, memberEntries: memberEntries])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    @Secured('(owner() or scrumMaster()) and !archivedProduct()')
    def update = {
        withTeam { Team team ->
            def newMembers = params.members.collect { k, v -> [id: v.toLong(), role: params.role[v].toInteger() ]}
            productService.updateTeamMembers(team, newMembers)
            render(status: 200)
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
        def memberEntries = teamService.getTeamMembersEntries(params.long('id'))
        render(status: 200, contentType: 'application/json', text: memberEntries as JSON)
    }
}
