%{--
- Copyright (c) 2011 Kagilum SAS.
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
<%@ page import="org.icescrum.core.utils.BundleUtils; grails.converters.JSON; org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState; org.icescrum.core.domain.Story.TestState" %>
<div class='templates'>
    <g:render template="templates"/>
    <g:render template="/home/templates"/>
    <g:render template="/project/templates"/>
    <g:render template="/team/templates"/>
    <g:render template="/sprint/templates"/>
    <g:if test="${params.product}">
        <g:render template="/story/templates"/>
        <g:render template="/task/templates"/>
        <g:render template="/comment/templates"/>
        <g:render template="/attachment/templates"/>
        <g:render template="/activity/templates"/>
        <g:render template="/feature/templates"/>
        <g:render template="/acceptanceTest/templates"/>
    </g:if>
</div>
<script>
    angular.element(document).ready(function () {
        var $rootScope = angular.element(document).injector().get('$rootScope');
        var Session = angular.element(document).injector().get('Session');
        $rootScope.initApplicationMenus(${is.getMenuBarFromUiDefinitions(splitHidden: false) as JSON});
        $rootScope.initMessages(${i18nMessages});
        Session.setProject(${product as JSON});
        Session.setUser(${user as JSON});
        Session.create();
    });
</script>