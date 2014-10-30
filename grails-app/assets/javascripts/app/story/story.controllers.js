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

controllers.controller('storyCtrl', ['$scope', 'StoryService', '$state', function($scope, StoryService, $state) {
    // Functions
    $scope.accept = function(story) {
        StoryService.accept(story)
            .then(function() {
                $scope.goToNewStory();
                $scope.notifySuccess('todo.is.ui.story.accepted');
            });
    };
    $scope.acceptAs = function(story, target) {
        StoryService.acceptAs(story, target)
            .then(function() {
                $scope.goToNewStory();
                $scope.notifySuccess('todo.is.ui.story.acceptedAs');
            });
    };
    $scope.follow = function(story) {
        StoryService.follow(story);
    };
    $scope.copy = function(story) {
        StoryService.copy(story)
    };
    $scope['delete'] = function(story) {
        //fake delete
        _.remove(StoryService.list, { id: story.id });
        $scope.goToNewStory();
        var notif = $scope.notifySuccess('todo.is.ui.deleted', {
            actions: [{
                label: 'Undo',
                fn: function() {
                    notif.data.close = angular.noop;
                    StoryService.list.push(story);
                    $state.go('sandbox.details', { id: story.id });
                    $scope.notifySuccess('todo.is.ui.deleted.cancelled');
                }
            }],
            close: function() {
                StoryService.delete(story);
            },
            duration: 5000
        });
    };
    $scope.authorizedStory = function(action, story) {
        return StoryService.authorizedStory(action, story);
    };
    // Settings
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
        $scope.formHolder = {};
        $scope.story = {};
        $scope.editableStory = {};
        $scope.editableStoryReference = {};
        $scope.allActivities = false;
        StoryService.get($stateParams.id).then(function(story) {
            $scope.story = story;
            // For edit
            $scope.resetStoryForm();
            $scope.selectDependsOnOptions.ajax.url = 'story/' + $scope.story.id + '/dependenceEntries';
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
         }).catch(function(e){
            $state.go('^.new');
            $scope.notifyError(e.message);
        });
        $scope.showNewTemplateModal = function(story) {
            $modal.open({
                templateUrl: 'story.template.new.html',
                size: 'sm',
                controller: ["$scope", "$modalInstance", function($scope, $modalInstance) {
                    $scope.submit = function(template) {
                        StoryService.saveTemplate(story, template.name)
                            .then(function() {
                                $modalInstance.close();
                                $scope.notifySuccess('todo.is.ui.story.template.saved');
                            });
                    };
                }]
            });
        };
        if ($state.params.tabId) {
            $scope.tabSelected = {};
            if ($state.params.tabId != 'attachments') {
                $scope.tabSelected[$state.params.tabId] = true;
            }
        } else {
            $scope.tabSelected = {'activities': true};
        }
        //watch from url change outside and keep updated of which tab is selected (getting params tabId in view)
        $scope.$watch('$state.params', function() {
            if ($state.params.tabId) {
                if ($state.params.tabId != 'attachments') {
                    $scope.tabSelected[$state.params.tabId] = true;
                }
                $timeout((function() {
                    var container = angular.element('#right');
                    var pos = $state.params.tabId == 'attachments' ? angular.element('#right .table.attachments').offset().top - angular.element('#right .panel-body').offset().top - 9 : angular.element('#right .nav-tabs-google').offset().top - angular.element('#right .panel-body').offset().top - 9;
                    container.animate({ scrollTop: pos }, 1000);
                }));
            }
        });
        $scope.setTabSelected = function(tab) {
            if ($state.params.tabId) {
                $state.go('.', {tabId: tab});
            } else {
                if ($state.$current.toString().indexOf('details') > 0) {
                    $state.go('.tab', {tabId: tab});
                }
            }
        };
        $scope.update = function(story) {
            StoryService.update(story)
                .then(function(story) {
                    $scope.story = story;
                    $scope.activities(story); // TODO check if not better solution
                    $scope.resetStoryForm();
                    $scope.notifySuccess('todo.is.ui.story.updated');
                });
        };
        $scope.like = function(story) {
            StoryService.like(story);
        };
        $scope.activities = function(story, all) {
            $scope.allActivities = all;
            StoryService.activities(story, all);
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
        // edit;
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableStory, $scope.editableStoryReference);
        };
        $scope.editForm = function(value) {
            $scope.setEditableMode(value); // global
            if (!value) {
                $scope.resetStoryForm();
            }
        };
        $scope.getShowStoryForm = function(story) {
            return ($scope.getEditableMode() || $scope.formHolder.formHover) && $scope.authorizedStory('update', story);
        };
        $scope.resetStoryForm = function() {
            $scope.editableStory = angular.copy($scope.story);
            $scope.editableStoryReference = angular.copy($scope.story);
            if ($scope.formHolder.storyForm) {
                $scope.formHolder.storyForm.$setPristine();
            }
        };
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
        $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
        $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
            if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
                event.preventDefault(); // cancel the state change
                $scope.mustConfirmStateChange = false;
                $scope.confirm({
                    message: 'todo.is.ui.dirty.confirm',
                    condition: $scope.isDirty() || ($scope.flow != undefined && $scope.flow.isUploading()),
                    callback: function() {
                        if ($scope.flow != undefined && $scope.flow.isUploading()) {
                            $scope.flow.cancel();
                        }
                        $state.go(toState, toParams)
                    },
                    closeCallback: function() {
                        $scope.mustConfirmStateChange = true;
                    }
                });
            }
        });
        $scope.atOptions = {
            tpl: "<li data-value='A[${uid}-${name}]'>${name}</li>",
            data: "actor/search",
            at: 'a'
        };
        $scope.clickDescriptionPreview = function($event, template) {
            if ($event.target.nodeName != 'A' && $scope.getShowStoryForm($scope.story)) {
                $scope.showDescriptionTextarea = true;
                var $el = angular.element($event.currentTarget);
                $el.prev().css('height', $el.outerHeight());
                $scope.editForm(true);
                if (!$scope.editableStory.description) {
                    ($scope.editableStory.description = template);
                }
            }
        };
        $scope.focusDescriptionPreview = function($event) {
            if (!$scope.descriptionPreviewMouseDown) {
                $timeout(function() {
                    angular.element($event.target).triggerHandler('click');
                });
            }
        };
        $scope.blurDescription = function(template) {
            if (!$('.atwho-view:visible').length && $scope.formHolder.storyForm.description.$valid) { // ugly hack on atwho
                $scope.showDescriptionTextarea = false;
                if ($scope.editableStory.description.trim() == template.trim()) {
                    $scope.editableStory.description = '';
                }
            }
        };
        $scope.getSelected = function() {
            return $scope.story;
        };
        $scope.clazz = 'story';
        $scope.attachmentQuery = function($flow, story) {
            //to add flow in storyDetailsCtrl scope
            $scope.flow = $flow;
            $flow.opts.target = 'attachment/story/' + story.id + '/flow';
            $flow.upload();
        };
        $scope.formHover = function(value) {
            $scope.formHolder.formHover = value;
        };
    }]);

controllers.controller('storyMultipleCtrl', ['$scope', '$controller', 'StoryService', 'listId', function($scope, $controller, StoryService, listId) {
    $controller('storyCtrl', { $scope: $scope }); // inherit from storyCtrl
    // Functions
    $scope.deleteMultiple = function() {
        // TODO cancellable delete ?
        StoryService.deleteMultiple(listId)
            .then(function() {
                $scope.goToNewStory();
                $scope.notifySuccess('todo.is.ui.multiple.deleted');
            });
    };
    $scope.copyMultiple = function() {
        StoryService.copyMultiple(listId);
    };
    $scope.updateMultiple = function(updatedFields) {
        StoryService.updateMultiple(listId, updatedFields)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.story.multiple.updated');
            });
    };
    $scope.acceptMultiple = function() {
        StoryService.acceptMultiple(listId)
            .then(function() {
                $scope.goToNewStory();
                $scope.notifySuccess('todo.is.ui.story.multiple.accepted');
            });
    };
    $scope.followMultiple = function(follow) {
        StoryService.followMultiple(listId, follow)
            .then(function() {
                refreshStories();
            });
    };
    $scope.acceptAsMultiple = function(target) {
        StoryService.acceptAsMultiple(listId, target)
            .then(function() {
                $scope.goToNewStory();
                $scope.notifySuccess('todo.is.ui.story.multiple.acceptedAs');
            });
    };
    // Init
    $scope.topStory = {};
    $scope.storyPreview = {};
    $scope.stories = [];
    $scope.allFollowed = false;
    $scope.noneFollowed = true;
    function refreshStories() {
        StoryService.getMultiple(listId).then(function(stories) {
            $scope.topStory = _.first(stories);
            $scope.storyPreview = {
                feature: _.every(stories, { feature: $scope.topStory.feature }) ? $scope.topStory.feature : null,
                type: _.every(stories, { type: $scope.topStory.type }) ? $scope.topStory.type : null
            };
            $scope.stories = stories;
            $scope.allFollowed = _.every(stories, 'followed');
            $scope.noneFollowed = !_.some(stories, 'followed');
        });
    }
    refreshStories();
}]);

controllers.controller('storyNewCtrl', ['$scope', '$state', '$http', '$modal', '$timeout', '$controller', 'StoryService', 'hotkeys',
    function($scope, $state, $http, $modal, $timeout, $controller, StoryService, hotkeys) {
        $controller('storyCtrl', { $scope: $scope }); // inherit from storyCtrl
        // Functions
        $scope.resetStoryForm = function() {
            var defaultStory = {};
            if ($scope.story && $scope.story.template) {
                defaultStory.template = $scope.story.template
            }
            $scope.story = defaultStory;
            if ($scope.formHolder.storyForm) {
                $scope.formHolder.storyForm.$setPristine();
            }
        };
        $scope.templateSelected = function() {
            if ($scope.story.template) {
                $http.get('story/templatePreview?template=' + $scope.story.template.id).success(function(storyPreview) {
                    $scope.storyPreview = storyPreview;
                });
            } else {
                $scope.storyPreview = {}
            }
        };
        $scope.showEditTemplateModal = function(story) {
            $modal.open({
                templateUrl: 'story.template.edit.html',
                size: 'sm',
                controller: ["$scope", "$http", function($scope, $http) {
                    $scope.templateEntries = [];
                    $http.get('story/templateEntries').success(function(templateEntries) {
                        $scope.templateEntries = templateEntries;
                    });
                    // TODO cancellable delete
                    $scope.deleteTemplate = function(templateEntry) {
                        StoryService.deleteTemplate(templateEntry.id)
                            .then(function() {
                                _.remove($scope.templateEntries, { id: templateEntry.id });
                                $scope.notifySuccess('todo.is.ui.deleted');
                            });
                    }
                }]
            });
        };
        $scope.save = function(story, andContinue) {
            StoryService.save(story)
                .then(function(story) {
                    if (andContinue) {
                        $scope.resetStoryForm();
                    } else {
                        $scope.setEditableMode(true);
                        $state.go('^.details', { id: story.id });
                    }
                    $scope.notifySuccess('todo.is.ui.story.saved');
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
        // Settings
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
        // Init
        $scope.formHolder = {};
        $scope.resetStoryForm();
        hotkeys.bindTo($scope).add({
            combo: 'esc',
            allowIn: ['INPUT'],
            callback: $scope.resetStoryForm
        });
    }]);