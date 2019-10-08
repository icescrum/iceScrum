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
<script type="text/ng-template" id="release.details.html">
<div class="card"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, release)"
     flow-drop-enabled="authorizedRelease('upload', release)"
     flow-drag-enter="dropClass='card drop-enabled'"
     flow-drag-leave="dropClass='card'"
     ng-class="authorizedRelease('upload', release) && dropClass">
    <div class="details-header">
        <a ng-if="previousRelease"
           class="btn btn-icon"
           role="button"
           tabindex="0"
           hotkey="{'left': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
           ui-sref=".({releaseId: previousRelease.id})">
            <span class="icon icon-caret-left"></span>
        </a>
        <a class="btn btn-icon"
           ng-class="nextRelease ? 'visible' : 'invisible'"
           role="button"
           tabindex="0"
           hotkey="{'right': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
           ui-sref=".({releaseId: nextRelease.id})">
            <span class="icon icon-caret-right"></span>
        </a>
        <details-layout-buttons remove-ancestor="removeReleaseAncestorOnClose"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-name" title="{{ release.name }}">{{ release.name }}</span>
            </div>
            <div class="btn-toolbar">
                <g:set var="formats" value="${is.exportFormats(entryPoint: 'releaseDetails')}"/>
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
                                   href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/release/{{ ::release.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                   ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                            </g:each>
                        </div>
                    </div>
                </g:if>
                <div class="btn-menu" uib-dropdown>
                    <shortcut-menu ng-model="release" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                    <div uib-dropdown-toggle></div>
                    <div uib-dropdown-menu ng-init="itemType = 'release'" template-url="item.menu.html"></div>
                </div>
            </div>
        </div>
        <visual-states ng-model="release" model-states="releaseStatesByName"/>
    </div>
    <ul class="nav nav-tabs nav-justified disable-active-link" ng-if="$state.current.data.displayTabs">
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl() }}"
               class="nav-link"
               ng-class="{'active':!$state.params.releaseTabId}">
                ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation"
            ng-if="authorizedTimeboxNotes()"
            class="nav-item">
            <a href="{{ tabUrl('notes') }}"
               class="nav-link"
               ng-class="{'active':$state.params.releaseTabId == 'notes'}">
                ${message(code: 'todo.is.ui.release.notes')}
            </a>
        </li>
        <entry:point id="release-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="release/templates/_release.properties.gsp"/>
    </div>
</div>
</script>
