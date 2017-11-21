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
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, release)"
     flow-drop-enabled="authorizedRelease('upload', release)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedRelease('upload', release) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-calendar"></i>
                <span class="item-name" title="{{ release.name }}">{{ release.name }}</span>
                <entry:point id="release-details-left-title"/>
            </div>
            <div class="right-title">
                <div style="margin-bottom:10px">
                    <entry:point id="release-details-right-title"/>
                    <div class="btn-group">
                        <a ng-if="previousRelease"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           ui-sref=".({releaseId: previousRelease.id})"><i class="fa fa-caret-left" title="${message(code: 'is.ui.backlogelement.toolbar.previous')}"></i></a>
                        <a ng-if="nextRelease"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           ui-sref=".({releaseId: nextRelease.id})"><i class="fa fa-caret-right" title="${message(code: 'is.ui.backlogelement.toolbar.next')}"></i></a>
                    </div>
                    <details-layout-buttons ng-if="!isModal"/>
                </div>
                <g:set var="formats" value="${is.exportFormats(entryPoint: 'releaseDetails')}"/>
                <g:if test="${formats}">
                    <div class="btn-group hidden-xs" uib-dropdown>
                        <button class="btn btn-default"
                                uib-tooltip="${message(code: 'todo.is.ui.export')}"
                                uib-dropdown-toggle type="button">
                            <i class="fa fa-download"></i>&nbsp;<i class="fa fa-caret-down"></i>
                        </button>
                        <ul uib-dropdown-menu
                            class="pull-right"
                            role="menu">
                            <g:each in="${formats}" var="format">
                                <li role="menuitem">
                                    <a href="${format.resource ?: 'story'}/release/{{ ::release.id }}/${format.action ?: 'print'}/${format.params.format}"
                                       ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                                </li>
                            </g:each>
                        </ul>
                    </div>
                </g:if>
                <div class="btn-group shortcut-menu" role="group">
                    <shortcut-menu ng-model="release" model-menus="menus" view-type="'details'"></shortcut-menu>
                    <div ng-class="['btn-group dropdown', {'dropup': application.minimizedDetailsView}]" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i ng-class="['fa', application.minimizedDetailsView ? 'fa-caret-up' : 'fa-caret-down']"></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'release'" template-url="item.menu.html"></ul>
                    </div>
                </div>
            </div>
        </h3>
        <visual-states ng-model="release" model-states="releaseStatesByName"/>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified" ng-if="$state.current.data.displayTabs">
        <li role="presentation" ng-class="{'active':!$state.params.releaseTabId}">
            <a href="{{ tabUrl() }}">
                <i class="fa fa-lg fa-edit"></i> ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.releaseTabId == 'notes'}">
            <a href="{{ tabUrl('notes') }}">
                <i class="fa fa-lg fa-newspaper-o"></i> ${message(code: 'todo.is.ui.release.notes')}
            </a>
        </li>
        <entry:point id="release-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="release/templates/_release.properties.gsp"/>
    </div>
</div>
</script>
