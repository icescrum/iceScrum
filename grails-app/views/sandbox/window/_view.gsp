<%@ page import="org.icescrum.core.domain.Story; grails.converters.JSON" %>
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
--}%

<g:set var="productOwner" value="${request.productOwner}"/>

<div id="backlog-layout-window-${controllerName}"
     class="row list-group">
    <div ng-click="go('/sandbox/' + story.id)" ng-repeat="story in stories | filter: {state: 1} | orderBy: predicate"
         class="item story col-xs-4 col-lg-4 ui-selectee grid-group-item">
        {{ story.name }}
    </div>
</div>