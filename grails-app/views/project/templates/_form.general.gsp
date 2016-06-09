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
<script type="text/ng-template" id="form.general.project.html">
    <h4>${message(code:"is.dialog.wizard.section.project")}</h4>
    <p class="help-block">${message(code:'is.dialog.wizard.section.project.description')}</p>
    <div class="row">
        <div class="col-sm-7 col-xs-7 form-group">
            <label for="name">${message(code:'is.product.name')}</label>
            <div class="input-group">
                <input autofocus
                       name="name"
                       type="text"
                       class="form-control"
                       placeholder="${message(code: 'todo.is.ui.project.noname')}"
                       ng-model="project.name"
                       ng-change="nameChanged()"
                       ng-required="isCurrentStep(1)"
                       ng-remote-validate="{{ checkProjectPropertyUrl }}/name">
                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)}">
                    <span class="input-group-btn">
                        <a class="btn btn-model"
                           uib-tooltip="{{project.preferences.hidden ? '${message(code: /is.product.preferences.project.hidden/)}' : '${message(code: /todo.is.ui.product.preferences.project.public/)}' }}"
                           ng-model="project.preferences.hidden"
                           ng-click="project.preferences.hidden = !project.preferences.hidden;"
                           ng-class="{ 'btn-danger': project.preferences.hidden, 'btn-success': !project.preferences.hidden }">
                            <i class="fa fa-lock" ng-class="{ 'fa-lock': project.preferences.hidden, 'fa-unlock': !project.preferences.hidden }"></i>
                        </a>
                    </span>
                </g:if>
            </div>
        </div>
        <div class="col-sm-5 col-xs-5 form-group">
            <label for="pkey">${message(code:'is.product.pkey')}</label>
            <input name="pkey"
                   type="text"
                   capitalize
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.project.nokey')}"
                   ng-model="project.pkey"
                   ng-pattern="/^[A-Z0-9]*$/"
                   ng-required="isCurrentStep(1)"
                   ng-remote-validate="{{ checkProjectPropertyUrl }}/pkey">
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 form-group">
            <label for="description">${message(code:'is.product.description')}</label>
            <textarea is-markitup
                      name="project.description"
                      class="form-control"
                      placeholder="${message(code: 'todo.is.ui.project.description.placeholder')}"
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
                 ng-bind-html="(project.description_html ? project.description_html : '<p>${message(code: 'todo.is.ui.project.description.placeholder')}</p>') | sanitize"></div>
        </div>
    </div>
</script>