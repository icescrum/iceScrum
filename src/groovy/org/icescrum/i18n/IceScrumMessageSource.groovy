/*
 * Copyright (c) 2014 Kagilum SAS.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Nicolas Noullet (nnoullet@kagilum.com)
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */

package org.icescrum.i18n

import org.codehaus.groovy.grails.context.support.PluginAwareResourceBundleMessageSource
import org.springframework.context.support.ReloadableResourceBundleMessageSource.PropertiesHolder

class IceScrumMessageSource extends PluginAwareResourceBundleMessageSource {
    public Map<String, String> getAllMessages(Locale locale) {
        def propertiesHolders = ([] << getMergedProperties(locale)) << getMergedPluginProperties(locale)
        def messages = [:]
        propertiesHolders.each { PropertiesHolder holder ->
            holder.properties.each { key, val ->
                messages[key] = val
            }
        }
        messages
    }
}