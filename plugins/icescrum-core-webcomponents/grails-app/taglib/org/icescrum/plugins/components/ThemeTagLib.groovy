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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */
package org.icescrum.plugins.components

import org.icescrum.components.UtilsWebComponents

class ThemeTagLib {

  static namespace = 'is'
  def grailsApplication

  def currentTheme = { attrs, body ->
    def name = grailsApplication.config.icescrum.theme
    out << name
    name
  }

  def currentThemeImage = { attrs, body ->
    def name = is.currentTheme(attrs, body)

    def value = "themes/" + name + "/images/"
    out << value
    value
  }

  def currentThemeCss = { attrs, body ->
    def name = is.currentTheme(attrs, body)
    def value = "themes/" + name + "/css/"
    out << value
    value
  }

  
}