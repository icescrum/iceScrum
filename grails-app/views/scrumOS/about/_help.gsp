%{--
- Copyright (c) 2015 Kagilum SAS.
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
<g:set var="analytics" value="?utm_source=about&utm_medium=link&utm_campaign=icescrum"/>
<p>
    <strong><g:message code="is.dialog.about.version.link"/></strong> : <a href="${version.link.toString() + analytics}">${version.link}</a>
</p>
<p>
    <strong><g:message code="is.dialog.about.version.pro"/></strong> : <a href="${version.pro.toString() + analytics}">${version.pro}</a>
</p>
<g:if test="${request.authenticated}">
    <p>
        <strong><g:message code="is.ui.guidedTour.welcome.label"/></strong> : <a href="javascript:;" onClick="jQuery('#dialog').dialog('close'); jQuery.icescrum.guidedTour('welcome', true)">${message(code: 'is.ui.guidedTour')}</a>
    </p>
    <p>
        <strong><g:message code="is.ui.guidedTour.createProject.label"/></strong> : <a href="javascript:;" onClick="jQuery('#dialog').dialog('close'); jQuery.icescrum.openWizard().done(function() { jQuery.icescrum.guidedTour('createProject', true) });">${message(code: 'is.ui.guidedTour')}</a>
    </p>
</g:if>
<p>
    <strong><g:message code="is.dialog.about.version.documentation.link"/></strong> : <a href="${version.documentation.toString() + analytics}">${version.documentation}</a>
</p>
<p>
    <strong><g:message code="is.dialog.about.version.documentation.gettingStarted"/></strong> : <a href="${version.gettingStarted.toString() + analytics}">${version.gettingStarted}</a>
</p>
<p class="last">
    <strong><g:message code="is.dialog.about.version.forum.link"/></strong> : <a href="${version.forum.toString() + analytics}">${version.forum}</a>
</p>