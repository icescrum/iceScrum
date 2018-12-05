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
        <div class="row" style="margin-top: 25px;">
            <div class="workspace col-md-4 text-center">
                <i class="fa fa-folder fa-7x"></i>
                <div>${message(code: 'is.ui.workspace.description.sampleProject')}</div>
                <button class="btn btn-default"
                        ng-disabled="application.submitting"
                        type="button"
                        tabindex="-1"
                        ng-click="createSampleProject()">
                    ${message(code: 'is.ui.workspace.new.sampleProject')}
                </button>
            </div>
            <g:each var="workspace" in="${Holders.grailsApplication.config.icescrum.workspaces}" status="i">
                <div class="workspace col-md-4 text-center">
                    <i class="fa fa-${workspace.value.icon} fa-7x"></i>
                    <div>${g.message(code: 'is.ui.workspace.description.' + workspace.key)}</div>
                    <button class="btn btn-primary" ${workspace.value.enabled(Holders.grailsApplication) ? '' : 'disabled="disabled"'}
                            type="button"
                            ng-click="openWizard('new${workspace.key.capitalize()}')">
                        ${g.message(code: 'is.ui.workspace.new.' + workspace.key)}
                    </button>
                    <g:if test="${!workspace.value.enabled(Holders.grailsApplication)}">
                        <a class="link" target="_blank" href="https://www.icescrum.com/pricing/">
                            <div class="text-muted">
                                <i class="fa fa-info-circle"></i> ${g.message(code: 'is.ui.workspace.disabled.' + workspace.key)}
                            </div>
                        </a>
                    </g:if>
                </div>
            </g:each>
        </div>
        <g:if test="${Holders.grailsApplication.config.icescrum.workspaces.size() > 1}">
            <div class="text-center" style="margin-bottom: 25px;">
                <a class="btn btn-secondary"
                   target="_blank"
                   href="https://www.icescrum.com/documentation/manage-product-development/">
                    <i class="fa fa-question-circle"></i> ${g.message(code: 'is.ui.workspace.choose.help')}
                </a>
            </div>
        </g:if>
    </div>
</is:modal>