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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */




package org.icescrum.core.domain

class Feature extends BacklogElement implements Serializable {
  static final long serialVersionUID = 7072515028109185168L

  static final int TYPE_FUNCTIONAL = 0
  static final int TYPE_ARCHITECTURAL = 1

  String color = "blue"
  
  Integer value = null
  int type = Feature.TYPE_FUNCTIONAL
  int rank

  static transients = ['countFinishedStories']

  static belongsTo = [
          parentDomain: Domain
  ]
  
  static hasMany = [stories: Story]

  static mappedBy = [stories: "feature"]

  static mapping = {
    cache true
    table 'icescrum2_feature'
    stories cascade: "refresh", sort: 'rank', 'name':'asc', cache: true
    sort "id"    
  }

  static constraints = {
    parentDomain(nullable:true)
    value(nullable:true)
  }

  static namedQueries = {

    findInAll{p, term ->
      backlog {
          eq 'id', p
        }
        or {
          ilike 'name', term
          ilike 'description', term
          ilike 'notes', term
        }
    }
  }

  int hashCode() {
    final int prime = 31
    int result = 1
    result = prime * result + ((!name) ? 0 : name.hashCode())
    result = prime * result + ((!backlog) ? 0 : backlog.hashCode())
    return result
  }

  boolean equals(Object obj) {
    if (this.is(obj))
      return true
    if (obj == null)
      return false
    if (getClass() != obj.getClass())
      return false
    final Feature other = (Feature) obj
    if (name == null) {
      if (other.name != null)
        return false
    }else if (!name.equals(other.name))
      return false
    if (backlog == null) {
      if (other.backlog != null)
        return false
    } else if (!backlog.equals(other.backlog))
      return false
    return true
  }

}
