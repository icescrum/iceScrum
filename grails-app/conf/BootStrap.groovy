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
 */


import grails.util.Metadata
import org.codehaus.groovy.grails.commons.DefaultGrailsApplication
import org.codehaus.groovy.grails.web.mime.DefaultAcceptHeaderParser
import org.codehaus.groovy.grails.web.servlet.GrailsApplicationAttributes
import org.codehaus.groovy.grails.web.servlet.HttpHeaders

import javax.servlet.http.HttpServletRequest

class BootStrap {

    def localeResolver
    DefaultGrailsApplication grailsApplication

    def init = { servletContext ->

        localeResolver.defaultLocale = Locale.ENGLISH
        java.util.Locale.setDefault(Locale.ENGLISH)
        TimeZone.setDefault(TimeZone.getTimeZone(grailsApplication.config.icescrum.timezone.default))
        println("------------------");
        println "Starting iceScrum version:${Metadata.current['app.version']} SCR:#${Metadata.current['scm.version']} Build date:${Metadata.current['build.date']}"
        println("------------------");

        // TODO Hack grails 1.3.x bug with accept header for request.format should be remove when upgrade to grails 2.x
        HttpServletRequest.metaClass.getMimeTypes = { ->
            def result = delegate.getAttribute(GrailsApplicationAttributes.REQUEST_FORMATS)
            if (!result) {

                def userAgent = delegate.getHeader(HttpHeaders.USER_AGENT)
                def msie = userAgent && useAgent ==~ /msie(?i)/ ?: false

                def parser = new DefaultAcceptHeaderParser()
                def header
                if (delegate.getRequestURI()?.contains('ws/')) {
                    header = delegate.getHeader(HttpHeaders.ACCEPT)
                } else {
                    header = delegate.contentType
                }
                if (!isValidType(header)) header = delegate.getHeader(HttpHeaders.CONTENT_TYPE)
                if (msie) header = "*/*"
                result = parser.parse(header)

                delegate.setAttribute(GrailsApplicationAttributes.REQUEST_FORMATS, result)
            }
            result
        }
    }

    static private boolean isValidType(String type) {
        type?.toLowerCase() in ["application/json", "application/xml"]
    }

    def destroy = {}
}