$scope.selectProject = function(project) {
    if (project.portfolio) {
        return;
    }
    var promise;
    if (project.id) {
        promise = $q.when(project);
    } else {
        project.pkey = _.upperCase(project.name).replace(/\W+/g, "").substring(0, 10);
        promise = addNewProject(project);
    }
    promise.then(function(project) {
        $scope.formHolder.projectSelection = null;
        if (project) {
            $scope.portfolio.projects.push(project);
        }
    });
};
var addNewProject = function(project) {
    return $uibModal.open({
        keyboard: false,
        backdrop: 'static',
        templateUrl: $rootScope.serverUrl + "/project/add",
        size: 'lg',
        controller: 'newProjectCtrl',
        resolve: {
            manualSave: true,
            lastStepButtonLabel: function() {
                return $scope.message('is.ui.apps.portfolio.add.project');
            },
            projectTemplate: function() {
                var template = _.find($scope.portfolio.projects, function(project) { return project.id === undefined; });
                if (template) {
                    template = angular.copy(template);
                    var templatePreferences = angular.copy(template.preferences);
                    return {
                        name: project ? project.name : '',
                        pkey: project ? project.pkey : '',
                        initialize: template.initialize ? template.initialize : '',
                        startDate: template.startDate,
                        endDate: template.endDate,
                        firstSprint: template.firstSprint,
                        vision: template.vision, //good idea?
                        planningPokerGameType: template.planningPokerGameType,
                        preferences: templatePreferences
                    }
                } else {
                    return {
                        name: project ? project.name : '',
                        pkey: project ? project.pkey : ''
                    };
                }
            }
        }
    }).result.then(function(project) {
        if (project) {
            return ProjectService.save(project).then(function(project) {
                project.new = true;
            });
        } else {
            return null;
        }
    });
};

$scope.alertCancelDeletableProjects = function(deletableProjects, callback) {
    $uibModal.open({
        keyboard: false,
        backdrop: 'static',
        templateUrl: "confirm.portfolio.cancel.modal.html",
        size: 'md',
        controller: ['$scope', function($scope) {
            // Functions
            $scope.confirmDelete = function() {
                $scope.$close(_.filter($scope.deletableProjects, {delete: true}));
            };
            // Init
            _.each(deletableProjects, function(project) {
                project.delete = true;
            });
            $scope.deletableProjects = deletableProjects;
        }]
    }).result.then(function(projectsToDelete) {
        if (projectsToDelete) {
            $scope.removeProjects(projectsToDelete);
        }
        if (projectsToDelete !== undefined && _.isFunction(callback)) {
            callback();
        }
    });
};
// Init
$scope.synchronizationHolder = {};
$scope.$watchCollection('portfolio.projects', function(projects) {
    PortfolioService.getSynchronizedProjects(projects).then(function(synchronizationData) {
        $scope.synchronizationHolder = synchronizationData;
    });
});