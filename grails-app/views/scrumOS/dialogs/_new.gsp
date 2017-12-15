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


<is:modal title="${message(code: 'todo.is.ui.choose.project.portfolio')}" class="wizard">
    <div class="workspace-wizard">
        <div class="row">
            <g:each var="workspace" in="${Holders.grailsApplication.config.icescrum.workspaces}">
                <div class="workspace col-md-6 text-center">
                    <g:if test="${workspace.key == 'portfolio'}">
                        <i class="fa fa-${workspace.value.icon} fa-7x text-muted" style="opacity: 0.4"></i>
                        <div class="">${g.message(code: workspace.value.description)}</div>
                        <button class="btn btn-primary disabled" disabled="disabled" style="opacity: 0.4">${g.message(code: 'todo.is.ui.workspace.new', args: [message(code: workspace.value.name)])}*</button>
                        <div class="text-muted">${g.message(code: 'is.ui.soon')}</div>
                    </g:if>
                    <g:else>
                        <i class="fa fa-${workspace.value.icon} fa-7x"></i>
                        <div class="">${g.message(code: workspace.value.description)}</div>
                        <button class="btn btn-primary" ng-click="openWizard('new${workspace.key.capitalize()}')">${g.message(code: 'todo.is.ui.workspace.new', args: [message(code: workspace.value.name)])}</button>
                    </g:else>
                </div>
            </g:each>
        </div>
    </div>
</is:modal>