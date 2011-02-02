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

class Release extends TimeBox implements Cloneable {

  static final long serialVersionUID = -8505932836642777504L

  static final int STATE_WAIT = 1
  static final int STATE_INPROGRESS = 2
  static final int STATE_DONE = 3

  int state = Release.STATE_WAIT
  Double releaseVelocity = 0d
  String vision = ""
  String name = "R"
  SortedSet<Sprint> sprints

  static belongsTo = [parentProduct: Product]

  static hasMany = [sprints: Sprint]

  static mappedBy = [sprints: 'parentRelease']

  static transients = ['firstDate']

  static mapping = {
    cache true
    table 'icescrum2_release'
    vision type:'text'
    sprints cascade: 'all-delete-orphan', sort: 'id', cache: true
    name index:'rel_name_index'
  }

  static constraints = {
    vision nullable: true
    name(blank: false,unique:'parentProduct')
  }

  static namedQueries = {
    findCurrentOrNextRelease {p ->
      parentProduct{
        eq 'id',p
      }
      or {
        eq 'state', Release.STATE_INPROGRESS
        eq 'state', Release.STATE_WAIT
      }
      order("orderNumber", "asc")
      maxResults(1)
    }
  }

  int hashCode() {
    final int prime = 31
    int result = 1
    result = prime * result + ((!name) ? 0 : name.hashCode())
    result = prime * result + ((!parentProduct) ? 0 : parentProduct.hashCode())
    return result
  }

  boolean equals(Object obj) {
    if (this.is(obj))
      return true
    if (obj == null)
      return false
    if (getClass() != obj.getClass())
      return false
    final Release other = (Release) obj
    if (name == null) {
      if (other.name != null)
        return false
    } else if (name != other.name)
      return false
    if (parentProduct == null) {
      if (other.parentProduct != null)
        return false
    } else if (!parentProduct.equals(other.parentProduct))
      return false
    return true
  }

  Date getFirstDate() {
    if (sprints?.size() > 0)
      return sprints.asList().last().endDate
    else
      return startDate
  }
}
