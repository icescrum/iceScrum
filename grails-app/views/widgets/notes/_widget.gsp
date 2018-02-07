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
<is:widget widgetDefinition="${widgetDefinition}">
    <div class="form-group" ng-if="authorizedWidget('update', widget)">
        <textarea at
                  id="note-size" is-markitup
                  class="form-control"
                  name="notes"
                  ng-model="widget.settings.text"
                  is-model-html="widget.settings.text_html"
                  ng-show="showNotesTextarea"
                  ng-blur="showNotesTextarea = false; update(widget)"
                  placeholder="${message(code: 'is.ui.widget.notes.placeholder')}"></textarea>
        <div class="markitup-preview"
             ng-show="!showNotesTextarea"
             ng-click="showNotesTextarea = true"
             ng-class="{'placeholder': !widget.settings.text_html}"
             tabindex="0"
             ng-bind-html="widget.settings.text_html ? widget.settings.text_html : '<p>${message(code: 'is.ui.widget.notes.placeholder')}</p>'"></div>
    </div>
    <div class="form-control-static" ng-if="!authorizedWidget('update', widget)" ng-bind-html="widget.settings.text_html">
</is:widget>