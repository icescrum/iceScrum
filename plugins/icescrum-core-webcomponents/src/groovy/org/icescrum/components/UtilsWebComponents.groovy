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

package org.icescrum.components
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils

public final class UtilsWebComponents {
  /**
   * Check the attributes for the rendered, renderedOnRoles, renderedOnNotRoles.
   * If they are defined, compute their values and return a boolean determining if the tag is to be
   * rendered or not. The rendered** entry are removed from the attrs array afterward.
   * @param attrs
   * @return
   */
  final static IS_ALLOWED = {true}
  final static sec = new grails.plugins.springsecurity.SecurityTagLib()


  public static boolean rendered(attrs) {
    def isRendered = ([attrs.rendered, attrs.restrictOnAccess, attrs.renderedOnRoles, attrs.renderedOnNotRoles, attrs.restrictOnRoles, attrs.renderedOnAccess, attrs.renderedOnNotAccess] ==
            [null, null, null, null, null, null]) ||
            ((attrs.rendered == null || attrs.rendered.asBoolean()) &&
                    (attrs.renderedOnRoles == null || SpringSecurityUtils.ifAnyGranted(attrs.renderedOnRoles)) &&
                    (attrs.restrictOnRoles == null || SpringSecurityUtils.ifAnyGranted(attrs.restrictOnRoles)) &&
                    (attrs.renderedOnNotRoles == null || SpringSecurityUtils.ifNotGranted(attrs.renderedOnNotRoles)) &&
                    (attrs.renderedOnAccess == null || sec.access(expression: attrs.renderedOnAccess, IS_ALLOWED)) &&
                    (attrs.restrictOnAccess == null || sec.access(expression: attrs.restrictOnAccess, IS_ALLOWED)) &&
                    (attrs.renderedOnNotAccess == null || sec.access(expression: attrs.renderedOnNotAccess, IS_ALLOWED)))
    attrs.remove('rendered')
    attrs.remove('restrictOnRoles')
    attrs.remove('restrictOnAccess')
    attrs.remove('renderedOnRoles')
    attrs.remove('renderedOnNotRoles')
    attrs.remove('renderedOnAccess')
    attrs.remove('renderedOnNotAccess')
    return isRendered
  }

  /**
   * Check the attributes for the disabled, disabledOnRoles, disabledOnNotRoles.
   * If they are defined, compute their values and return a boolean determining if the tag is to be
   * enabled or not. The disabled** entry are removed from the attrs array afterward.
   * @param attrs
   * @return
   */
  public static boolean enabled(attrs) {
    def isEnabled = ([attrs.disabled, attrs.disabledOnRoles, attrs.disabledOnNotRoles, attrs.disabledOnAccess, attrs.disableOnNotAccess] == [null, null, null, null, null]) ||
            ((attrs.disabled == null || !attrs.disabled.asBoolean()) &&
                    (attrs.disabledOnRoles == null || SpringSecurityUtils.ifNotGranted(attrs.disabledOnRoles)) &&
                    (attrs.disabledOnAccess == null || sec.access(expression: attrs.disabledOnAccess, IS_ALLOWED)) &&
                    (attrs.disabledOnAccess == null || sec.access(expression: attrs.disableOnNotAccess, IS_ALLOWED)) &&
                    (attrs.disabledOnNotRoles == null || SpringSecurityUtils.ifAllGranted(attrs.disabledOnNotRoles)))
    attrs.remove('disabled')
    attrs.remove('disabledOnRoles')
    attrs.remove('disabledOnNotRoles')
    attrs.remove('disabledOnAccess')
    attrs.remove('disableOnNotAccess')
    return isEnabled
  }

  public static def formatColForJS(coll) {
    if (coll instanceof Map) {
      '{' + coll.findAll {k, v -> v}.collect {k, v ->
        if (v instanceof Collection || v instanceof Map) {
          v = formatColForJS(v)
        }
        " $k:$v"
      }.join(',') + '}'
    } else if (coll instanceof Collection) {
      '[' + coll.findAll {v -> v}.collect {v ->
        if (v instanceof Collection || v instanceof Map) {
          v = formatColForJS(v)
        }
        " $v"
      }.join(',') + ']'
    }
  }

  /**
   * Wrap the value with simple quotes if it is not null.
   * @param attr The value to wrap
   * @param defaultValue The value returned if attr is null
   * @return
   */
  public static def wrap(attr, defaultValue = null, doubleQuote = false) {
    if (attr instanceof Map) {
      defaultValue = attr.defaultValue ?: null
      doubleQuote = attr.doubleQuote ?: false
      attr = attr.attr
    }
    def quoteChar = doubleQuote ? '"' : '\''
    attr ? "${quoteChar}${attr}${quoteChar}" : defaultValue
  }

  /**
   * Normal map implementation does a shallow clone. This implements a deep clone for maps
   * using recursion
   */
  public static deepClone(Map map) {
      def cloned = [:]
      map?.each { k,v ->
          if(v instanceof Map) {
             cloned[k] = deepClone(v)
          }
          else {
           cloned[k] = v
          }
      }
      return cloned
  }

  public static String createQueryString(params) {
    def allParams = []
    for (entry in params) {
      def value = entry.value
      def key = entry.key
      allParams << "${key.encodeAsURL()}=${value.encodeAsURL()}".encodeAsJavaScript()
    }
    if (allParams.size() == 1) {
      return allParams[0]
    }
    return allParams.join('&')
  }
}
