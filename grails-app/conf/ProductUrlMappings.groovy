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

class ProductUrlMappings {
    static mappings = {

        "/p/$product/finder" {
            controller = 'finder'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/textileParser" {
            controller = 'scrumOS'
            action = 'textileParser'
        }


        name baseUrlProduct: "/p/$product/" {
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

        name shortURLTASK: "/p/$product-T$id/" {
            controller = 'task'
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

        name urlProduct: "/p/$product/$controller/$action?/$id?/$type?" {
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        //new way to handle requests (REST Style)

        "/p/$product/$controller/print/$format" {
            action = print
            constraints {
                product(matches: /[0-9A-Z]*/)
                format(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/task" {
            controller = 'task'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/task/$id" {
            controller = 'task'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/task/$id/$action" {
            controller = 'task'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/task/$type/$id" {
            controller = 'task'
            action = [GET: "tasksStory"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                type(inList: ['story', 'sprint'])
            }
        }

        "/p/$product/story" {
            controller = 'story'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/story/$id" {
            controller = 'story'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/story/$id/$action" {
            controller = 'story'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/actor" {
            controller = 'actor'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/actor/$id" {
            controller = 'actor'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/feature" {
            controller = 'feature'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/feature/$id" {
            controller = 'feature'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }

        "/p/$product/comment/$type/$commentable" {
            controller = 'comment'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task'])
                commentable(matches: /\d*/)
            }
        }

        "/p/$product/comment/$type/$commentable/$id" {
            controller = 'comment'
            action = [GET: "show", PUT:"update", DELETE:"delete"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task'])
                id(matches: /\d*/)
                commentable(matches: /\d*/)
            }
        }

        "/p/$product/attachment/$type/$attachmentable" {
            controller = 'attachment'
            action = [GET: "list", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                type(inList: ['story', 'task'])
            }
        }

        "/p/$product/attachment/$type/$attachmentable/$id" {
            controller = 'attachment'
            action = [GET: "show", DELETE:"delete"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                attachmentable(matches: /\d*/)
                id(matches: /\d*/)
                type(inList: ['story', 'task'])
            }
        }

        "/p/$product/acceptanceTest/story/$parentStory" {
            controller = 'acceptanceTest'
            action = [GET: "list"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                parentStory(matches: /\d*/)
            }
        }

        "/p/$product/acceptanceTest" {
            controller = 'acceptanceTest'
            action = [POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }

        "/p/$product/acceptanceTest/$id" {
            controller = 'acceptanceTest'
            action = [POST:"update", DELETE:"delete"]
            constraints {
                id(matches: /\d*/)
                product(matches: /[0-9A-Z]*/)
            }
        }

    }
}