<%@ page import="org.icescrum.core.support.ApplicationSupport;grails.util.Environment" %>
<div>
    <g:set var="analytics" value="?utm_source=about&utm_medium=link&utm_campaign=icescrum"/>
    <div class="table-responsive">
        <table class="table">
            <tbody>
                <tr>
                    <td>${message(code: 'is.dialog.about.version.link')}</td>
                    <td><a href="${version.link.toString() + analytics}" target="_blank">${version.link}</a></td>
                </tr>
                <tr>
                    <td>${message(code: 'is.dialog.about.version.pro')}</td>
                    <td><a href="${version.pro.toString() + analytics}" target="_blank">${version.pro}</a></td>
                </tr>
                <tr>
                    <td>${message(code: 'is.ui.documentation')}</td>
                    <td><a href="${version.documentation.toString() + analytics}" target="_blank">${version.documentation}</a></td>
                </tr>
                <tr>
                    <td>${message(code: 'is.ui.documentation.api')}</td>
                    <td><a href="${ApplicationSupport.serverURL() + '/api'}" target="_blank">${ApplicationSupport.serverURL() + '/api'}</a></td>
                </tr>
                <tr>
                    <td>${message(code: 'is.ui.documentation.getting.started')}</td>
                    <td><a href="${version.gettingStarted.toString() + analytics}" target="_blank">${version.gettingStarted}</a></td>
                </tr>
                <tr>
                    <td>${message(code: 'is.dialog.about.version.forum.link')}</td>
                    <td><a href="${version.forum.toString() + analytics}" target="_blank">${version.forum}</a></td>
                </tr>
            </tbody>
        </table>
    </div>
    <h4 class="mb-2">${message(code: 'is.dialog.about.version.build.title')}</h4>
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <tbody>
                <tr>
                    <td><strong>${message(code: 'is.dialog.about.version.appVersion')}</strong></td>
                    <td>${versionNumber.contains('Cloud') ? versionNumber : versionNumber + ' On-Premise'}</td>
                </tr>
                <g:if test="${request.authenticated}">
                    <tr>
                        <td><strong>${message(code: 'is.dialog.about.appID')}</strong></td>
                        <td><is:appId/></td>
                    </tr>
                </g:if>
                <g:if test="${request.admin}">
                    <tr>
                        <td>${message(code: 'is.dialog.about.version.configLocation')}</td>
                        <td>${configLocation.encodeAsHTML()}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.ui.server.user.name')}</td>
                        <td>${System.getProperty('user.name') ?: ''}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.ui.server.user.home')}</td>
                        <td>${System.getProperty('user.home')}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.ui.server.user.start')}</td>
                        <td>${System.getProperty('user.dir')}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'config.icescrum.baseDir')}</td>
                        <td>${grailsApplication.config.icescrum.baseDir}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'config.icescrum.log.dir')}</td>
                        <td>${grailsApplication.config.icescrum.log.dir}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'config.icescrum.debug.enable')}</td>
                        <td>${grailsApplication.config.icescrum.debug.enable}</td>
                    </tr>
                    <tr>
                        <td>Server Timezone</td>
                        <td>${grailsApplication.config.icescrum.timezone.default}</td>
                    </tr>
                    <g:if test="${g.meta(name: 'build.date')}">
                        <tr>
                            <td>${message(code: 'is.dialog.about.version.buildDate')}</td>
                            <td><g:meta name="build.date"/></td>
                        </tr>
                    </g:if>
                    <g:if test="${g.meta(name: 'environment.BUILD_NUMBER')}">
                        <tr>
                            <td>${message(code: 'is.dialog.about.version.buildNumber')}</td>
                            <td>#<g:meta name="environment.BUILD_NUMBER"/></td>
                        </tr>
                    </g:if>
                    <g:if test="${grailsApplication.config.icescrum.beta.enable && grailsApplication.config.icescrum.beta.features}">
                        <tr>
                            <td>${message(code: 'is.ui.server.beta.features')}</td>
                            <td>
                                <g:each in="${grailsApplication.config.icescrum.beta.features}" var="feature">
                                    ${feature}: <g:if test="${grailsApplication.config.icescrum.beta[feature].enable}">${message(code: 'is.ui.server.beta.features.enabled')}</g:if>
                                    <g:else>${message(code: 'is.ui.server.beta.features.disabled')}</g:else><g:if test="${feature != grailsApplication.config.icescrum.beta.features.last()}">,</g:if>
                                </g:each>
                            </td>
                        </tr>
                    </g:if>
                    <tr>
                        <td>OS</td>
                        <td>${System.getProperty('os.name')} ${System.getProperty('os.version')} ${System.getProperty('os.arch')}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.dialog.about.version.javaVersion')}</td>
                        <td>${System.getProperty('java.version')}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.dialog.about.version.serverVersion')}</td>
                        <td>${server}</td>
                    </tr>
                    <tr>
                        <td>${message(code: 'is.ui.server.environment')}</td>
                        <td>${Environment.current == Environment.DEVELOPMENT ? 'dev' : grailsApplication.config.icescrum.environment}</td>
                    </tr>
                    <tr test="${maxMemory}">
                        <td>${message(code: 'is.ui.server.max.memory')}</td>
                        <td>${maxMemory}</td>
                    </tr>
                    <tr ng-if="atmosphere.liveConnections">
                        <td>${message(code: 'is.ui.server.connections.live')}</td>
                        <td>{{ atmosphere.liveConnections }} <small class="muted float-right">${message(code: 'is.ui.server.connections.refreshed')}</small></td>
                    </tr>
                    <tr ng-if="atmosphere.maxConnections">
                        <td>${message(code: 'is.ui.server.connections.max')}</td>
                        <td>{{ atmosphere.maxConnections }} <small class="muted float-right">{{ atmosphere.maxConnectionsDate | dateTime}}</small></td>
                    </tr>
                    <tr ng-if="atmosphere.liveUsers">
                        <td>${message(code: 'is.ui.server.connections.users.live')}</td>
                        <td>{{ atmosphere.liveUsers }} <small class="muted float-right">${message(code: 'is.ui.server.connections.refreshed')}</small></td>
                    </tr>
                    <tr ng-if="atmosphere.maxUsers">
                        <td>${message(code: 'is.ui.server.connections.users.max')}</td>
                        <td>{{ atmosphere.maxUsers }} <small class="muted float-right">{{ atmosphere.maxUsersDate }}</small></td>
                    </tr>
                    <tr ng-if="atmosphere.transports">
                        <td>${message(code: 'is.ui.server.connections.transports')}</td>
                        <td><span ng-repeat="(key, value) in atmosphere.transports">
                            {{ key }}: {{ value }},
                        </span>
                        </td>
                    </tr>
                    <g:if test="${System.getenv('JAVA_OPTS')}">
                        <tr>
                            <td>JAVA_OPTS</td>
                            <td>${System.getenv('JAVA_OPTS')}</td>
                        </tr>
                        <tr>
                            <td>CATALINA_OPTS</td>
                            <td>${System.getenv('CATALINA_OPTS')}</td>
                        </tr>
                    </g:if>
                    <tr>
                        <td>CATALINA_HOME</td>
                        <td>${System.getenv('CATALINA_HOME')}</td>
                    </tr>
                    <tr>
                        <td>CATALINA_BASE</td>
                        <td>${System.getenv('CATALINA_BASE')}</td>
                    </tr>
                    <tr>
                        <td>catalina.home</td>
                        <td>${System.getProperty('catalina.home')}</td>
                    </tr>
                    <tr>
                        <td>catalina.base</td>
                        <td>${System.getProperty('catalina.base')}</td>
                    </tr>
                </g:if>
                <tr ng-if="application.transport">
                    <td>${message(code: 'is.ui.server.connections.transport')}</td>
                    <td>{{ application.transport }}</td>
                </tr>
                <tr>
                    <td>${message(code: 'config.icescrum.serverURL')}</td>
                    <td>${serverUrl.encodeAsHTML()}</td>
                </tr>
                <tr>
                    <td>Mobile</td>
                    <td>${grailsApplication.mainContext.getBean('userAgentIdentService').isMobile()}</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>