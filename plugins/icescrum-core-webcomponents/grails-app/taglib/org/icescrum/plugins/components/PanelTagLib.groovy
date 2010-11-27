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
 * Damien Vitrac (damien@oocube.com)
 */

package org.icescrum.plugins.components

import org.icescrum.components.UtilsWebComponents

class PanelTagLib {
  static namespace = 'is'

  def panel = {attrs, body ->

    def id = attrs.id ?: "panel" + new Date().time
    out << "<div class=\"panel-box\" id=\"${id}\">"
    out << body()
    out << "</div>"

    def jqCode = "\$('#${id}').hover(function(){\$(this).addClass('panel-box-active');}, function(){\$(this).removeClass('panel-box-active');});"
    out << jq.jquery(null, {jqCode})
  }

  def panelTitle = {attrs, body ->
    out << "<h3 class=\"panel-box-title\">"
    out << body()
    out << "</h3>"
  }

  def panelLine = {attrs, body ->
    assert pageScope.panelContext
    if (UtilsWebComponents.rendered(attrs)) {
      def line = { isLast ->
        "<tr class=\"panel-line ${isLast ? "panel-line-last" : ""}\">"+
        "<td class=\"line-left\">" + attrs.remove("legend") + "</td>"+
        "<td class=\"line-right\">" + body() + "</td>"+
        "</tr>"
      }
      pageScope.panelContext.lines << line
    }
  }

  def panelContext = {attrs, body ->
    pageScope.panelContext = [lines:[]]
    out << "<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"width:100%\">"
    out << body()
    pageScope.panelContext.lines.eachWithIndex { line, index ->
      out << line(index == pageScope.panelContext.lines.size()-1)
    }
    out << "</table>"
  }

  def panelTabButton = {attrs, body ->
    def id = attrs.remove("id") ?: ""
    out << "<div id=\"${id}\" class=\"panel-tab-button clearfix\">"
    out << body()
    out << "</div>"
  }

  def panelTab = {attrs, body ->
    def c = attrs.remove("selected") ? "tab-selected" : ""
    def id = attrs.remove("id") ?: ""

    out << "<div id=\"${id}\" class=\"panel-tab-content ${c}\">"
    out << body()
    out << "</div>"
  }

  def wizard = {attrs, body ->
    assert attrs.next
    assert attrs.previous
    assert attrs.cancel
    assert attrs.id
    assert attrs.controller
    assert attrs.action

    out << "<form action='' id='${attrs.id}' method='post' class='box-form box-form-250 box-form-200-legend'>"
    out << body()
    out << "</form>"

    def submitFunction = g.remoteFunction(
            action: attrs.action,
            controller: attrs.controller,
            remote: true,
            onSuccess: attrs.onSuccess,
            before: attrs.before,
            update: attrs.update,
            params: "jQuery('#${attrs.id}').serialize()"
    )
    def jqCode = """\$('#${attrs.id}').isWizard({
                                    submitButton:'${message(code: attrs.submit)}',
                                    nextButton:'${message(code: attrs.next)}',
                                    previousButton:'${message(code: attrs.previous)}',
                                    cancelButton:'${message(code: attrs.cancel)}',
                                    submitFunction:function(){${submitFunction}}});"""
    out << jq.jquery(null, jqCode)
  }

  def tabs = { attrs,body ->
     pageScope.tab = []
     body()

     out << "<div id='${attrs.elementId}'>"
     out << "<ul>"
     pageScope.tab.each { t ->
        out << "<li><a href='#${t.elementId}'>${t.title}</a></li>"
     }
     out << "</ul>"
     pageScope.tab.each { t ->
        out << "<div id='${t.elementId}' class='${t."class"?:''}'>${t.content}</div>"
     }
     out << "</div>"
     out << jq.jquery(null,"\$('#${attrs.elementId}').tabs();")
  }

  def tab = { attrs,body ->
    if (pageScope.tab == null) return
    def param = [
      elementId:attrs.elementId,
      title:message(code:attrs.title),
      content:body()?:null,
      "class":attrs."class"
    ]
    pageScope.tab << param
  }

  /**
   *
   */
  def panelButton = { attrs, body ->

    assert attrs.id

    if (UtilsWebComponents.rendered(attrs)) {
      out << jq.jquery(null, {"\$('#${attrs.id}-list').dropmenu();"})
      def paramsIcon = [
              class: 'button-n dropmenu-button',
              disabled: 'true',
              dropmenu: 'true'
      ]

      if (attrs.icon)
        paramsIcon.icon = attrs.icon

      out << "<li class=\"navigation-item\">"
      out << "<div class=\"dropmenu\" id=\"${attrs.id}-list\">"

      def str = attrs.text

      out << is.buttonNavigation(paramsIcon, str)

      attrs."class" ?: ""

      out << """<div class="dropmenu-content ui-corner-all ${attrs."class"}">
          ${body()}
        </div>"""

      out << "</div>"
      out << '</li>'
    }
  }

  def panelSearch = {attrs, body ->
    assert attrs.id

    out << "<li class=\"navigation-search search\" id=\"" + attrs.id + "\">"
    out << "<a class=\"search-button\"></a>"
    out << "<div class=\"search-content ui-corner-all\">"
    out << "<div class=\"input-content\">"
    out << body()
    out << "</div>"
    out << "</div>"
    out << '</li>'

    out << jq.jquery(null, {"\$('#${attrs.id}').searchmenu({hover:\"search-hover\", content:\"search-content\", top:27, left:130, noWindows:true})"})
  }

  def chartView = { attrs, body ->
    out << "<div class=\"view-chart\">${body()}</div>"
  }
}
