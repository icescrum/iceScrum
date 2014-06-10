<%@ page import="org.icescrum.core.domain.PlanningPokerGame; org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="feature.details.html">
<div class="panel panel-default">
    <div id="feature-header"
         class="panel-heading"
         ng-controller="featureHeaderCtrl"
         fixed="#right"
         fixed-offset-top="1"
         fixed-offset-width="-2">
        <h3 class="panel-title row">
            <div class="col-sm-8">
                <span>{{ selected.name }}</span>
            </div>
            <div class="col-sm-4">
                <div class="pull-right">
                    <span class="label label-default"
                          tooltip="${message(code: 'is.backlogelement.id')}">{{ selected.uid }}</span>
                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#feature/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#feature/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 tooltip="${message(code: 'todo.is.feature.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
            </div>
            <div class="btn-group pull-right">
                <button name="attachments" class="btn btn-default"
                        ng-click="setTabSelected('attachments')"
                        tooltip="{{ selected.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="selected.attachments_count">{{ selected.attachments_count }}</span>
                </button>
                <button name="stories" class="btn btn-default"
                        ng-click="setTabSelected('stories')"
                        tooltip="{{ selected.stories_count }} ${message(code:'todo.is.feature.stories')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="selected.stories_count">{{ selected.stories_count }}</span>
                </button>
            </div>
        </div>
    </div>

    <div id="right-feature-container"
         class="right-properties new panel-body">
        <form ng-submit="update(feature)" name='featureForm' show-validation ng-controller="featureEditCtrl">
            <div class="form-group">
                <label for="feature.name">${message(code:'is.feature.name')}</label>
                <div class="input-group">
                    <input required
                           name="feature.name"
                           ng-model="feature.name"
                           ng-readonly="readOnly()"
                           type="text"
                           class="form-control">
                    <span class="input-group-btn">
                        <button type="button"
                                tabindex="-1"
                                popover-title="${message(code:'is.permalink')}"
                                popover="** $.icescrum.o.grailsServer **/** $.icescrum.product.pkey **-** feature.uid **"
                                popover-append-to-body="true"
                                popover-placement="left"
                                class="btn btn-default">
                            <i class="fa fa-link"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="clearfix no-padding">
                <div class="col-md-6 form-group">
                    <label for="feature.type">${message(code:'is.feature.type')}</label>
                    <div class="input-group">
                        <select style="width:100%"
                            class="form-control"
                            ng-model="feature.type"
                            ng-readonly="readOnly()"
                            ui-select2>
                            <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
                        </select>
                        <span class="input-group-btn">
                            <button colorpicker
                                    class="btn {{ feature.color | contrastColor }}"
                                    type="button"
                                    style="background-color:{{ feature.color }};"
                                    colorpicker-position="top"
                                    value="#bf3d3d"
                                    ng-model="feature.color"><i class="fa fa-pencil"></i></button>
                        </span>
                    </div>
                </div>
                <div class="col-md-6 form-group">
                    <label for="feature.value">${message(code:'is.feature.value')}</label>
                    <select style="width:100%"
                            class="form-control"
                            ng-model="feature.value"
                            ng-readonly="readOnly()"
                            ui-select2>
                        <is:options values="${PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)}" />
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="feature.description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                          ng-model="feature.description"
                          ng-readonly="readOnly()"/></textarea>
            </div>
            <div class="form-group">
                <input type="hidden"
                       style="width:100%"
                       class="form-control"
                       value="{{ feature.tags.join(',') }}"
                       ng-model="feature.tags"
                       ng-readonly="readOnly()"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
            </div>
            <div class="form-group">
                <label for="feature.notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea is-markitup
                          class="form-control"
                          ng-model="feature.notes"
                          is-model-html="feature.notes_html"
                          ng-show="showNotesTextarea"
                          ng-blur="showNotesTextarea = false"
                          ng-readonly="readOnly()"
                          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                <div class="markitup-preview"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = true"
                     ng-focus="showNotesTextarea = true"
                     ng-class="{'placeholder': !feature.notes_html}"
                     tabindex="0"
                     ng-bind-html="(feature.notes_html ? feature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
            </div>
        </form>
        <tabset type="{{ tabsType }}">
            <tab select="$state.params.tabId ? setTabSelected('attachments') : ''"
                 heading="${message(code: 'is.ui.backlogelement.attachment')}"
                 active="tabSelected.attachments">
            </tab>
            <tab select="stories(selected); setTabSelected('stories');"
                 heading="${message(code: 'todo.is.feature.stories')}"
                 active="tabSelected.stories">
                <table class="table table-striped">
                    <tbody ng-include src="'nested.stories.html'"></tbody>
                </table>
            </tab>
        </tabset>
    </div>
</div>
</script>
