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
controllers.controller('storyCtrl', ['$scope', '$state', 'selected', 'StoryService', 'TaskService', 'CommentService', function ($scope, $state, selected, StoryService, TaskService, CommentService) {
    $scope.selected = selected;
    $scope.tabsType = 'tabs nav-tabs-google';
    $scope.tabSelected = {};
    //watch from url change outside and keep updated of which tab is selected (getting params tabId in view)
    $scope.$watch('$state.params', function(newValue, oldValue){
        if ($state.params.id == selected.id){
            $scope.tabSelected[$state.params.tabId] = true;
        }
    });
    //for buttons in story header
    $scope.setTabSelected = function(tab){
        $state.go('.', {tabId:tab});
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

    //grab comments when needed
    $scope.comments = function(story){
        CommentService.list(story);
    };
}]);

controllers.controller('storyHeaderCtrl',['$scope', '$state', '$filter', 'StoryStates', 'StoryService', function ($scope, $state, $filter, StoryStates, StoryService) {
    //$scope.selected is inherited from storyCtrl
    //show follow & like status
    StoryService.follow($scope.selected, true);
    StoryService.like($scope.selected, true);
    //manage display next / previous
    var list = $state.current.data.filterListParams ? $filter('filter')(StoryService.list, $state.current.data.filterListParams) : StoryService.list;
    var ind = list.indexOf($scope.selected);
    $scope.previous = ind > 0 ? list[ind - 1] : null;
    $scope.next = ind + 1 <= list.length ? list[ind + 1] : null;
    //compute progress state
    $scope.progressStates = [];
    var width = 100 / _.filter(_.keys(StoryStates), function (key) {
        return key > 0
    }).length;
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

controllers.controller('storyEditCtrl',['$scope', 'Session', function ($scope, Session) {
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
    $scope.selectTagsOptions = {
        tags:[],
        multiple:true,
        simple_tags:true,
        tokenSeparators: [",", " "],
        createSearchChoice:function (term) {
            return {id:term, text:term};
        },
        formatSelection:function(object){
            return '<a href="#finder/?tag='+object.text+'" onclick="document.location=this.href;"> <i class="fa fa-tag"></i> '+object.text+'</a>';
        },
        ajax: {
            url: 'finder/tag',
            cache: 'true',
            data: function (term) {
                return {term: term};
            },
            results: function (data) {
                var results = [];
                angular.forEach(data, function(result){
                    results.push({id:result,text:result});
                });
                return {results:results};
            }
        }
    };
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
        return !Session.roles.productOwner &&
               !Session.roles.scrumMaster &&
               Session.user.id != $scope.story.creator.id;
    }
}]);