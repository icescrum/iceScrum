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

class Story extends BacklogElement implements Cloneable {

  static final long serialVersionUID = -6800252507987149001L

  static final int STATE_SUGGESTED = 1
  static final int STATE_ACCEPTED = 2
  static final int STATE_ESTIMATED = 3
  static final int STATE_PLANNED = 4
  static final int STATE_INPROGRESS = 5
  static final int STATE_DONE = 7
  static final int TYPE_USER_STORY = 0
  static final int TYPE_DEFECT = 2
  static final int TYPE_TECHNICAL_STORY = 3
  static final int EXECUTION_FREQUENCY_HOUR = 0
  static final int EXECUTION_FREQUENCY_DAY = 1
  static final int EXECUTION_FREQUENCY_WEEK = 2
  static final int EXECUTION_FREQUENCY_MONTH = 3

  int type = 0
  int executionFrequency = Story.EXECUTION_FREQUENCY_DAY
  Date suggestedDate
  Date acceptedDate
  Date plannedDate
  Date estimatedDate
  Date inProgressDate
  Date doneDate
  String origin = ""
  Integer effort = null
  int rank = 0
  int state = Story.STATE_SUGGESTED
  int value = 0
  String textAs
  String textICan
  String textTo
  String affectVersion


  static belongsTo = [
          creator: User,
          feature: Feature,
          parentSprint: Sprint,
          actor: Actor
  ]

  static hasMany = [
          tasks: Task
  ]

  static mappedBy = [
          tasks: 'parentStory'
  ]

  static transients = [
          'todo'
  ]

  static mapping = {
    cache true
    table 'icescrum2_story'
    tasks cascade: 'all'
  }

  static constraints = {
    textAs(maxSize: 500, nullable: true)
    textICan(maxSize: 1000, nullable: true)
    textTo(maxSize: 1000, nullable: true)
    suggestedDate(nullable: true)
    acceptedDate(nullable: true)
    estimatedDate(nullable: true)
    plannedDate(nullable: true)
    inProgressDate(nullable: true)
    doneDate(nullable: true)
    parentSprint(nullable: true)
    feature(nullable: true)
    actor(nullable: true)
    affectVersion(nullable: true)
    effort(nullable:true)
    creator(nullable: true) // in case of a user deletion, the story can remain without owner
  }

  static namedQueries = {

    findInStoriesSuggested {p, term ->
      backlog {
        eq 'id', p
      }
      or {
        ilike 'name', term
        ilike 'textAs', term
        ilike 'textICan', term
        ilike 'textTo', term
        ilike 'description', term
        ilike 'notes', term
        feature {
          ilike 'name', term
        }
      }
      and {
        eq 'state', Story.STATE_SUGGESTED
      }
    }

    findInStoriesAcceptedEstimated {p, term ->
      backlog {
        eq 'id', p
      }
      or {
        ilike 'name', term
        ilike 'textAs', term
        ilike 'textICan', term
        ilike 'textTo', term
        ilike 'description', term
        ilike 'notes', term
        feature {
          ilike 'name', term
        }
      }
      and {
        or {
          eq 'state', Story.STATE_ACCEPTED
          eq 'state', Story.STATE_ESTIMATED
        }
      }
    }

    findAllStoriesInSprints { p ->
      parentSprint {
        parentRelease {
          parentProduct {
            eq 'id', p.id
          }
          order('orderNumber')
        }
        order('orderNumber')
      }
      order('rank')
    }

    findNextStoryInSprints {p ->
      parentSprint {
        parentRelease {
          parentProduct {
            eq 'id', p.id
          }
          order('orderNumber')
        }
        order('orderNumber')
      }
      order('rank')
    }

    findPreviousStoryInSprints {p ->
      parentSprint {
        parentRelease {
          parentProduct {
            eq 'id', p.id
          }
          order('orderNumber')
        }
        order('orderNumber')
      }
      order('rank')
    }

    storiesByRelease { r ->
      parentSprint {
        parentRelease {
          eq 'id', r.id
        }
      }
    }

    findPreviousSuggested { p, d ->
      backlog {
        eq 'id', p
      }
      eq 'state', Story.STATE_SUGGESTED
      gt 'suggestedDate', d
      maxResults(1)
      order("suggestedDate", "asc")
    }

    findFirstSuggested { p ->
      backlog {
        eq 'id', p
      }
      eq 'state', Story.STATE_SUGGESTED
      maxResults(1)
      order("suggestedDate", "asc")
    }

    findNextSuggested { p, d ->
      backlog {
        eq 'id', p
      }
      eq 'state', Story.STATE_SUGGESTED
      lt 'suggestedDate', d
      maxResults(1)
      order("suggestedDate", "desc")
    }

    findNextAcceptedOrEstimated { p, r ->
      backlog {
        eq 'id', p
      }
      or {
        eq 'state', Story.STATE_ACCEPTED
        eq 'state', Story.STATE_ESTIMATED
      }
      eq 'rank', r
    }

    findLastAcceptedOrEstimated { p ->
      backlog {
        eq 'id', p
      }
      or {
        eq 'state', Story.STATE_ACCEPTED
        eq 'state', Story.STATE_ESTIMATED
      }
      maxResults(1)
      order("rank", "desc")
    }

    findAllAcceptedOrEstimated { p ->
      backlog {
        eq 'id', p
      }
      or {
        eq 'state', Story.STATE_ACCEPTED
        eq 'state', Story.STATE_ESTIMATED
      }
    }

    findStoriesFilter { s,term = null,u = null ->
      cache false
      parentSprint{
        eq 'id', s.id
      }
      tasks {
        if (term){
          or {
            ilike 'name', term
            ilike 'description', term
            ilike 'notes', term
          }
        }
        if (u){
          responsible{
            if(u.preferences.filterTask == 'myTasks'){
              eq 'id', u.id
            }
          }
          if (u.preferences.filterTask == 'freeTasks'){
            isNull('responsible')
          }
        }
      }
      if (term){
        feature {
          ilike 'name', term
        }
      }
      if (u?.preferences?.hideDoneState){
        ne 'state', Story.STATE_DONE
      }
    }

    filterByFeature { p, f, r = null ->
      backlog {
        eq 'id', p.id
      }
      if (r) {
        parentSprint {
          parentRelease {
            eq 'id', r.id
          }
        }
      }
      feature {
        eq 'id', f.id
      }
    }

    // Return the total number of points in the backlog
    totalPoint { idProduct ->
      projections {
        sum 'effort'
        backlog {
          eq 'id', idProduct
        }
        isNull 'parentSprint'
        isNull 'effort'
      }
    }
  }

  static recentActivity(Product currentProductInstance) {
    executeQuery("SELECT DISTINCT a.activity " +
            "FROM grails.plugin.fluxiable.ActivityLink as a, org.icescrum.core.domain.Story as s " +
            "WHERE a.type='story' " +
            "and s.backlog=:p " +
            "and s.id=a.activityRef " +
            "and not (a.activity.code like 'task%') " +
            "ORDER BY a.activity.dateCreated DESC", [p: currentProductInstance], [max: 15])
  }

  static recentActivity(Team currentTeamInstance) {
    executeQuery("SELECT DISTINCT a.activity " +
            "FROM grails.plugin.fluxiable.ActivityLink as a, org.icescrum.core.domain.Story as s, org.icescrum.core.domain.Product as p " +
            "INNER JOIN s.backlog.teams as team " +
            "WHERE "+
            "((a.type='story' " +
            "and team.id=:t " +
            "and not (a.activity.code like 'task%') " +
            "and s.id=a.activityRef) " +
            "OR (a.type='product' " +
            "and p.id=a.activityRef " +
            "and p.id=s.backlog.id)) " +
            "and a.activity.posterId in "+
            "(SELECT DISTINCT u2.id FROM org.icescrum.core.domain.User as u2 INNER JOIN u2.teams as t WHERE t.id = :t)" +
            "ORDER BY a.activity.dateCreated DESC", [t: currentTeamInstance.id], [max: 15])
  }

  int compareTo(Story o) {
    return rank.compareTo(o.rank)
  }

  @Override
  int hashCode() {
    final Integer prime = 31
    int result = 1
    result = prime * result +((!effort) ? 0 : effort.hashCode())
    result = prime * result + ((!name) ? 0 : name.hashCode())
    result = prime * result + ((!backlog) ? 0 : backlog.hashCode())
    result = prime * result + ((!parentSprint) ? 0 : parentSprint.hashCode())
    result = prime * result + ((!state) ? 0 : state.hashCode())
    return result
  }

  @Override
  boolean equals(obj) {
    if (this.is(obj))
      return true
    if (obj == null)
      return false
    if (getClass() != obj.getClass())
      return false
    Story other = (Story) obj
    if (effort == null) {
      if (other.effort != null)
        return false
    } else if (!effort.equals(other.effort))
      return false
    if (name == null) {
      if (other.name != null)
        return false
    } else if (!name.equals(other.name))
      return false
    if (backlog == null) {
      if (other.backlog != null)
        return false
    } else if (!backlog.equals(other.backlog))
      return false
    if (parentSprint == null) {
      if (other.parentSprint != null)
        return false
    } else if (!parentSprint.equals(other.parentSprint))
      return false
    if (state == null) {
      if (other.state != null)
        return false
    } else if (!state.equals(other.state))
      return false
    return true
  }

  int getTodo() {
    int todo = 0
    tasks.each {
      if (it.estimations.last != Task.NO_ESTIMATION)
        todo += it.estimations.last
    }
    return todo
  }
}
