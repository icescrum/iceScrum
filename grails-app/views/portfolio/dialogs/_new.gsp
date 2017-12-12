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
        <wizard class="row wizard-row">
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
            <wz-step wz-title="${message(code: "is.dialog.wizard.section.portfolio")}" icon="fa fa-pencil">
                <ul>
                    <li ng-repeat="project in portfolio.projects">{{ project.name }}</li>
                </ul>
                <button type="button" ng-click="addNewProject()"></button>
                <div class="btn-toolbar wizard-next">
                    <button type="button"
                            role="button"
                            class="btn btn-default"
                            ng-click="$close()">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <input type="submit"
                           class="btn btn-default"
                           ng-disabled="portfolio.projects < 2"
                           wz-finish="createPortfolio(portfolio)"
                           value="${message(code: 'todo.is.ui.wizard.finish')}"/>
                </div>
            </wz-step>
        </wizard>
    </form>
</is:modal>