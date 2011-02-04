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

import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.TeamPreferences
import org.icescrum.web.support.MenuBarSupport
import org.icescrum.core.domain.security.Authority
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.core.support.ApplicationSupport
import grails.plugin.springcache.annotations.Cacheable
import grails.plugin.springcache.annotations.CacheFlush

@Secured('isAuthenticated()')
class TeamController {

  static ui = true

  def springSecurityService
  def teamService
  def productService
  def grailsApplication

  static final id = 'team'
  static menuBar = MenuBarSupport.teamDynamicBar('is.ui.project', id, true, 1)
  static window = [title: 'is.ui.project', help: 'is.ui.project.help', toolbar: false, init: 'dashboard']


  def create = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.team.creation.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }
    render template: 'dialogs/create', model: [user: User.get(springSecurityService.principal.id)]
  }

  def save = {
    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.team.creation.enable)){
        if(!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)){
        render(status:403)
        return
      }
    }

    def team = new Team(params.team)
    team.preferences = new TeamPreferences()
    try {
      teamService.saveTeam team, params.searchid
      flash.message = "is.team.saved"
      render(text: jq.jquery(null, "document.location='${createLink(controller: 'team', params: [team: team.id])}';"))
    } catch (e) {
      e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
    }

  }

  def openProperties = {
    def currentTeam = Team.get(params.long('team'))
    render(template: "dialogs/properties", model: [team: currentTeam])
  }


  @Secured('scrumMaster()')
  def update = {

    def msg
    def currentTeam = Team.get(params.long('teamd.id'))
    if (params.long('teamd.version') != currentTeam.version) {
      msg = message(code: 'is.stale.object', args: [message(code: 'is.team')])
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    currentTeam.properties = params.teamd

    try {
      teamService.updateTeam(currentTeam)
    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: message(code: ise.getMessage()))
      return
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: currentTeam)]] as JSON)
      return
    }
    render(status: 200, contentType: 'application/json', text: [name: currentTeam.name, notice: message(code: 'is.team.updated')] as JSON)
    pushOthers "${params.team}-team"
  }

  def teamDetails = {
    if (!params.currentTeam) {
      params.currentTeam = Team.get(params.team)
    }
    render(template: "dialogs/details", model: [id: id, currentTeam: params.currentTeam])
  }

  def findMembers = {
    def users
    def results = []

    users = User.findUsersLike(params.term ?: '').list()



    users?.each {
      results << [id: it.id, label: "$it.firstName $it.lastName ($it.username)",
              value: it.username,
              image: createLink(controller: 'user', action: 'avatar', id: it.id), extra: "${it.teams?.size()} ${message(code: 'is.ui.team.assigned')}<br />${it.preferences.activity ?: ''}"]
    }

    render(results as JSON)
  }

  def findTeams = {
    def teams
    def results = []
    teams = Team.teamLike(params.term ?: '').list(max: 10)

    teams?.each {
      results << [id: it.id, label: it.name, value: it.members.collect {it2 -> [id: it2.id, label: it2.username, value: it2.username]},
              image: resource(dir: is.currentThemeImage(), file: 'choose/default.png'), extra: "${it.members?.size()} ${message(code: 'is.ui.user.assigned')}"
      ]
    }

    render(results as JSON)
  }

  @Secured('owner()')
  def delete = {
    if (!params.team) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)

    }
    assert params.team

    def team = Team.get(params.team)
    try {
      teamService.deleteTeam(team)
      pushOthers "${params.team}-team-delete"
      team.products.each {
        pushOthers "${it.id}-product-delete"
      }
      render(status: 200, contentType: 'application/json', text: [url: createLink(uri: '/')] as JSON)
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.deleted')]] as JSON)
    }
  }


  def joinList = {
    def max = 7

    def total
    def teams
    teams = Team.exceptMember(springSecurityService.principal.id, params.term ?: '', [offset: params.int('offset') ?: 0, max: max, sort: "name", order: "asc"])
    total = Team.countExceptMember(springSecurityService.principal.id, [:])[0]

    def results = []
    teams?.each {
      results << [id: it.id, label: it.name.encodeAsHTML(),
              image: resource(dir: is.currentThemeImage(), file: 'choose/default.png'), extra: "${it.members?.size()} ${message(code: 'is.ui.user.assigned')}"
      ]
    }

    render template: "/components/browserColumn", plugin: 'icescrum-core-webcomponents', model: [name: 'team-join', max: max, total: total, term: params.term, offset: params.int('offset') ?: 0, browserCollection: results, actionDetails: 'details']
  }

  def detailsMembers = {
    def team = Team.get(params.id)
    def max = 14
    if (!team) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)
      return
    }

    def members = Team.members(team, [max: max, offset: params.int('offset') ?: 0, sort: 'm.name'])
    render template: 'dialogs/chooseDetailsMembers', model: [members: members,
            max: max,
            total: team.members?.size(),
            offset: params.int('offset') ?: 0,
            team: team]
  }

  def detailsProducts = {
    def team = Team.get(params.id)
    def max = 14
    if (!team) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)
      return
    }
    def products = Team.products(team, [max: max, offset: params.int('offset') ?: 0, sort: 'p.name'])
    render template: 'dialogs/chooseDetailsProducts', model: [products: products,
            max: max,
            total: team.products?.size(),
            offset: params.int('offset') ?: 0,
            team: team]
  }



  def details = {
    def team = Team.get(params.id)
    if (!team) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)
      return
    }

    render template: "dialogs/chooseDetails", model: [team: team]
  }

  def join = {
    render template: 'dialogs/choose'
  }


  def requestMembership = {
    def team = Team.get(params.id)
    if (!team) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)
      return
    }

    try {
      teamService.addMember(team, User.get(springSecurityService.principal.id))
      flash.message = "is.team.saved"
      render(text: jq.jquery(null, "document.location='${createLink(controller: 'team', params: [team: team.id])}';"))
    } catch (e) {
      e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.team.error.not.exist')]] as JSON)
    }
  }

  def index = {
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def locale = RCU.getLocale(request)
    if (locale.toString() != currentUserInstance.preferences.language) {
      RCU.getLocaleResolver(request).setLocale(request, response, new Locale(currentUserInstance.preferences.language))
    }
    forward controller: 'scrumOS', action: 'index', params: params
  }


  def openWidget = {
    if (!params.window) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.no.widget')]] as JSON)
      return
    }
    def controllerRequested = "${params.window}Controller"
    def controller = grailsApplication.uIControllerClasses.find {
      it.shortName.toLowerCase() == controllerRequested.toLowerCase()
    }
    if (controller) {
      if (!session['widgetsTeamList']?.contains(params.window)) {
        session['widgetsTeamList'] = session['widgetsTeamList'] ?: []
        session['widgetsTeamList'].add(params.window)
      }
      render is.widget([
              id: params.window,
              pushDisabled: grailsApplication.config?.icepush?.disabled ?: true,
              hasToolbar: (controller.getPropertyValue('widget')?.toolbar != null) ?controller.getPropertyValue('widget')?.toolbar: true,
              hasTitleBarContent: controller.getPropertyValue('widget')?.titleBarContent ?: false,
              title: message(code: controller.getPropertyValue('widget')?.title ?: ''),
              init: controller.getPropertyValue('widget')?.init ?: 'indexWidget',
              controller: controller
      ], {})
    }
  }

  def closeWindow = {
    forward controller: 'scrumOS', action: 'closeWindow', params: params
  }

  def closeWidget = {
    if (session['widgetsTeamList']?.contains(params.window))
      session['widgetsTeamList'].remove(params.window);
    render(status: 200)
  }

  def changeView = {
    forward controller: 'scrumOS', action: 'changeView', params: params
  }

  def openWindow = {
    if (!params.window) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.no.window')]] as JSON)
      return
    }
    session['currentWindow'] = params.window
    session['currentView'] = session['currentView'] ?: springSecurityService.isLoggedIn() ? 'postitsView' : 'tableView'

    if (session['widgetsTeamList']?.contains(params.window))
      session['widgetsTeamList'].remove(params.window);

    def controllerRequested = "${params.window}Controller"
    def controller = grailsApplication.uIControllerClasses.find {
      it.shortName.toLowerCase() == controllerRequested.toLowerCase()
    }

    render is.window([
            window: params.window,
            pushDisabled: grailsApplication.config?.icepush?.disabled ?: true,
            title: message(code: controller.getPropertyValue('window')?.title ?: ''),
            help: message(code: controller.getPropertyValue('window')?.help ?: null),
            hasToolbar: (controller.getPropertyValue('window')?.toolbar != null) ?controller.getPropertyValue('window')?.toolbar: true,
            hasTitleBarContent: controller.getPropertyValue('window')?.titleBarContent ?: false,
            init: params.actionWindow ?: controller.getPropertyValue('window').init ?: 'index',
            controller: controller
    ], {})
  }

  def reloadToolbar = {
    forward controller: 'scrumOS', action: 'reloadToolbar', params: params
  }

  def changeMenuOrder = {
    forward controller: 'scrumOS', action: 'changeMenuOrder', params: params
  }

  def sendError = {
    forward controller: 'scrumOS', action: 'sendError', params: params
  }

  def dashboard = {
    def currentTeam = Team.get(params.long('team'))
    render template: 'window/dashboard', model: [team: currentTeam, storyActivities: Story.recentActivity(currentTeam)]
  }
}
