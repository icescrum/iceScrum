/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */


package org.icescrum.core.services

import groovy.util.slurpersupport.NodeChild
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.preferences.TeamPreferences
import org.icescrum.core.support.ProgressSupport
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.access.annotation.Secured
import org.springframework.security.access.prepost.PostFilter
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumTeamEvent
import org.icescrum.core.event.IceScrumProductEvent

class TeamService {

  static transactional = true

  def springSecurityService
  def securityService
  def springcacheService
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()


  @PreAuthorize("inTeam(#teamId)")
  Team openTeam(Long teamId) {
    Team.get(teamId)
  }

  @PostFilter("inTeam(filterObject) and !hasRole('ROLE_ADMIN')")
  List getTeamList() {
    return Team.list(cache: true)
  }

  void saveTeam(Team team, memberIds, userid) {
    if (!team)
      throw new RuntimeException('is.team.error.not.exist')

    if (!team.save()) {
      throw new RuntimeException('is.team.error.not.saved')
    }

    else {
      securityService.secureDomain(team)
      def currentUser = User.get(userid)
      if (memberIds) {
        for (member in User.getAll(memberIds*.toLong())) {
          if (currentUser.id != member.id) {
            team.addToMembers(member)
            securityService.createTeamMemberPermissions member, team
          }
        }
      }
      team.addToMembers(currentUser)
      securityService.createScrumMasterPermissions currentUser, team
      if (!team.save()) {
        throw new RuntimeException()
      }
      publishEvent(new IceScrumTeamEvent(team,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
    }

  }

  void updateTeam(Team _team) {
    if (!_team.name?.trim()) {
      throw new IllegalStateException("is.product.error.no.name")
    }

    if (!_team.save(flush:true)) {
      throw new RuntimeException()
    }
    publishEvent(new IceScrumTeamEvent(_team,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }

  void deleteTeam(Team team) {
    if (!team)
      throw new IllegalStateException('Team must not be null')

    Team.withSession {session ->

      def toDelete = team.products.collect {it}

      for (product in toDelete)
        removeTeamsFromProduct(product, [team.id])
      session.flush()

      toDelete = team.members.collect {it}

      for (member in toDelete)
        removeTeamsFromUser(member, [team.id])

      team.delete()

      securityService.unsecureDomain team
      publishEvent(new IceScrumTeamEvent(team,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
    }

  }

  void removeTeamsFromUser(User _user, teamIds) {
    if (!_user)
      throw new IllegalStateException('_user must not be null')

    if (!teamIds)
      throw new IllegalStateException('_user must have at least one team')


    for (team in Team.getAll(teamIds)) {
      _user.removeFromTeams(team)
      securityService.deleteTeamMemberPermissions _user, team
      securityService.deleteScrumMasterPermissions _user, team
    }

    if (!_user.save())
      throw new IllegalStateException('_user not saved')
  }


  void removeTeamsFromProduct(Product _product, teamIds) {
    if (!_product)
      throw new IllegalStateException('Product must not be null')

    if (!teamIds)
      throw new IllegalStateException('Product must have at least one team')


    for (team in Team.getAll(teamIds)) {
      if (team)
        _product.removeFromTeams(team)
        publishEvent(new IceScrumProductEvent(_product,team,this.class,User.get(springSecurityService.principal?.id),IceScrumProductEvent.EVENT_TEAM_REMOVED))
    }

    if (!_product.save())
      throw new IllegalStateException('Product not saved')

    springcacheService.flush(SecurityService.CACHE_OPENPRODUCTTEAM)
    springcacheService.flush(SecurityService.CACHE_PRODUCTTEAM)

  }

  void saveImportedTeam(Team team) {
    if (!team)
      throw new IllegalStateException('is.team.error.not.exist')

    if (!team.save()) {
      throw new RuntimeException('is.team.error.not.saved')
    }

    def scrumMasters = team.scrumMasters
    securityService.secureDomain(team)

    def u = User.get(springSecurityService.principal?.id)
    for (member in team.members) {
      if (!(member in scrumMasters))
        securityService.createTeamMemberPermissions member, team
    }
    if (scrumMasters){
      scrumMasters.eachWithIndex {it,index ->
        securityService.createScrumMasterPermissions it, team
      }
      securityService.changeOwner(team.scrumMasters.first(),team)
    }else{
      securityService.createScrumMasterPermissions u, team
      securityService.changeOwner(u,team)
    }
    publishEvent(new IceScrumTeamEvent(team,this.class,u,IceScrumEvent.EVENT_CREATED))
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void beScrumMaster(Team t) {
    if (t.preferences.allowRoleChange)
      throw new AccessDeniedException('')

    def user = User.get(springSecurityService.principal.id)
    securityService.createScrumMasterPermissions user, t
    securityService.deleteTeamMemberPermissions user, t
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void dontBeSecrumMaster( Team t) {
    if (t.preferences.allowRoleChange)
      throw new AccessDeniedException('')

    def u = User.get(springSecurityService.principal.id)

    securityService.deleteScrumMasterPermissions u, t
    securityService.createTeamMemberPermissions u, t
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void addMember(Team team, User member) {
    team.addToMembers(member).save()
    securityService.createTeamMemberPermissions member, team
    springcacheService.getOrCreateCache(SecurityService.CACHE_OPENPRODUCTTEAM).flush()
    springcacheService.getOrCreateCache(SecurityService.CACHE_PRODUCTTEAM).flush()
    publishEvent(new IceScrumTeamEvent(team,member,this.class,User.get(springSecurityService.principal?.id),IceScrumTeamEvent.EVENT_MEMBER_ADDED))
  }

  @Secured(['ROLE_USER', 'RUN_AS_PERMISSIONS_MANAGER'])
  void deleteMember(Team team, User member) {
    team.removeFromMembers(member).save()
    securityService.deleteTeamMemberPermissions member, team
    springcacheService.getOrCreateCache(SecurityService.CACHE_OPENPRODUCTTEAM).flush()
    springcacheService.getOrCreateCache(SecurityService.CACHE_PRODUCTTEAM).flush()
    publishEvent(new IceScrumTeamEvent(team,member,this.class,User.get(springSecurityService.principal?.id),IceScrumTeamEvent.EVENT_MEMBER_REMOVED))
  }


  @Transactional(readOnly = true)
  def unMarshallTeam(NodeChild team, Product p = null, ProgressSupport progress = null) {
    try {
      def existingTeam = true
      def t = new Team(
              name: team.name.text(),
              velocity: (team.velocity.text().isNumber()) ? team.velocity.text().toInteger() : 0,
              description: team.description.text(),
              idFromImport: team.@id.text().toInteger()
      )

      t.preferences = new TeamPreferences(
              allowNewMembers: team.preferences.allowNewMembers.text()?.toBoolean() ?: true,
              allowRoleChange: team.preferences.allowRoleChange.text()?.toBoolean() ?: true
      )

      def userService = (UserService) ApplicationHolder.application.mainContext.getBean('userService');
      team.members.user.eachWithIndex {user, index ->
        User u = userService.unMarshallUser(user)
        if (!u.id) {
          existingTeam = false
        }
        if (p){
          def uu =(User) p.getAllUsers().find{ def id = it.idFromImport?:it.id
                                   id == u.idFromImport
                                 }?:null
          uu ? t.addToMembers(uu) : t.addToMembers(u)
        }else{
          t.addToMembers(u)
        }
        progress?.updateProgress((team.members.user.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.user')]))
      }
      def scrumMastersList = []
      team.scrumMasters.scrumMaster.eachWithIndex {user, index ->
        User u = (User) t?.members?.find {it.idFromImport == user.@id.text().toInteger()} ?: null
        if (u)
          scrumMastersList << u
        progress?.updateProgress((team.members.user.size() * (index + 1) / 100).toInteger(), g.message(code: 'is.parse', args: [g.message(code: 'is.user')]))
      }
      t.scrumMasters = scrumMastersList

      if (existingTeam) {
        Team dbTeam = Team.findByName(t.name)
        if (dbTeam) {
          if (dbTeam.members.size() != t.members.size()) existingTeam = false
          if (existingTeam) {
            for (member in dbTeam.members) {
              def u = t.members.find {member.username == it.username && member.email == it.email}
              if (!u) {
                existingTeam = false
                break
              }
              u.idFromImport = t.members.find {it.username == member.username}.idFromImport
            }
          }
        } else {
          existingTeam = false
        }
        if (existingTeam) {
          return dbTeam
        } else {
          return t
        }
      } else {
        return t
      }
    } catch (Exception e) {
      if (log.debugEnabled) e.printStackTrace()
      progress?.progressError(g.message(code: 'is.parse.error', args: [g.message(code: 'is.team')]))
      throw new RuntimeException(e)
    }
  }
}
