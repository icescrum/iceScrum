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
<%@ page import="org.icescrum.core.domain.Release" %>
<g:set var="poOrsm" value="${request.productOwner || request.scrumMaster}"/>

<li class="first">
    <a href="#releasePlan/${release.id}">
        ${message(code:'is.ui.timeline.menu.open')}
    </a>
</li>
<g:if test="${poOrsm && (release.state == Release.STATE_WAIT && release.activable)}">
<li>
    <a href="${createLink(action:'activate', controller: 'release', id:release.id, params:[product:params.product])}"
       data-ajax="true"
       data-ajax-confirm="${message(code:'is.ui.timeline.menu.activate.confirm').encodeAsJavaScript()}"
       data-ajax-trigger="activate_release">
        ${message(code:'is.ui.timeline.menu.activate')}
    </a>
</li>
</g:if>
<g:if test="${poOrsm && (release.state == Release.STATE_INPROGRESS && release.closable)}">
    <a href="${createLink(action:'close', controller: 'release', id:release.id, params:[product:params.product])}"
       data-ajax="true"
       data-ajax-confirm="${message(code:'is.ui.timeline.menu.close.confirm').encodeAsJavaScript()}"
       data-ajax-trigger="close_release">
        ${message(code:'is.ui.timeline.menu.close')}
    </a>
</g:if>
<g:if test="${poOrsm && release.state != org.icescrum.core.domain.Release.STATE_DONE}">
<li>
    <a href="#timeline/edit/${release.id}">
        ${message(code:'is.ui.timeline.menu.update')}
    </a>
</li>
</g:if>
<g:if test="${poOrsm && release.state == Release.STATE_WAIT}">
<li>
    <a href="${createLink(action:'delete', controller: 'release', id:release.id, params:[product:params.product])}"
       data-ajax="true"
       data-ajax-trigger="remove_release">
        ${message(code:'is.ui.timeline.menu.delete')}
    </a>
</li>
</g:if>
<entry:point id="${controllerName}-${actionName}-menu" model="[release:release]"/>