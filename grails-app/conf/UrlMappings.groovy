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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

import org.springframework.security.acls.model.NotFoundException
import org.springframework.security.access.AccessDeniedException

class UrlMappings {
  static mappings = {

    "/$controller/$action/$id?" {
    }

    "/$action" {
      controller = 'scrumOS'
    }

    "/$action/$window?/$id?" {
      controller = 'scrumOS'
      constraints {
        id(matches: /\d*/)
      }
    }

    "/" {
      controller = 'scrumOS'
      action='index'
    }

    "/textileParser" {
      controller = 'scrumOS'
      action='textileParser'
    }

    "/services/mylyn/$action?/$id?"(controller: 'mylynWebService')

    "/services/stories/suggest/$id?"(controller: 'storyWebService', parseRequest: true) {
      action = [POST: "suggestStory"]
    }

    "/services/stories/add/$id?"(controller: 'storyWebService', parseRequest: true) {
      action = [POST: "addStory"]
    }

    "/services/stories/$action?/$id?"(controller: 'storyWebService', parseRequest: true)

    "/login"(controller: 'login', action: 'auth')

    "500"(view: '/error')

    "/attachmentable/download/$id?"(controller: "errors", action: "error403")
    "403"(controller: "errors", action: "error403")
    "400"(controller: "errors", action: "fakeError")
    "302"(controller: "errors", action: "fakeError")
    "500"(controller: "errors", action: "error403", exception: AccessDeniedException)
    "500"(controller: "errors", action: "error403", exception: NotFoundException)
  }
}