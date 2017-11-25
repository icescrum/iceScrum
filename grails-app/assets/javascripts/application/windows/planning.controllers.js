/*
 * Copyright (c) 2016 Kagilum SAS.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

extensibleController('planningCtrl', ['$scope', '$state', 'SprintStatesByName', 'ReleaseStatesByName', 'project', function($scope, $state, SprintStatesByName, ReleaseStatesByName, project) {
    $scope.isSelected = function(selectable) {
        if ($state.params.storyId) {
            return $state.params.storyId == selectable.id;
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.storyId != undefined;
    };
    $scope.hasPreviousVisibleSprints = function() {
        return $scope.visibleSprintOffset > 0;
    };
    $scope.hasNextVisibleSprints = function() {
        return $scope.visibleSprintMax + $scope.visibleSprintOffset + 1 <= $scope.sprints.length;
    };
    $scope.visibleSprintsPrevious = function() {
        $scope.visibleSprintOffset--;
        $scope.computeVisibleSprints();
    };
    $scope.visibleSprintsNext = function() {
        $scope.visibleSprintOffset++;
        $scope.computeVisibleSprints();
    };
    $scope.computeVisibleSprints = function() {
        $scope.visibleSprints = $scope.sprints.slice($scope.visibleSprintOffset, $scope.visibleSprintMax + $scope.visibleSprintOffset);
    };
    var getNewStoryState = function(storyId, currentStateName) {
        var newStateName;
        var newStateParams = {storyId: storyId};
        if (_.startsWith(currentStateName, 'planning.release.sprint.multiple')) {
            newStateName = 'planning.release.sprint.multiple.story.details';
        } else if (_.startsWith(currentStateName, 'planning.release.sprint.withId')) {
            newStateName = 'planning.release.sprint.withId.story.details';
        } else if (currentStateName === 'planning.release.sprint') {
            // Special case when there is no sprintId in the state params so we must retrieve it manually
            newStateName = 'planning.release.sprint.withId.story.details';
            newStateParams.sprintId = $scope.selectedItems[0].id;
        } else {
            newStateName = 'planning.release.story.details';
            if (currentStateName === 'planning' || currentStateName == 'planning.new') { // Special case when there is no releasedID in the state params so we must retrieve it manually
                newStateParams.releaseId = $scope.selectedItems[0].id;
            }
        }
        return {name: newStateName, params: newStateParams}
    };
    $scope.openReleaseUrl = function(release) {
        var stateName = 'planning.release';
        if ($state.current.name != 'planning.release.details') {
            stateName += '.details';
        }
        return $state.href(stateName, {releaseId: release ? release.id : ''});
    };
    $scope.openStoryUrl = function(storyId) {
        var newStoryState = getNewStoryState(storyId, $state.current.name);
        return $state.href(newStoryState.name, newStoryState.params);
    };
    $scope.openSprintUrl = function(sprint) {
        var stateName = 'planning.release.sprint.withId';
        if ($state.current.name != 'planning.release.sprint.withId.details') {
            stateName += '.details';
        }
        return $state.href(stateName, {sprintId: sprint.id, releaseId: sprint.parentRelease.id});
    };
    $scope.openMultipleSprintDetailsUrl = function() {
        var stateName = 'planning.release.sprint.multiple';
        if ($state.current.name != 'planning.release.sprint.multiple.details') {
            stateName += '.details';
        }
        return $state.href(stateName);
    };
    $scope.isMultipleSprint = function() {
        return _.startsWith($state.current.name, 'planning.release.sprint.multiple');
    };
    // Init
    $scope.viewName = 'planning';
    $scope.visibleSprintMax = $scope.application.mobilexs ? 1 : ($scope.application.mobile ? 2 : 3);
    $scope.visibleSprintOffset = 0;
    $scope.visibleSprints = [];
    $scope.project = project;
    $scope.releases = project.releases;
    $scope.sprints = [];
    $scope.timelineSelected = function(selectedItems) { // Timeline -> URL
        if (selectedItems.length == 0) {
            $state.go('planning');
        } else {
            var stateName, stateParams;
            if (selectedItems.length == 1 && selectedItems[0].class == 'Release') {
                stateName = 'planning.release';
                stateParams = {releaseId: selectedItems[0].id};
            } else if (selectedItems.length == 1 && selectedItems[0].class == 'Sprint') {
                var sprint = selectedItems[0];
                stateName = 'planning.release.sprint.withId';
                stateParams = {releaseId: sprint.parentRelease.id, sprintId: sprint.id};
            } else {
                stateName = 'planning.release.sprint.multiple';
                stateParams = {releaseId: selectedItems[0].parentRelease.id, sprintListId: _.map(selectedItems, 'id')};
            }
            var currentStateName = $state.current.name;
            var sameStateName = _.endsWith(currentStateName, '.details') && currentStateName == stateName + '.details' || currentStateName == stateName;
            var sameStateParams = $state.params.sprintId == stateParams.sprintId && $state.params.releaseId == stateParams.releaseId;
            var sameState = sameStateName && sameStateParams;
            if (_.endsWith(currentStateName, '.details') && !sameState || !_.endsWith(currentStateName, '.details') && sameState) {
                stateName += '.details';
            }
            $state.go(stateName, stateParams);
        }
    };
    $scope.$watch("release.sprints_count", function(newValues) {
        var releaseId = $state.params.releaseId;
        var release = _.find($scope.releases, {id: releaseId});
        if ($state.params.sprintListId || $state.params.sprintId) {
            var missing = false;
            var ids = _.map(release.sprints, function(sprint) {
                return sprint.id.toString()
            });
            if ($state.params.sprintListId) {
                var selecteds = $state.params.sprintListId.split(",");
                missing = _.every(selecteds, function(selected) {
                    return !_.includes(ids, selected);
                });
            } else {
                missing = !_.includes(ids, $state.params.sprintId.toString());
            }
            if (missing) {
                $scope.timelineSelected([]);
            }
        }
        $scope.releases = project.releases;
        $scope.computeVisibleSprints();
    });
    $scope.$watchGroup([function() { return $state.$current.self.name; }, function() { return $state.params.releaseId; }, function() { return $state.params.sprintId; }, function() { return $state.params.sprintListId; }], function(newValues) {
        var stateName = newValues[0];
        var releaseId = newValues[1];
        var sprintId = newValues[2];
        var sprintListId = newValues[3];
        var release = _.find($scope.releases, {id: releaseId});
        $scope.visibleSprintOffset = 0;
        if (release && stateName.indexOf('.sprint') != -1 && stateName.indexOf('.new') == -1) {
            if (sprintId) {
                $scope.sprints = [_.find(release.sprints, {id: sprintId})];
            } else if (sprintListId) {
                var ids = _.map(sprintListId.split(','), function(id) {
                    return parseInt(id);
                });
                $scope.sprints = _.filter(release.sprints, function(sprint) {
                    return _.includes(ids, sprint.id);
                });
            } else {
                var sprint = _.find(release.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.TODO || sprint.state == SprintStatesByName.IN_PROGRESS;
                });
                if (!sprint) {
                    sprint = _.last(release.sprints);
                }
                $scope.sprints = [sprint];
            }
            $scope.selectedItems = $scope.sprints; // URL -> Timeline
        } else {
            if (!release) {
                release = _.find($scope.releases, function(release) {
                    return release.state == ReleaseStatesByName.TODO || release.state == ReleaseStatesByName.IN_PROGRESS;
                });
                if (!release) {
                    release = _.last($scope.releases);
                }
            }
            if (release) {
                if (release.sprints == null) {
                    release.sprints = [];
                }
                $scope.sprints = release.sprints;
                $scope.selectedItems = [release]; // URL -> Timeline
                var firstSprintToShowIndex = _.findIndex($scope.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.TODO || sprint.state == SprintStatesByName.IN_PROGRESS;
                });
                if (firstSprintToShowIndex == -1) {
                    firstSprintToShowIndex = $scope.sprints.length > $scope.visibleSprintMax ? $scope.sprints.length - $scope.visibleSprintMax - 1 : 0;
                }
                $scope.visibleSprintOffset = firstSprintToShowIndex;
            }
        }
        $scope.release = release;
        $scope.computeVisibleSprints();
    });
    $scope.$watchGroup(['application.mobile', 'application.mobilexs'], function(n, o) {
        var oldVisible = $scope.visibleSprintMax;
        $scope.visibleSprintMax = $scope.application.mobilexs ? 1 : ($scope.application.mobile ? 2 : 3);
        if (oldVisible != $scope.visibleSprintMax) {
            $state.reload();
        }
    });
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        allowMultiple: false,
        selectionUpdated: function(selectedIds) {
            var currentStateName = $state.current.name;
            var storyIndexInStateName = currentStateName.indexOf('story');
            if (selectedIds.length == 0 && storyIndexInStateName != -1) {
                $state.go(currentStateName.slice(0, storyIndexInStateName - 1));
            } else {
                var newStoryState = getNewStoryState(selectedIds[0], currentStateName);
                $state.go(newStoryState.name, newStoryState.params);
            }
        }
    };
}]);
