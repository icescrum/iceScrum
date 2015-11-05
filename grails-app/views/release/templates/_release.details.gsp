%{--
- Copyright (c) 2015 Kagilum.
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
<script type="text/ng-template" id="release.details.html">
<div class="panel panel-default"
     ng-if="release"
     flow-drop
     flow-files-submitted="attachmentQuery($flow, release)"
     flow-drop-enabled="authorizedRelease('upload', release)"
     flow-drag-enter="class='panel panel-default drop-enabled'"
     flow-drag-leave="class='panel panel-default'"
     flow-init
     ng-class="authorizedRelease('upload', release) && class">
    <div id="release-header"
         class="panel-heading"
         fixed="#main-content .details:first" fixed-offset-width="10">
        <h3 class="panel-title row">
            <div class="the-title">
                <span>{{ release.name }}</span>
            </div>
            <div class="the-id">
                <div class="pull-right">
                    <button class="btn btn-xs btn-default"
                            disabled="disabled">{{ release.id }}</button>
                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#releasePlan/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#releasePlan/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="actions-left">
                <div class="btn-group"
                     uib-dropdown
                     uib-tooltip="${message(code: 'todo.is.ui.actions')}"
                     tooltip-append-to-body="true">
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <span class="fa fa-cog"></span> <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" ng-include="'release.menu.html'"></ul>
                </div>
            </div>
        </div>
    </div>
    <div id="right-release-container"
         class="panel-body">
        <form ng-submit="update(editableRelease)"
              name='formHolder.releaseForm'
              class="form-editable"
              ng-mouseleave="formHover(false)"
              ng-mouseover="formHover(true)"
              ng-class="{'form-editing': getShowReleaseForm(release)}"
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-group">
                    <label for="name">${message(code:'is.release.name')}</label>
                    <input required
                           name="name"
                           ng-focus="editForm(true)"
                           ng-model="editableRelease.name"
                           type="text"
                           class="form-control"
                           placeholder="${message(code: 'is.ui.release.noname')}"/>
                </div>
                <div class="form-half">
                    <label for="release.startDate">${message(code:'is.release.startDate')}</label>
                    <div ng-class="{'input-group': authorizedRelease('update', release)}">
                        <span class="input-group-btn"
                              ng-if="authorizedRelease('update', release)">
                            <button type="button"
                                    class="btn btn-default"
                                    ng-focus="editForm(true)"
                                    ng-click="openDatepicker($event, startDateOptions)">
                                <i class="fa fa-calendar"></i>
                            </button>
                        </span>
                        <input type="text"
                               class="form-control"
                               required
                               ng-focus="editForm(true)"
                               name="release.startDate"
                               ng-model="editableRelease.startDate"
                               uib-datepicker-popup
                               min-date="minStartDate"
                               max-date="maxStartDate"
                               is-open="startDateOptions.opened"/>
                    </div>
                </div>
                <div class="form-half">
                    <label for="release.endDate" class="text-right">${message(code:'is.release.endDate')}</label>
                    <div ng-class="{'input-group': authorizedRelease('update', release)}">
                        <input type="text"
                               class="form-control text-right"
                               required
                               ng-focus="editForm(true)"
                               name="release.endDate"
                               ng-model="editableRelease.endDate"
                               uib-datepicker-popup
                               min-date="minEndDate"
                               is-open="endDateOptions.opened"/>
                        <span class="input-group-btn"
                              ng-if="authorizedRelease('update', release)">
                            <button type="button"
                                    class="btn btn-default"
                                    ng-focus="editForm(true)"
                                    ng-click="openDatepicker($event, endDateOptions)">
                                <i class="fa fa-calendar"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label for="vision">${message(code:'is.ui.releasePlan.toolbar.vision')}</label>
                <textarea is-markitup
                          ng-maxlength="5000"
                          class="form-control"
                          name="vision"
                          ng-model="editableRelease.vision"
                          is-model-html="editableRelease.vision_html"
                          ng-show="showVisionTextarea"
                          ng-blur="showVisionTextarea = false"
                          placeholder="${message(code: 'todo.is.ui.release.novision')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="!getShowReleaseForm(release)"
                     ng-show="!showVisionTextarea"
                     ng-click="showVisionTextarea = getShowReleaseForm(release)"
                     ng-focus="editForm(true); showVisionTextarea = getShowReleaseForm(release)"
                     ng-class="{'placeholder': !editableRelease.vision_html}"
                     tabindex="0"
                     ng-bind-html="(editableRelease.vision_html ? editableRelease.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>') | sanitize"></div>
            </div>
            <div class="btn-toolbar" ng-if="getShowReleaseForm(release) && getEditableMode()">
                <button class="btn btn-primary pull-right"
                        ng-disabled="!isDirty() || formHolder.releaseForm.$invalid"
                        uib-tooltip="${message(code:'default.button.update.label')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'default.button.update.label')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        uib-tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="editForm(false)">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <div class="form-group">
                <label>${message(code:'is.backlogelement.attachment')} {{ release.attachments.length > 0 ? '(' + release.attachments.length + ')' : '' }}</label>
                <div ng-if="authorizedRelease('upload', release)">
                    <button type="button" flow-btn class="btn btn-default"><i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}</button>
                </div>
                <div class="form-control-static">
                    <div class="drop-zone">
                        <h2>${message(code:'todo.is.ui.drop.here')}</h2>
                    </div>
                    <table class="table table-striped attachments" ng-controller="attachmentCtrl">
                        <tbody ng-include="'attachment.list.html'"></tbody>
                    </table>
                </div>
            </div>
        </form>
    </div>
</div>
</script>