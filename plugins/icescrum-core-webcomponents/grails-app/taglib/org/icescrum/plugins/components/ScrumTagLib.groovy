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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Damien Vitrac (damien@oocube.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */
package org.icescrum.plugins.components

import org.icescrum.components.UtilsWebComponents
import org.icescrum.core.domain.Product

class ScrumTagLib {

  static namespace = 'is'

  static returnObjectForTags = ['storyTemplate']

  def postit = { attrs, body ->
    def params = attrs
    try {
      pageScope.menu = ''
    } catch (e) {}
    attrs.title = attrs.title.decodeHTML()
    params.title = (attrs.title.length() > 17) ? attrs.title[0..16] + '...' : attrs.title
    params.content = body()
    params.type = attrs.type ? attrs.type : ""
    params.color = params.color ?: "yellow"

    if (attrs.typeName != null)
      params.typeName = attrs.typeName

    if (attrs.rect == "true")
      params.className = 'postit-rect';
    else
      params.className = 'postit'

    if (attrs.sortable != null && UtilsWebComponents.rendered(attrs.sortable) && UtilsWebComponents.enabled(attrs.sortable)) {
      params.sortable = true
    } else {
      params.sortable = false
    }

    try {
      params.embeddedMenu = pageScope.menu
    } catch (e) {}


    if (params.content.trim() == '') {
      params.content = '&nbsp;';
    }
    out << g.render(template: '/components/postit', plugin: 'icescrum-core-webcomponents', model: params)
  }

  def postitIcon = {attrs, body ->
    def color = attrs.color ?: "yellow"
    out << "<span ${attrs.name ?'title="'+attrs.name+'"': ''} class=\"postit-icon postit-icon-${color}\">${body()}</span>"
  }

  /**
   * Generate the embedded postit menu (the spanner)
   * The menu will not be generated if it is outside a postit tag or
   * if the body is empty or only contain blankspaces
   */
  def postitMenu = { attrs, body ->
    if (!UtilsWebComponents.rendered(attrs))
      return

    if (pageScope?.menu != '') return
    attrs.id = 'postit-' + attrs.id

    pageScope.menu = is.menu(attrs, body())
  }

  def postitMenuItem = {attrs, body ->
    if (!UtilsWebComponents.rendered(attrs))
      return
    out << "<li"
    if (attrs.first == "true" || attrs.first)
      out << " class=\"first\""
    out << ">"
    out << body()
    out << "</li>"
  }

  def menuItem = {attrs, body ->
    if (!UtilsWebComponents.rendered(attrs))
      return
    out << "<li"
    if (attrs.first == "true")
      out << " class=\"first\""
    out << ">"
    out << body()
    out << "</li>"
  }

  def backlogElementLayout = { attrs, body ->
    if (!attrs.value && (!attrs.emptyRendering || (attrs.emptyRendering && attrs.emptyRendering != 'true'))) return
    attrs.var = attrs.var ?: 'it'
    def jqCode = ''

    def container = attrs.remove('container') ?: 'div'

    // Selectable options
    if (attrs.selectable != null && UtilsWebComponents.rendered(attrs.selectable)) {
      if (attrs.selectable.onload != null) {
        jqCode += attrs.selectable.onload
        attrs.selectable.remove('onload')
      }
      def selectableOptions = [
              filter: UtilsWebComponents.wrap(attr: (attrs.selectable.filter), doubleQuote: true),
              cancel: UtilsWebComponents.wrap(attrs.selectable.cancel),
              stop: attrs.selectable.stop,
              selected: "function(event,ui){${attrs.selectable.selected}}"
      ]
      def opts = selectableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v" }.join(',')
      jqCode += " \$('#backlog-layout-${attrs.id}').selectable({$opts}); "
    }

    if (attrs.dblclickable != null && UtilsWebComponents.rendered(attrs.dblclickable)) {
      jqCode += " jQuery('#backlog-layout-${attrs.id} ${attrs.dblclickable.selector}').dblclick(function(e){ var obj = jQuery(e.currentTarget); ${attrs.dblclickable.callback}});"
    }

    // Sortable options
    if (attrs.sortable != null && UtilsWebComponents.rendered(attrs.sortable)) {
      if (attrs.changeRank) {
        attrs.sortable.update = is.changeRank(attrs.changeRank)
      }
      def sortableOptions = [
              placeholder: UtilsWebComponents.wrap(attr: attrs.sortable.placeholder, doubleQuote: true),
              revert: "'true'",
              items: "'.postit, .postit-rect'",
              handle: UtilsWebComponents.wrap(attr: attrs.sortable.handle, doubleQuote: true),
              start: "function(event,ui){${attrs.sortable.start}}",
              stop: "function(event,ui){${attrs.sortable.stop}}",
              change: "function(event,ui){${attrs.sortable.change}}",
              update: "function(event,ui){${attrs.sortable.update}}",
              receive: "function(event,ui){${attrs.sortable.receive}}",
              cancel: UtilsWebComponents.wrap(attrs.sortable.cancel),
              connectWith: UtilsWebComponents.wrap(attrs.sortable.connectWith),
              disabled: attrs.sortable.disabled
      ]

      def opts = sortableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v" }.join(',')
      jqCode += " \$('#backlog-layout-${attrs.id}').sortable({$opts}); "
    }

    // Draggable options
    if (attrs.draggable != null && UtilsWebComponents.rendered(attrs.draggable)) {
      def draggableOptions = [
              revert: UtilsWebComponents.wrap(attrs.draggable.revert) ?: "true",
              zIndex: 100,
              handle: UtilsWebComponents.wrap(attr: attrs.draggable.handle, doubleQuote: true),
              scope: UtilsWebComponents.wrap(attrs.draggable.scope),
              connectToSortable: UtilsWebComponents.wrap(attrs.draggable.connectToSortable),
              helper: UtilsWebComponents.wrap(attrs.draggable.helper),
              start: "function(event,ui){${attrs.draggable.start}}",
              stop: "function(event,ui){${attrs.draggable.stop}}",
              appendTo: UtilsWebComponents.wrap(attrs.draggable.appendTo),
              scroll: attrs.draggable.scroll ?: true
      ]
      def opts = draggableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v" }.join(',')
      jqCode += " \$('#backlog-layout-${attrs.id} > ${attrs.draggable.selector ?: 'div'}').draggable({$opts}); "
    }

    // Droppable options
    if (attrs.droppable != null && UtilsWebComponents.rendered(attrs.droppable)) {
      def droppableOptions = [
              drop: attrs.droppable.drop ? "function(event, ui) {${attrs.droppable.drop}}" : null,
              hoverClass: UtilsWebComponents.wrap(attrs.droppable.hoverClass),
              activeClass: UtilsWebComponents.wrap(attrs.droppable.activeClass),
              accept: UtilsWebComponents.wrap(attrs.droppable.accept)
      ]
      def opts = droppableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v"}.join(',')
      jqCode += " \$('#backlog-layout-${attrs.id} > ${attrs.droppable.selector ?: 'div'}').droppable({$opts});"
    }

    if (attrs.editable != null && UtilsWebComponents.rendered(attrs.editable)) {
      attrs.editable.wrap = false
      jqCode += is.editable(attrs.editable);
    }

    // Wrapper
    out << jq.jquery(null, {jqCode})

    out << "<$container id=\"backlog-layout-${attrs.id}\" class=\"view-postit backlog ${attrs.remove('containerClass')}\"${attrs.style ? ' style="' + attrs.style + '"' : ''}>"
    attrs.remove('id')
    attrs.value.each {
      attrs[(attrs.'var')] = it
      out << body(attrs)
    }
    out << "</$container>"
  }

  def truncated = { attrs, body ->
    assert attrs.size

    def position = attrs.remove('position') ?: 'end'

    def size = attrs.size.toInteger()
    def str = attrs.value ?: body()

    if (str == "null")
      str = ""

    if (attrs.encodedHTML)
      str = str.decodeHTML()
    def length = str?.length() ?: 0

    if (str && length > size) {
      switch (position) {
        case 'end':
          str = str[0..(size - 1)] + '...'
          break
        case 'begin':
          str = '...' + str[(length - size)..(length - 1)]
          break
        default:
          def midSize = size / 2
          str = str[0..(midSize - 1)] + ' [...] ' + str[(length - midSize)..(length - 1)]
      }

    }

    if (attrs.encodedHTML) {
      out << str?.encodeAsHTML()
    } else {
      out << str
    }
  }

  /**
   * Overload the default g:link tag, added "rendered", "disabled",
   * (boolean test that will or will not show/enable the link)
   * "renderedOnRoles", "renderedOnNotRoles", "disabledOnAccess" and "disabledOnNotAccess" attributes
   * (check if the current user has the specified Spring Security's role)
   */
  def link = {attrs, body ->
    // Compute the rendered** attributes to determine if the link can be generated or not
    def isRendered = UtilsWebComponents.rendered(attrs)
    // Compute the disabled** attributes to determine if the link has to be disabled or not
    // A disabled link does not redirect to any page (href=javascript:;)
    def isEnabled = UtilsWebComponents.enabled(attrs)

    if (attrs.href) {
      isEnabled = false
    }

    def value = body() ?: ''
    if (attrs.value != null) {
      value = attrs.value + value
      attrs.remove('value')
    }

    def history = attrs.history ? attrs.history.toBoolean() : true
    attrs.remove('history')


    def space = params.product ? 'product' : (params.team ? 'team' : null)
    if (space && !attrs.remove('noprefix')) {
      if (space == 'product')
        params.product = params.product.decodeProductKey()
      if (!attrs.params) {
        attrs.params = [(space): params[space]]
      } else if (Map.isAssignableFrom(attrs.params.getClass())) {
        attrs.params << [(space): params[space]]
      }
    }

    // Rendering the link
    if (isRendered && isEnabled) {
      def remote = attrs.remove('remote')
      if (remote && remote == 'true') {
        if (history) {
          def fragment
          if (attrs.url) {
            fragment = "${attrs.url.controller ?: controllerName}/${attrs.url.action ?: actionName}/${attrs.url.id ?: ''}"
          } else {
            fragment = "${attrs.controller ?: controllerName}/${attrs.action ?: actionName}/${attrs.id ?: ''}"
          }
          attrs.onSuccess = "${attrs.onSuccess ?: ''}; \$.icescrum.addHistory('${fragment}')";
          attrs.onClick = "${attrs.onclick ?: ''}; return false;"
        }

        //FIXME
        attrs.remove('elementId')
        out << g.remoteLink(attrs, value)
      } else {
        out << g.link(attrs, value)
      }
    }
    else if (isRendered && !isEnabled) {
      attrs.remove('controller')
      attrs.remove('action')
      attrs.remove('params')
      def elementId = attrs.remove('elementId')
      out << "<a href='${attrs.href ?: 'javascript:;'}'"
      attrs.remove('href');
      if (elementId)
        out << " id=\"${elementId}\""
      out << "${attrs.collect {k, v -> " $k=\"$v\"" }.join('')}>"
      out << "${value}</a>"
    }
  }

  def createScrumLink = {attrs ->
    def space = 'product'
    def id = attrs.remove('product')
    if (!space) {
      id = attrs.remove('team')
      space = 'team'
    }

    def spaceParams
    if (!id)
      space = params.product ? 'product' : (params.team ? 'team' : null)
    if (space) {
      if (space == 'product' && params.long('product'))
        spaceParams = [product: Product.get(params.product).pkey]
      else if(id)
        spaceParams = [(space): id]
      else
        spaceParams = [(space): params[space]]
    }

    def fragment = attrs.controller + (attrs.action ? '/' + attrs.action : '') + (attrs.id ? '/' + attrs.id : '') + (attrs.params ? '/?' : '') + attrs.params.collect {it -> it.key + "=" + it.value}.join("&")

    //def fragment = g.createLink(controller: attrs.controller, action: attrs.action?:null, id: attrs.id, params: attrs.params) - (request.contextPath+'/')

    out << g.createLink(controller: space == 'team' ? 'team' : 'scrumOS', action: 'index', params: spaceParams, absolute: attrs.absolute ?: false, base: attrs.base ?: null) + '#' + fragment
  }

  def scrumLink = {attrs, body ->
    def params = attrs + [url: createScrumLink(attrs)]
    params.'class' = 'scrum-link'
    params.remove('controller')
    params.remove('action')
    params.remove('id')
    params.remove('params')
    out << g.link(params, body())
  }

  def textTemplate = { attrs, body ->
    pageScope.textTemplate = [
            id: attrs.id,
            title: attrs.title,
            rows: [],
            disabled: attrs.disabled,
            label: attrs.label,
            checked: attrs.checked != true && attrs.checked != 'true'
    ]
    body()
    out << g.render(template: '/components/textTemplate', plugin: 'icescrum-core-webcomponents', model: pageScope.textTemplate)
  }

  def textTemplateRow = { attrs, body ->
    pageScope.textTemplate.rows << [
            title: attrs.title,
            content: body()
    ]
  }

  def storyTemplate = { attrs ->
    assert attrs.story

    def textStory = attrs.story.description ? attrs.story.description + ' \n ' : ""
    def tempTxt = [attrs.story.textAs, attrs.story.textICan, attrs.story.textTo]*.trim()
    if (tempTxt != ['null', 'null', 'null'] && tempTxt != ['', '', ''] && tempTxt != [null, null, null]) {
      textStory += message(code: 'is.story.template.as') + ' '
      textStory += (attrs.story.actor?.name ?: attrs.story.textAs ?: '') + ', '
      textStory += message(code: 'is.story.template.ican') + ' '
      textStory += (attrs.story.textICan ?: '') + ' '
      textStory += message(code: 'is.story.template.to') + ' '
      textStory += (attrs.story.textTo ?: '')
    }
    textStory = textStory.encodeAsHTML()
    return textStory.encodeAsNL2BR()
  }
}