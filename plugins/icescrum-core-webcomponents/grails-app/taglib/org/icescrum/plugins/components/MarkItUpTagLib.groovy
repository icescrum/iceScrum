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

import org.icescrum.components.UtilsWebComponents

class MarkItUpTagLib {
  static namespace='markitup'

  def editor = { attrs, body ->

    def content = attrs.value
    if (!attrs.value){
      content = body()
    }
    content = content.trim()

    def txtParams = [
            id: attrs.id,
            name: attrs.name,
            value: content,
            style: "${attrs.height?'height:'+attrs.height+'px;':'height:100px;'}"
    ]

    out << textArea(txtParams)

    def settings = "textileSettings"
    if (attrs.preview){
      settings = "textileSettingsPreview"
    }

    def jqCode = "\$('textarea#${txtParams.id}').markItUp(${settings});"

    if (attrs.fillWidth){
      jqCode += "jQuery('#${attrs.id}-field').width(jQuery('#${attrs.id}-field').parent().width() - ${attrs.margin?:0});"
    }else if(attrs.width){
      jqCode += "jQuery('#${attrs.id}-field').width(${attrs.width});"
    }

    out << jq.jquery(null, jqCode)
  }
}
