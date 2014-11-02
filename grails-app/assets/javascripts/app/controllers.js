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

var controllers = angular.module('controllers', []);

controllers.controller('appCtrl', ['$scope', '$modal', 'Session', 'SERVER_ERRORS', 'CONTENT_LOADED' , 'Fullscreen', 'notifications', '$interval', '$timeout', '$http', function ($scope, $modal, Session, SERVER_ERRORS, CONTENT_LOADED, Fullscreen, notifications, $interval, $timeout, $http) {

    $scope.app = {
        isFullScreen:false,
        loading:10
    };

    $scope.currentUser = Session.user;
    $scope.roles = Session.roles;

    // TODO remove, user role change for dev only
    $scope.changeRole = function(newRole) {
        Session.changeRole(newRole);
    };

    $scope.showAbout = function() {
        $modal.open({ templateUrl: 'scrumOS/about' });
    };
    $scope.showProfile = function() {
        $modal.open({ templateUrl: $scope.serverUrl + '/user/openProfile', controller: 'userCtrl' });
    };
    $scope.showAuthModal = function() {
        $modal.open({
            templateUrl: $scope.serverUrl + '/login/auth',
            controller:'loginCtrl',
            size:'sm'
        });
    };

    $scope.menus = {
        visible:[],
        hidden:[]
    };

    $scope.sortableOptions = {
        items:'li.menuitem',
        connectWith:'.menubar',
        handle:'.handle'
    };

    var updateMenu = function(info){
        $http({ url: $scope.serverUrl + '/user/menu',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            transformRequest: function (data) { return formObjectData(data, ''); },
            data:info});
    };
    $scope.menuSortableUpdate = function (startModel, destModel, start, end) {
        updateMenu({id:destModel[end].id, position:end + 1, hidden:false});
    };

    $scope.menuHiddenSortableUpdate = function (startModel, destModel, start, end) {
        updateMenu({id:destModel[end].id, position:end + 1, hidden:true});
    };

    //fake loading
    var loadingAppProgress = $interval(function() {
        if ($scope.app.loading <= 80){
            $scope.app.loading += 10;
        }
    }, 100);

    //real ready app
    $scope.$on(CONTENT_LOADED, function() {
        $scope.app.loading = 90;
        $timeout(function() {
            $scope.app.loading = 100;
            $interval.cancel(loadingAppProgress);
        }, 500);
    });

    $scope.$on(SERVER_ERRORS.notAuthenticated, function(event, e) {
        $scope.showAuthModal();
    });

    $scope.$on(SERVER_ERRORS.clientError, function(event, error) {
        if (angular.isArray(error.data)) {
            notifications.error("", error.data[0].text);
        } else if (angular.isObject(error.data)) {
            notifications.error("", error.data.text);
        } else {
            notifications.error("", $scope.message('todo.is.ui.error.unknown'), options);
        }
    });

    $scope.$on(SERVER_ERRORS.serverError, function(event, error) {
        if (angular.isArray(error.data)) {
            notifications.error($scope.message('todo.is.ui.error.server'), error.data[0].text);
        } else if (angular.isObject(error.data)) {
            notifications.error($scope.message('todo.is.ui.error.server'), error.data.text);
        } else {
            notifications.error($scope.message('todo.is.ui.error.server'), $scope.message('todo.is.ui.error.unknown'));
        }
    });

    $scope.fullScreen = function(){
        if (Fullscreen.isEnabled()){
            Fullscreen.cancel();
            $scope.app.isFullScreen = false;
        }
        else {
            var el = angular.element('#main-content > div:first-of-type');
            if (el.length > 0){
                Fullscreen.enable(el[0]);
                $scope.app.isFullScreen = !$scope.app.isFullScreen;
            }
        }
    };

    $scope.print = function(data){
        var url = data;
        if (angular.isObject(data)){
            url = data.currentTarget.attributes['ng-href'] ? data.currentTarget.attributes['ng-href'].value : data.target.href;
            data.preventDefault();
        }
        var modal = $modal.open({
            templateUrl: "report.progress.html",
            size: 'sm',
            controller: ['$scope', function($scope){
                $scope.downloadFile(url);
                $scope.progress = true;
            }]
        });
        modal.result.then(
            function(result) {
                $scope.downloadFile("");
            },
            function(){
                $scope.downloadFile("");
            }
        );
    }

}]).controller('loginCtrl',['$scope', '$rootScope', 'SERVER_ERRORS', 'AuthService', function ($scope, $rootScope, SERVER_ERRORS, AuthService) {
    $scope.credentials = {
        j_username: '',
        j_password: ''
    };
    $scope.login = function (credentials) {
        AuthService.login(credentials).then(function (stuff) {
            var lastOpenedUrl = stuff.data.url;
            var normalizedCurrentLocation = window.location.href.charAt(window.location.href.length - 1) == '/' ? window.location.href.substring(0, window.location.href.length - 1) : window.location.href;
            if (normalizedCurrentLocation == $rootScope.serverUrl && lastOpenedUrl) {
                document.location = lastOpenedUrl;
            } else {
                document.location.reload(true);
            }
        }, function () {
            $rootScope.$broadcast(SERVER_ERRORS.loginFailed);
        });
    };
}]).controller('registerCtrl',['$scope', 'User', 'UserService', '$modalInstance', function ($scope, User, UserService, $modalInstance) {
    $scope.user = new User();
    $scope.register = function(){
        UserService.save($scope.user).then(function(){
            $modalInstance.close();
        });
    }
}]).controller('retrieveCtrl',['$scope', 'User', 'UserService', '$modalInstance', function ($scope, User, UserService, $modalInstance) {
    $scope.user = new User();
    $scope.retrieve = function(){
        UserService.retrievePassword($scope.user).then(function(){
            $modalInstance.close();
        });
    }

}]).controller('sandboxCtrl', ['$scope', '$state', 'StoryStatesByName', 'stories', 'StoryService', function ($scope, $state, StoryStatesByName, stories, StoryService) {
    $scope.orderBy = {
        reverse: false,
        status: false,
        current: {id:'suggestedDate', name:'Date'},
        values:[
            {id:'name', name:'Name'},
            {id:'tasks_count', name:'Tasks'},
            {id:'suggestedDate', name:'Date'},
            {id:'feature.id', name:'Feature'},
            {id:'type', name:'Type'}
        ]
    };
    $scope.goToNewStory = function() {
        $state.go('sandbox.new');
    };
    $scope.defaultStoryState = StoryStatesByName.SUGGESTED;
    $scope.selectableOptions = {
        filter:"> .postit-container",
        cancel: "a",
        stop:function(e, ui, selectedItems) {
            switch (selectedItems.length){
                case 0:
                    $state.go('sandbox.new');
                    break;
                case 1:
                    $state.go($state.params.tabId ? 'sandbox.details.tab' : 'sandbox.details', { id: selectedItems[0].id });
                    break;
                default:
                    $state.go('sandbox.multiple',{listId:_.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        } 
    };
    $scope.stories = stories;
    $scope.isSelected = function(story) {
        if ($state.params.id) {
            return $state.params.id == story.id ;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), story.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedStory = function(action, story) {
        return StoryService.authorizedStory(action, story);
    };
}]);

controllers.controller('actorsCtrl', ['$scope', '$state', 'ActorService', 'actors', function ($scope, $state, ActorService, actors) {
    $scope.orderBy = {
        reverse: false,
        status: false,
        current: {id:'dateCreated', name:'todo.Date'},
        values:[
            {id:'dateCreated', name:'todo.Date'},
            {id:'name', name:'todo.Name'},
            {id:'stories_ids.length', name:'todo.Stories'}
        ]
    };
    $scope.goToNewActor = function() {
        $state.go('actor.new');
    };
    $scope.selectableOptions = {
        filter:"> .postit-container",
        cancel: "a",
        stop:function(e, ui, selectedItems) {
            switch (selectedItems.length){
                case 0:
                    $state.go('actor.new');
                    break;
                case 1:
                    $state.go($state.params.tabId ? 'actor.details.tab' : 'actor.details', { id: selectedItems[0].id });
                    break;
                default:
                    $state.go('actor.multiple',{listId:_.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        }
    };
    $scope.actors = actors;
    $scope.isSelected = function(feature) {
        if ($state.params.id) {
            return $state.params.id == feature.id ;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), feature.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedActor = function(action) {
        return ActorService.authorizedActor(action);
    };
}]);

controllers.controller('featuresCtrl', ['$scope', '$state', 'FeatureService', 'features', function ($scope, $state, FeatureService, features) {
    $scope.orderBy = {
        reverse: false,
        status: false,
        current: {id:'dateCreated', name:'todo.Date'},
        values:[
            {id:'dateCreated', name:'todo.Date'},
            {id:'name', name:'todo.Name'},
            {id:'stories_ids.length', name:'todo.Stories'},
            {id:'value', name:'todo.Value'}
        ]
    };
    $scope.goToNewFeature = function() {
        $state.go('feature.new');
    };
    $scope.selectableOptions = {
        filter:"> .postit-container",
        cancel: "a",
        stop:function(e, ui, selectedItems) {
            switch (selectedItems.length){
                case 0:
                    $state.go('feature.new');
                    break;
                case 1:
                    $state.go($state.params.tabId ? 'feature.details.tab' : 'feature.details', { id: selectedItems[0].id });
                    break;
                default:
                    $state.go('feature.multiple',{listId:_.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        }
    };
    $scope.features = features;
    $scope.isSelected = function(feature) {
        if ($state.params.id) {
            return $state.params.id == feature.id ;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), feature.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
}]);