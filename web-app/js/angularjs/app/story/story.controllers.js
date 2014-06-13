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
 *
 */
controllers.controller('storyCtrl', ['$scope', '$state', '$timeout', 'selected', 'StoryService', 'TaskService', 'CommentService', 'AcceptanceTestService', function ($scope, $state, $timeout, selected, StoryService, TaskService, CommentService, AcceptanceTestService) {
    $scope.selected = selected;

    $scope.acceptanceTestEdit = {};
    $scope.editAcceptanceTest = function(id, value) {
        $scope.acceptanceTestEdit = {};
        $scope.acceptanceTestEdit[id] = value;
    };

    $scope.tabsType = 'tabs nav-tabs-google';
    if ($state.params.tabId){
        $scope.tabSelected = {};
        $scope.tabSelected[$state.params.tabId] = true;
    } else {
        $scope.tabSelected = {'activities':true};
    }
    //watch from url change outside and keep updated of which tab is selected (getting params tabId in view)
    $scope.$watch('$state.params', function() {
        if ($state.params.tabId){
            $scope.tabSelected[$state.params.tabId] = true;
            //scrollToTab
            $timeout((function(){
                var container = angular.element('#right');
                var pos = angular.element('#right .nav-tabs-google [active="tabSelected.'+$state.params.tabId+'"]').position().top + container.scrollTop();
                container.animate({ scrollTop : pos }, 1000);
            }));
        }
    });
    //for buttons in story header
    $scope.setTabSelected = function(tab){
        if ($state.params.tabId) {
            $state.go('.', {tabId:tab});
        } else {
            $state.go('.tab', {tabId:tab});
        }
    };

    $scope.update = function(story) {
        StoryService.update(story, function(){
            $scope.$digest();
        });
    };

    $scope['delete'] = function(story) {
        StoryService.delete(story);
        $state.go('^');
    };

    //follow
    $scope.follow = function(story) {
        StoryService.follow(story);
    };
    //like
    $scope.like = function(story) {
        StoryService.like(story);
    };

    //grab activities when needed
    $scope.activities = function(story){
        StoryService.activities(story);
    };

    //grab tasks when needed
    $scope.tasks = function(story){
        TaskService.list(story);
    };

    $scope.acceptanceTests = function(story){
        AcceptanceTestService.list(story);
    };

    //grab comments when needed
    $scope.comments = function(story){
        CommentService.list(story);
    };
}]);

controllers.controller('storyHeaderCtrl',['$scope', '$state', '$filter', 'StoryStates', 'StoryService', 'FormService', function ($scope, $state, $filter, StoryStates, StoryService, FormService) {
    StoryService.follow($scope.selected, true);
    StoryService.like($scope.selected, true);
    //manage display next / previous
    var list = $state.current.data.filterListParams ? $filter('filter')(StoryService.list, $state.current.data.filterListParams) : StoryService.list;
    $scope.previous = FormService.previous(list, $scope.selected);
    $scope.next = FormService.next(list, $scope.selected);
    //compute progress state
    $scope.progressStates = [];
    var width = 100 / _.filter(_.keys(StoryStates), function (key) { return key > 0 }).length;
    _.each(StoryStates, function (state, key) {
        var date = $scope.selected[state.code.toLowerCase() + 'Date'];
        if (date != null) {
            $scope.progressStates.push({
                name: state.code + ' ' + '(' + date + ')',
                code: state.code,
                width: width
            });
        }
    });
}]);

controllers.controller('storyEditCtrl',['$scope', 'Session', 'FormService', function ($scope, Session, FormService) {
    //$scope.selected is inherited from storyCtrl
    //copy story model
    $scope.story = angular.copy($scope.selected);

    //select affectVersion
    $scope.selectAffectionVersionOptions = {
        allowClear: true,
        createChoiceOnEmpty:true,
        minimumResultsForSearch: 6,
        resultAsString:true,
        createSearchChoice: function (term) {
            return {id:term, text:term};
        },
        initSelection : function (element, callback) {
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
    //select tags
    $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
    //select feature
    $scope.selectFeatureOptions = {
        formatResult: function(object, container){
            container.css('border-left','4px solid '+object.color);
            return object.text ? object.text : object.name;
        },
        formatSelection: function(object, container){
            container.css('border-color',object.color);
            return object.text ? object.text : object.name;
        },
        allowClear:true,
        createChoiceOnEmpty:false,
        minimumResultsForSearch: 6,
        //important to preserve logic id='' server side
        resultAsEmptyId:true,
        initSelection : function (element, callback) {
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
    //select dependsOn
    $scope.selectDependsOnOptions = {
        formatSelection: function(object){
            return object.text ? object.text : object.name+' ('+object.id+')';
        },
        allowClear:true,
        createChoiceOnEmpty:false,
        minimumResultsForSearch: 6,
        //important to preserve logic id='' server side
        resultAsEmptyId:true,
        initSelection : function (element, callback) {
            callback(JSON.parse(element.val()));
        },
        ajax: {
            url: 'story/'+$scope.story.id+'/dependenceEntries',
            cache: 'true',
            data: function(term) {
                return { term: term };
            },
            results: function(data) {
                return { results: data };
            }
        }
    };
    $scope.readOnly = function() {
        return !(Session.poOrSm() || Session.creator($scope.story));
    }
}]);

controllers.controller('storyMultipleCtrl', ['$scope', '$state', 'listId', function ($scope, $state, listId) {
    $scope.ids = listId;
}]);