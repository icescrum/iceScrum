controllers.controller("widgetCtrl", ['$scope', 'WidgetService', function($scope, WidgetService) {
    $scope.toggleSettings = function(widget) {
        $scope.showSettings = !$scope.showSettings;
    };

    $scope.update = function(widget) {
        WidgetService.update(widget);
    };

    $scope.delete = function(widget) {
        WidgetService.delete(widget);
    };
}]);