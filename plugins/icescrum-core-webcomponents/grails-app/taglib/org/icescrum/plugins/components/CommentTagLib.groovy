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

class CommentTagLib {
  static namespace = "isComment"

  def each = { attrs, body ->
    def bean = attrs.bean
    def varName = attrs.var ?: "comment"
    if (bean?.metaClass?.hasProperty(bean, "comments")) {
      bean.comments?.each {
        out << body((varName): it)
      }
    }
  }

  def eachRecent = { attrs, body ->
    def domain = attrs.domain
    if (!domain && attrs.bean) domain = attrs.bean?.class
    def varName = attrs.var ?: "comment"

    if (domain) {
      domain.recentComments?.each {
        out << body((varName): it)
      }
    }
  }

  def render = { attrs, body ->
    def bean = attrs.bean
    def noEscape = attrs.containsKey('noEscape') ? attrs.noEscape : false
    def noComment = attrs.noComment ?: 'No comment.'
    if (bean?.metaClass?.hasProperty(bean, "comments")) {
      out << g.render(template: "/components/comments", plugin: "icescrum-core-webcomponents", model: [commentable: bean, noEscape: noEscape, noComment:noComment])
    }
  }
}
