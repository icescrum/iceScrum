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

class Actor extends BacklogElement implements Serializable, Comparable<Actor> {

  static final long serialVersionUID = 2762136778121132424L

  static final int NUMBER_INSTANCES_INTERVAL_1 = 0
  static final int NUMBER_INSTANCES_INTERVAL_2 = 1
  static final int NUMBER_INSTANCES_INTERVAL_3 = 2
  static final int NUMBER_INSTANCES_INTERVAL_4 = 3
  static final int NUMBER_INSTANCES_INTERVAL_5 = 4

  static final int EXPERTNESS_LEVEL_LOW = 0
  static final int EXPERTNESS_LEVEL_MEDIUM = 1
  static final int EXPERTNESS_LEVEL_HIGH = 2

  static final int USE_FREQUENCY_HOUR = 0
  static final int USE_FREQUENCY_DAY = 1
  static final int USE_FREQUENCY_WEEK = 2
  static final int USE_FREQUENCY_MONTH = 3
  static final int USE_FREQUENCY_TRIMESTER = 4

  String satisfactionCriteria = ""

  int instances = Actor.NUMBER_INSTANCES_INTERVAL_1
  int expertnessLevel = Actor.EXPERTNESS_LEVEL_MEDIUM
  int useFrequency = Actor.USE_FREQUENCY_WEEK


  static hasMany = [stories: Story]

  static mappedBy = [stories: "actor"]

  static mapping = {
    cache true
    table 'icescrum2_actor'
    stories cascade: "refresh, evict", cache: true
  }

  static constraints = {
    satisfactionCriteria(nullable:true)
  }

  static namedQueries = {
    findActorByProductAndTerm { pid, term ->
      backlog {
          eq 'id', pid
      }
      or {
        ilike 'name', term
        ilike 'description', term
        ilike 'notes', term
      }
    }
  }

  @Override
  boolean equals(Object obj) {
    if (this.is(obj))
      return true
    if (obj == null)
      return false
    if (getClass() != obj.getClass())
      return false
    final Actor other = (Actor) obj
    if (backlog == null) {
      if (other.backlog != null)
        return false
    } else if (!backlog.equals(other.backlog))
      return false
    if (name != other.name)
      return false
    if (instances != other.instances)
      return false
    if (description != other.description)
      return false
    if (satisfactionCriteria != other.satisfactionCriteria)
      return false
    if (expertnessLevel != other.expertnessLevel)
      return false
    if (useFrequency != other.useFrequency)
      return false
    return true
  }

  @Override
  int hashCode() {
    final int prime = 31
    int result = 1
    result = prime * result + ((backlog == null) ? 0 : backlog.hashCode())
    result = prime * result + name.hashCode()
    return result
  }

  int compareTo(Actor cr) {
    return name.compareTo(cr.name)
  }
  
}
