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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 *
 */
package org.icescrum.web.webservices

import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Product
import grails.converters.XML

class StoryWebServiceController {

  def productBacklogService
  def businessRulesService

  def suggestStory = {
    def product = Product.get(params.long('id'))
    if (!product) {
      render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_common_no_product') + '</error>')
      return
    }
    if (!params['story']) {
      render(status: 400, contentType: "text/xml", text: '<error></error>')
      return
    }
    def story = new Story(name: params['story']['name'], description: params['story']['description'], notes: params['story']['notes'])

    def type = params['story']['type']
    if (type == Story.TYPE_USER_STORY || type == Story.TYPE_FEATURE || type == Story.TYPE_DEFECT || type == Story.TYPE_TECHNICAL_STORY) {
      story.type = type
    }

    int state = productBacklogService.saveStory(story, product, null, request.isUser, null, false)
    switch (state) {
      case org.icescrum.core.services.ProductBacklogService.VALIDATE:
        render story as XML
        break

      case ProductBacklogService.ERROR:
        render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_pbi_no_name') + '</error>')
        break

      case ProductBacklogService.SAME_NAME:
        render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_pbi_same_name') + '</error>')
        break

      case ProductBacklogService.ITEM_NOT_VALIDATE:
        render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_item_no_validate') + '</error>')
        break
    }
  }

  def addStory = {
    def product = Product.get(params.long('id'))
    if (!product) {
      render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_common_no_product') + '</error>')
      return
    }
    if (!params['story']) {
      render(status: 400, contentType: "text/xml", text: '<error></error>')
      return
    }
    def story = new Story(name: params['story']['name'], description: params['story']['description'], notes: params['story']['notes'])

    def effort = 0
    if (params['story']['effort'] != '') {
      try {
        effort = Integer.valueOf(params['story']['effort'])
      } catch (NumberFormatException e) {}
    }
    if (effort > 0)
      story.effort = effort
    else {
      story.effort = 0
    }

    def type = 0
    if (params['story']['type'] != '') {
      try {
        type = Integer.valueOf(params['story']['type'])
      } catch (NumberFormatException e) {}
    }

    if (type == Story.TYPE_USER_STORY || type == Story.TYPE_FEATURE || type == Story.TYPE_DEFECT || type == Story.TYPE_TECHNICAL_STORY) {
      story.type = type
    }

    if (businessRulesService.isPo(request.isUser, product)) {
      int state = productBacklogService.saveStory(story, product, null, request.isUser, null)
      switch (state) {
        case ProductBacklogService.VALIDATE:
          render story as XML
          break

        case ProductBacklogService.ERROR:
          render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_pbi_no_name') + '</error>')
          break

        case ProductBacklogService.SAME_NAME:
          render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_pbi_same_name') + '</error>')
          break

        case ProductBacklogService.ITEM_NOT_VALIDATE:
          render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_item_no_validate') + '</error>')
          break
      }
    } else {
      render(status: 400, contentType: "text/xml", text: '<error>' + message(code: 'is_no_po') + '</error>')
    }
  }
}