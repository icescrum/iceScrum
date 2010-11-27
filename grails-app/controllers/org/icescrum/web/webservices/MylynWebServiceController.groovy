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

package org.icescrum.web.webservices

import org.icescrum.core.domain.Task

class MylynWebServiceController {

  final static FILTER_ALL = 0
  final static FILTER_NOBODY = 1
  final static FILTER_MY = 2

  def all = {
    render(contentType: "application/xml") {
      mapTask.delegate = delegate
      'tasks-mylyn' {
        for (t in retrieveTasks())
          mapTask(t)
      }
    }
  }

  def nobody = {
    render(contentType: "application/xml") {
      mapTask.delegate = delegate
      'tasks-mylyn' {
        for (t in retrieveTasks(FILTER_NOBODY))
          mapTask(t)
      }
    }
  }

  def my = {
    render(contentType: "application/xml") {
      mapTask.delegate = delegate
      'tasks-mylyn' {
        for (t in retrieveTasks(FILTER_MY))
          mapTask(t)
      }
    }
  }

  private retrieveTasks(sort = FILTER_ALL) {
    def c = Task.createCriteria()
    c.list {
      switch (sort) {
        case FILTER_MY: eq('responsible', request.isUser); break;
        case FILTER_NOBODY: isNull('responsible'); break;
      }
      parentStory {
        eq('state', 5)
        order('rank', 'asc')
        parentSprint {
          parentRelease {
            backlog {
              eq('id', params.long('id'))
            }
          }
        }
      }
    }
  }

  private mapTask = {t ->
    'task-mylyn' {
      id(t.id)
      description(t.notes)
      'owner'(t.responsible ? "$t.responsible.firstName $t.responsible.lastName" : '')
      status(message(code:t.getStateBundle()))
      type(message(code:t.parentStory.getStateBundle()))
    }
  }
}