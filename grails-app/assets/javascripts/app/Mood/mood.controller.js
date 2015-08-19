controllers.controller('moodCtrl', ['$scope', 'MoodService', function ($scope, MoodService) {

    $scope.save = function (mood) {
        MoodService.save(mood).then(function (mood) {
            $scope.newMood = {};
            $scope.mood = mood;
            $scope.mood.push(mood);
        })
    }
}]);
controllers.controller( 'Ctrldate', ['$scope', function($scope) {
    $scope.date = new Date();
}]);


