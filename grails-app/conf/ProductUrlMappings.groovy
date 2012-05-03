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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

class ProductUrlMappings {
    static mappings = {

        "/p/textileParser" {
            controller = 'scrumOS'
            action = 'textileParser'
        }


        "/p/$product/" {
            controller = 'scrumOS'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }


        name shortURL: "/p/$product-$id/" {
            controller = 'story'
            action = 'shortURL'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /[0-9]*/)
            }
        }

        name profile: "/profile/$id/" {
            controller = 'user'
            action = 'profileURL'
            constraints {
                id(matches: /[a-zA-Z0-9]*/)
            }
        }

        "/$action/user/$actionWindow/$id" {
            controller = 'scrumOS'
            window = 'user'
            constraints {
                actionWindow(matches: /[a-zA-Z]*/)
                action(matches: /[a-zA-Z]*/)
            }
        }

        "/b/$id" {
            controller = 'story'
            action = 'idURL'
            constraints {
                id(matches: /[0-9]*/)
            }
        }

        "/p/$product/$action/$window?/$actionWindow?/$id?" {
            controller = 'scrumOS'
            constraints {
                actionWindow(matches: /[a-zA-Z]*/)
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/$action/$window?/$id/$actionWindow?/$subid?" {
            controller = 'scrumOS'
            constraints {
                actionWindow(matches: /[a-zA-Z]*/)
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/$action/$window?/$id?" {
            controller = 'scrumOS'
            constraints {
                id(matches: /\d*/)
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/$controller/$id?" {
            constraints {
                id(matches: /\d*/)
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/$controller/$id?/$action?/$subid?" {
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                subid(matches: /\d*/)
            }
        }

        "/p/$product/$controller/$action?/$id?/$type?" {
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/ws/p/$product/$controller/$action?/$id?/$type?"(parseRequest: true) {
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/ws/p/$product/$controller?/$id?/$type?"(parseRequest: true) {
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

    }
}