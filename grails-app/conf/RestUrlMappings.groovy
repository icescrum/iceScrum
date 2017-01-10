/*
 * Copyright (c) 2012 Kagilum.
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
 *
 */

class RestUrlMappings {

    static mappings = {

        "/ws/version" {
            action = [GET: "version"]
            controller = 'scrumOS'
        }

        "/ws/user" {
            controller = 'user'
            action = [POST: "forceRestSave", GET: "index"]
        }

        "/ws/user/$id" {
            action = [GET: "show", PUT: "update"]
            controller = 'user'
            constraints {
                id(matches: /\d*/)
            }
        }

        "/ws/p/$project/$controller" {
            action = [POST: "save", GET: "index"]
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$project/$id/sprint" {
            controller = 'sprint'
            action = [GET: "index"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/ws/p/$project/task/$filter" {
            controller = 'task'
            action = [GET: "index"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                filter(matches:/[A-Za-z]*/)
            }
        }

        "/ws/p/$project/search/tag" {
            controller = 'search'
            action = [GET: "tag"]
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$project/search" {
            controller = 'search'
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$project/$sprint/task/$filter?" {
            controller = 'task'
            action = [GET: "index"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                sprint(matches: /\d*/)
            }
        }

        "/ws/p/$project/$story/acceptanceTest" {
            controller = 'acceptanceTest'
            action = [GET: "index"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                story(matches: /\d*/)
            }
        }

        "/ws/p/$project/$controller/$id" {
            action = [GET: "show", PUT: "update", DELETE: "delete"]
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/ws/p/$project/$controller/$id/$action" {
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
    }

}
