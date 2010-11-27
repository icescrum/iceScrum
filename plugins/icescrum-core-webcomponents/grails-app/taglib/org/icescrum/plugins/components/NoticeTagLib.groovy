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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

package org.icescrum.plugins.components

class NoticeTagLib {
    static namespace = 'is'

    /**
   * Show a notice using the Pines pnotify jQuery plugin
   * The attributes available are roughly the same as a direct $.pnotify call
   * with additional attribute like :
   * data : a JSON object containing a "notice" element
   * xhr : a XMLHttpRequest object, used for server errors automatic notice
   */
  def notice = { attrs, body ->
    // Arguments with default values
    def args = [
            pnotify_addclass: "'stack-bottomleft'",
            pnotify_after_close: attrs.after_close,
            pnotify_after_init: attrs.after_init,
            pnotify_animate_speed: attrs.animate_speed,
            pnotify_animation: "{effect_in: 'slide', effect_out: 'fade'}",
            pnotify_before_open: attrs.before_open,
            pnotify_closer: attrs.closer,
            pnotify_delay: attrs.delay ?: '7000',
            pnotify_hide: attrs.hide,
            pnotify_history: "false",
            pnotify_nonblock: attrs.nonblock,
            pnotify_notice_icon: attrs.icon ? "'${attrs.icon}'" : null,
            pnotify_opacity: attrs.opacity,
            pnotify_stack: "stack_bottomleft",
            pnotify_text: attrs.text ? "'${attrs.text.replace("'", "\\'")}'" : null,
            pnotify_title: attrs.title ? "'${attrs.title}'" : null,
            pnotify_type: attrs.type ? "'${attrs.type}'" : null,
            pnotify_width: attrs.width
    ]

    // If the 'data' attribute exists, we use it as a JSON response object
    // and use its 'notice' content as value for the notice
    if (attrs.data) {
      args.pnotify_text = attrs.data + '.notice.text'
      args.pnotify_title = attrs.data + '.notice.title'
      args.pnotify_type = "'error'"

      // If the 'xhr' attribute is set, we use it as a XMLHttpRequest object
      // and use its content as text value for the notice
    } else if (attrs.xhr) {
      args.pnotify_text = "'Error ' + ${attrs.xhr}.status + '<br />' + ${attrs.xhr}.responseText"
      args.pnotify_type = "'error'"
    }

    switch (attrs.type) {
      case 'error':
        args.pnotify_type = "'error'"
        break
      case 'info':
        args.pnotify_type = "'notice'"
        args.pnotify_notice_icon = ""
        break
    }

    def noticeCode = "\$.pnotify({"
    noticeCode += args.findAll {k, v -> v}.collect {k, v ->
      " $k:$v"
    }.join(',')
    noticeCode += "});"

    // If the wrap attribute is defined, wrap the notice code in a jquery tag
    if (attrs.wrap && attrs.wrap == 'true')
      out << jq.jquery(null, noticeCode)
    else
      out << noticeCode
  }
}
