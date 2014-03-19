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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 */
import org.grails.plugin.resource.CSSLinkProcessor
import org.grails.plugin.resource.mapper.MapperPhase


class CssFontFixResourceMapper {

    def grailsResourceProcessor
    static phase = MapperPhase.LINKNORMALISATION
    static defaultIncludes = [ '**/*.css' ]

    def map(resource, config) {
        def processor = new CSSLinkProcessor()
        if (log.debugEnabled) {
            log.debug "FontFixCSS Preprocessor munging ${resource}"
        }
        processor.process(resource, grailsResourceProcessor) { prefix, originalUrl, suffix ->
            if (originalUrl.indexOf('resource:/fonts/') >= 0){
                def revertedUrl = originalUrl.replaceAll('resource:/fonts/', '../fonts/')
                if (log.debugEnabled) {
                    log.debug "FontFixCSS reverts ${revertedUrl} from ${originalUrl}"
                }
                return "${prefix}${revertedUrl}${suffix}"
            } else {
                return "${prefix}${originalUrl}${suffix}"
            }
        }
    }

}