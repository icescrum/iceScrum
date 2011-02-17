/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.team

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.web.support.MenuBarSupport
import grails.plugin.springcache.annotations.Cacheable

@Secured('isAuthenticated() and (stakeHolder() or inProduct() or inTeam())')
class MembersController {

  static ui = true
  def springSecurityService
  def teamService
  def productService
  def securityService

  static final id = 'members'
  static menuBar = MenuBarSupport.teamOrProductDynamicBar('is.ui.members', id, false, 10)
  static window = [title: 'is.ui.members', help: 'is.ui.members.help', toolbar: true, init: 'browse']

  static shortcuts = [
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],
          [code:'is.ui.shortcut.del.code',text:'is.ui.shortcut.members.del.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.members.ctrln.text']
  ]

  def toolbar = {
    render template: 'window/toolbar', model: [id: id, product: Product.get(params.product), team: Team.get(params.team)]
  }

  @Secured('productOwner()')
  def addTeam = {
    render template: 'dialogs/addTeam'
  }

  def index = {}

  @Secured('scrumMaster()')
  def addMember = {
    render template: 'dialogs/addMember'
  }

  @Secured('productOwner()')
  def updateTeams = {
    def product = Product.get(params.product)
    try {
      productService.addTeamsToProduct(product, params.teamid in String ? [params.teamid] : params.teamid)
      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [product: params.product]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: product)]] as JSON)
    }
  }

  @Secured('scrumMaster()')
  def updateMembers = {
    def team = Team.get(params.team)
    try {
      for (m in params.list('userid'))
        teamService.addMember(team, User.get(m))

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [team: params.team]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: team)]] as JSON)
    }
  }

  @Secured('teamMember() or scrumMaster()')
  def beProductOwner = {
    def product = Product.get(params.product)
    try {
      productService.beProductOwner product

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('teamMember()')
  def beScrumMaster = {
    def team = Team.get(params.team)
    try {
      teamService.beScrumMaster(team)

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('scrumMaster()')
  def dontBeScrumMaster = {
    def team = Team.get(params.team)
    try {
      teamService.dontBeSecrumMaster(team)

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('productOwner()')
  def dontBeProductOwner = {
    def product = Product.get(params.product)
    try {
      productService.dontBeProductOwner product

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }


  @Secured('owner()')
  def setProductOwner = {
    def product = Product.get(params.product)
    List idList = params.list('uid')
    try {
      for (m in idList)
        securityService.createProductOwnerPermissions(User.get(m), product)

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [product: params.product]
      //pushOthers "$params.product-members"
    } catch (e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('ROLE_ADMIN')
  def setOwner = {
    def product = Product.get(params.product)
    def team = Team.get(params.team)
    List idList = params.list('uid')
    try {

      def user = User.get(idList[0])
      securityService.changeOwner(user, team ?: product)
      if(team)
        securityService.createScrumMasterPermissions(user,team)
      else if(product)
        securityService.createProductOwnerPermissions(user,product)

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: product ? [product: params.product] : [team: params.team]
      //pushOthers "$params.product-members"
    } catch (e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }


  @Secured('owner()')
  def unsetProductOwner = {
    def product = Product.get(params.product)
    def idList = params.list('uid')
    try {
      for (m in idList)
        securityService.deleteProductOwnerPermissions(User.get(m), product)

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [product: params.product]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('owner()')
  def setScrumMaster = {
    def team = Team.get(params.team)
    def idList = params.list('uid')
    def user
    try {
      for (m in idList){
        user=User.get(m)
        securityService.createScrumMasterPermissions(user, team)
        securityService.deleteTeamMemberPermissions(user, team)
      }

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [team: params.team]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  @Secured('owner()')
  def unsetScrumMaster = {
    def team = Team.get(params.team)
    def idList = params.list('uid')
    def user
    try {
      for (m in idList){
        user=User.get(m)
        securityService.createTeamMemberPermissions(user, team)
        securityService.deleteScrumMasterPermissions(user, team)
      }

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [team: params.team]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.denied')]] as JSON)
    }
  }

  def browse = {
    def teams = []

    if (params.team)
      teams << Team.get(params.team)
    else if (params.product)
      teams = Product.get(params.product).teams

    render model: [teams: teams, principalId: springSecurityService.principal.id], template: 'window/browse'
  }


  @Secured('productOwner() or scrumMaster()')
  def leaveProduct = {
    def product = Product.get(params.product)
    try {
      teamService.removeTeamsFromProduct(product, params.list('id'))
      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [product: params.product]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: product)]] as JSON)
    }
  }

  @Secured('scrumMaster()')
  def deleteMembers = {
    def team = Team.get(params.team)
    try {
      for (m in params.list('id')) {
        if (springSecurityService.principal.id != m)
          teamService.deleteMember(team, User.get(m))
      }

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      redirect action: 'browse', params: [team: params.team]
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: product)]] as JSON)
    }
  }

  @Secured('teamMember()')
  def leaveTeam = {
    def team = Team.get(params.team)
    try {
      teamService.deleteMember(team, User.get((springSecurityService.principal.id)))

      flash.notice = [text: message(code: 'is.team.saved'), type: 'notice']
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (e) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: team)]] as JSON)
    }
  }
}
