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
    <p>
      <strong><g:message code="is.dialog.about.version.appVersion"/></strong> : ${g.meta(name:"app.version").contains('Pro_Cloud') ? g.meta(name:"app.version") : g.meta(name:"app.version") + ' Standalone'} <g:if test="${Metadata.current['app.promoteVersion'] == 'true'}">(<a data-ajax="true" href="${g.createLink(controller: "scrumOS", action: "whatsNew")}">${message(code:'is.ui.whatsnew.title')}</a>)</g:if>
    </p>
    <p>
        <strong><g:message code="is.dialog.about.appID"/></strong> : <is:appId/>
    </p>
    <p>
      <strong><g:message code="is.dialog.about.version.buildDate"/></strong> : <g:meta name="build.date"/>
    </p>
    <p>
      <strong><g:message code="is.dialog.about.version.scr"/></strong> : #<g:meta name="scm.version"/>
    </p>
    <g:if test="${g.meta(name:'environment.BUILD_NUMBER')}">
      <p>
        <strong><g:message code="is.dialog.about.version.buildNumber"/></strong> : #<g:meta name="environment.BUILD_NUMBER"/>
      </p>
    </g:if>
    <g:if test="${g.meta(name:'environment.BUILD_ID')}">
      <p>
        <strong><g:message code="is.dialog.about.version.buildID"/></strong> : <g:meta name="environment.BUILD_ID"/>
      </p>
    </g:if>
    <g:if test="${g.meta(name:'environment.BUILD_TAG')}">
      <p>
        <strong><g:message code="is.dialog.about.version.buildTag"/></strong> : <g:meta name="environment.BUILD_TAG"/>
      </p>
    </g:if>
    <p>
      <strong><g:message code="is.dialog.about.version.env"/></strong> : ${System.getProperty('grails.env')}
    </p>
<g:if test="${request.authenticated}">
    <p>
      <strong><g:message code="is.dialog.about.version.grailsVersion"/></strong> : <g:meta name="app.grails.version"/>
    </p>
    <p>
      <strong><g:message code="is.dialog.about.version.javaVersion"/></strong> : ${System.getProperty('java.version')}
    </p>
    <p>
        <strong><g:message code="is.dialog.about.version.serverVersion"/></strong> : ${server}
    </p>
</g:if>
</div>
<h4><g:message code="is.dialog.about.version.plugins.title"/></h4>
<g:set var="pluginManager" value="${applicationContext.getBean('pluginManager').allPlugins.sort({it.name.toUpperCase()})}"/>
<div class="table-responsive">
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th width="70%">${message(code:'is.dialog.about.version.plugin.name')}</th>
                <th width="30%">${message(code:'is.dialog.about.version.plugin.version')}</th>
            </tr>
        </thead>
        <tbody>
            <g:each in="${pluginManager}" var="plugin">
            <tr>
                <td>${plugin.name}</td>
                <td>${plugin.version}</td>
            </tr>
            </g:each>
        </tbody>
    </table>
</div>
<h4><g:message code="is.dialog.about.version.libraries.title"/></h4>
<div class="table-responsive">
    <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th width="60%">${message(code:'is.dialog.about.version.library.name')}</th>
            <th width="40%">${message(code:'is.dialog.about.version.library.version')}</th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${version.library}" var="library">
            <tr>
                <td>${library.name}</td>
                <td>${library.version}</td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>