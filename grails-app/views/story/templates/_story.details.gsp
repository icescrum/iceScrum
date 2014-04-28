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
--}%
<script type="text/ng-template" id="story.details.html">
<div class="panel panel-default">
    <div id="story-header"
         class="panel-heading"
         ng-controller="storyHeaderCtrl"
         is-fixed="#right"
         is-fixed-offset-top="1"
         is-fixed-offset-width="-2">
        <h3 class="panel-title">
            <a href
               tooltip="{{ selected.follow.followers }}"
               tooltip-append-to-body="true"
               ng-click="follow(selected)"
               ng-switch on="selected.follow.status"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star"
                                                                                                 ng-switch-when="true"></i></a>
            <span>{{ selected.name }}</span><small ng-show="selected.origin">${message(code: 'is.story.origin')}: {{ selected.origin }}</small>

            <div class="pull-right">
                <span tooltip="${message(code: 'is.story.creator')} : {{ selected.creator | userFullName }}">
                    <img ng-src="{{ selected.creator | userAvatar }}" alt="{{ selected.creator | userFullName }}"
                         height="21px"/>
                </span>
                <span class="label label-default"
                      tooltip="${message(code: 'is.backlogelement.id')}">{{ selected.uid }}</span>

                <a ng-if="previous"
                   class="btn btn-xs btn-default"
                   role="button"
                   tabindex="0"
                   href="#sandbox/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                <a ng-if="next"
                   class="btn btn-xs btn-default"
                   role="button"
                   tabindex="0"
                   href="#sandbox/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 tooltip="${message(code: 'todo.is.story.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
            </div>
            <div class="btn-group pull-right">
                <a class="btn btn-default"
                   ng-click="like(selected)"
                   ng-switch on="selected.like.status"
                   role="button"
                   tabindex="0"
                   tooltip="{{ selected.like.likers }}"
                   tooltip-append-to-body="true">
                    <i class="fa fa-thumbs-o-up" ng-switch-default></i>
                    <i class="fa fa-thumbs-up" ng-switch-when="true"></i>
                    <span class="badge"ng-show="selected.like.likers">{{ selected.like.likers }}</span>
                </a>
                <button name="activities" class="btn btn-default"
                        ng-click="setTabActive('activities')"
                        tooltip="${message(code:'todo.is.story.lastActivity')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-clock-o"></span>
                </button>
                <button name="attachments" class="btn btn-default"
                        ng-click="setTabActive('attachments')"
                        tooltip="{{ selected.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="selected.attachments_count">{{ selected.attachments_count }}</span>
                </button>
                <button name="comments" class="btn btn-default"
                        ng-click="setTabActive('comments')"
                        tooltip="{{ selected.comments.length }} ${message(code:'todo.is.story.comments')}"
                        tooltip-append-to-body="true"
                        ng-switch on="{{ selected.comments_count }}">
                    <span class="fa fa-comment-o" ng-switch-default></span>
                    <span class="fa fa-comment" ng-switch-when="true"></span>
                    <span class="badge" ng-show="selected.comments_count">{{ selected.comments_count }}</span>
                </button>
                <button name="tasks" class="btn btn-default"
                        ng-click="setTabActive('tasks')"
                        tooltip="{{ selected.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="selected.tasks_count">{{ selected.tasks_count }}</span>
                </button>
                <button name="tests" class="btn btn-default"
                        ng-click="setTabActive('tests')"
                        tooltip="{{ selected.tests.length }} ${message(code:'todo.is.acceptanceTests')}"
                        tooltip-append-to-body="true"
                        tooltip-placement="left"
                        ng-switch on="{{ selected.tests.length > 0 }}">
                    <span class="fa fa-check-square-o" ng-switch-default></span>
                    <span class="fa fa-check-square" ng-switch-when="true"></span>
                    <span class="badge" ng-if="selected.tests.length > 0">{{ selected.tests.length }}</span>
                </button>
            </div>
        </div>
        <div class="progress">
            <div ng-repeat="progressState in progressStates"
                 class="progress-bar progress-bar-{{ progressState.code }}"
                 tooltip-placement="left"
                 tooltip-append-to-body="true"
                 tooltip="{{ progressState.name }}" style="width:{{ progressState.width }}%">
                {{ progressState.days }}
            </div>
        </div>
    </div>

    <div id="right-story-container"
         class="right-properties new panel-body">
        <form ng-submit="update(story)" name='storyForm' show-validation ng-controller="storyEditCtrl">
            <div class="clearfix no-padding">
                <div class="col-md-6 form-group">
                    <label for="story.name">${message(code:'is.story.name')}</label>
                    <div class="input-group">
                        <input required
                               name="story.name"
                               ng-model="story.name"
                               type="text"
                               class="form-control">
                        <span class="input-group-btn">
                            <button type="button"
                                    tabindex="-1"
                                    popover-title="${message(code:'is.permalink')}"
                                    popover="** $.icescrum.o.grailsServer **/** $.icescrum.product.pkey **-** story.uid **"
                                    popover-append-to-body="true"
                                    popover-placement="left"
                                    class="btn btn-default">
                                <i class="fa fa-link"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-md-6 form-group">
                    <label for="story.feature.id">${message(code:'is.feature')}</label>
                    <div ng-class="{'input-group':story.feature.id, 'select2-border':story.feature.id}">
                    <input type="hidden"
                           style="width:100%;"
                           class="form-control"
                           value="{{ story.feature.id ? story.feature : '' }}"
                           ng-model="story.feature"
                           ui-select2="selectFeatureOptions"
                           data-placeholder="${message(code: 'is.ui.story.nofeature')}"/>
                        <span class="input-group-btn" ng-show="story.feature.id">
                            <a href="#feature/{{ story.feature.id }}"
                               title="{{ story.feature.name }}"
                               class="btn btn-default">
                                <i class="fa fa-external-link"></i>
                            </a>
                        </span>
                    </div>
                </div>
            </div>
            <div class="clearfix no-padding">
                <div ng-class="{ 'form-group':true, 'col-md-6' : story.type == 2 }">
                    <label for="story.type">${message(code:'is.story.type')}</label>
                    <select style="width:100%"
                            class="form-control"
                            ng-model="story.type"
                            ui-select2>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}" />
                </select>
                </div>
                <div ng-class="{ 'form-group':true, 'col-md-6':true}" ng-show="story.type == 2">
                    <label for="story.affectVersion">${message(code:'is.story.affectVersion')}</label>
                    <input class="form-control"
                           type="hidden"
                           value="{{ story.affectVersion  }}"
                           ng-model="story.affectVersion"
                           ui-select2="selectAffectionVersionOptions"
                           data-placeholder="${message(code:'is.ui.story.noaffectversion')}"
                           style="width:100%"/>
                </div>
            </div>
            <div class="form-group">
                <label for="story.dependsOn.id">${message(code:'is.story.dependsOn')}</label>
                <div ng-class="{'input-group':story.dependsOn.id}">
                    <input  type="hidden"
                            style="width:100%;"
                            class="form-control"
                            value="{{ story.dependsOn.id ? story.dependsOn : '' }}"
                            ng-model="story.dependsOn"
                            ui-select2="selectDependsOnOptions"
                            data-placeholder="${message(code: 'is.ui.story.nodependence')}"/>
                    <span class="input-group-btn" ng-show="story.dependsOn.id">
                        <a href="#story/{{ story.dependsOn.id }}"
                           title="{{ story.dependsOn.name }}"
                           class="btn btn-default">
                            <i class="fa fa-external-link"></i>
                        </a>
                    </span>
                </div>
                <div class="clearfix" style="margin-top: 15px;" ng-if="story.dependences.length">
                    <strong>${message(code:'is.story.dependences')} :</strong>
                    <a class="scrum-link" title="{{ dependence.name }}" ng-repeat="dependence in story.dependences">{{ dependence.name }}</a>
                </div>
            </div>
            <div class="form-group">
                <label for="story.description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          ng-model="story.description"
                          ng-show="showDescriptionTextarea"
                          ng-blur="showDescriptionTextarea = false"
                          focus-me="{{ showDescriptionTextarea }}"
                          data-at
                          data-at-at="a"
                          data-at-matcher="$.icescrum.story.formatters.description"
                          data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                          data-at-placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                          data-at-change="${updateUrl}"
                          data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                          data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}"></textarea>
                <div class="atwho-preview form-control-static"
                     ng-show="!showDescriptionTextarea"
                     ng-click="showDescriptionTextarea = true"
                     ng-focus="showDescriptionTextarea = true"
                     tabindex="0"
                     ng-bind-html="story | descriptionHtml | sanitize"></div>
            </div>
            <div class="form-group">
                <input type="hidden"
                       style="width:100%"
                       class="form-control"
                       value="{{ story.tags.join(',') }}"
                       ng-model="story.tags"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
            </div>
            <div class="form-group">
                <label for="story.notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea is-markitup
                          class="form-control"
                          ng-model="story.notes"
                          is-model-html="story.notes_html"
                          ng-show="showNotesTextarea"
                          ng-blur="showNotesTextarea = false"
                          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                <div class="markitup-preview"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = true"
                     ng-focus="showNotesTextarea = true"
                     tabindex="0"
                     ng-bind-html="story.notes_html | sanitize"></div>
            </div>
        </form>
        <tabset type="tabsType">
            <tab select="activities(selected)"
                 heading="${message(code: 'is.ui.backlogelement.activity')}"
                 active="tabActive['activities']"
                 scroll-to-tab="#right">
                <table class="table table-striped">
                    <tbody ng-include src="'activity.list.html'"></tbody>
                </table>
            </tab>
            <tab heading="${message(code: 'is.ui.backlogelement.attachment')}"
                 active="tabActive['attachments']"
                 scroll-to-tab="#right">
            </tab>
            <tab select="comments(selected)"
                 heading="${message(code: 'is.ui.backlogelement.activity.comments')}"
                 active="tabActive['comments']"
                 scroll-to-tab="#right">
                <table class="table table-striped">
                    <tbody ng-include src="'comment.list.html'"></tbody>
                </table>
                <div ng-include src="'comment.editor.html'"></div>
            </tab>
            <tab select="tasks(selected)"
                 heading="${message(code: 'is.ui.backlogelement.activity.task')}"
                 active="tabActive['tasks']"
                 scroll-to-tab="#right">
                <div ng-include src="'story.task.new.html'"></div>
                <table class="table table-striped">
                    <tbody ng-include src="'story.tasks.html'"></tbody>
                </table>
            </tab>
            <tab heading="${message(code: 'is.ui.backlogelement.activity.test')}"
                 active="tabActive['tests']"
                 scroll-to-tab="#right">
            </tab>
        </tabset>
    </div>
</div>
</script>
