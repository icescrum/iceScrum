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
- Colin Bontemps (cbontemps@kagilum.com)
--}%
<script type="text/ng-template" id="sprint.details.html">
<div class="card"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, sprint)"
     flow-drop-enabled="authorizedSprint('upload', sprint)"
     flow-drag-enter="dropClass='card drop-enabled'"
     flow-drag-leave="dropClass='card'"
     ng-class="authorizedSprint('upload', sprint) && dropClass">
    <div class="details-header">
        <a ng-if="previousSprint"
           class="btn btn-icon"
           role="button"
           tabindex="0"
           hotkey="{'left': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
           ui-sref=".({sprintId: previousSprint.id})">
            <span class="icon icon-caret-left"></span>
        </a>
        <a class="btn btn-icon"
           ng-class="nextSprint ? 'visible' : 'invisible'"
           role="button"
           tabindex="0"
           hotkey="{'right': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
           ui-sref=".({sprintId: nextSprint.id})">
            <span class="icon icon-caret-right"></span>
        </a>
        <details-layout-buttons ng-if="!isModal" remove-ancestor="removeSprintAncestorOnClose"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-name" title="{{ release.name + ' - ' + (sprint | sprintName) }}">{{ release.name + ' - ' + (sprint | sprintName) }}</span>
            </div>
            <div class="btn-toolbar">
                <g:set var="formats" value="${is.exportFormats(windowDefinition: 'taskBoard', entryPoint: 'sprintDetails')}"/>
                <g:if test="${formats}">
                    <div class="btn-group" uib-dropdown ng-if="authenticated()">
                        <button class="btn btn-secondary btn-sm"
                                uib-dropdown-toggle type="button">
                            <span defer-tooltip="${message(code: 'todo.is.ui.export')}"><i class="fa fa-download"></i></span>
                        </button>
                        <div uib-dropdown-menu
                             class="dropdown-menu-right"
                             role="menu">
                            <g:each in="${formats}" var="format">
                                <a role="menuitem"
                                   class="dropdown-item"
                                   href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/sprint/{{ ::sprint.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                   ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                            </g:each>
                        </div>
                    </div>
                </g:if>
                <div class="btn-menu" uib-dropdown>
                    <shortcut-menu ng-model="sprint" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                    <div uib-dropdown-toggle></div>
                    <div uib-dropdown-menu ng-init="itemType = 'sprint'" template-url="item.menu.html"></div>
                </div>
            </div>
        </div>
        <visual-states ng-model="sprint" model-states="sprintStatesByName"/>
    </div>
    <ul class="nav nav-tabs nav-justified disable-active-link" ng-if="$state.current.data.displayTabs">
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl() }}"
               ng-class="{'active':!$state.params.sprintTabId}"
               class="nav-link">
                ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation"
            ng-if="authorizedTimeboxNotes()"
            class="nav-item">
            <a href="{{ tabUrl('notes') }}"
               ng-class="{'active':$state.params.sprintTabId == 'notes'}"
               class="nav-link">
                ${message(code: 'todo.is.ui.sprint.notes')}
            </a>
        </li>
        <entry:point id="sprint-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="sprint/templates/_sprint.properties.gsp"/>
    </div>
</div>
</script>
