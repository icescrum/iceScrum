/*
 * Copyright (c) 2014 Kagilum SAS.
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

controllers.controller('storyCtrl', ['$scope', 'StoryService', function($scope, StoryService) {
    $scope.accept = function(story) {
        StoryService.accept(story).then($scope.goToNewStory);
    };
    $scope.acceptAs = function(story, target) {
        StoryService.acceptAs(story, target).then($scope.goToNewStory);
    };
    $scope.copy = function(story) {
        StoryService.copy(story);
    };
    $scope['delete'] = function(story) {
        StoryService.delete(story).then($scope.goToNewStory);
    };
    $scope.authorized = function(action, story) {
        return StoryService.authorized(action, story);
    };
    $scope.selectFeatureOptions = {
        formatResult: function(object, container) {
            container.css('border-left', '4px solid ' + object.color);
            return object.text ? object.text : object.name;
        },
        formatSelection: function(object, container) {
            container.css('border-color', object.color);
            return object.text ? object.text : object.name;
        },
        allowClear: true,
        createChoiceOnEmpty: false,
        //important to preserve logic id='' server side
        resultAsEmptyId: true,
        initSelection: function(element, callback) {
            callback(JSON.parse(element.val()));
        },
        ajax: {
            url: 'feature/featureEntries',
            cache: 'true',
            data: function(term) {
                return { term: term };
            },
            results: function(data) {
                return { results: data };
            }
        }
    };
}]);

controllers.controller('storyDetailsCtrl', ['$scope', '$controller', '$state', '$timeout', '$filter', '$stateParams', '$modal', 'StoryService', 'StoryStates', 'TaskService', 'CommentService', 'AcceptanceTestService', 'FormService',
    function($scope, $controller, $state, $timeout, $filter, $stateParams, $modal, StoryService, StoryStates, TaskService, CommentService, AcceptanceTestService, FormService) {
        $controller('storyCtrl', { $scope: $scope }); // inherit from storyCtrl
        $scope.story = {};
        StoryService.get($stateParams.id).then(function(story) {
            $scope.story = story;
            // For header
            var list = $state.current.data.filterListParams ? $filter('filter')(StoryService.list, $state.current.data.filterListParams) : StoryService.list;
            $scope.previous = FormService.previous(list, $scope.story);
            $scope.next = FormService.next(list, $scope.story);
            $scope.progressStates = [];
            var width = 100 / _.filter(_.keys(StoryStates), function(key) {
                return key > 0
            }).length;
            _.each(StoryStates, function(state, key) {
                var date = $scope.story[state.code.toLowerCase() + 'Date'];
                if (date != null) {
                    $scope.progressStates.push({
                        name: state.code + ' ' + '(' + date + ')',
                        code: state.code,
                        width: width
                    });
                }
            });
        });
        $scope.acceptanceTestEdit = {};
        $scope.editAcceptanceTest = function(id, value) {
            $scope.acceptanceTestEdit = {};
            $scope.acceptanceTestEdit[id] = value;
        };
        $scope.commentEdit = {};
        $scope.editComment = function(id, value) {
            $scope.commentEdit = {};
            $scope.commentEdit[id] = value;
        };
        $scope.showNewTemplateModal = function(story) {
            $modal.open({
                templateUrl: 'story.template.new.html',
                size: 'sm',
                controller: function($scope, $modalInstance) {
                    $scope.submit = function(template) {
                        StoryService.saveTemplate(story, template.name).then(function() {
                            $modalInstance.close();
                        });
                    };
                }
            });
        };
        $scope.tabsType = 'tabs nav-tabs-google';
        if ($state.params.tabId) {
            $scope.tabSelected = {};
            $scope.tabSelected[$state.params.tabId] = true;
        } else {
            $scope.tabSelected = {'activities': true};
        }
        //watch from url change outside and keep updated of which tab is selected (getting params tabId in view)
        $scope.$watch('$state.params', function() {
            if ($state.params.tabId) {
                $scope.tabSelected[$state.params.tabId] = true;
                //scrollToTab
                $timeout((function() {
                    var container = angular.element('#right');
                    var pos = angular.element('#right .nav-tabs-google [active="tabSelected.' + $state.params.tabId + '"]').position().top + container.scrollTop();
                    container.animate({ scrollTop: pos }, 1000);
                }));
            }
        });
        $scope.setTabSelected = function(tab) {
            if ($state.params.tabId) {
                $state.go('.', {tabId: tab});
            } else {
                $state.go('.tab', {tabId: tab});
            }
        };
        $scope.update = function(story) {
            StoryService.update(story);
        };
        $scope.follow = function(story) {
            StoryService.follow(story);
        };
        $scope.like = function(story) {
            StoryService.like(story);
        };
        $scope.activities = function(story) {
            StoryService.activities(story);
        };
        $scope.tasks = function(story) {
            TaskService.list(story);
        };
        $scope.acceptanceTests = function(story) {
            AcceptanceTestService.list(story);
        };
        $scope.comments = function(story) {
            CommentService.list(story);
        };
    }]);

controllers.controller('storyEditCtrl', ['$scope', '$stateParams', 'FormService', 'StoryService', function($scope, $stateParams, FormService, StoryService) {
    $scope.story = {}; // We cannnot use the story inherited from parent scope because it may not be retrieved yet (promise)
    $scope.selectDependsOnOptions = {
        formatSelection: function(object) {
            return object.text ? object.text : object.name + ' (' + object.id + ')';
        },
        allowClear: true,
        createChoiceOnEmpty: false,
        resultAsEmptyId: true, //important to preserve logic id='' server side
        initSelection: function(element, callback) {
            callback(JSON.parse(element.val()));
        },
        ajax: {
            // The URL can't be known yet (the story will be known only after promise completion
            cache: 'true',
            data: function(term) {
                return { term: term };
            },
            results: function(data) {
                return { results: data };
            }
        }
    };
    StoryService.get($stateParams.id).then(function(story) {
        $scope.story = angular.copy(story);
        $scope.selectDependsOnOptions.ajax.url = 'story/' + $scope.story.id + '/dependenceEntries';

    });
    $scope.selectAffectionVersionOptions = {
        allowClear: true,
        createChoiceOnEmpty: true,
        resultAsString: true,
        createSearchChoice: function(term) {
            return {id: term, text: term};
        },
        initSelection: function(element, callback) {
            callback({id: element.val(), text: element.val()});
        },
        ajax: {
            url: 'project/versions',
            cache: 'true',
            data: function(term) {
                return { term: term };
            },
            results: function(data) {
                return { results: data };
            }
        }
    };
    $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
}]);

controllers.controller('storyMultipleCtrl', ['$scope', '$controller', 'StoryService', 'listId', function($scope, $controller, StoryService, listId) {
    $controller('storyCtrl', { $scope: $scope }); // inherit from storyCtrl
    $scope.topStory = {};
    $scope.storyPreview = {};
    $scope.stories = [];
    $scope.allFollowed = false;
    function refreshStories() {
        StoryService.getMultiple(listId).then(function(stories) {
            $scope.topStory = _.first(stories);
            $scope.storyPreview = {
                feature: angular.copy($scope.topStory.feature),
                type: $scope.topStory.type
            };
            $scope.stories = stories;
            $scope.allFollowed = _.every(stories, 'followed');
        });
    }
    refreshStories();
    $scope.deleteMultiple = function() {
        StoryService.deleteMultiple(listId).then($scope.goToNewStory);
    };
    $scope.copyMultiple = function() {
        StoryService.copyMultiple(listId);
    };
    $scope.updateMultiple = function(updatedFields) {
        StoryService.updateMultiple(listId, updatedFields);
    };
    $scope.acceptMultiple = function() {
        StoryService.acceptMultiple(listId).then($scope.goToNewStory);
    };
    $scope.followMultiple = function(follow) {
        StoryService.followMultiple(listId, follow).then(function() {
            refreshStories();
        });
    };
    $scope.acceptAsMultiple = function(target) {
        StoryService.acceptAsMultiple(listId, target).then($scope.goToNewStory);
    };
}]);

controllers.controller('storyNewCtrl', ['$scope', '$state', '$http', '$modal', '$timeout', '$controller', 'StoryService', 'hotkeys',
    function($scope, $state, $http, $modal, $timeout, $controller, StoryService, hotkeys) {
        $controller('storyCtrl', { $scope: $scope }); // inherit from storyCtrl
        function initStory() {
            var defaultStory = {};
            if ($scope.story && $scope.story.template) {
                defaultStory.template = $scope.story.template
            }
            return defaultStory;
        }
        hotkeys
            .bindTo($scope) // to remove the hotkey when the scope is destroyed
            .add({
                combo: 'esc',
                allowIn: ['INPUT'],
                callback: function() {
                    $scope.story = initStory();
                }
            });
        $scope.story = initStory();
        $scope.templateSelected = function() {
            if ($scope.story.template) {
                $http.get('story/templatePreview?template=' + $scope.story.template.id).success(function(storyPreview) {
                    $scope.storyPreview = storyPreview;
                });
            } else {
                $scope.storyPreview = {}
            }
        };
        $scope.selectTemplateOptions = {
            allowClear: true,
            ajax: {
                url: 'story/templateEntries',
                cache: 'true',
                data: function(term) {
                    return { term: term };
                },
                results: function(data) {
                    return { results: data };
                }
            }
        };
        $scope.showEditTemplateModal = function(story) {
            $modal.open({
                templateUrl: 'story.template.edit.html',
                size: 'sm',
                controller: function($scope, $http) {
                    $scope.templateEntries = [];
                    $http.get('story/templateEntries').success(function(templateEntries) {
                        $scope.templateEntries = templateEntries;
                    });
                    $scope.deleteTemplate = function(templateEntry) {
                        StoryService.deleteTemplate(templateEntry.id).then(function() {
                            _.remove($scope.templateEntries, { id: templateEntry.id });
                        });
                    }
                }
            });
        };
        $scope.save = function(story, andContinue) {
            StoryService.save(story).then(function(story) {
                if (andContinue) {
                    $scope.story = initStory();
                } else {
                    $state.go('^.details', { id: story.id });
                }
            });
        };
        $scope.findDuplicates = function(term) {
            if (term == null || term.length <= 5) {
                $scope.messageDuplicate = '';
            } else if (term.length >= 5) {
                var trimmedTerm = term.trim();
                //TODO maybe local search ?
                $timeout.cancel($scope.timerDuplicate);
                $scope.timerDuplicate = $timeout(function() {
                    if ($scope.lastSearchedTerm != trimmedTerm) {
                        $http.get('story/findDuplicate?term=' + trimmedTerm).success(function(messageDuplicate) {
                            $scope.lastSearchedTerm = trimmedTerm;
                            $scope.messageDuplicate = messageDuplicate ? messageDuplicate : '';
                        });
                    }
                }, 500);
            }
        };
    }]);