%{--
- Copyright (c) 2018 Kagilum.
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

<script type="text/ng-template" id="feature.storyForm.editor.html">
<form ng-submit="save(editableStory, selected)"
      name="formHolder.storyForm"
      ng-class="['form-editable form-editing', formHolder.formExpanded ? 'form-expanded' : 'form-not-expanded']"
      novalidate>
    <div class="clearfix no-padding">
        <div class="form-group" ng-class="formHolder.formExpanded ? 'col-sm-8' : 'col-sm-12'">
            <div class="input-group">
                <span class="input-group-addon no-style"><strong>42</strong></span>
                <input required
                       type="text"
                       ng-maxlength="100"
                       name="name"
                       ng-model="editableStory.name"
                       ng-focus="formHolder.formExpanded = true;"
                       class="form-control"
                       placeholder="${message(code: 'is.ui.story.noname')}">
                <span class="input-group-btn visible-hidden">
                    <button class="btn btn-primary" type="button" ng-click="formHolder.formExpanded = true;"><i class="fa fa-plus"></i></button>
                </span>
            </div>
        </div>
    </div>
    <div class="form-group hidden-not-expanded">
        <textarea class="form-control"
                  ng-maxlength="3000"
                  name="description"
                  ng-model="editableStory.description"
                  ng-show="showDescriptionTextarea"
                  ng-blur="blurDescription()"
                  at="atOptions"
                  autofocus
                  placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
        <div class="atwho-preview form-control-static important"
             ng-show="!showDescriptionTextarea"
             ng-click="clickDescriptionPreview()"
             ng-focus="focusDescriptionPreview($event)"
             ng-mousedown="$parent.descriptionPreviewMouseDown = true"
             ng-mouseup="$parent.descriptionPreviewMouseDown = false"
             ng-class="{'placeholder': !editableStory.description}"
             tabindex="0"
             ng-bind-html="editableStory.description ? (editableStory.description | lineReturns | actorTag: actors) : '${message(code: 'is.ui.backlogelement.nodescription')}'"></div>
    </div>
    <div class="btn-toolbar">
        <button class="btn btn-primary pull-right"
                ng-disabled="!formHolder.storyForm.$dirty || formHolder.storyForm.$invalid || application.submitting"
                type="submit">
            ${message(code: 'default.button.create.label')}
        </button>
        <button class="btn btn-secondary pull-right"
                ng-click="formHolder.formExpanded = false;"
                type="button">
            ${message(code: 'is.button.cancel')}
        </button>
    </div>
</form>
</script>
