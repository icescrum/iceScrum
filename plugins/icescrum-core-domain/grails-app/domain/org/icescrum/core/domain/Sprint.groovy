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

class Sprint extends TimeBox implements Serializable {
  static final long serialVersionUID = -7022481404086376233L

  static final int STATE_WAIT = 1
  static final int STATE_INPROGRESS = 2
  static final int STATE_DONE = 3


  static mappedBy = [
          stories: "parentSprint",
          tasks:"backlog"
  ]

  static hasMany = [
          stories: Story,
          tasks: Task,
  ]

  static belongsTo = [
          parentRelease: Release
  ]

  static transients = [
          'recurrentTasks', 'urgentTasks'
  ]

  static namedQueries = {

    findCurrentSprint {p ->
      parentRelease {
        parentProduct{
          eq 'id',p
        }
        eq 'state', Release.STATE_INPROGRESS
        order("orderNumber", "asc")
      }
      eq 'state', Sprint.STATE_INPROGRESS
      maxResults(1)
    }

    findCurrentOrNextSprint {p ->
      parentRelease {
        parentProduct{
          eq 'id',p
        }
        or {
          eq 'state', Release.STATE_INPROGRESS
          eq 'state', Release.STATE_WAIT
        }
        order("orderNumber", "asc")
      }
      and {
        or {
          eq 'state', Sprint.STATE_INPROGRESS
          eq 'state', Sprint.STATE_WAIT
        }
      }
      maxResults(1)
      order("orderNumber", "asc")
    }

    findCurrentOrLastSprint {p ->
      parentRelease {
        parentProduct{
          eq 'id',p
        }
        or {
          eq 'state', Release.STATE_INPROGRESS
          eq 'state', Release.STATE_DONE
        }
        order("orderNumber", "desc")
      }
      and {
        or {
          eq 'state', Sprint.STATE_INPROGRESS
          eq 'state', Sprint.STATE_DONE
        }
      }
      maxResults(1)
      order("orderNumber", "desc")
    }
  }

  static mapping = {
    table 'icescrum2_sprint'
    retrospective type:'text'
    doneDefinition type:'text'
    stories cascade: 'delete', batchSize: 15, cache: true
    tasks cascade: 'all-delete-orphan', batchSize: 25
    orderNumber index:'s_order_index'
  }

  static constraints = {
    retrospective nullable:true
    doneDefinition nullable:true
    activationDate nullable:true
    closeDate nullable:true
    resource nullable:true
  }

  int state = Sprint.STATE_WAIT
  String retrospective
  String doneDefinition
  Date activationDate
  Date closeDate
  Double velocity = 0d
  Double capacity = 0d
  Double dailyWorkTime = 8d

  Integer resource

  void setDone() {
    this.state = Sprint.STATE_DONE
  }

  @Override
  int hashCode() {
    final int prime = 31
    int result = 1
    result = prime * result + ((!endDate) ? 0 : endDate.hashCode())
    result = prime * result + ((!parentRelease) ? 0 : parentRelease.hashCode())
    result = prime * result + ((!startDate) ? 0 : startDate.hashCode())
    return result
  }

  /**
   * Clone method override.
   *
   * @return
   */
  @Override
  Object clone() {
    Sprint copy
    try {
      copy = (Sprint) super.clone()
    } catch (Exception e) {
      return null
    }

    return copy
  }

  @Override
  boolean equals(Object obj) {
    if (obj == null) {
      return false
    }
    if (getClass() != obj.getClass()) {
      return false
    }
    final Sprint other = (Sprint) obj
    if (this.orderNumber != other.orderNumber && (this.orderNumber == null || !this.orderNumber.equals(other.orderNumber))) {
      return false
    }
    if (this.state != other.state && (this.state == null || !this.state.equals(other.state))) {
      return false
    }
    if ((this.goal == null) ? (other.goal != null) : !this.goal.equals(other.goal)) {
      return false
    }
    if (this.startDate != other.startDate && (this.startDate == null || !this.startDate.equals(other.startDate))) {
      return false
    }
    if (this.endDate != other.endDate && (this.endDate == null || !this.endDate.equals(other.endDate))) {
      return false
    }
    if (this.parentRelease != other.parentRelease && (this.parentRelease == null || !this.parentRelease.equals(other.parentRelease))) {
      return false
    }
    if (this.velocity != other.velocity && (this.velocity == null || !this.velocity.equals(other.velocity))) {
      return false
    }
    if (this.capacity != other.capacity && (this.capacity == null || !this.capacity.equals(other.capacity))) {
      return false
    }
    if (this.dailyWorkTime != other.dailyWorkTime && (this.dailyWorkTime == null || !this.dailyWorkTime.equals(other.dailyWorkTime))) {
      return false
    }
    return true
  }

  def getRecurrentTasks(){
    return tasks?.findAll{ it.type == Task.TYPE_RECURRENT }
  }

  def getUrgentTasks() {
    return tasks?.findAll{ it.type == Task.TYPE_URGENT }
  }

}