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

<is:modal title="${message(code:'is.dialog.wizard')}" class="wizard" footer="${false}">
    <form name="newProjectForm"
          show-validation
          novalidate>
        <wizard class="row">
            <wz-step title="${message(code:"is.dialog.wizard.section.project")}">
                <h4>${message(code:"is.dialog.wizard.section.project")}</h4>
                <p class="help-block">${message(code:'is.dialog.wizard.section.project.description')}</p>
                <div class="row">
                    <div class="col-sm-8 form-group">
                        <label for="name">${message(code:'is.product.name')}</label>
                        <p class="input-group">
                            <input required
                                   autofocus="autofocus"
                                   name="name"
                                   type="text"
                                   class="form-control"
                                   ng-model="product.name"
                                   ng-required="isCurrentStep(1)"
                                   ng-remote-validate="/project/available/name">
                            <span class="input-group-btn">
                                <button class="btn"
                                        tooltip="{{product.preferences.hidden ? '${message(code: 'is.product.preferences.project.hidden')}' : '${message(code: 'todo.is.product.preferences.project.public')}' }}"
                                        tooltip-append-to-body="true"
                                        type="button"
                                        ng-click="product.preferences.hidden = !product.preferences.hidden"
                                        ng-class="{ 'btn-danger': product.preferences.hidden, 'btn-success': !product.preferences.hidden }">
                                    <i class="fa fa-lock" ng-class="{ 'fa-lock': product.preferences.hidden, 'fa-unlock': !product.preferences.hidden }"></i>
                                </button>
                            </span>
                        </p>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="pkey">${message(code:'is.product.pkey')}</label>
                        <input required
                               name="pkey"
                               type="text"
                               capitalize
                               class="form-control"
                               ng-model="product.pkey"
                               ng-pattern="/^[A-Z0-9]*$/"
                               ng-remote-validate="/project/available/pkey"
                               ng-required="isCurrentStep(1)">
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-4 form-group">
                        <label for="product.startDate">${message(code:'is.product.startDate')}</label>
                        <p class="input-group">
                            <input required
                                   type="text"
                                   class="form-control"
                                   name="product.startDate"
                                   ng-model="product.startDate"
                                   datepicker-popup="{{startDate.format}}"
                                   datepicker-options="startDate"
                                   is-open="startDate.opened"
                                   close-text="Close"
                                   show-button-bar="false"
                                   max-date="productMaxDate"
                                   ng-required="isCurrentStep(1)"/>
                            <span class="input-group-btn">
                                <button type="button" class="btn btn-default" ng-click="openDatepicker($event, false)"><i class="glyphicon glyphicon-calendar"></i></button>
                            </span>
                        </p>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="product.endDate">${message(code:'is.release.endDate')}</label>
                        <p class="input-group">
                            <input required
                                   type="text"
                                   class="form-control"
                                   name="product.endDate"
                                   ng-model="product.endDate"
                                   datepicker-popup="{{endDate.format}}"
                                   datepicker-options="endDate"
                                   is-open="endDate.opened"
                                   close-text="Close"
                                   show-button-bar="false"
                                   min-date="productMinDate"
                                   ng-class="{current:step.selected}"
                                   ng-required="isCurrentStep(1)"/>
                            <span class="input-group-btn">
                                <button type="button" class="btn btn-default" ng-click="openDatepicker($event, true)"><i class="glyphicon glyphicon-calendar"></i></button>
                            </span>
                        </p>
                    </div>
                    <div class="col-sm-4 form-group">
                        <label for="product.preferences.timezone">${message(code:'is.product.preferences.timezone')}</label>
                        <is:localeTimeZone required="required"
                                           class="form-control"
                                           ng-required="isCurrentStep(1)"
                                           name="product.preferences.timezone"
                                           ng-model="product.preferences.timezone"
                                           ui-select2=""></is:localeTimeZone>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-12 form-group">
                        <label for="description">${message(code:'is.product.description')}</label>
                        <textarea is-markitup
                                  name="product.description"
                                  class="form-control"
                                  placeholder="${message(code: 'todo.is.ui.product.description.placeholder')}"
                                  ng-model="product.description"
                                  ng-show="showDescriptionTextarea"
                                  ng-blur="showDescriptionTextarea = false"
                                  is-model-html="product.description_html"></textarea>
                        <div class="markitup-preview"
                             tabindex="0"
                             ng-show="!showDescriptionTextarea"
                             ng-click="showDescriptionTextarea = true"
                             ng-focus="showDescriptionTextarea = true"
                             ng-class="{'placeholder': !product.description_html}"
                             ng-bind-html="(product.description_html ? product.description_html : '<p>${message(code: 'todo.is.ui.product.description.placeholder')}</p>') | sanitize"></div>
                    </div>
                </div>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.step2')}" />
                </div>
            </wz-step>

            <wz-step title="${message(code:"is.dialog.wizard.section.team")}">
                <div class="row">
                    <div class="col-sm-12">
                        <h4>${message(code:"is.dialog.wizard.section.team")}</h4>
                        <p class="help-block">${message(code:'is.dialog.wizard.section.team.description')}</p>
                    </div>
                    <div class="col-sm-5">
                        <h4>Team</h4>
                        <label for="team.name">${message(code:'is.team.name')}</label>
                        <p class="input-group typeahead">
                            <input type="text"
                                   name="team.name"
                                   autofocus="autofocus"
                                   ng-model="team.name"
                                   typeahead="team as team.name for team in searchTeam($viewValue)"
                                   typeahead-loading="searching"
                                   typeahead-on-select="selectTeam($item, $model, $label)"
                                   typeahead-template-url="select.or.create.team.html"
                                   typeahead-input-formatter=""
                                   ng-disabled="team.selected"
                                   class="form-control">
                            <span class="input-group-addon"><i class="fa" ng-click="unSelectTeam()" ng-class="{ 'fa-search': !searching, 'fa-refresh':searching, 'fa-close':team.selected }"></i></span>
                        </p>
                    </div>
                    <div class="col-sm-7" ng-show="team.selected">
                        <h4>{{ team.members.length }} team member(s):</h4>
                        <table class="table table-striped">
                            <thead>
                            <tr>
                                <th></th>
                                <th>${message(code:'todo.is.ui.team.name')}</th>
                                <th>${message(code:'todo.is.ui.team.role')}</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr ng-repeat="member in team.members">
                                <td><img ng-src="{{ member | userAvatar }}" height="32" width="32" title="{{ member.username }}"></td>
                                <td><span title="{{ member.username }}" class="text-overflow">{{ member.firstName }} {{ member.lastName }}</span></td>
                                <td>
                                    <input type="checkbox" name="member.role" ng-model="member.scrumMaster" ng-disabled="team.id">
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <input type="submit" class="btn btn-default pull-right" wz-next value="Go on" />
            </wz-step>

            <wz-step title="${message(code:"is.dialog.wizard.section.options")}">
                <input type="submit" class="btn btn-default pull-right" wz-next value="Finish now" />
            </wz-step>

            <wz-step title="${message(code:"is.dialog.wizard.section.starting")}">
                <input type="submit" class="btn btn-default pull-right" wz-next value="Finish now" />
            </wz-step>

        </wizard>
    </form>
</is:modal>