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



package org.icescrum.core.domain

import org.icescrum.core.services.SecurityService
import org.icescrum.core.domain.preferences.TeamPreferences

class Team {

  String name
  int velocity = 0
  String description

  Date dateCreated
  Date lastUpdated

  TeamPreferences preferences

  static hasMany = [
          products: Product,
          members: User
  ]

  static transients = [
          'idFromImport',
          'scrumMasters'
  ]

  def scrumMasters = null
  int idFromImport

  static belongsTo = [Product]

  static constraints = {
    description(nullable: true, maxSize: 1000)
    name(blank: false, unique: true)
  }

  static mapping = {
    cache true
    preferences lazy: true
    table 'icescrum2_team'
    products cache: true
    members lazy:false, cache:true
  }

  static members(Team team, params) {
    executeQuery('select distinct t.members as m from org.icescrum.core.domain.Team as t where t.id=:id', [id: team.id], params ?: [:])
  }

  static products(Team team, params) {
    executeQuery('select distinct t.products as p from org.icescrum.core.domain.Team as t where t.id=:id', [id: team.id], params ?: [:])
  }

  static exceptMember(Long id, String term, params) {
    executeQuery(
            "SELECT DISTINCT t " +
                    "FROM org.icescrum.core.domain.Team as t " +
                    "WHERE t.id not in " +
                    "(SELECT DISTINCT t2.id FROM org.icescrum.core.domain.Team as t2 " +
                    "INNER JOIN t2.members as m " +
                    "WHERE m.id = :u) AND lower(t.name) like :term " +
                    "AND t.preferences.allowNewMembers = :allow ", [allow:true, term: "%$term%", u: id], params ?: [:])
  }

  static countExceptMember(Long id, params) {
    executeQuery(
            "SELECT DISTINCT count(t) " +
                    "FROM org.icescrum.core.domain.Team as t " +
                    "WHERE t.id not in " +
                    "(SELECT DISTINCT t2.id FROM org.icescrum.core.domain.Team as t2 " +
                    "INNER JOIN t2.members as m " +
                    "WHERE m.id = :u) AND t.preferences.allowNewMembers = :allow", [allow: true, u: id], params ?: [:])
  }

  static findExceptProduct(Long id, term, params) {
    executeQuery(
            "SELECT DISTINCT t " +
                    "FROM org.icescrum.core.domain.Team as t " +
                    "WHERE lower(t.name) like lower(:term) and t.id not in " +
                    "(SELECT DISTINCT t2.id FROM org.icescrum.core.domain.Team as t2 " +
                    "INNER JOIN t2.products as p " +
                    "WHERE p.id = :p) ", [p: id,term: "%$term%"], params ?: [:])
  }

  static namedQueries = {

    productTeam {p, u ->
      products {
        idEq(p)
      }
      members {
        idEq(u)
      }
    }


    teamLike {term ->
      ilike("name", "%$term%")
    }

  }

  def aclUtilService
  def getScrumMasters(){
    if (this.scrumMasters){
      this.scrumMasters
    }else if(this.id) {
      def acl = aclUtilService.readAcl(this.getClass(), this.id)
      def scrumMastersList = User.withCriteria {
        or{
          acl.entries.findAll{it.permission in SecurityService.scrumMasterPermissions}*.sid.each{sid ->
            eq('username', sid.principal)
          }
        }
      }
      scrumMastersList
    }else{
      null
    }
  }

  boolean equals(o) {
    if (this.is(o)) return true;
    if (getClass() != o.class) return false;

    Team team = (Team) o;

    if (name != team.name) return false;

    return true;
  }

  int hashCode() {
    return name.hashCode();
  }
}
