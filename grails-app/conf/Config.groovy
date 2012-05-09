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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

import org.apache.log4j.DailyRollingFileAppender
import org.apache.log4j.PatternLayout
import org.icescrum.core.support.ApplicationSupport

/*
 Public URL
*/
grails.serverURL = "http://localhost:8080/${appName}"

/*
Administration section
 */
icescrum.registration.enable = true
icescrum.login.retrieve.enable = true

icescrum.alerts.subject_prefix = "[icescrum]"
icescrum.alerts.enable = true
icescrum.alerts.default.from = "webmaster@icescrum.org"

icescrum.attachments.enable = true
icescrum.alerts.errors.to = "dev@icescrum.org"
icescrum.timezone.default = System.getProperty('user.timezone') ?: 'UTC'

println "Server Timezone : ${icescrum.timezone.default}"

/*
Project administration section
 */
icescrum.project.import.enable = true
icescrum.project.export.enable = true
icescrum.project.creation.enable = true
icescrum.project.private.enable = true

/*
  IceScrum css theme
 */
icescrum.theme = 'is'
icescrum.gravatar.secure = false
icescrum.gravatar.enable = false

/*
  IceScrum base dir
*/
icescrum.baseDir = new File(System.getProperty('user.home'), appName).canonicalPath

/*
Autofollowing
 */
icescrum.auto_follow_productowner = true
icescrum.auto_follow_stakeholder  = true
icescrum.auto_follow_scrummaster  = true

/*  Mail section  */
/*grails.mail.host = "smtp.gmail.com"
grails.mail.port = 465
grails.mail.username = "username@gmail.com"
grails.mail.password = ""
grails.mail.props = ["mail.smtp.auth":"true",
        "mail.smtp.socketFactory.port":"465",
        "mail.smtp.socketFactory.class":"javax.net.ssl.SSLSocketFactory",
        "mail.smtp.socketFactory.fallback":"false"]*/


/*
  Push section
 */
icescrum.marshaller = [
        actor:[include:['totalAttachments']],
        task:[include:['totalAttachments','sprint']],
        feature:[include:['totalAttachments'],
                 asShort:['color', 'name']],
        story:[include:['totalAttachments','totalComments','tasks'],
               asShort:['state', 'effort']],
        sprint:[include:['activable','totalRemainingHours'],
                asShort:['state', 'capacity', 'velocity', 'orderNumber', 'parentReleaseId', 'hasNextSprint', 'activable']],
        release:[asShort:['name', 'state', 'endDate', 'startDate', 'orderNumber']],
        user:[asShort:['firstName', 'lastName']],
        productPreferences:[asShort:['displayRecurrentTasks','displayUrgentTasks','hidden','limitUrgentTasks','assignOnBeginTask']]
]

icescrum.restMarshaller = [
        //global exclude
        exclude:['dateCreated','totalAttachments','totalComments'],
        story:[exclude:['affectVersion','origin','backlog']],
        feature: [exclude: ['parentDomain','backlog']],
        actor: [exclude: ['backlog']],
        task:[exclude:['impediment']],
        product:[exclude: ['domains','impediments','goal']],
        sprint:[exclude: ['description','goal']],
        team:[exclude: ['velocity','description','preferences']],
        user: [exclude: ['password','accountExpired','accountLocked','passwordExpired']]
]

/*
    Check for update
*/
icescrum.check.enable   = true
icescrum.check.url      = 'http://www.icescrum.org'
icescrum.check.path     = 'check.php'
icescrum.check.interval = 1440 //in minutes (24h)
icescrum.check.timeout  = 5000
/*
 Attachmentable section
 */
grails.attachmentable.storyDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}stories${File.separator + it.id + File.separator}"}
grails.attachmentable.featureDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}features${File.separator + it.id + File.separator}"}
grails.attachmentable.actorDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}actors${File.separator + it.id + File.separator}"}
grails.attachmentable.taskDir = {
    if (it.parentStory)
        return "${File.separator + it.parentStory?.backlog?.id + File.separator}attachments${File.separator}tasks${File.separator + it.id + File.separator}"
    else
        return "${File.separator + it.backlog?.parentRelease?.parentProduct?.id + File.separator}attachments${File.separator}tasks${File.separator + it.id + File.separator}"
}

/*
  Default grails config
 */

grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [html: ['text/html', 'application/xhtml+xml'],
        xml: ['text/xml', 'application/xml'],
        text: 'text/plain',
        js: 'text/javascript',
        rss: 'application/rss+xml',
        atom: 'application/atom+xml',
        css: 'text/css',
        csv: 'text/csv',
        all: '*/*',
        json: ['application/json', 'text/json'],
        //form: 'application/x-www-form-urlencoded',
        multipartForm: 'multipart/form-data'
]

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"

// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'
// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable fo AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []

grails.views.javascript.library = 'jquery'

environments {
    development {
        icescrum.debug.enable = true
        grails.entryPoints.debug = false
        grails.tomcat.nio = true
        //grails.resources.debug=true
    }
    test {
        icescrum.debug.enable = true
        grails.entryPoints.debug = false
        grails.tomcat.nio = true
    }
    production {
        grails.config.locations = ["classpath:config.properties"]
        icescrum.debug.enable = false
        grails.entryPoints.debug = false
    }
}

// log4j configuration
icescrum.log.dir = System.getProperty('icescrum.log.dir') ?: 'logs';
println "log dir : ${icescrum.log.dir}"

log4j = {
    def logLayoutPattern = new PatternLayout("%d [%t] %-5p %c %x - %m%n")

    error 'org.codehaus.groovy.grails.plugins',
          'org.grails.plugin',
          'grails.app'

    error 'org.codehaus.groovy.grails.web.servlet',  //  controllers
          'org.codehaus.groovy.grails.web.pages', //  GSP
          'org.codehaus.groovy.grails.web.sitemesh', //  layouts
          'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
          'org.codehaus.groovy.grails.web.mapping', // URL mapping
          'org.codehaus.groovy.grails.commons', // core / classloading
          'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
          'org.springframework',
          'org.hibernate',
          'net.sf.ehcache.hibernate'

    warn  'org.mortbay.log'

    if (grails.entryPoints.debug) {
        debug 'org.icescrum.plugins.entryPoints'
    }

    if (ApplicationSupport.booleanValue(icescrum.debug.enable)) {
        debug 'grails.app.service.org.icescrum'
        debug 'grails.app.controller.org.icescrum'
        debug 'grails.app.domain.org.icescrum'
        debug 'grails.app.org.icescrum'
        debug 'org.icescrum.atmosphere'
        debug 'org.icescrum.cache'
        debug 'org.icescrum.core'
        debug 'grails.plugin.springcache'
        debug 'net.sf.jasperreports'
        debug 'com.kagilum'
    }else{
        off 'grails.plugin.springcache'
    }

    appenders {
        appender new DailyRollingFileAppender(name: "icescrumFileLog",
                fileName: "${icescrum.log.dir}/${appName}.log",
                datePattern: "'.'yyyy-MM-dd",
                layout: logLayoutPattern
        )

        rollingFile name: "stacktrace", maxFileSize: 1024, file: "${icescrum.log.dir}/stacktrace.log"
    }

    root {
        if (ApplicationSupport.booleanValue(icescrum.debug.enable)) {
            debug 'stdout', 'icescrumFileLog'
            error 'stdout', 'icescrumFileLog'
            info 'stdout', 'icescrumFileLog'
        }else{
            debug 'icescrumFileLog'
            error 'icescrumFileLog'
            info 'icescrumFileLog'
        }
        additivity = true
    }

    off 'org.codehaus.groovy.grails.web.converters.JSONParsingParameterCreationListener'
}

/*

 CACHE SECTION

 */

springcache {
    defaults {
        timeToLive = 432000
        timeToIdle = 0
    }
    caches {
        applicationCache {
            eternal = true
        }
    }
}

/*

SECURITY SECTION

*/

grails {
    plugins {
        springsecurity {
            userLookup.userDomainClassName = 'org.icescrum.core.domain.User'
            userLookup.authorityJoinClassName = 'org.icescrum.core.domain.security.UserAuthority'
            authority.className = 'org.icescrum.core.domain.security.Authority'
            successHandler.alwaysUseDefault = false

            useBasicAuth = true
            basic.realmName = "iceScrum authentication for private stuff"
            filterChain.chainMap = [
                    '/ws/**': 'JOINED_FILTERS,-exceptionTranslationFilter',
                    '/**': 'JOINED_FILTERS,-basicAuthenticationFilter,-basicExceptionTranslationFilter'
            ]

            auth.loginFormUrl = '/login'

            rememberMe {
                cookieName = 'iceScrum'
                key = 'twelveMe'
            }

            useRunAs = true
            runAs.key = 'tw3lv3Scrum!'
            acl.authority.changeAclDetails = 'ROLE_RUN_AS_PERMISSIONS_MANAGER'
        }
    }
}

/*

CLIENT MODULES SECTION

*/

grails.resources.caching.excludes = ['js/timeline**/*.js']
grails.resources.zip.excludes = ['/**/*.png', '/**/*.gif', '/**/*.jpg', '/**/*.gz']

if (!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
println "--------------------------------------------------------"
// 1: A command line option should override everything.
// Like grails -Dicescrum_config_location=C:\temp\icescrum-config.groovy run-app
if (System.getProperty(ApplicationSupport.CONFIG_ENV_NAME) && new File(System.getProperty(ApplicationSupport.CONFIG_ENV_NAME)).exists()) {
    println "Including configuration file specified on command line: " + System.getProperty(ApplicationSupport.CONFIG_ENV_NAME)
    grails.config.locations << "file:" + System.getProperty(ApplicationSupport.CONFIG_ENV_NAME)
}
// 2: If this is a developer machine, then they will have their own config and I should use that.
else if (new File("${userHome}${File.separator}.grails${File.separator}${appName}-config.groovy").exists()) {
    println "*** User defined config: file:${userHome}${File.separator}.grails${File.separator}${appName}-config.groovy. ***"
    grails.config.locations = ["file:${userHome}${File.separator}.grails${File.separator}${appName}-config.groovy"]
}
// 3: Most QA and PROD machines should define a System Environment variable that will define where we should look.
else if (System.getenv(ApplicationSupport.CONFIG_ENV_NAME) && new File(System.getenv(ApplicationSupport.CONFIG_ENV_NAME)).exists()) {
    println("Including System Environment configuration file: " + System.getenv(ApplicationSupport.CONFIG_ENV_NAME))
    grails.config.locations << "file:" + System.getenv(ApplicationSupport.CONFIG_ENV_NAME)
}
// 4: Last resort is looking for a properties based configuration on the developer machine.
else if (new File("${userHome}${File.separator}.grails${File.separator}${appName}.properties").exists()) {
    println "*** User defined config: file:${userHome}${File.separator}.grails${File.separator}${appName}.properties. ***"
    grails.config.locations = ["file:${userHome}${File.separator}.grails${File.separator}${appName}.properties"]
}
else if (new File("${userHome}${File.separator}.icescrum${File.separator}config.properties").exists()) {
    println "*** iceScrum home defined config: file:${userHome}${File.separator}.icescrum${File.separator}config.properties. ***"
    grails.config.locations = ["file:${userHome}${File.separator}.icescrum${File.separator}config.properties"]
}
else {
    println "*** No external configuration file defined (${ApplicationSupport.CONFIG_ENV_NAME}). ***"
}
println "(*) grails.config.locations = ${grails.config.locations}"
println "--------------------------------------------------------"
