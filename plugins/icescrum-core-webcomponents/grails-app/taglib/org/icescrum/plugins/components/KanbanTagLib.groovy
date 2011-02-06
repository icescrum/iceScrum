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

class KanbanTagLib {
  static namespace = 'is'

  def kanban = {attrs, body ->
    pageScope.kanbanHeaders = []
    pageScope.kanbanRows = []
    body()

    def opts
    // Selectable options
    if (attrs.selectable != null) {
      def selectableOptions = [
              filter: UtilsWebComponents.wrap(attr: (attrs.selectable.filter), doubleQuote: true),
              cancel: UtilsWebComponents.wrap(attrs.selectable.cancel),
              selected: "function(event,ui){${attrs.selectable.selected}}",
              stop: attrs.selectable.stop,
      ]
      opts = selectableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v" }.join(',')
    }
    
    out << '<table border="0" cellpadding="0" cellspacing="0" ' + (attrs.id ? "id=\"${attrs.id}\" " : '') + 'class="table kanban">'
    // Header
    out << "<thead>"
    out << '<tr class="table-legend">'
    def maxCols = pageScope.kanbanHeaders.size()
    pageScope.kanbanHeaders.eachWithIndex { col, index ->
      if (index == 0)
        out << '<th class="first kanban-col-' + index +'"><div class="table-cell">' << col.name << '</div></th>'
      else if (index == (maxCols - 1))
        out << '<th class="last kanban-col-' + index +'"><div class="table-cell">' << col.name << '</div></th>'
      else
        out << '<th  class="kanban-col-' + index +'"><div class="table-cell">' << col.name << '</div></th>'
    }
    out << '</tr>'
    out << "</thead>"

    // Rows
    def maxRows = pageScope.kanbanRows?.size() ?: 0
    out << "<tbody>"
    pageScope.kanbanRows.eachWithIndex { row, indexRow ->
      if (indexRow == (maxRows - 1))
        out << '<tr class="table-line line-last kanban-row-' + indexRow + '">'
      else
        out << '<tr class="table-line kanban-row-' + indexRow + '">'
      row.columns.eachWithIndex { col, indexCol ->
        if (indexCol == 0)
          out << '<td id="'+ col.elementId +'" class="first kanban-cell kanban-row-'+indexRow+' kanban-col-'+indexCol+' '+ col.'class' +'"><div class="kanban-label">' + is.nbps(null, col?.body(row.attrs)) + '</div></td>'
        else if (indexCol == (maxCols - 1))
          out << '<td id="'+ col.elementId +'" class="last kanban-cell kanban-row-'+indexRow+' kanban-col-'+indexCol+' '+ col.'class' +'">' + is.nbps(null, col?.body(row.attrs)) + '</td>'
        else
          out << '<td id="'+ col.elementId +'" class="kanban-cell kanban-row-'+indexRow+' kanban-col-'+indexCol+' '+ col.'class' +'">' + is.nbps(null, col?.body(row.attrs)) + '</td>'
      }
      out << '</tr>'
    }
    out << "</tbody>"
    def uniqueColumns = pageScope.kanbanRows*.columns.unique()
    def jqCode = ''
    uniqueColumns*.eachWithIndex { col, indexCol ->
      if(col.sortableOptions)
        jqCode += " \$('#${col.elementId}').sortable({${col.sortableOptions}}); \n"
    }
    if(opts)
        jqCode += " \$('.kanban').selectable({${opts}}); "

    // end
    out << '</table>'

    out << jq.jquery(null, jqCode);
  }

  /**
   * Helper tag for a Kanban header
   */
  def kanbanHeader = { attrs, body ->
    if (pageScope.kanbanHeaders == null) return

    def options = [
            name: attrs.name,
            key: attrs.key,
            'class': attrs.'class',
    ]

    pageScope.kanbanHeaders << options
  }

  /**
   * Helper tag for the Kanban rows
   */
  def kanbanRows = { attrs, body ->
    attrs.'in'.eachWithIndex { row, indexRow ->
      def attrsCloned = attrs.clone()
      attrsCloned[attrs.var] = row
      pageScope.kanbanColumns = []
      body(attrsCloned)
      def columns = pageScope.kanbanColumns.clone()
      attrsCloned.remove('in')
      def options = [
              columns:columns,
              attrs:attrsCloned
      ]
      
      pageScope.kanbanRows << options
    }

  }

  /**
   * Helper tag for a specific kanban row
   */
  def kanbanRow = { attrs, body ->

    if (!UtilsWebComponents.rendered(attrs))
      return

    pageScope.kanbanColumns = []
    body()
    def options = [
            columns:pageScope.kanbanColumns,
            attrs:attrs
    ]
    pageScope.kanbanRows << options
  }

  /**
   * Helper tag for the column content
   */
  def kanbanColumn = { attrs, body ->
    if (pageScope.kanbanColumns == null) return

    def options = [
            key: attrs.key,
            'class': attrs.'class'?:'',
            elementId:attrs.elementId,
            body: body ?: {->}
    ]

    

    // Sortable options
    if (attrs.sortable != null) {
      def sortableOptions = [
              placeholder: UtilsWebComponents.wrap(attr: attrs.sortable.placeholder, doubleQuote: true),
              revert: "'true'",
              items: "'.postit, .postit-rect'",
              handle: UtilsWebComponents.wrap(attr: attrs.sortable.handle, doubleQuote: true),
              start: "function(event,ui){${attrs.sortable.start}}",
              stop: "function(event,ui){${attrs.sortable.stop}}",
              update: "function(event,ui){${attrs.sortable.update}}",
              over: "function(event,ui){${attrs.sortable.over}}",
              change: "function(event,ui){${attrs.sortable.change}}",
              receive: "function(event,ui){${attrs.sortable.receive}}",
              cancel: UtilsWebComponents.wrap(attrs.sortable.cancel),
              connectWith: UtilsWebComponents.wrap(attrs.sortable.connectWith),
              disabled: attrs.sortable.disabled
      ]
      def opts = sortableOptions.findAll {k, v -> v}.collect {k, v -> " $k:$v" }.join(',')
      options.sortableOptions = opts
    }

    pageScope.kanbanColumns << options
  }
}
