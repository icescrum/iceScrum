/*
 * Copyright (c) 2016 Kagilum SAS.
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


import grails.util.Holders
import grails.util.Metadata
import org.apache.log4j.DailyRollingFileAppender
import org.apache.log4j.PatternLayout
import org.codehaus.groovy.grails.plugins.web.taglib.JavascriptTagLib
import org.icescrum.core.domain.Activity
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.web.JQueryProvider

import javax.naming.InitialContext



/* Public URL */
grails.serverURL = "http://localhost:${System.getProperty('grails.server.port.http') ?: '8080'}/${appName}"

/* Administration */
icescrum.feed.default.url = "https://www.icescrum.com/blog/feed/"
icescrum.feed.default.title = "iceScrum Blog"
icescrum.registration.enable = true
icescrum.login.retrieve.enable = true
icescrum.invitation.enable = false
icescrum.alerts.subject_prefix = "[icescrum]"
icescrum.alerts.enable = true
icescrum.alerts.default.from = "webmaster@icescrum.org"
icescrum.alerts.emailPerAccount = false
icescrum.attachments.enable = true
icescrum.alerts.errors.to = "dev@icescrum.org"
icescrum.gravatar.enable = true

/* Server TimeZone */
try {
    String extConfFile = (String) new InitialContext().lookup("java:comp/env/icescrum.timezone.default")
    if (extConfFile) {
        icescrum.timezone.default = extConfFile;
    }
} catch (Exception e) {
    icescrum.timezone.default = System.getProperty('user.timezone') ?: 'UTC'
}
println "Server Timezone : ${icescrum.timezone.default}"

/* Project administration */
icescrum.project.import.enable = true
icescrum.project.export.enable = true
icescrum.project.creation.enable = true
icescrum.project.private.enable = true
icescrum.project.private.default = false

/* iceScrum base dir */
try {
    String extConfFile = (String) new InitialContext().lookup("java:comp/env/icescrum.basedir")
    if (extConfFile) {
        icescrum.baseDir = extConfFile;
    }
} catch (Exception e) {
    icescrum.baseDir = new File(System.getProperty('user.home'), appName).canonicalPath
}

/* Autofollowing */
icescrum.auto_follow_productowner = true
icescrum.auto_follow_stakeholder  = true
icescrum.auto_follow_scrummaster  = true

/*  Mail */
/*grails.mail.host = "smtp.gmail.com"
grails.mail.port = 465
grails.mail.username = "username@gmail.com"
grails.mail.password = ""
grails.mail.props = ["mail.smtp.auth":"true",
                     "mail.smtp.socketFactory.port":"465",
                     "mail.smtp.socketFactory.class":"javax.net.ssl.SSLSocketFactory",
                     "mail.smtp.socketFactory.fallback":"false"]*/

/* Push */
icescrum.push.enable = true

//remove total*
icescrum.marshaller = [
        story: [include: ['testState', 'tags', 'dependences', 'attachments', 'liked', 'followed', 'countDoneTasks'],
                includeCount: ['comments'],
                textile: ['notes'],
                asShort: ['state', 'effort', 'uid', 'name', 'rank']],
        comment: [textile: ['body'], include: ['poster']],
        product: [include: ['owner', 'productOwners', 'stakeHolders', 'invitedStakeHolders', 'invitedProductOwners'],
                  exclude: ['cliches'],
                  textile: ['description']],
        team: [include: ['members', 'scrumMasters', 'invitedScrumMasters', 'invitedMembers', 'owner']],
        task: [exclude: ['impediment', 'participants'],
               textile: ['notes'],
               includeCount: ['comments'],
               include: ['tags', 'attachments', 'sprint']],
        user: [exclude: ['password', 'accountExpired', 'accountLocked', 'passwordExpired'],
               asShort: ['firstName', 'lastName']],
        actor: [include: ['tags', 'attachments'],
                withIds: ['stories']],
        feature: [include: ['countDoneStories', 'state', 'effort', 'tags', 'attachments', 'inProgressDate', 'doneDate'],
                  withIds: ['stories'],
                  textile: ['notes'],
                  asShort: ['color', 'name']],
        sprint: [include: ['activable', 'totalRemaining', 'duration', 'attachments'],
                 exclude: ['cliches'],
                 withIds: ['stories'],
                 textile: ['retrospective', 'doneDefinition'],
                 asShort: ['state', 'capacity', 'velocity', 'orderNumber', 'parentReleaseId', 'hasNextSprint', 'activable', 'parentReleaseName']],
        release: [include: ['duration', 'closable', 'activable', 'attachments'],
                  textile: ['vision'],
                  asShort: ['name', 'state', 'endDate', 'startDate', 'orderNumber'],
                  exclude: ['cliches']
        ],
        backlog: [include: ['count', 'isDefault'],
                  textile: ['notes']],
        activity: [include: ['important']],
        userpreferences: [asShort: ['activity', 'language', 'emailsSettings', 'filterTask']],
        productpreferences: [asShort: ['webservices', 'archived', 'noEstimation', 'autoDoneStory', 'displayRecurrentTasks', 'displayUrgentTasks', 'hidden', 'limitUrgentTasks', 'assignOnCreateTask',
                                       'stakeHolderRestrictedViews', 'assignOnBeginTask', 'autoCreateTaskOnEmptyStory', 'timezone', 'estimatedSprintsDuration', 'hideWeekend']],
        attachment: [include: ['filename']],
        acceptancetest: [textile: ['description'], asShort: ['state']]
]

icescrum.restMarshaller = [
        //global exclude
        exclude: ['dateCreated'],
        story: [exclude: ['backlog'], include: ['tags', 'testState', 'comments']],
        feature: [exclude: ['parentDomain', 'backlog'], include: ['tags']],
        actor: [exclude: ['backlog'], include: ['tags']],
        task: [exclude: ['impediment'], include: ['tags', 'comments']],
        product: [exclude: ['domains', 'impediments', 'goal', 'cliches', 'duration']],
        sprint: [exclude: ['description', 'cliches', 'duration']],
        release: [exclude: ['description', 'cliches', 'duration']],
        team: [exclude: ['velocity', 'description', 'preferences']],
        user: [exclude: ['password', 'accountExpired', 'accountLocked', 'passwordExpired', 'teams']],
        userpreferences: [asShort: ['activity', 'language']],
        acceptancetest: []
]

icescrum.activities.important = [Activity.CODE_SAVE, 'acceptAs', 'estimate', 'plan', 'unPlan', 'done', 'unDone', 'returnToSandbox']

/* Assets */
grails.assets.less.compile = 'less4j'
grails.assets.excludes = ["**/*.less"]
grails.assets.includes = ["styles.less"]
grails.assets.plugin."commentable".excludes = ["**/*"]
grails.assets.plugin."hd-image-utils".excludes = ["**/*"]

/* CORS */
icescrum.cors.enable = true
icescrum.cors.url.pattern = '/ws/*'

/* Check for update */
icescrum.check.enable   = true
icescrum.check.url      = 'https://www.icescrum.com'
icescrum.check.path     = 'wc-api/v2/kagilum/version'
icescrum.check.interval = 1440 //in minutes (24h)
icescrum.check.timeout  = 5000

/* Array for visual & catched errors */
icescrum.errors = []

/* Contexts */
icescrum {
    contexts {
        product {
            contextClass = Product
            config = { product -> [key: product.pkey, path: 'p'] }
            params = { product -> [product: product.id] }
            indexScrumOS = { productContext, user, securityService, springSecurityService ->
                def product = productContext.object
                if (product?.preferences?.hidden && !securityService.inProduct(product, springSecurityService.authentication) && !securityService.stakeHolder(product, springSecurityService.authentication, false)) {
                    forward(action: springSecurityService.isLoggedIn() ? 'error403' : 'error401', controller: 'errors')
                    return
                }

                if (product && user && !securityService.hasRoleAdmin(user) && user.preferences.lastProductOpened != product.pkey) {
                    user.preferences.lastProductOpened = product.pkey
                    user.save()
                }
            }
            contextScope = [
                charts:[
                    project:[
                        [id:'burnup',name:'is.ui.project.charts.productBurnup'],
                        [id:'burndown',name:'is.ui.project.charts.productBurndown'],
                        [id:'velocity',name:'is.ui.project.charts.productVelocity'],
                        [id:'parkingLot',name:'is.ui.project.charts.productParkingLot'],
                        [id:'flowCumulative',name:'is.ui.project.charts.productCumulativeFlow'],
                        [id:'velocityCapacity',name:'is.ui.project.charts.productVelocityCapacity'],
                    ],
                    release: [
                        [id:'burndown', name:'is.chart.releaseBurndown'],
                        [id:'parkingLot', name:'is.chart.releaseParkingLot'],
                    ],
                    sprint: [
                        [id:'burnupTasks', name:'is.chart.sprint.BurnupTasksChart'],
                        [id:'burnupPoints', name:'is.chart.sprint.BurnupPointsChart'],
                        [id:'burnupStories', name:'is.chart.sprint.BurnupStoriesChart'],
                        [id:'burndownRemaining', name:'is.chart.sprint.BurndownRemainingChart']
                    ]
                ]
            ]
        }
    }
}

/*
 Attachmentable section
 */
grails.attachmentable.storyDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}stories${File.separator + it.id + File.separator}"}
grails.attachmentable.featureDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}features${File.separator + it.id + File.separator}"}
grails.attachmentable.actorDir = {"${File.separator + it.backlog.id + File.separator}attachments${File.separator}actors${File.separator + it.id + File.separator}"}
grails.attachmentable.releaseDir = {"${File.separator + it.parentProduct.id + File.separator}attachments${File.separator}releases${File.separator + it.id + File.separator}"}
grails.attachmentable.sprintDir = {"${File.separator + it.parentRelease.parentProduct.id + File.separator}attachments${File.separator}sprints${File.separator + it.id + File.separator}"}
grails.attachmentable.productDir = {"${File.separator + it.id + File.separator}attachments${File.separator}product${File.separator + it.id + File.separator}"}
grails.attachmentable.taskDir = {
    if (it.parentStory)
        return "${File.separator + it.parentStory?.backlog?.id + File.separator}attachments${File.separator}tasks${File.separator + it.id + File.separator}"
    else
        return "${File.separator + it.backlog?.parentRelease?.parentProduct?.id + File.separator}attachments${File.separator}tasks${File.separator + it.id + File.separator}"
}

grails.taggable.preserve.case = true

/* Default grails config */
grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.disable.accept.header.userAgents = ['Gecko', 'WebKit', 'Presto', 'Trident'] // experiment
grails.mime.types = [
        html: ['text/html', 'application/xhtml+xml'],
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

grails.controllers.defaultScope = 'singleton' // big experiment

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
    }
    test {
        icescrum.debug.enable = true
        grails.entryPoints.debug = false
        grails.tomcat.nio = true
    }
    production {
        grails.config.locations = []
        icescrum.debug.enable = false
        grails.entryPoints.debug = false
    }
}

grails.cache.config = {
    cache {
        name 'feed'
        timeToLiveSeconds 120
    }
}

icescrum.securitydebug.enable = false

/* log4j configuration */
try {
    String extConfFile = (String) new InitialContext().lookup("java:comp/env/icescrum.log.dir")
    if (extConfFile) {
        icescrum.log.dir = extConfFile;
    }
} catch (Exception e) {
    icescrum.log.dir = System.getProperty('icescrum.log.dir') ?: 'logs';
}
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
    warn  'org.atmosphere.cpr'

    if (Holders.config.grails.entryPoints.debug) {
        debug 'org.icescrum.plugins.entryPoints'
    }

    if (ApplicationSupport.booleanValue(Holders.config.icescrum.debug.enable)) {
        debug "org.grails.plugins.atmosphere_meteor"
        debug 'grails.app.controllers.org.icescrum'
        debug 'grails.app.controllers.com.kagilum'
        debug 'grails.app.services.org.icescrum'
        debug 'grails.app.services.com.kagilum'
        debug 'grails.app.domain.org.icescrum'
        debug 'grails.app.domain.com.kagilum'
        debug 'org.icescrum.plugins.chat'
        debug 'org.icescrum.atmosphere'
        debug 'grails.app.org.icescrum'
        debug 'org.icescrum.plugins'
        debug 'net.sf.jasperreports'
        debug 'org.icescrum.core'
        debug 'org.atmosphere'
        debug 'com.kagilum'
    }

    if (ApplicationSupport.booleanValue(Holders.config.icescrum.securitydebug.enable)) {
        debug 'org.springframework.security'
        /* debug 'grails.plugin.springsecurity'*/
    }

    appenders {
        appender new DailyRollingFileAppender(name: "icescrumFileLog",
                fileName: "${Holders.config.icescrum.log.dir}/${Metadata.current.'app.name'}.log",
                datePattern: "'.'yyyy-MM-dd",
                layout: logLayoutPattern
        )

        rollingFile name: "stacktrace", maxFileSize: 1024, file: "${Holders.config.icescrum.log.dir}/stacktrace.log"
    }

    root {
        if (ApplicationSupport.booleanValue(Holders.config.icescrum.debug.enable)) {
            debug 'stdout', 'icescrumFileLog'
            error 'stdout', 'icescrumFileLog'
            info 'stdout', 'icescrumFileLog'
        } else {
            debug 'icescrumFileLog'
            error 'icescrumFileLog'
            info 'icescrumFileLog'
        }
        additivity = true
    }

    off 'org.codehaus.groovy.grails.web.converters.JSONParsingParameterCreationListener'
    off 'org.codehaus.groovy.grails.web.converters.XMLParsingParameterCreationListener'
}

/* Security */
grails {
    plugin {
        springsecurity {
            password.algorithm = 'SHA-256'
            password.hash.iterations = 1

            rejectIfNoRule = false
            fii.rejectPublicInvocations = true
            controllerAnnotations.staticRules = [
                    //app controllers rules
                    '/stream/app/**' : ['permitAll'],
                    '/scrumOS/**'    : ['permitAll'],
                    '/user/**'       : ['permitAll'],
                    '/errors/**'     : ['permitAll'],
                    '/assets/**'     : ['permitAll'],
                    '/**/js/**'      : ['permitAll'],
                    '/**/css/**'     : ['permitAll'],
                    '/**/images/**'  : ['permitAll'],
                    '/**/favicon.ico': ['permitAll']
            ]

            userLookup.userDomainClassName = 'org.icescrum.core.domain.User'
            userLookup.authorityJoinClassName = 'org.icescrum.core.domain.security.UserAuthority'
            authority.className = 'org.icescrum.core.domain.security.Authority'
            successHandler.alwaysUseDefault = false

            useBasicAuth = true
            basic.realmName = "iceScrum authentication for REST API"
            filterChain.chainMap = [
                    '/ws/**': 'JOINED_FILTERS,-exceptionTranslationFilter',
                    '/**'   : 'JOINED_FILTERS,-basicAuthenticationFilter,-basicExceptionTranslationFilter'
            ]

            auth.loginFormUrl = '/login'

            rememberMe {
                cookieName = 'iceScrum'
                key = 'VincNicoJuShazam'
            }

            useRunAs = true
            runAs.key = 'VincNicoJuShazam!'
            acl.authority.changeAclDetails = 'ROLE_RUN_AS_PERMISSIONS_MANAGER'
            ldap.authorities.retrieveGroupRoles = false
            ldap.authorities.groupSearchFilter = ""
            ldap.authorities.groupSearchBase = ""
            ldap.active = false

            useSecurityEventListener = true
            onInteractiveAuthenticationSuccessEvent = { e, appCtx ->
                User.withTransaction {
                    def user = User.lock(e.authentication.principal.id)
                    user.lastLogin = new Date()
                    user.save(flush: true)
                }
            }
        }
    }
}

/* User config */
environments {
    production {
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
        } else if (new File("${userHome}${File.separator}.icescrum${File.separator}config.groovy").exists()) {
            println "*** iceScrum home defined config: file:${userHome}${File.separator}.icescrum${File.separator}config.groovy. ***"
            grails.config.locations = ["file:${userHome}${File.separator}.icescrum${File.separator}config.groovy"]
        } else {
            println "*** No external configuration file defined (${ApplicationSupport.CONFIG_ENV_NAME}). ***"
        }
        try {
            String extConfFile = (String) new InitialContext().lookup("java:comp/env/icescrum_config_location") ?: (String) new InitialContext().lookup("java:comp/env/icescrum.config.location")
            if (extConfFile) {
                grails.config.locations << extConfFile
                println "*** JNDI defined config: file:${extConfFile}"
            }
        } catch (Exception e) {}
        println "(*) grails.config.locations = ${grails.config.locations}"
        println "--------------------------------------------------------"
    }
}

JavascriptTagLib.LIBRARY_MAPPINGS.jquery = ["jquery/jquery-${jQueryVersion}.min"]
JavascriptTagLib.PROVIDER_MAPPINGS.jquery = JQueryProvider.class


//cache config
def uniqueCacheManagerName = appName + "-EhCacheManager-" + System.currentTimeMillis()
grails {
    cache {
        order = 2000 // higher than default (1000) and plugins, usually 1500
        enabled = true
        clearAtStartup = true // reset caches when redeploying
        ehcache {
            cacheManagerName = uniqueCacheManagerName
        }
        config = {
            provider {
                // unique name when configuring caches
                name uniqueCacheManagerName
            }
        }
    }
}
beans {
    cacheManager {
        shared = true
    }
}