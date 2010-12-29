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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stephane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

import org.apache.log4j.DailyRollingFileAppender
import org.apache.log4j.PatternLayout

/*
 Public URL
*/
grails.serverURL = "http://localhost:8080/${appName}"

/*
Administration section
 */
icescrum.enable.registration=true
icescrum.enable.login.retrieve=true

/*
Project administration section
 */
icescrum.project.enable.import=true
icescrum.project.enable.export=true
icescrum.project.enable.creation=true
icescrum.project.disable.private=false

/*
Team administration section
 */
icescrum.team.enable.creation = true

/*
  Images section
 */
icescrum.images.products.dir = ""
icescrum.images.teams.dir = ""
icescrum.images.users.dir = ""

/*
  IceScrum css theme
 */
icescrum.theme = 'is'

/*
  IceScrum base dir
*/
icescrum.baseDir = new File(System.getProperty('user.home'), appName).canonicalPath


/*
  Mail section
grails.mail.host = "smtp.gmail.com"
grails.mail.port = 465
grails.mail.username = "barrier.vincent@gmail.com"
grails.mail.password = ""
grails.mail.props = ["mail.smtp.auth":"true",
        "mail.smtp.socketFactory.port":"465",
        "mail.smtp.socketFactory.class":"javax.net.ssl.SSLSocketFactory",
        "mail.smtp.socketFactory.fallback":"false"]
grails.mail.default.from="webmaster@icescrum.org"
*/

/*
  Push section
 */
icepush.disabled=false

/*
 Attachmentable section
 */
grails.attachmentable.baseDir = icescrum.baseDir
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
  Report jasper section
*/

if (baseDir) {
  jasper.dir.reports = "${baseDir}${File.separator}src${File.separator}java${File.separator}org${File.separator}icescrum${File.separator}reports"
} else {
  jasper.dir.reports = "classpath:org${File.separator}icescrum${File.separator}reports"
}
jasper.dir.projects.reports = {(new File(System.getProperty('user.home'),appName).canonicalPath) + "${File.separator + it.backlog.id + File.separator}reports${File.separator}"}

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
        form: 'application/x-www-form-urlencoded',
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
  production {
    grails.config.locations = ["classpath:config.properties"]
  }
}
// log4j configuration
log4j = {
  def logLayoutPattern = new PatternLayout("%d [%t] %-5p %c %x - %m%n")

  error 'org.codehaus.groovy.grails.web.servlet',  //  controllers
          'org.codehaus.groovy.grails.web.pages', //  GSP
          'org.codehaus.groovy.grails.web.sitemesh', //  layouts
          'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
          'org.codehaus.groovy.grails.web.mapping', // URL mapping
          'org.codehaus.groovy.grails.commons', // core / classloading
          'org.codehaus.groovy.grails.plugins', // plugins
          'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
          'org.springframework',
          'org.hibernate',
          'net.sf.ehcache.hibernate'
  warn 'org.mortbay.log'

  appenders {
    appender new DailyRollingFileAppender(name: "icescrumFileLog",
            fileName: "logs/${appName}.log",
            datePattern: "'.'yyyy-MM-dd",
            layout: logLayoutPattern
    )
  }

  root {
    debug 'stdout', 'icescrumFileLog'
    error 'stdout', 'icescrumFileLog'
    info 'stdout', 'icescrumFileLog'
    additivity = true
  }

}

/*

 CACHE SECTION

 */

springcache {
  defaults {
    timeToLive = 600
  }
  caches {
    activitiesFeed {
      timeToLive = 120
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
              '/private/**': 'JOINED_FILTERS,-exceptionTranslationFilter',
              '/**': 'JOINED_FILTERS,-basicAuthenticationFilter,-basicExceptionTranslationFilter'
      ]

      auth.loginFormUrl = '/login'
      rememberMe {
        cookieName = 'iceScrum_doh_twelve_me'
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

environments {
  development {
    grails.resources.debug = true
  }
}

grails.resources.caching.excludes = ['js/timeline**/*.js']
grails.resources.zip.excludes = ['/**/*.png', '/**/*.gif', '/**/*.jpg', '/**/*.gz']

def ENV_NAME = "icescrum_config_location"
if (!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
println "--------------------------------------------------------"
// 1: A command line option should override everything.
// Like grails -Dicescrum_config_location=C:\temp\icescrum-config.groovy run-app
if (System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "Including configuration file specified on command line: " + System.getProperty(ENV_NAME)
    grails.config.locations << "file:" + System.getProperty(ENV_NAME)
}
// 2: If this is a developer machine, then they will have their own config and I should use that.
else if (new File("${userHome}/.grails/${appName}-config.groovy").exists()) {
        println "*** User defined config: file:${userHome}/.grails/${appName}-config.groovy. ***"
        grails.config.locations = ["file:${userHome}/.grails/${appName}-config.groovy"]
}
// 3: Most QA and PROD machines should define a System Environment variable that will define where we should look.
else if (System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println("Including System Environment configuration file: " + System.getenv(ENV_NAME))
    grails.config.locations << "file:" + System.getenv(ENV_NAME)
}
// 4: Last resort is looking for a properties based configuration on the developer machine.
else if (new File("${userHome}/.grails/${appName}.properties").exists()) {
        println "*** User defined config: file:${userHome}/.grails/${appName}.properties. ***"
        grails.config.locations = ["file:${userHome}/.grails/${appName}.properties"]
}
else {
        println "*** No external configuration file defined (${ENV_NAME}). ***"
}
println "(*) grails.config.locations = ${grails.config.locations}"
println "--------------------------------------------------------"