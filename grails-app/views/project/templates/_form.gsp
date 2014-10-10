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
<script type="text/ng-template" id="form.project.html">
    <h4>${message(code:"is.dialog.wizard.section.project")}</h4>
    <p class="help-block">${message(code:'is.dialog.wizard.section.project.description')}</p>
    <div class="row">
        <div class="col-sm-8 col-xs-8 form-group">
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
                    <a class="btn"
                       tooltip="{{product.preferences.hidden ? '${message(code: 'is.product.preferences.project.hidden')}' : '${message(code: 'todo.is.product.preferences.project.public')}' }}"
                       tooltip-append-to-body="true"
                       type="button"
                       ng-click="product.preferences.hidden = !product.preferences.hidden"
                       ng-class="{ 'btn-danger': product.preferences.hidden, 'btn-success': !product.preferences.hidden }">
                        <i class="fa fa-lock" ng-class="{ 'fa-lock': product.preferences.hidden, 'fa-unlock': !product.preferences.hidden }"></i>
                    </a>
                </span>
            </p>
        </div>
        <div class="col-sm-4 col-xs-4 form-group">
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
        <div class="col-sm-4 col-xs-6 form-group">
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
        <div class="col-sm-4 col-xs-6 form-group">
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
        <div class="col-sm-4 col-xs-12 form-group">
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
</script>