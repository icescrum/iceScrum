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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */




package org.icescrum.core.domain

import org.springframework.security.core.context.SecurityContextHolder as SCH
import grails.plugin.attachmentable.Attachmentable

class User implements Serializable, Attachmentable {
  static final long serialVersionUID = 813639032272976126L

  String lastName = "Doe"
  String firstName = "John"
  String username = ""
  String password = ""
  String email
  Date dateCreated
  Date lastUpdated
  preferences.UserPreferences preferences

  boolean enabled = true
  boolean accountExpired
  boolean accountLocked
  boolean passwordExpired


  static hasMany = [
          teams: Team
  ]

  static belongsTo = [Team]

  static transients = [
          'idFromImport'
  ]
  int idFromImport


  static mapping = {
    cache true
    table 'icescrum2_user'
    password column: '`password`'
    username index:'username_index'
  }

  static constraints = {
    username(blank: false, unique: true)
    password(blank: false)
    lastName(blank: false)
    firstName(blank: false)
    email(blank: false, email: true)
  }

  static findExceptTeam(Long id, term, params) {
    executeQuery(
            "SELECT DISTINCT u " +
                    "FROM org.icescrum.core.domain.User as u " +
                    "WHERE u.id != :uid and (lower(u.username) like lower(:term) or lower(u.firstName) like lower(:term) " +
                    "or lower(u.lastName) like lower(:term)) and u.id not in " +
                    "(SELECT DISTINCT u2.id FROM org.icescrum.core.domain.User as u2 " +
                    "INNER JOIN u2.teams as t " +
                    "WHERE t.id = :t) ", [uid: SCH.context.authentication.principal?.id, t:id,term: "%$term%"], params ?: [:])
  }

  static namedQueries = {

    findUsersLike{term ->
      ne('id',SCH.context.authentication.principal?.id)
      or{
        ilike("username","%$term%")
        ilike("lastName","%$term%")
        ilike("firstName","%$term%")
        maxResults(8)
        order("username","asc")
      }
    }
  }


  Set<security.Authority> getAuthorities() {
    security.UserAuthority.findAllByUser(this).collect { it.authority } as Set
  }

  boolean equals(o) {
    if (this.is(o)) return true
    if (!o || getClass() != o.class) return false
    User user = (User) o
    if (!username.equals(user.username)) return false
    return true
  }

  int hashCode() {
    return username.hashCode()
  }
}
