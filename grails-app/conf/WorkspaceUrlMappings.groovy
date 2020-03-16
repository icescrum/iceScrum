/*
 * Copyright (c) 2020 Kagilum.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 */

import org.icescrum.core.domain.WorkspaceType

class WorkspaceUrlMappings {

    static mappings = {
        // Meeting
        "/$workspaceType/$workspace/meeting/$subjectType?/$subjectId?" {
            controller = 'meeting'
            action = [GET: 'index']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                subjectType(inList: ['story', 'task', 'feature', 'release', 'sprint'])
                subjectId(matches: /\d*/)
            }
        }
        "/$workspaceType/$workspace/meeting" {
            controller = 'meeting'
            action = [POST: 'save']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
            }
        }
        "/$workspaceType/$workspace/meeting/$id" {
            controller = 'meeting'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        // Comment
        "/$workspaceType/$workspace/comment/$type/$commentable" {
            controller = 'comment'
            action = [GET: 'index']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task', 'feature'])
                commentable(matches: /\d*/)
            }
        }
        "/$workspaceType/$workspace/comment" {
            controller = 'comment'
            action = [POST: 'save']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
            }
        }
        "/$workspaceType/$workspace/comment/$id" {
            controller = 'comment'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        // Attachment
        "/$workspaceType/$workspace/attachment/$type/$attachmentable/flow" {
            controller = 'attachment'
            action = [GET: "save", POST: "save"]
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
            }
        }
        "/$workspaceType/$workspace/attachment/$type/$attachmentable" {
            controller = 'attachment'
            action = [GET: "index", POST: "save"]
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
            }
        }
        "/$workspaceType/$workspace/attachment/$type/$attachmentable/$id" {
            controller = 'attachment'
            action = [GET: "show", POST: "update", DELETE: "delete"]
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                id(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
            }
        }
    }
}
