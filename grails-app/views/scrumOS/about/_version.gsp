<%@ page import="grails.util.Metadata" %>
%{--
- Copyright (c) 2014 Kagilum SAS.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<h4><g:message code="is.dialog.about.version.build.title"/></h4>

<div class="table-responsive">
    <table class="table table-bordered table-striped">
        <tbody>
        <tr>
            <td><strong><g:message code="is.dialog.about.version.appVersion"/></strong></td>
            <td>${versionNumber.contains('Cloud') ? versionNumber : versionNumber + ' Standalone'}</td>
        </tr>
        <g:if test="${request.authenticated}">
            <tr>
                <td><strong><g:message code="is.dialog.about.appID"/></strong></td>
                <td><is:appId/></td>
            </tr>
        </g:if>
        <g:if test="${request.admin}">
            <tr>
                <td><g:message code="is.dialog.about.version.configLocation"/></td>
                <td>${configLocation}</td>
            </tr>
            <g:if test="${g.meta(name: 'build.date')}">
                <tr>
                    <td><g:message code="is.dialog.about.version.buildDate"/></td>
                    <td><g:meta name="build.date"/></td>
                </tr>
            </g:if>
            <g:if test="${g.meta(name: 'environment.BUILD_NUMBER')}">
                <tr>
                    <td><g:message code="is.dialog.about.version.buildNumber"/></td>
                    <td>#<g:meta name="environment.BUILD_NUMBER"/></td>
                </tr>
            </g:if>
            <g:if test="${g.meta(name: 'environment.BUILD_ID')}">
                <tr>
                    <td><g:message code="is.dialog.about.version.buildID"/></td>
                    <td><g:meta name="environment.BUILD_ID"/></td>
                </tr>
            </g:if>
            <g:if test="${g.meta(name: 'environment.BUILD_TAG')}">
                <tr>
                    <td><g:message code="is.dialog.about.version.buildTag"/></td>
                    <td><g:meta name="environment.BUILD_TAG"/></td>
                </tr>
            </g:if>
            <g:if test="${System.getProperty('grails.env')}">
                <tr>
                    <td><g:message code="is.dialog.about.version.env"/></td>
                    <td>${System.getProperty('grails.env')}</td>
                </tr>
            </g:if>
            <tr>
                <td><g:message code="is.dialog.about.version.grailsVersion"/></td>
                <td><g:meta name="app.grails.version"/></td>
            </tr>
            <tr>
                <td><g:message code="is.dialog.about.version.javaVersion"/></td>
                <td>${System.getProperty('java.version')}</td>
            </tr>
            <tr>
                <td><g:message code="is.dialog.about.version.serverVersion"/></td>
                <td>${server}</td>
            </tr>
        </g:if>
        </tbody>
    </table>
</div>
<g:if test="${request.authenticated}">
    <h4><g:message code="is.dialog.about.version.libraries.title"/></h4>
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <tbody>
            <g:each in="${version.library}" var="library">
                <tr>
                    <td>${library.name}</td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </div>
</g:if>