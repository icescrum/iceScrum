<%@ page import="org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="actor.details.html">
<div class="panel panel-default"
     ng-if="actor"
     flow-drop
     flow-files-submitted="attachmentQuery($flow, actor)"
     flow-drop-enabled="authorizedActor('upload', actor)"
     flow-drag-enter="class='panel panel-default drop-enabled'"
     flow-drag-leave="class='panel panel-default'"
     flow-init
     ng-class="authorizedActor('upload', actor) && class">
    <div class="panel-heading"
         fixed="#main-content .details:first">
        <h3 class="panel-title row">
            <div class="the-title">
                <span>{{ actor.name }}</span>
            </div>
            <div class="the-id">
                <div class="pull-right">
                    <button class="btn btn-xs btn-default"
                            disabled="disabled">{{ actor.uid }}</button>
                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#actor/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#actor/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 tooltip="${message(code: 'todo.is.ui.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
                <ul class="dropdown-menu"
                    ng-include="'actor.menu.html'"></ul>
            </div>
           <div class="btn-group pull-right">
                <button name="attachments" class="btn btn-default"
                        ng-click="setTabSelected('attachments')"
                        tooltip="{{ actor.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="actor.attachments.length">{{ actor.attachments.length }}</span>
                </button>
                <a class="btn btn-default"
                   href="#actor/{{ actor.id }}/stories"
                   tooltip="{{ actor.stories_ids.length }} ${message(code:'todo.is.actor.stories')}"
                   tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="actor.stories_ids.length">{{ actor.stories_ids.length }}</span>
                </a>
            </div>
        </div>
    </div>

    <div class="panel-body">
        <form ng-submit="update(editableActor)"
              name='formHolder.actorForm'
              class="form-editable"
              ng-mouseleave="formHover(false)"
              ng-mouseover="formHover(true)"
              ng-class="{'form-editing': getShowActorForm(actor)}"
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="name">${message(code:'is.actor.name')}</label>
                    <input required
                           ng-focus="editForm(true)"
                           ng-disabled="!getShowActorForm(actor)"
                           ng-maxlength="100"
                           name="name"
                           ng-model="editableActor.name"
                           type="text"
                           class="form-control">
                </div>
                <div class="form-half">
                    <label for="instances">${message(code:'is.actor.instances')}</label>
                    <select class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!getShowActorForm(actor)"
                            name="instances"
                            ng-model="editableActor.instances"
                            ui-select2>
                        <is:options values="${BundleUtils.actorInstances}" />
                </select>
                </div>
            </div>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="expertnessLevel">${message(code:'is.actor.it.level')}</label>
                    <select class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!getShowActorForm(actor)"
                            name="expertnessLevel"
                            ng-model="editableActor.expertnessLevel"
                            ui-select2>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.actorLevels)}" />
                    </select>
                </div>
                <div class="form-half">
                    <label for="useFrequency">${message(code:'is.actor.use.frequency')}</label>
                    <select class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!getShowActorForm(actor)"
                            name="useFrequency"
                            ng-model="editableActor.useFrequency"
                            ui-select2>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.actorFrequencies)}" />
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          ng-maxlength="3000"
                          ng-focus="editForm(true)"
                          ng-disabled="!getShowActorForm(actor)"
                          placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                          name="description"
                          ng-model="editableActor.description"></textarea>
            </div>
            <div class="form-group">
                <label for="tags">${message(code:'is.backlogelement.tags')}</label>
                <input type="hidden"
                       ng-focus="editForm(true)"
                       ng-disabled="!getShowActorForm(actor)"
                       class="form-control"
                       value="{{ editableActor.tags.join(',') }}"
                       name="tags"
                       ng-model="editableActor.tags"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
            </div>
            <div class="form-group">
                <label for="notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea is-markitup
                          class="form-control"
                          ng-maxlength="5000"
                          name="notes"
                          ng-model="editableActor.notes"
                          is-model-html="editableActor.notes_html"
                          ng-show="showNotesTextarea"
                          ng-blur="showNotesTextarea = false"
                          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="!getShowActorForm(actor)"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = getShowActorForm(actor)"
                     ng-focus="editForm(true); showNotesTextarea = getShowActorForm(actor)"
                     ng-class="{'placeholder': !editableActor.notes_html}"
                     tabindex="0"
                     ng-bind-html="(editableActor.notes_html ? editableActor.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
            </div>
            <div class="btn-toolbar" ng-if="getShowActorForm(editableActor) && getEditableMode()">
                <button class="btn btn-primary pull-right"
                        ng-disabled="!isDirty() || formHolder.actorForm.$invalid"
                        tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.update')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="editForm(false)">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <div class="form-group">
                <label>${message(code:'is.backlogelement.attachment')}</label>
                <div ng-if="authorizedActor('upload', actor)">
                    <button type="button" flow-btn class="btn btn-default"><i class="fa fa-upload"></i> todo.is.ui.new.upload</button>
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
