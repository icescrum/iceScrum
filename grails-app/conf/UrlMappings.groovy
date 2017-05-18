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
        // Scrum OS
        "/" {
            controller = 'scrumOS'
            action = 'index'
        }
        "/$action" {
            controller = 'scrumOS'
        }
        "/robots.txt" {
            controller = 'scrumOS'
            action = 'robots'
        }
        "/browserconfig.xml" {
            controller = 'scrumOS'
            action = 'browserconfig'
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
        "/$project-F$uid/" {
            controller = 'feature'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/$project-T$uid/" {
            controller = 'task'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/$project-$uid/" {
            controller = 'story'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        // Legacy permalinks
        "/p/$project-F$uid/" {
            controller = 'feature'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/p/$project-T$uid/" {
            controller = 'task'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
                uid(matches: /[0-9]*/)
            }
        }
        "/p/$project-$uid/" {
            controller = 'story'
            action = 'permalink'
            constraints {
                project(matches: /[0-9A-Z]*/)
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
        "/feed/$project" {
            controller = 'project'
            action = 'feed'
            constraints {
                project(matches: /[0-9A-Z]*/)
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
        "/project/$project/leaveTeam" {
            controller = 'project'
            action = 'leaveTeam'
            constraints {
                project(matches: /\d*/)
            }
        }
        "/project/$project/team" {
            controller = 'project'
            action = 'team'
            constraints {
                project(matches: /\d*/)
            }
        }
        "/project/$project/activities" {
            controller = 'project'
            action = 'activities'
            constraints {
                project(matches: /\d*/)
            }
        }
        "/project/$project/updateTeam" {
            controller = 'project'
            action = 'updateTeam'
        }
        "/project/$project/archive" {
            controller = 'project'
            action = 'archive'
        }
        "/project/$project/unArchive" {
            controller = 'project'
            action = 'unArchive'
        }
        "/project/$project/$action" {
            controller = 'project'
            constraints {
                action(inList: ['flowCumulative', 'velocityCapacity', 'velocity', 'parkingLot', 'burndown', 'burnup'])
            }
        }
        "/project/$project" {
            controller = 'project'
            action = [GET: "show", DELETE: "delete", POST: "update"]
            constraints {
                //must be the id
                project(matches: /\d*/)
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
        "/project/$project/available/$property" {
            controller = 'project'
            action = [POST: "available"]
            constraints {
                project(matches: /\d*/)
                property(inList: ['name', 'pkey'])
            }
        }
        // Print
        "/p/$project/$controller/print" {
            action = 'print'
            constraints {
                project(matches: /[0-9A-Z]*/)
                controller(inList: ['backlog', 'feature'])
            }
        }
        // Export
        "/p/$project/export" {
            controller = 'project'
            action = 'export'
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$project/exportDialog" {
            controller = 'project'
            action = 'exportDialog'
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        // Attachment
        "/p/$project/attachment/$type/$attachmentable/flow" {
            controller = 'attachment'
            action = [GET: "save", POST: "save"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
            }
        }
        "/p/$project/attachment/$type/$attachmentable" {
            controller = 'attachment'
            action = [GET: "index", POST: "save"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
            }
        }
        "/p/$project/attachment/$type/$attachmentable/$id" {
            controller = 'attachment'
            action = [GET: "show", DELETE: "delete"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                id(matches: /\d*/)
                type(inList: ['story', 'task', 'feature', 'release', 'sprint', 'project'])
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
        "/team/project/$project" {
            controller = 'team'
            action = 'show'
            constraints {
                project(matches: /\d*/)
            }
        }
        // Widget
        "/widget/feed" {
            controller = 'feed'
            action = [POST: "index"]
        }
        // Errors mapping
        "/notFound"(controller: "errors", action: "error404")
        "404"(redirect: '/notFound')
        "/forbidden"(controller: "errors", action: "error403")
        "403"(redirect: '/forbidden')
        "/generalError/"(controller: "errors", action: "error500")
        "500"(controller: "errors", action: "error403", exception: AccessDeniedException)
        "500"(controller: "errors", action: "error403", exception: NotFoundException)
        "500"(controller: 'errors', action: 'memory', exception: OutOfMemoryError)
        "500"(controller: 'errors', action: 'database', exception: CannotCreateTransactionException)
        "500"(controller: 'errors', action: 'database', exception: CommunicationsException)
        "500"(controller: 'errors', action: 'error500')
    }
}
