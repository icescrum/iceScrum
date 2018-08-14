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
<script type="text/ng-template" id="form.practices.project.html">
<h4>${message(code: "is.dialog.wizard.section.options")}</h4>
<h5>${message(code: "is.dialog.wizard.section.practices.backlog")}</h5>
<div class="row">
    <div class="form-group" ng-class="project.preferences.noEstimation ? 'col-sm-12' : 'col-sm-6'">
        <label for="noEstimation" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.noEstimation"
                   id="noEstimation"
                   ng-model="project.preferences.noEstimation">
            ${message(code: 'is.project.preferences.planification.noEstimation')}
        </label>
    </div>
    <div class="form-half" ng-show="!project.preferences.noEstimation">
        <label for="estimationSuite">${message(code: 'is.project.preferences.planification.estimationSuite')}</label>
        <ui-select class="form-control"
                   name="type"
                   ng-disabled="project.preferences.noEstimation"
                   ng-model="project.planningPokerGameType">
            <ui-select-match>{{ $select.selected | i18n:'PlanningPokerGameSuites' }}</ui-select-match>
            <ui-select-choices repeat="planningPokerType in planningPokerTypes">{{ planningPokerType | i18n:'PlanningPokerGameSuites' }}</ui-select-choices>
        </ui-select>
    </div>
</div>
<h5>${message(code: "is.dialog.wizard.section.practices.sprint")}</h5>
<div class="row">
    <div class="form-half">
        <label for="autoDoneStory" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.autoDoneStory"
                   id="autoDoneStory"
                   ng-model="project.preferences.autoDoneStory">
            {{ message('is.project.preferences.sprint.autoDoneStory', [(storyStatesByName.DONE | i18n: 'StoryStates')]) }}
        </label>
    </div>
    <div class="form-half">
        <label for="autoCreateTaskOnEmptyStory" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.autoCreateTaskOnEmptyStory"
                   id="autoCreateTaskOnEmptyStory"
                   ng-model="project.preferences.autoCreateTaskOnEmptyStory">
            ${message(code: 'is.project.preferences.sprint.autoCreateTaskOnEmptyStory')}
        </label>
    </div>
    <div class="form-half">
        <label for="assignOnCreateTask" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.assignOnCreateTask"
                   id="assignOnCreateTask"
                   ng-model="project.preferences.assignOnCreateTask">
            ${message(code: 'is.project.preferences.sprint.assignOnCreateTask')}
        </label>
    </div>
    <div class="form-half">
        <label for="assignOnBeginTask" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.assignOnBeginTask"
                   id="assignOnBeginTask"
                   ng-model="project.preferences.assignOnBeginTask">
            ${message(code: 'is.project.preferences.sprint.assignOnBeginTask')}
        </label>
    </div>
    <div class="form-half">
        <label for="displayRecurrentTasks" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.displayRecurrentTasks"
                   id="displayRecurrentTasks"
                   ng-model="project.preferences.displayRecurrentTasks">
            ${message(code: 'is.project.preferences.sprint.displayRecurrentTasks')}
        </label>
    </div>
</div>
<div class="row">
    <div class="form-group" ng-class="project.preferences.displayUrgentTasks ? 'col-sm-6' : 'col-sm-12'">
        <label for="displayUrgentTasks" class="checkbox-inline">
            <input type="checkbox"
                   name="project.preferences.displayUrgentTasks"
                   id="displayUrgentTasks"
                   ng-model="project.preferences.displayUrgentTasks">
            ${message(code: 'is.project.preferences.sprint.displayUrgentTasks')}
        </label>
    </div>
    <div class="form-half" ng-show="project.preferences.displayUrgentTasks">
        <label for="limitUrgentTasks">${message(code: 'is.project.preferences.sprint.limitUrgentTasks')}</label>
        <input type="number"
               min="0"
               class="form-control"
               name="project.preferences.limitUrgentTasks"
               id="limitUrgentTasks"
               ng-model="project.preferences.limitUrgentTasks"/>
    </div>
</div>
</script>
