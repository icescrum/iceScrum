<%@ page import="org.icescrum.core.domain.security.Authority; grails.plugin.springsecurity.SpringSecurityUtils; org.icescrum.core.support.ApplicationSupport" %>
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
                       ng-model="project.name"
                       ng-required="isCurrentStep(1)"
                       ng-remote-validate="/project/available/name">
                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)}">
                    <span class="input-group-btn">
                        <a class="btn"
                           tooltip="{{project.preferences.hidden ? '${message(code: 'is.product.preferences.project.hidden')}' : '${message(code: 'todo.is.product.preferences.project.public')}' }}"
                           tooltip-append-to-body="true"
                           type="button"
                           ng-click="project.preferences.hidden = !project.preferences.hidden"
                           ng-class="{ 'btn-danger': project.preferences.hidden, 'btn-success': !project.preferences.hidden }">
                            <i class="fa fa-lock" ng-class="{ 'fa-lock': project.preferences.hidden, 'fa-unlock': !project.preferences.hidden }"></i>
                        </a>
                    </span>
                </g:if>
            </p>
        </div>
        <div class="col-sm-4 col-xs-4 form-group">
            <label for="pkey">${message(code:'is.product.pkey')}</label>
            <input required
                   name="pkey"
                   type="text"
                   capitalize
                   class="form-control"
                   ng-model="project.pkey"
                   ng-pattern="/^[A-Z0-9]*$/"
                   ng-required="isCurrentStep(1)"
                   ng-remote-validate="/project/available/pkey">
        </div>
    </div>
    <div class="row">
        <div class="col-sm-4 col-xs-6 form-group">
            <label for="project.startDate">${message(code:'is.product.startDate')}</label>
            <p class="input-group">
                <input required
                       type="text"
                       class="form-control"
                       name="project.startDate"
                       ng-model="project.startDate"
                       datepicker-popup="{{startDate.format}}"
                       datepicker-options="startDate"
                       is-open="startDate.opened"
                       close-text="Close"
                       show-button-bar="false"
                       max-date="projectMaxDate"
                       ng-required="isCurrentStep(1)"/>
                <span class="input-group-btn">
                    <button type="button" class="btn btn-default" ng-click="openDatepicker($event, false)"><i class="glyphicon glyphicon-calendar"></i></button>
                </span>
            </p>
        </div>
        <div class="col-sm-4 col-xs-6 form-group">
            <label for="project.endDate">${message(code:'is.release.endDate')}</label>
            <p class="input-group">
                <input required
                       type="text"
                       class="form-control"
                       name="project.endDate"
                       ng-model="project.endDate"
                       datepicker-popup="{{endDate.format}}"
                       datepicker-options="endDate"
                       is-open="endDate.opened"
                       close-text="Close"
                       show-button-bar="false"
                       min-date="projectMinDate"
                       ng-class="{current:step.selected}"
                       ng-required="isCurrentStep(1)"/>
                <span class="input-group-btn">
                    <button type="button" class="btn btn-default" ng-click="openDatepicker($event, true)"><i class="glyphicon glyphicon-calendar"></i></button>
                </span>
            </p>
        </div>
        <div class="col-sm-4 col-xs-12 form-group">
            <label for="project.preferences.timezone">${message(code:'is.product.preferences.timezone')}</label>
            <is:localeTimeZone required="required"
                               class="form-control"
                               ng-required="isCurrentStep(1)"
                               name="project.preferences.timezone"
                               ng-model="project.preferences.timezone"
                               ui-select2=""></is:localeTimeZone>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 form-group">
            <label for="description">${message(code:'is.product.description')}</label>
            <textarea is-markitup
                      name="project.description"
                      class="form-control"
                      placeholder="${message(code: 'todo.is.ui.product.description.placeholder')}"
                      ng-model="project.description"
                      ng-show="showDescriptionTextarea"
                      ng-blur="showDescriptionTextarea = false"
                      is-model-html="project.description_html"></textarea>
            <div class="markitup-preview"
                 tabindex="0"
                 ng-show="!showDescriptionTextarea"
                 ng-click="showDescriptionTextarea = true"
                 ng-focus="showDescriptionTextarea = true"
                 ng-class="{'placeholder': !project.description_html}"
                 ng-bind-html="(project.description_html ? project.description_html : '<p>${message(code: 'todo.is.ui.product.description.placeholder')}</p>') | sanitize"></div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-4">
            <label for="productOwners.search">${message(code:'todo.is.ui.select.productowner')}</label>
            <p class="input-group typeahead">
                <input autocomplete="off"
                       type="text"
                       name="productOwner.search"
                       id="productOwner.search"
                       autofocus="autofocus"
                       class="form-control"
                       ng-model="po.name"
                       typeahead="po as po.name for po in searchUsers($viewValue)"
                       typeahead-loading="searchingPo"
                       typeahead-wait-ms="250"
                       typeahead-on-select="addUser($item, 'po')"
                       typeahead-template-url="select.member.html">
                <span class="input-group-addon">
                    <i class="fa" ng-click="unSelectTeam()" ng-class="{ 'fa-search': !searchingPo, 'fa-refresh':searchingPo, 'fa-close':po.name }"></i>
                </span>
            </p>
        </div>
        <div class="col-sm-8">
            <div ng-class="{'list-users':project.productowners.length > 0}">
                <ng-include ng-init="role = 'po';" ng-repeat="user in project.productowners" src="'user.item.html'"></ng-include>
            </div>
        </div>
    </div>
    <div class="row" ng-show="project.preferences.hidden">
        <div class="col-sm-4">
            <label for="stakeHolders.search">${message(code:'todo.is.ui.select.stakeholder')}</label>
            <p class="input-group typeahead">
                <input autocomplete="off"
                       type="text"
                       name="stakeHolder.search"
                       id="stakeHolder.search"
                       autofocus="autofocus"
                       class="form-control"
                       ng-model="sh.name"
                       typeahead="sh as sh.name for sh in searchUsers($viewValue)"
                       typeahead-loading="searchingSh"
                       typeahead-wait-ms="250"
                       typeahead-on-select="addUser($item, 'sh')"
                       typeahead-template-url="select.member.html">
                <span class="input-group-addon">
                    <i class="fa" ng-click="unSelectTeam()" ng-class="{ 'fa-search': !searchingSh, 'fa-refresh':searchingSh, 'fa-close':sh.name }"></i>
                </span>
            </p>
        </div>
        <div class="col-sm-8">
            <div ng-class="{'list-users':project.stakeholders.length > 0}">
                <ng-include ng-init="role = 'sh';" ng-repeat="user in project.stakeholders" src="'user.item.html'"></ng-include>
            </div>
        </div>
    </div>
</script>