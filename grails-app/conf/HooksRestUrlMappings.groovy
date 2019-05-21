/*
 * Copyright (c) 2019 Kagilum SAS
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
 * Authors: Vincent Barrier (vbarrier@kagilum.com)
 *
 */

class HooksRestUrlMappings {

    static mappings = {
        "/ws/$workspaceType/$workspaceId/hook" {
            controller = 'hook'
            action = {
                params.workspaceId = params.workspaceId."decode${params.workspaceType.capitalize()}Key"()?.toLong()
                request["${params.workspaceType}_id"] = params.workspaceId
                switch (request.method) {
                    case "GET":
                        params.action = 'index'
                        break
                    case "POST":
                        params.action = 'save'
                        break
                }
            }
            constraints {
                workspaceType(inList: getGrailsApplication().config.icescrum.workspaces*.value*.type)
                workspaceId(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/$workspaceType/$workspaceId/hook/$id" {
            controller = 'hook'
            action = {
                params.workspaceId = params.workspaceId."decode${params.workspaceType.capitalize()}Key"()?.toLong()
                request["${params.workspaceType}_id"] = params.workspaceId
                switch (request.method) {
                    case "GET":
                        params.action = 'show'
                        break
                    case "PUT":
                        params.action = 'update'
                        break
                    case "POST":
                        params.action = 'update'
                        break
                    case "DELETE":
                        params.action = 'delete'
                        break
                }
                return params.action
            }
            constraints {
                workspaceType(inList: getGrailsApplication().config.icescrum.workspaces*.value*.type)
                workspaceId(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/ws/hook" {
            controller = 'hook'
            action = [GET: "index", POST: "save"]
        }
        "/ws/hook/$id" {
            controller = 'hook'
            action = [GET: "show", PUT: "update", DELETE: 'delete', POST: 'update']
            constraints {
                id(matches: /\d+(,\d+)*/)
            }
        }
    }
}