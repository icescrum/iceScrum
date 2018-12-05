/**
 * BEEN CUSTOMISEDDDDD !!!Easy to use Wizard library for AngularJS
 * @version v0.6.1 - 2015-12-31 * @link https://github.com/mgonto/angular-wizard
 * @author Martin Gontovnikas <martin@gon.to>
 * @license MIT License, http://www.opensource.org/licenses/MIT
 */
angular.module('templates-angularwizard', ['step.html', 'wizard.html']);

angular.module("step.html", []).run(["$templateCache", function($templateCache) {
    $templateCache.put("step.html",
        "<section ng-show=\"selected\" ng-class=\"{current: selected, done: completed}\" class=\"step\" ng-transclude>\n" +
        "</section>");
}]);

angular.module("wizard.html", []).run(["$templateCache", function($templateCache) {
    $templateCache.put("wizard.html",
        "<div>\n" +
        "   <div class=\"left-card col-xs-12 col-sm-3\">\n" +
        "       <ul class=\"left-card-body steps-{{getEnabledSteps().length}} nav nav-list\" ng-if=\"!hideIndicators\">\n" +
        "           <li ng-class=\"{default: !step.completed && !step.selected, current: step.selected && !step.completed, done: step.completed && !step.selected, editing: step.selected && step.completed}\" ng-repeat=\"step in getEnabledSteps()\">\n" +
        "               <a ng-click=\"goTo(step)\"><i ng-if=\"step.icon\" class=\"{{ step.icon }}\"></i> <i class=\"fa fa-check text-success hidden-xs\" ng-show=\"step.completed\"></i> <span class=\"hidden-xs\">{{step.title || step.wzTitle}}</span></a>\n" +
        "           </li>\n" +
        "       </ul>\n" +
        "   </div>\n" +
        "   <div class=\"right-card steps col-xs-12 col-sm-9\" ng-transclude></div>\n" +
        "</div>\n" +
        "");
}]);

angular.module('mgo-angular-wizard', ['templates-angularwizard']);

angular.module('mgo-angular-wizard').directive('wzStep', function() {
    return {
        restrict: 'EA',
        replace: true,
        transclude: true,
        scope: {
            wzTitle: '@',
            canenter: '=',
            canexit: '=',
            icon: '@',
            disabled: '@?wzDisabled',
            description: '@',
            wzData: '='
        },
        require: '^wizard',
        templateUrl: function(element, attributes) {
            return attributes.template || "step.html";
        },
        link: function($scope, $element, $attrs, wizard) {
            $scope.title = $scope.wzTitle;
            wizard.addStep($scope);
        }
    };
});

angular.module('mgo-angular-wizard').directive('wizard', function() {
    return {
        restrict: 'EA',
        replace: true,
        transclude: true,
        scope: {
            currentStep: '=',
            onFinish: '&',
            hideIndicators: '=',
            editMode: '=',
            name: '@'
        },
        templateUrl: function(element, attributes) {
            return attributes.template || "wizard.html";
        },

        controller: ['$scope', '$element', '$log', 'WizardHandler', '$q', function($scope, $element, $log, WizardHandler, $q) {
            var firstRun = true;
            WizardHandler.addWizard($scope.name || WizardHandler.defaultName, this);
            $scope.$on('$destroy', function() {
                WizardHandler.removeWizard($scope.name || WizardHandler.defaultName);
            });

            $scope.steps = [];

            var stepIdx = function(step) {
                var idx = 0;
                var res = -1;
                angular.forEach($scope.getEnabledSteps(), function(currStep) {
                    if (currStep === step) {
                        res = idx;
                    }
                    idx++;
                });
                return res;
            };

            var stepByTitle = function(titleToFind) {
                var foundStep = null;
                angular.forEach($scope.getEnabledSteps(), function(step) {
                    if (step.wzTitle === titleToFind) {
                        foundStep = step;
                    }
                });
                return foundStep;
            };

            $scope.context = {};

            $scope.$watch('currentStep', function(step) {
                if (!step) return;
                var stepTitle = $scope.selectedStep.wzTitle;
                if ($scope.selectedStep && stepTitle !== $scope.currentStep) {
                    $scope.goTo(stepByTitle($scope.currentStep));
                }

            });

            $scope.$watch('[editMode, steps.length]', function() {
                var editMode = $scope.editMode;
                if (angular.isUndefined(editMode) || (editMode === null)) return;

                if (editMode) {
                    angular.forEach($scope.getEnabledSteps(), function(step) {
                        step.completed = true;
                    });
                } else {
                    var completedStepsIndex = $scope.currentStepNumber() - 1;
                    angular.forEach($scope.getEnabledSteps(), function(step, stepIndex) {
                        if (stepIndex >= completedStepsIndex) {
                            step.completed = false;
                        }
                    });
                }
            }, true);

            this.addStep = function(step) {
                $scope.steps.push(step);
                if ($scope.getEnabledSteps().length === 1) {
                    $scope.goTo($scope.getEnabledSteps()[0]);
                }
            };

            this.context = $scope.context;

            $scope.getStepNumber = function(step) {
                return stepIdx(step) + 1;
            };

            $scope.goTo = function(step) {
                if (firstRun) {
                    unselectAll();
                    $scope.selectedStep = step;
                    if (!angular.isUndefined($scope.currentStep)) {
                        $scope.currentStep = step.wzTitle;
                    }
                    step.selected = true;
                    $scope.$emit('wizard:stepChanged', {step: step, index: stepIdx(step)});
                    firstRun = false;
                } else {
                    var thisStep;
                    if ($scope.currentStepNumber() > 0) {
                        thisStep = $scope.currentStepNumber() - 1;
                    } else if ($scope.currentStepNumber() === 0) {
                        thisStep = 0;
                    }
                    $q.all([canExitStep($scope.getEnabledSteps()[thisStep], step), canEnterStep(step)]).then(function(data) {
                        if (data[0] && data[1]) {
                            unselectAll();

                            $scope.selectedStep = step;
                            if (!angular.isUndefined($scope.currentStep)) {
                                $scope.currentStep = step.wzTitle;
                            }
                            step.selected = true;
                            $scope.$emit('wizard:stepChanged', {step: step, index: stepIdx(step)});
                        }
                    });
                }
            };

            function canEnterStep(step) {
                var defer,
                    canEnter;
                if (step.canenter === undefined) {
                    return true;
                }
                if (typeof step.canenter === 'boolean') {
                    return step.canenter;
                }
                canEnter = step.canenter($scope.context);
                if (angular.isFunction(canEnter.then)) {
                    defer = $q.defer();
                    canEnter.then(function(response) {
                        defer.resolve(response);
                    });
                    return defer.promise;
                } else {
                    return canEnter === true;
                }
            }

            function canExitStep(step, stepTo) {
                var defer,
                    canExit;
                if (typeof(step.canexit) === 'undefined' || $scope.getStepNumber(stepTo) < $scope.currentStepNumber()) {
                    return true;
                }
                if (typeof step.canexit === 'boolean') {
                    return step.canexit;
                }
                canExit = step.canexit($scope.context);
                if (angular.isFunction(canExit.then)) {
                    defer = $q.defer();
                    canExit.then(function(response) {
                        defer.resolve(response);
                    });
                    return defer.promise;
                } else {
                    return canExit === true;
                }
            }

            $scope.currentStepNumber = function() {
                return stepIdx($scope.selectedStep) + 1;
            };

            $scope.getEnabledSteps = function() {
                return $scope.steps.filter(function(step) {
                    return step.disabled !== 'true';
                });
            };

            function unselectAll() {
                angular.forEach($scope.getEnabledSteps(), function(step) {
                    step.selected = false;
                });
                $scope.selectedStep = null;
            }

            this.currentStepTitle = function() {
                return $scope.selectedStep.wzTitle;
            };

            this.currentStepDescription = function() {
                return $scope.selectedStep.description;
            };

            this.currentStep = function() {
                return $scope.selectedStep;
            };

            this.totalStepCount = function() {
                return $scope.getEnabledSteps().length;
            }

            this.getEnabledSteps = function() {
                return $scope.getEnabledSteps();
            };

            this.currentStepNumber = function() {
                return $scope.currentStepNumber();
            };
            this.next = function(callback) {
                var enabledSteps = $scope.getEnabledSteps();
                var index = stepIdx($scope.selectedStep);
                if (angular.isFunction(callback)) {
                    if (callback()) {
                        if (index === enabledSteps.length - 1) {
                            this.finish();
                        } else {
                            $scope.goTo(enabledSteps[index + 1]);
                        }
                    } else {
                        return;
                    }
                }
                if (!callback) {
                    $scope.selectedStep.completed = true;
                }
                if (index === enabledSteps.length - 1) {
                    this.finish();
                } else {
                    $scope.goTo(enabledSteps[index + 1]);
                }
            };

            this.goTo = function(step) {
                var enabledSteps = $scope.getEnabledSteps();
                var stepTo;
                if (angular.isNumber(step)) {
                    stepTo = enabledSteps[step];
                } else {
                    stepTo = stepByTitle(step);
                }
                $scope.goTo(stepTo);
            };

            this.finish = function() {
                if ($scope.onFinish) {
                    $scope.onFinish();
                }
            };

            this.previous = function() {
                var index = stepIdx($scope.selectedStep);
                if (index === 0) {
                    throw new Error("Can't go back. It's already in step 0");
                } else {
                    $scope.goTo($scope.getEnabledSteps()[index - 1]);
                }
            };

            this.cancel = function() {
                var index = stepIdx($scope.selectedStep);
                if (index === 0) {
                    throw new Error("Can't go back. It's already in step 0");
                } else {
                    $scope.goTo($scope.getEnabledSteps()[0]);
                }
            };

            this.reset = function() {
                angular.forEach($scope.getEnabledSteps(), function(step) {
                    step.completed = false;
                });
                this.goTo(0);
            };
        }]
    };
});

function wizardButtonDirective(action) {
    angular.module('mgo-angular-wizard')
        .directive(action, function() {
            return {
                restrict: 'A',
                replace: false,
                require: '^wizard',
                link: function($scope, $element, $attrs, wizard) {

                    $element.on("click", function(e) {
                        e.preventDefault();
                        $scope.$apply(function() {
                            $scope.$eval($attrs[action]);
                            wizard[action.replace("wz", "").toLowerCase()]();
                        });
                    });
                }
            };
        });
}

wizardButtonDirective('wzNext');
wizardButtonDirective('wzPrevious');
wizardButtonDirective('wzFinish');
wizardButtonDirective('wzCancel');
wizardButtonDirective('wzReset');

angular.module('mgo-angular-wizard').factory('WizardHandler', function() {
    var service = {};

    var wizards = {};

    service.defaultName = "defaultWizard";

    service.addWizard = function(name, wizard) {
        wizards[name] = wizard;
    };

    service.removeWizard = function(name) {
        delete wizards[name];
    };

    service.wizard = function(name) {
        var nameToUse = name;
        if (!name) {
            nameToUse = service.defaultName;
        }
        return wizards[nameToUse];
    };

    return service;
});
