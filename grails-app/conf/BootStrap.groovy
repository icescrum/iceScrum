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
import org.icescrum.core.support.ApplicationSupport

class BootStrap {

    def localeResolver
    def authorityService
    def timeoutHttpSessionListener
    DefaultGrailsApplication grailsApplication

    def init = { servletContext ->

        if(grailsApplication.config.icescrum.createDefaultAdmin && !grailsApplication.config.icescrum.setupCompleted){
            println "Creating default admin..."
            authorityService.initDefaultAdmin()
            grailsApplication.config.icescrum.setupCompleted = true
        }

        servletContext.addListener(timeoutHttpSessionListener)
        localeResolver.defaultLocale = Locale.ENGLISH
        java.util.Locale.setDefault(Locale.ENGLISH)
        TimeZone.setDefault(TimeZone.getTimeZone(grailsApplication.config.icescrum.timezone.default))

        println " "
        println " "
        println """                                                                                                                        
            ,,,,,,,,,                                                                                                   
        ...,,,,,,,,,,,,,,                                                                                               
    ......,,,,,,,,,,,,,,*****                                                                                           
..........,,,,,,,,,,,,,,,********  .,                          ,                                            
  ........,,,,,,,,,,,,,*******,    .,                      ,##, .##/                                        
 *%%%%*...,,,,,,,,,,,,,****////*   **   ,*****    *****.   (##.       /#####  /#(##(.##   ##. ##(####/####. 
 %%%######*,,,,,,,,,,,*(((//////.  **  **       ,*,...,*,     /####/ ##.   ,  /##   .##   ##. ##   (#(   ## 
   //########(*,,,*(((((////*,     **  **,   *,  **   ..   ##*   *## ##(   #( /##   .##   ##. ##   (#(   ## 
(////////###((((((((((//*,,,,,,,.  **    ,***.    .****      (####     (###*  /##     (##*(#* ##   (#(   ## 
   *///////*/(((((((**,,,,,,,.                                                                                          
       */***********,,,,,,                                                                                              
           ,******,,,,                                                                                                  
               ,,,"""
        println " "
        println " "
        println "Version: ${Metadata.current['app.version']} - Build date: ${Metadata.current['build.date'] ?: 'now!'} - Release notes: ${ApplicationSupport.getReleaseNotesLink()}"
        println "Check our website for training, coaching or custom development: https://www.icescrum.com"
        println "Try for free or purchase a license to access all the Apps & integrations: https://www.icescrum.com/pricing/#on-premise"
        println " "
    }

    static private boolean isValidType(String type) {
        type?.toLowerCase() in ["application/json", "application/xml"]
    }

    def destroy = {}
}