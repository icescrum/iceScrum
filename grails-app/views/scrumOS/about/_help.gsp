<%@ page import="grails.util.Environment" %>
<div>
    <g:set var="analytics" value="?utm_source=about&utm_medium=link&utm_campaign=icescrum"/>
    <p>
        <strong>${message(code: 'is.dialog.about.version.link')}</strong> : <a href="${version.link.toString() + analytics}" target="_blank">${version.link}</a>
    </p>
    <p>
        <strong>${message(code: 'is.dialog.about.version.pro')}</strong> : <a href="${version.pro.toString() + analytics}" target="_blank">${version.pro}</a>
    </p>
    <p>
        <strong>${message(code: 'is.dialog.about.version.documentation.link')}</strong> : <a href="${version.documentation.toString() + analytics}" target="_blank">${version.documentation}</a>
    </p>
    <p>
        <strong>${message(code: 'is.dialog.about.version.documentation.gettingStarted')}</strong> : <a href="${version.gettingStarted.toString() + analytics}" target="_blank">${version.gettingStarted}</a>
    </p>
    <p>
        <strong>${message(code: 'is.dialog.about.version.forum.link')}</strong> : <a href="${version.forum.toString() + analytics}" target="_blank">${version.forum}</a>
    </p>
    <br/>
    <h4>${message(code: 'is.dialog.about.version.build.title')}</h4>
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <tbody>
                <tr>
                    <td><strong>${message(code: 'is.dialog.about.version.appVersion')}</strong></td>
                    <td>${versionNumber.contains('Cloud') ? versionNumber : versionNumber + ' Standalone'}</td>
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
                        <td>${configLocation}</td>
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
                        <td>{{ atmosphere.liveConnections }} <small class="muted pull-right">${message(code: 'is.ui.server.connections.refreshed')}</small></td>
                    </tr>
                    <tr ng-if="atmosphere.maxConnections">
                        <td>${message(code: 'is.ui.server.connections.max')}</td>
                        <td>{{ atmosphere.maxConnections }} <small class="muted pull-right">{{ atmosphere.maxConnectionsDate | dateTime}}</small></td>
                    </tr>
                    <!--<tr ng-if="atmosphere">
                        <td>${message(code: 'is.ui.server.connections.users.live')}</td>
                        <td>{{ atmosphere.liveUsers }} <small class="muted pull-right">({{ atmosphere.liveUsers.length }}) ${message(code: 'is.ui.server.connections.refreshed')}</small></td>
                    </tr>
                    <tr ng-if="atmosphere">
                        <td>${message(code: 'is.ui.server.connections.users.max')}</td>
                        <td>{{ atmosphere.maxUsers }} <small class="muted pull-right">({{ atmosphere.maxUsers.length }}) {{ atmosphere.maxUsersDate }}</small></td>
                    </tr>-->
                    <g:if test="${System.getenv('JAVA_OPTS')}">
                        <tr>
                            <td>JAVA_OPTS</td>
                            <td>${System.getenv('JAVA_OPTS')}</td>
                        </tr>
                        <tr>
                            <td>CATALINA_OPTS</td>
                            <td>${System.getenv('CATALINA_OPTS')}</td>
                        </tr>
                        <tr>
                            <td>CATALINA_HOME</td>
                            <td>${System.getenv('CATALINA_HOME')}</td>
                        </tr>
                        <tr>
                            <td>CATALINA_BASE</td>
                            <td>${System.getenv('CATALINA_BASE')}</td>
                        </tr>
                    </g:if>
                </g:if>
                <tr ng-if="application.transport">
                    <td>${message(code: 'is.ui.server.connections.transport')}</td>
                    <td>{{ application.transport }}</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>