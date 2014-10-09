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
            action = [POST: "forceRestSave", GET: "list"]
        }

        "/ws/user/$id" {
            action = [GET: "index", PUT: "update"]
            controller = 'user'
            constraints {
                id(matches: /\d*/)
            }
        }

        "/ws/p/$product/$controller" {
            action = [POST: "save", GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$product/$id/sprint" {
            controller = 'sprint'
            action = [GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/ws/p/$product/task/$filter" {
            controller = 'task'
            action = [GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                filter(matches:/[A-Za-z]*/)
            }
        }

        "/ws/p/$product/finder/tag" {
            controller = 'finder'
            action = [GET: "tag"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$product/finder" {
            controller = 'finder'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$product/$sprint/task/$filter?" {
            controller = 'task'
            action = [GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                sprint(matches: /\d*/)
            }
        }

        "/ws/p/$product/$story/acceptanceTest" {
            controller = 'acceptanceTest'
            action = [GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                story(matches: /\d*/)
            }
        }

        "/ws/p/$product/$controller/$id" {
            action = [GET: "index", PUT: "update", DELETE: "delete"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/ws/p/$product/$controller/$id/$action" {
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
    }

}