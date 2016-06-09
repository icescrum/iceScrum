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
 * Nicolas Noullet (nnoullet@kagilum.com)
 */

class ProductUrlMappings {

    static mappings = {

        "/p/$product/search" {
            controller = 'search'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        name baseUrlProduct: "/p/$product/" {
            controller = 'scrumOS'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        // Scrum OS & generic
        "/p/$product/ui/window/$windowDefinitionId" {
            controller = 'scrumOS'
            action = 'window'
            constraints {
                windowDefinitionId(matches: /[a-zA-Z]*/)
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
        // new way to handle requests (REST Style)
        "/p/$product/$controller/print/$format?" {
            action = 'print'
            constraints {
                product(matches: /[0-9A-Z]*/)
                format(matches: /[0-9A-Z]*/)
            }
        }
        // Task
        "/p/$product/task" {
            controller = 'task'
            action = [POST:"save"]
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
            action = [GET: "index"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                type(inList: ['story', 'sprint'])
            }
        }
        // Story
        "/p/$product/story" {
            controller = 'story'
            action = [GET: "index", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/story/$type/$typeId" {
            controller = 'story'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
                typeId(matches: /\d*/)
                type(inList: ['actor', 'feature', 'sprint', 'backlog'])
            }
        }
        "/p/$product/story/$id" {
            controller = 'story'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/story/$id/$action" {
            controller = 'story'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/story/listByField" {
            controller = 'story'
            action = 'listByField'
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        // Actor
        "/p/$product/actor" {
            controller = 'actor'
            action = [GET: "index", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/actor/$id" {
            controller = 'actor'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        // Feature
        "/p/$product/feature" {
            controller = 'feature'
            action = [GET: "index", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/feature/$id" {
            controller = 'feature'
            action = [GET: "show", PUT:"update", DELETE:'delete', POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/feature/$id/$action" {
            controller = 'feature'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        // Activity
        "/p/$product/activity/$type/$fluxiableId" {
            controller = 'activity'
            action = [GET: "index"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task'])
                fluxiableId(matches: /\d*/)
            }
        }
        // Comment
        "/p/$product/comment/$type/$commentable" {
            controller = 'comment'
            action = [GET: "index", POST:"save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task'])
                commentable(matches: /\d*/)
            }
        }
        "/p/$product/comment/$type/$commentable/$id" {
            controller = 'comment'
            action = [GET: "show", PUT:"update", DELETE:"delete", POST:'update']
            constraints {
                product(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task'])
                id(matches: /\d*/)
                commentable(matches: /\d*/)
            }
        }
        // Acceptance test
        "/p/$product/acceptanceTest/story/$parentStory" {
            controller = 'acceptanceTest'
            action = [GET: "index"]
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
        // Backlog
        "/p/$product/backlog" {
            controller = 'backlog'
            action = [GET: "index"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        // Release
        "/p/$product/release" {
            controller = 'release'
            action = [GET: "index", POST: "save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/release/$id" {
            controller = 'release'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/release/$id/$action" {
            controller = 'release'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        // Sprint
        "/p/$product/sprint" {
            controller = 'sprint'
            action = [POST: "save"]
            constraints {
                product(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/sprint/$id" {
            controller = 'sprint'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/sprint/$id/$action" {
            controller = 'sprint'
            constraints {
                product(matches: /[0-9A-Z]*/)
                id(matches: /\d+(,\d+)*/)
            }
        }
        "/p/$product/sprint/release/$releaseId" {
            controller = 'sprint'
            action = 'index'
            constraints {
                product(matches: /[0-9A-Z]*/)
                releaseId(matches: /[0-9A-Z]*/)
            }
        }
        "/p/$product/sprint/release/$releaseId/generateSprints" {
            controller = 'sprint'
            action = 'generateSprints'
            constraints {
                product(matches: /[0-9A-Z]*/)
                releaseId(matches: /[0-9A-Z]*/)
            }
        }
    }
}