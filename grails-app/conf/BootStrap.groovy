/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

import grails.util.Metadata
import org.codehaus.groovy.grails.commons.DefaultGrailsApplication

class BootStrap {

    def messageSource
    def localeResolver
    DefaultGrailsApplication grailsApplication

    def init = { servletContext ->

        localeResolver.defaultLocale = Locale.ENGLISH
        java.util.Locale.setDefault(Locale.ENGLISH)
        TimeZone.setDefault(TimeZone.getTimeZone(grailsApplication.config.icescrum.timezone.default))
        println("------------------");
        println "Starting iceScrum version:${Metadata.current['app.version']} SCR:#${Metadata.current['scm.version']} Build date:${Metadata.current['build.date']}"
        println("------------------");
    }
    def destroy = {

    }
}