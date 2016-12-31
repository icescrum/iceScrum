<%@ page import="grails.plugin.springsecurity.SpringSecurityUtils; org.icescrum.core.domain.security.Authority" %>
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
<table ng-controller="warningsCtrl">
    <thead ng-if="warnings">
    <tr>
        <th width="50%">${message(code:'is.dialog.about.warnings.name')}</th>
        <th width="50%">${message(code:'is.dialog.about.warnings.message')}</th>
    </tr>
    </thead>
    <tbody>
        <tr ng-repeat="warning in warnings">
            <td><i class="fa fa-{{ warning.icon }}"></i> {{ warning.title }}</td>
            <td>{{ warning.message }}</td>
            <g:if test="${SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)}">
                <td><button ng-if="warning.hideable" ng-click="hideWarning(warning)" class="btn btn-sm btn-default"><i class="fa" ng-class="{'fa-bell':!warning.silent,'fa-bell-slash':warning.silent}"></i></button></td>
            </g:if>
        </tr>
    </tbody>
</table>