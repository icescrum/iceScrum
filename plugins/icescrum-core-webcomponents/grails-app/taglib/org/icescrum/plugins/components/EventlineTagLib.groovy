/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */


package org.icescrum.plugins.components

import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.components.UtilsWebComponents

class EventlineTagLib {
  static namespace = 'is'

  def eventline = { attrs, body ->
    pageScope.eventLine = [
            id:attrs.id
    ]
    pageScope.events = []
    body()
    def params = [
            events:pageScope.events.collect { v ->
              render(template:'/components/event',plugin:'icescrum-core-webcomponents', model:[
                      id:attrs.id,
                      orderNumber:v.orderNumber,
                      header:v.header.content,
                      headerClass:v.header."class",
                      headerAttrs:v.headerAttrs,
                      content:v.content,
                      contentAttrs:v.contentAttrs
              ])
            }.join(''),
            subEvents:pageScope.events.collect { v ->
              "<div class=\"event-sub\" ondblclick=\"\$('.event-line-limiter').eventline('eventFocus', ${v.orderNumber-1})\">${v.title}</div>"
            }.join('')
    ]
    out << g.render(template:'/components/eventline',plugin:'icescrum-core-webcomponents', model:params)
    def jsParams = [
            rootContainer:UtilsWebComponents.wrap(attrs.container),
            eventFocus:attrs.eventFocus
    ]
    def opts = jsParams.findAll {k, v -> v}.collect{k, v-> " $k:$v"}.join(',')
    def jqCode = "\$('.event-line-limiter').eventline({${opts}});"
    out << jq.jquery(null, jqCode)
  }

  def event = { attrs, body ->
    pageScope.event = [
            header:[],
            content:'',
            title:attrs.title,
            contentAttrs:'',
            orderNumber:pageScope.events?.size()+1 ?: 1
    ]
    body()

    pageScope.events << pageScope.event
  }

  def eventHeader = { attrs, body ->
    pageScope.event.header = [
            class:attrs."class",
            content:body()
    ]
    pageScope.event.headerAttrs = attrs.findAll {k, v -> v}.collect{k, v -> "$k=\"$v\""}.join(' ')
  }

  def eventContent = { attrs, body ->
    def jqCode = ''
    pageScope.event.content = body()
    if(attrs.droppable != null && UtilsWebComponents.rendered(attrs.droppable)){
      def droppableOptions = [
              drop:attrs.droppable.drop ? "function(event, ui) {${attrs.droppable.drop}}" : null,
              hoverClass:UtilsWebComponents.wrap(attrs.droppable.hoverClass),
              activeClass:UtilsWebComponents.wrap(attrs.droppable.activeClass),
              accept:UtilsWebComponents.wrap(attrs.droppable.accept)
      ]
      def opts = droppableOptions.findAll {k, v -> v}.collect{k, v -> " $k:$v"}.join(',')
      attrs.remove('droppable')
      jqCode += "\$('#event-id-${pageScope.eventLine.id}-${pageScope.event.orderNumber} > .event-content-list').droppable({$opts});"
    }
    pageScope.event.content += jqCode ? jq.jquery(null, jqCode) : ''
    pageScope.event.contentAttrs = attrs.findAll {k, v -> v}.collect{k, v -> "$k=\"$v\""}.join(' ')
  }
}
