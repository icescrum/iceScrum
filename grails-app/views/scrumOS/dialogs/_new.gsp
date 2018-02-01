<%@ page import="grails.util.Holders" %>
%{--
- Copyright (c) 2017 Kagilum.
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


<is:modal title="${message(code: 'is.ui.workspace.choose')}" class="wizard">
    <div class="workspace-wizard">
        <div class="row">
            <g:each var="workspace" in="${Holders.grailsApplication.config.icescrum.workspaces}">
                <div class="workspace col-md-6 text-center">
                    <i class="fa fa-${workspace.value.icon} fa-7x"></i>
                    <div>${g.message(code: 'is.ui.workspace.description.' + workspace.key)}</div>
                    <button class="btn btn-primary" ${workspace.value.enabled(Holders.grailsApplication) ? '' : 'disabled="disabled"'}
                            ng-click="openWizard('new${workspace.key.capitalize()}')">
                        ${g.message(code: 'is.ui.workspace.new.' + workspace.key)}
                    </button>
                    <g:if test="${!workspace.value.enabled(Holders.grailsApplication)}">
                        <div class="text-muted">${g.message(code: 'is.ui.workspace.disabled.' + workspace.key)}</div>
                    </g:if>
                </div>
            </g:each>
        </div>
    </div>
</is:modal>