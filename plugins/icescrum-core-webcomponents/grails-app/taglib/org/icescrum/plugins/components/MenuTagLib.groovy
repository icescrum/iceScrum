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

class MenuTagLib {

  static namespace = 'is'

  /**
   * Generate iceScrum menu bar (only show up when a project is opened)
   */
  def menuBar = { attrs, body ->
    def menuElements = []
    def menuElementsHiddden = []
    grailsApplication.uIControllerClasses.each {controller ->
      if (controller) {
        def show = controller.getPropertyValue('menuBar')?.show
        if (show in Closure) {
          show.delegate = delegate
          show = show()
        }
        if (show && show.visible) {
          menuElements << [title: controller.getPropertyValue('menuBar').title,
                  id: controller.getPropertyValue('id'),
                  selected: controller.getPropertyValue('id') == session.currentWindow,
                  position: show.pos.toInteger() ?: 1,
                  widgetable: controller.getPropertyValue('widget') ? true : false,
          ]
        }else if (show){
          menuElementsHiddden << [title: controller.getPropertyValue('menuBar').title,
                  id: controller.getPropertyValue('id'),
                  selected: controller.getPropertyValue('id') == session.currentWindow,
                  position: show.pos ?: 1,
                  widgetable: controller.getPropertyValue('widget') ? true : false,
          ]
        }
      }
    }
    menuElements = menuElements.sort {it.position}
    menuElementsHiddden = menuElementsHiddden.sort {it.position}
    out << g.render(template: '/components/menuBar',plugin:'icescrum-core-webcomponents', model: [menuElements: menuElements, menuElementsHiddden:menuElementsHiddden])
  }

  /**
   * Generate a project menu element
   */
  def menuElement = { attrs, body ->

    out << "<li class='menubar navigation-line li ${attrs.widgetable?'widgetable':''} ${attrs.draggable?'draggable-to-desktop':''}' ${attrs.hidden?'hidden=\'true\'':''} id='elem_${attrs.id}'>"
    out << "<a class='button-s clearfix' href='#${attrs.id}'><span class='start'></span><span class='content'>${message(code: attrs.title)}</span><span class='end'></span></a>"
    out << "</li>"
  }

  /**
   * Generate a project menu element
   */
  def menuElementHidden = { attrs, body ->

    out << "<li>"
    out << "<a class='button-s clearfix href='#${attrs.id}'><span class='start'></span><span class='content'>${message(code: attrs.title)}</span><span class='end'></span></a>"
    out << "</li>"
  }

  def menu = { attrs, body ->

     if (!UtilsWebComponents.rendered(attrs))
      return

     def content
     if (attrs.contentView)
       content = render(template: "${attrs.contentView}", model: attrs.params)
     else
       content = body()

     if (!content.trim()) return

     def params = [
             id: attrs.id,
             menuItems: content,
             top:attrs.top?:13,
             yoffset:attrs.yoffset?:0,
             noWindows:attrs.noWindows?:false,
     ]

     params.classdrop = attrs."class" ?: ""
     out << g.render(template: '/components/menu',plugin:'icescrum-core-webcomponents', model: params)
   }

   /**
   * Generate a menu that appear when the mouse pointer come over the element
   */
  def dropMenu = { attrs, body ->
    def params = [
            idMenu: attrs.id,
            title: attrs.title,
            content: body()
    ]
    out << g.render(template: '/components/dropMenu', plugin:'icescrum-core-webcomponents', model: params)
  }
}
