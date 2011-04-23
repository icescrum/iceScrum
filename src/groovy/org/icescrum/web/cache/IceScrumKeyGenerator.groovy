/*
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
 * Vincent Barrier (vbarrier@kagilum.com)
 */
package org.icescrum.web.cache

import grails.plugin.springcache.key.CacheKeyBuilder
import grails.plugin.springcache.web.ContentCacheParameters
import grails.plugin.springcache.web.key.AbstractKeyGenerator

class IceScrumKeyGenerator extends AbstractKeyGenerator{

    @Override protected void generateKeyInternal(CacheKeyBuilder builder, ContentCacheParameters context) {
        def currentLocale = context.request.session?.getAttribute("org.springframework.web.servlet.i18n.SessionLocaleResolver.LOCALE")
		currentLocale = currentLocale?currentLocale:context.request?.getLocale()

        builder << context.controllerName
		builder << context.actionName
        builder << currentLocale

        context.params?.sort { it.key }?.each { entry ->
			if (!(entry.key in ["controller", "action"])) {
				builder << entry
			}
		}
    }
}
