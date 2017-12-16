<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
%{--
- Copyright (c) 2014 Kagilum.
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


<is:modal icon="briefcase" title="{{ (portfolio.name ? portfolio.name : '${message(code: /is.dialog.wizard.portfolio/)}') + (portfolio.fkey ? ' - ' + portfolio.fkey : '') }}" class="wizard" footer="${false}">
    <form name="formHolder.portfolioForm"
          show-validation
          novalidate>
        <wizard class="row wizard-row" name="portfolio">
            <wz-step wz-title="${message(code: "is.dialog.wizard.section.portfolio")}" icon="fa fa-pencil">
                <ng-include src="'form.general.portfolio.html'"></ng-include>
                <div class="btn-toolbar wizard-next">
                    <button type="button"
                            role="button"
                            class="btn btn-default"
                            ng-click="$close()">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <input type="submit" class="btn btn-default" ng-disabled="formHolder.portfolioForm.$invalid" wz-next value="${message(code: 'todo.is.ui.wizard.next')}"/>
                </div>
            </wz-step>
            <wz-step wz-title="${message(code: "is.dialog.wizard.section.portfolio.projects")}" icon="fa fa-folder">
                <label for="project.name">${message(code: 'todo.is.ui.project.create.or.select')}</label>
                <div class="input-group" style="margin-bottom:15px;">
                    <input autocomplete="off"
                           type="text"
                           autofocus
                           name="project.name"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.project.noproject')}"
                           uib-typeahead="project as project.name for project in searchProject($viewValue)"
                           typeahead-loading="searching"
                           typeahead-wait-ms="250"
                           typeahead-on-select="selectProject($item, $model); "
                           typeahead-template-url="select.or.create.project.html"
                           ng-model="projectSelection">
                    <span class="input-group-addon"><i class="fa fa-search"></i></span>
                </div>
                <table class="table table-striped table-bordered" ng-if="portfolio.projectsSize > 0">
                    <thead>
                        <th>${message(code: 'is.project.name')}</th>
                        <th>${message(code: 'is.project.startDate')}</th>
                        <th>${message(code: 'is.project.preferences.planification.estimatedSprintsDuration')}</th>
                        <th>${message(code: 'todo.is.ui.project.productOwners')}</th>
                        <th>${message(code: 'is.team')}</th>
                        <th></th>
                    </thead>
                    <tbody>
                        <tr ng-repeat="project in portfolio.projects" is-watch="project">
                            <td>
                                {{:: project.name }} <i ng-class="['fa', {'fa-unlock text-success': !project.preferences.hidden, 'fa-lock text-danger': project.preferences.hidden }]"></i> <div class="bg-warning" ng-if="project.id"
                                                                                                                                                                                                 style="display: inline-block;padding-left: 2px;padding-right: 2px;font-weight:bold;">existing</div><div
                                    class="bg-success" ng-if="!project.id" style="display: inline-block;padding-left: 2px;padding-right: 2px;font-weight:bold;">new</div>
                            </td>
                            <td>{{:: project.startDate | dayShort }}</td>
                            <td>{{:: project.preferences.estimatedSprintsDuration }} ${g.message(code: 'is.dialog.wizard.project.days').toLowerCase()}</td>
                            <td>{{:: project.productOwners | displayNames }}</td>
                            <td>{{:: project.team.name }} ({{:: (project.team.scrumMasters.length + project.team.members.length) }})</td>
                            <td><button class="btn btn-default btn-sm" ng-click="removeProject(project)" type="button"><i class="fa fa-times"></i></button></td>
                        </tr>
                    </tbody>
                </table>
                <div class="btn-toolbar wizard-next">
                    <button type="button"
                            role="button"
                            class="btn btn-default"
                            ng-click="$close()">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <input type="submit" class="btn btn-default" ng-disabled="portfolio.projectsSize < 2" wz-next value="${message(code: 'todo.is.ui.wizard.next')}"/>
                </div>
            </wz-step>
            <wz-step wz-title="${message(code: "is.dialog.wizard.section.portfolio.members")}" icon="fa fa-users">
                <div class="row">
                    <div class="col-sm-4">
                        <label for="businessOwners.search">${message(code: 'todo.is.ui.select.portfolio.businessOwner')}</label>
                        <p class="input-group">
                            <input autocomplete="off"
                                   type="text"
                                   name="businessOwners.search"
                                   id="businessOwners.search"
                                   class="form-control"
                                   placeholder="${message(code: 'todo.is.ui.select.notext')}"
                                   ng-model="bo.name"
                                   uib-typeahead="bo as bo.name for bo in searchUsers($viewValue, true)"
                                   typeahead-append-to-body="true"
                                   typeahead-loading="searchingBo"
                                   typeahead-min-length="2"
                                   typeahead-wait-ms="250"
                                   typeahead-on-select="addUser($item, 'bo')"
                                   typeahead-template-url="select.member.html">
                            <span class="input-group-addon">
                                <i class="fa" ng-class="{ 'fa-search': !searchingBo, 'fa-refresh':searchingBo }"></i>
                            </span>
                        </p>
                    </div>
                    <div class="col-sm-8">
                        <label ng-if="portfolio.businessOwners.length">${message(code: 'todo.is.ui.portfolio.businessOwners')}</label>
                        <div ng-class="{'list-users': portfolio.businessOwners.length > 0}">
                            <ng-include ng-init="role = 'bo';" ng-repeat="user in portfolio.businessOwners" src="'user.item.html'"></ng-include>
                        </div>
                    </div>
                </div>
                <div class="row" ng-show="portfolio.hidden">
                    <div class="col-sm-4">
                        <label for="stakeHolders.search">${message(code: 'todo.is.ui.select.portfolio.stakeholder')}</label>
                        <p class="input-group">
                            <input autocomplete="off"
                                   type="text"
                                   name="stakeHolder.search"
                                   id="stakeHolder.search"
                                   class="form-control"
                                   placeholder="${message(code: 'todo.is.ui.select.notext')}"
                                   ng-model="sh.name"
                                   uib-typeahead="sh as sh.name for sh in searchUsers($viewValue)"
                                   typeahead-append-to-body="true"
                                   typeahead-loading="searchingSh"
                                   typeahead-min-length="2"
                                   typeahead-wait-ms="250"
                                   typeahead-on-select="addUser($item, 'sh')"
                                   typeahead-template-url="select.member.html">
                            <span class="input-group-addon">
                                <i class="fa" ng-class="{ 'fa-search': !searchingSh, 'fa-refresh':searchingSh }"></i>
                            </span>
                        </p>
                    </div>
                    <div class="col-sm-8">
                        <label ng-if="portfolio.stakeHolders.length">${message(code: 'todo.is.ui.portfolio.stakeholders')}</label>
                        <div ng-class="{'list-users': portfolio.stakeHolders.length > 0}">
                            <ng-include ng-init="role = 'sh';" ng-repeat="user in portfolio.stakeHolders" src="'user.item.html'"></ng-include>
                        </div>
                    </div>
                </div>
                <div class="btn-toolbar wizard-next">
                    <button type="button"
                            role="button"
                            class="btn btn-default"
                            ng-click="$close()">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <input type="submit"
                           class="btn btn-primary"
                           ng-disabled=""
                           wz-finish="createPortfolio(portfolio)"
                           value="${message(code: 'todo.is.ui.wizard.finish', args: [message(code: 'is.workspace.portfolio').toLowerCase()])}"/>
                </div>
            </wz-step>
        </wizard>
    </form>
</is:modal>