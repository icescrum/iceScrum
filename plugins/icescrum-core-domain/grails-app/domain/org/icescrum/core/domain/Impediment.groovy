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
 */




package org.icescrum.core.domain

class Impediment extends BacklogElement implements Serializable, Comparable<Impediment> {
  static final long serialVersionUID = -4539116826820983569L

  static final int TODO = 1
  static final int SOLVING = 3
  static final int SOLVED = 7

  Date dateOpen = new Date()
  Date dateClose
  String impact = ""
  String solution = ""
  Integer rank
  int state = Impediment.TODO

  static belongsTo = [
          creator: User
  ]

  static hasMany = [tasks: Task]

  static mappedBy = [tasks: 'impediment']

  static transients = ['stateBundle']

  static mapping = {
    cache true
    table 'icescrum2_impediment'
    impact length: 3000
    solution length: 3000
  }

  static constraints = {
    impact(maxSize: 3000)
    dateClose nullable:true
    rank nullable:true
    solution(maxSize: 3000)
  }

  static namedQueries = {
    // Return the highest problem's rank in a product specified by its id
    rankMax { idProduct ->
      projections {
        max('rank')
        backlog {
          eq("id", idProduct)
        }
      }
    }
    // Return the impediment which states are Impediment.UNASSIGNED in a specified product
    filterByUnassignedImpediments { product ->
      backlog {
        eq "id", product.id
      }
      eq "state", Impediment.TODO
    }
    // Return the impediment which states are Impediment.SOLVING in a specified product
    filterBySolvingImpediments { product ->
      backlog {
        eq "id", product.id
      }
      eq "state", Impediment.SOLVING
    }
    // Return the impediment which state are Impediment.SOLVED in a specified product
    filterBySolvedImpediments { product ->
      backlog {
        eq "id", product.id
      }
      eq "state", Impediment.SOLVED
    }
  }

  int hashCode() {
    final int prime = 31
    int result = 1
    result = prime * result
    +((dateOpen == null) ? 0 : dateOpen.hashCode())
    result = prime * result + ((name == null) ? 0 : name.hashCode())
    return result
  }
  
  boolean equals(Object obj) {
    if (this.is(obj))
      return true
    if (obj == null)
      return false
    if (getClass() != obj.getClass())
      return false
    final Impediment other = (Impediment) obj
    if (dateOpen == null) {
      if (other.dateOpen != null)
        return false
    } else if (!dateOpen.equals(other.dateOpen))
      return false
    if (name == null) {
      if (other.name != null)
        return false
    } else if (!name.equals(other.name))
      return false
    return true
  }

  int compareTo(Impediment o) {
    return this.rank.compareTo(o.rank)
  }

  String getStateBundle() {
    switch (state) {
      case 1: return "is_submitted"
      case 2: return "is_validated"
      case 3: return "is_estimated"
      case 4: return "is_planned"
      case 5: return "is_locked"
      case 6: return "is_tested"
      default: return "is_done"
    }
  }
}
