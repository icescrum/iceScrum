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
    def timeoutHttpSessionListener
    DefaultGrailsApplication grailsApplication

    def init = { servletContext ->

        servletContext.addListener(timeoutHttpSessionListener)
        localeResolver.defaultLocale = Locale.ENGLISH
        java.util.Locale.setDefault(Locale.ENGLISH)
        TimeZone.setDefault(TimeZone.getTimeZone(grailsApplication.config.icescrum.timezone.default))

        println " "
        println " "
        println """tt   tttttt   tttttt    EEEEE    EEEEEE    EEEE E     EE   EEEEEE EEEEE
tt  tt   ttt ttt   tt  EE   EE  EE   EEE  EEE   E     EE  EE   EEEE   EEE
tt tt     tt tt    tt  EE       E     EE  EE    E     EE  EE    EEE    EE
tt t        tt   ttt   EEEE    EE         E     E     EE  E     EE     EE      ,
tt t        tt ttt       EEEE  E         EE     E     EE  E     EE     EE ,,,,,,
tt t        tt t            EE EE        EE     E     EE  E      E     E ,,,,,,,
tt tt     tt tt     t EE    EE  E     EE EE     EE    EE  E      E       ,,,,,,
tt  tt   ttt ttt   tt EEE   EE  EE   EEE EE     EE   EEE  E      E      ,,,,,,,
t    tttttt    ttttt   EEEEEE    EEEEEE  EE      EEEEE    E      E     ,,,,,,,"""
        println " "
        println " "
        println "Version: ${Metadata.current['app.version']} - Build date: ${ Metadata.current['build.date'] ?: 'dev' }"
        println "Check our website for training, coaching or custom development: https://www.icescrum.com"
        println "Try for free or buy your iceScrum Pro license and start using its nice features: https://www.icescrum.com/pricing"
        println " "
    }

    static private boolean isValidType(String type) {
        type?.toLowerCase() in ["application/json", "application/xml"]
    }

    def destroy = {}
}