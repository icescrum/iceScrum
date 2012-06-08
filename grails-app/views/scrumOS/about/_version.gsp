%{--
- Copyright (c) 2010 iceScrum Technologies.
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
--}%
<p>
  <strong><g:message code="is.dialog.about.version.link"/></strong> : <a href="${version.link}">${version.link}</a>
</p>
<p class="last">
  <strong><g:message code="is.dialog.about.version.documentation.link"/></strong> : <a href="${version.link}">${version.link}</a>
</p>
<h3><g:message code="is.dialog.about.version.build.title"/></h3>
<p>
  <strong><g:message code="is.dialog.about.version.appVersion"/></strong> : <g:meta name="app.version"/>
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
<p>
  <strong><g:message code="is.dialog.about.version.grailsVersion"/></strong> : <g:meta name="app.grails.version"/>
</p>
<p>
  <strong><g:message code="is.dialog.about.version.javaVersion"/></strong> : ${System.getProperty('java.version')}
</p>
<p class="last">
  <strong><g:message code="is.dialog.about.appID"/></strong> : <is:appId/>
</p>
<h3><g:message code="is.dialog.about.version.plugins.title"/></h3>
<g:set var="pluginManager" value="${applicationContext.getBean('pluginManager').allPlugins.sort({it.name.toUpperCase()})}"/>
<is:table class="buildinfos-table">
  <is:tableHeader name="${message(code:'is.dialog.about.version.plugin.name')}"/>
  <is:tableHeader name="${message(code:'is.dialog.about.version.plugin.version')}" class="buildinfos-table-version"/>
  <is:tableRows in="${pluginManager}" var="plugin">
    <is:tableColumn>
      ${plugin.name}
    </is:tableColumn>
    <is:tableColumn>
      ${plugin.version}
    </is:tableColumn>
  </is:tableRows>
</is:table>
<br/>
<h3><g:message code="is.dialog.about.version.libraries.title"/></h3>
<is:table class="buildinfos-table">
  <is:tableHeader name="${message(code:'is.dialog.about.version.library.name')}"/>
  <is:tableHeader name="${message(code:'is.dialog.about.version.library.version')}" class="buildinfos-table-version"/>
  <is:tableRows in="${version.library}" var="library">
    <is:tableColumn>
      ${library.name}
    </is:tableColumn>
    <is:tableColumn>
      ${library.version}
    </is:tableColumn>
  </is:tableRows>
</is:table>