/*
 * Copyright (c) 2014 Kagilum.
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
 * Vincent Barrier (vbarrier@kagilum.com)
 */


import org.springframework.security.access.AccessDeniedException
import org.springframework.security.acls.model.NotFoundException
import org.springframework.transaction.CannotCreateTransactionException
import com.mysql.jdbc.CommunicationsException

class UrlMappings {

    static mappings = {

        name default: "/$controller/$action/$id?" {}
        name privateURL: "/ws/$controller/$action/$id?" {}
        // Scrum OS
        "/" {
            controller = 'scrumOS'
            action = 'index'
        }
        "/$action" {
            controller = 'scrumOS'
        }
        "/textileParser" {
            controller = 'scrumOS'
            action = 'textileParser'
        }
        "/charts/$context" {
            action = 'charts'
            controller = 'scrumOS'
            constraints {
                context(matches: /[a-zA-Z]*/)
            }
        }
        // Permalinks
        "/$product-F$uid/" {
            controller = 'feature'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/$product-T$uid/" {
            controller = 'task'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/$product-$uid/" {
            controller = 'story'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        // Legacy permalinks
        "/p/$product-F$uid/" {
            controller = 'feature'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/p/$product-T$uid/" {
            controller = 'task'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/p/$product-$uid/" {
            controller = 'story'
            action = 'permalink'
            constraints {
                product(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        // Window
        "/ui/window/$windowDefinitionId" {
            controller = 'scrumOS'
            action = 'window'
            constraints {
                windowDefinitionId(matches: /[a-zA-Z]*/)
            }
        }
        // Widget
        "/ui/widget" {
            controller = 'widget'
            action = [GET: "index", POST: "save"]
        }
        "/ui/widget/$widgetDefinitionId/$id?" {
            controller = 'widget'
            action = [GET: "show", POST: "update", DELETE: "delete"]
            constraints {
                widgetDefinitionId(matches: /[a-zA-Z]*/)
                id(matches: /\d*/)
            }
        }
        "/ui/widget/definitions" {
            controller = 'widget'
            action = 'definitions'
        }
        // Progress
        "/progress" {
            controller = 'scrumOS'
            action = 'progress'
        }
        // Login
        "/login"(controller: 'login', action: 'auth')
        // User
        "/user" {
            controller = 'user'
            action = [GET: "index", POST: "save"]
        }
        "/user/retrieve" {
            controller = 'user'
            action = [GET: "retrieve", POST: "retrieve"]
        }
        "/user/$id" {
            controller = 'user'
            action = [GET: "show", PUT: "update", POST: "update"]
            constraints {
                id(matches: /\d*/)
            }
        }
        "/user/$id/activities" {
            controller = 'user'
            action = 'activities'
            constraints {
                id(matches: /\d*/)
            }
        }
        "/user/$id/widget" {
            controller = 'user'
            action = [POST: "widget"]
        }
        "/user/$id/menu" {
            controller = 'user'
            action = [POST: "menu"]
        }
        "/user/$id/unreadActivitiesCount" {
            controller = 'user'
            action = 'unreadActivitiesCount'
            constraints {
                id(matches: /\d*/)
            }
        }
        "/user/$id/avatar" {
            controller = 'user'
            action = 'avatar'
            constraints {
                id(matches: /\d*/)
            }
        }
        "/user/current" {
            controller = 'user'
            action = [GET: "current"]
        }
        "/user/available/$property" {
            controller = 'user'
            action = [POST: "available"]
            constraints {
                property(inList: ['username', 'email'])
            }
        }
        // Feed
        "/feed/$product" {
            controller = 'project'
            action = 'feed'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        // Project
        "/project" {
            controller = 'project'
            action = [POST: "save"]
        }
        "/project/import" {
            controller = 'project'
            action = 'import'
        }
        "/project/importDialog" {
            controller = 'project'
            action = 'importDialog'
        }
        "/project/edit" {
            controller = 'project'
            action = 'edit'
        }
        "/project/$product/leaveTeam" {
            controller = 'project'
            action = 'leaveTeam'
            constraints {
                product(matches: /\d*/)
            }
        }
        "/project/$product/team" {
            controller = 'project'
            action = 'team'
            constraints {
                product(matches: /\d*/)
            }
        }
        "/project/$product/activities" {
            controller = 'project'
            action = 'activities'
            constraints {
                product(matches: /\d*/)
            }
        }
        "/project/$product/updateTeam" {
            controller = 'project'
            action = 'updateTeam'
        }
        "/project/$product/archive" {
            controller = 'project'
            action = 'archive'
        }
        "/project/$product/unArchive" {
            controller = 'project'
            action = 'unArchive'
        }
        "/project/$product/$action" {
            controller = 'project'
            constraints {
                action(inList: ['flowCumulative', 'velocityCapacity', 'velocity', 'parkingLot', 'burndown', 'burnup'])
            }
        }
        "/project/$product" {
            controller = 'project'
            action = [GET: "show", DELETE: "delete", POST: "update"]
            constraints {
                //must be the id
                product(matches: /\d*/)
            }
        }
        // New project
        "/project/available/$property" {
            controller = 'project'
            action = [POST: "available"]
            constraints {
                property(inList: ['name', 'pkey'])
            }
        }

        // Update project
        "/project/$product/available/$property" {
            controller = 'project'
            action = [POST: "available"]
            constraints {
                product(matches: /\d*/)
                property(inList: ['name', 'pkey'])
            }
        }
        // Print
        "/p/$product/$controller/print" {
            action = 'print'
            constraints {
                product(matches: /[0-9A-Z]*/)
                controller(inList: ['backlog', 'actor', 'feature'])
            }
        }
        // Export
        "/p/$product/export" {
            controller = 'project'
            action = 'export'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/exportDialog" {
            controller = 'project'
            action = 'exportDialog'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        // Attachment
        "/p/$product/attachment/$type/$attachmentable/flow" {
            controller = 'attachment'
            action = [GET: "save", POST: "save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'actor', 'feature', 'release', 'sprint'])
            }
        }
        "/p/$product/attachment/$type/$attachmentable" {
            controller = 'attachment'
            action = [GET: "index", POST: "save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'actor', 'feature'])
            }
        }
        "/p/$product/attachment/$type/$attachmentable/$id" {
            controller = 'attachment'
            action = [GET: "show", DELETE: "delete"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                id(matches: /\d*/)
                type(inList: ['story', 'task', 'actor', 'feature'])
            }
        }
        // Team
        "/team/" {
            controller = 'team'
            action = [GET: "index", POST: "save"]
        }
        "/team/$id" {
            controller = 'team'
            action = [POST: "update", DELETE: "delete"]
            constraints {
                id(matches: /\d*/)
            }
        }
        "/team/project/$product" {
            controller = 'team'
            action = 'show'
            constraints {
                product(matches: /\d*/)
            }
        }
        // Widget
        "/widget/feed" {
            controller = 'feed'
            action = [POST: "index"]
        }
        // Errors
        "404"(controller: "errors", action: "error404")
        "403"(controller: "errors", action: "error403")
        "500"(controller: "errors", action: "error403", exception: AccessDeniedException)
        "500"(controller: "errors", action: "error403", exception: NotFoundException)
        "500"(controller: 'errors', action: 'memory', exception: OutOfMemoryError)
        "500"(controller: 'errors', action: 'database', exception: CannotCreateTransactionException)
        "500"(controller: 'errors', action: 'database', exception: CommunicationsException)
        "500"(controller: 'errors', action: 'error500')
    }
}
