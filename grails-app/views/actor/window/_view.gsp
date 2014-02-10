%{--
- Copyright (c) 2014 Kagilum SAS.
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

<div id="backlog-layout-window-${controllerName}"
     data-ui-selectable
     data-ui-selectable-global-stop="true"
     data-ui-selectable-stop="$.icescrum.actor.onSelectableStop"
     data-ui-selectable-filter="div.postit-actor"
     data-ui-selectable-cancel=".postit-label, a"
     data-is-shortcut
     data-is-shortcut-on="#backlog-layout-window-${controllerName}"
     data-is-shortcut-key="a arrows"
     data-is-shortcut-callback="$.icescrum.selectableShortcut"
     data-binding
     data-binding-after-binding="$.icescrum.selectableHash"
     data-binding-type="actor"
     data-binding-selector="div.postit-actor"
     data-binding-tpl="tpl-postit-actor"
     data-binding-watch="items"
     data-binding-highlight="true"
     data-binding-sort-on="type"
     data-binding-reverse="true"
     data-binding-config="actors"
     class="view-postit backlog">
    <div class="add-new-postit">
        <span>+</span>
    </div>
</div>