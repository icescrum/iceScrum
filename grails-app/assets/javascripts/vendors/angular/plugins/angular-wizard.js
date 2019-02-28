/**
 * Easy to use Wizard library for Angular JS
 * @version v1.1.1 - 2017-06-07 * @link https://github.com/mgonto/angular-wizard
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
        "    <h2 ng-show=\"selectedStep.wzHeadingTitle != ''\">{{ selectedStep.wzHeadingTitle }}</h2>\n" +
        "\n" +
        "    <div class=\"steps\" ng-if=\"indicatorsPosition === 'bottom'\" ng-transclude></div>\n" +
        "    <ul class=\"steps-indicator steps-{{getEnabledSteps().length}}\" ng-if=\"!hideIndicators\">\n" +
        "      <li ng-class=\"{default: !step.completed && !step.selected, current: step.selected && !step.completed, done: step.completed && !step.selected, editing: step.selected && step.completed}\" ng-repeat=\"step in getEnabledSteps()\">\n" +
        "        <a ng-click=\"goTo(step)\">{{step.title || step.wzTitle}}</a>\n" +
        "      </li>\n" +
        "    </ul>\n" +
        "    <div class=\"steps\" ng-if=\"indicatorsPosition === 'top'\" ng-transclude></div>\n" +
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
            wzHeadingTitle: '@',
            canenter : '=',
            canexit : '=',
            disabled: '@?wzDisabled',
            description: '@',
            wzData: '=',
            wzOrder: '@?'
        },
        require: '^wizard',
        templateUrl: function(element, attributes) {
            return attributes.template || "step.html";
        },
        link: function ($scope, $element, $attrs, wizard) {
            $attrs.$observe('wzTitle', function (value) {
                $scope.title = $scope.wzTitle;
            });
            $scope.title = $scope.wzTitle;
            wizard.addStep($scope);
            $scope.$on('$destroy', function(){
                wizard.removeStep($scope);
            });
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
            onCancel: '&',
            onFinish: '&',
            hideIndicators: '=',
            editMode: '=',
            name: '@',
            indicatorsPosition: '@?'
        },
        templateUrl: function(element, attributes) {
            return attributes.template || "wizard.html";
        },

        controller: ['$scope', '$element', '$log', 'WizardHandler', '$q', '$timeout', function ($scope, $element, $log, WizardHandler, $q, $timeout) {
            if ($scope.indicatorsPosition == undefined) {
                $scope.indicatorsPosition = 'bottom';
            }
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


            var handleEditModeChange = function() {
                var editMode = $scope.editMode;
                if (angular.isUndefined(editMode) || (editMode === null)) return;

                angular.forEach($scope.steps, function (step) {
                    step.completed = editMode;
                });

                if (!editMode) {
                    var completedStepsIndex = $scope.currentStepNumber() - 1;
                    angular.forEach($scope.getEnabledSteps(), function(step, stepIndex) {
                        if(stepIndex < completedStepsIndex) {
                            step.completed = true;
                        }
                    });
                }
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
                handleEditModeChange();
            }, true);

            this.addStep = function(step) {
                var wzOrder = (step.wzOrder >= 0 && !$scope.steps[step.wzOrder]) ? step.wzOrder : $scope.steps.length;
                $scope.steps[wzOrder] = step;
                if ($scope.getEnabledSteps()[0] === step) {
                    $scope.goTo($scope.getEnabledSteps()[0]);
                }
            };

            this.removeStep = function (step) {
                var index = $scope.steps.indexOf(step);
                if (index > 0) {
                    $scope.steps.splice(index, 1);
                }
            };

            this.context = $scope.context;

            $scope.getStepNumber = function(step) {
                return stepIdx(step) + 1;
            };

            $scope.goTo = function(step) {
                if(firstRun){
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
                    if($scope.currentStepNumber() > 0){
                        thisStep = $scope.currentStepNumber() - 1;
                    } else if ($scope.currentStepNumber() === 0){
                        thisStep = 0;
                    }
                    $q.all([canExitStep($scope.getEnabledSteps()[thisStep], step), canEnterStep(step)]).then(function(data) {
                        if(data[0] && data[1]){
                            unselectAll();

                            $scope.selectedStep = step;
                            if(!angular.isUndefined($scope.currentStep)){
                                $scope.currentStep = step.wzTitle;
                            }
                            step.selected = true;
                            $scope.$emit('wizard:stepChanged', {step: step, index: stepIdx(step)});
                        } else {
                            $scope.$emit('wizard:stepChangeFailed', {step: step, index: _.indexOf($scope.getEnabledSteps(), step)});
                        }
                    });
                }
            };

            function canEnterStep(step) {
                var defer;
                var canEnter;
                if(step.canenter === undefined){
                    return true;
                }
                if(typeof step.canenter === 'boolean'){
                    return step.canenter;
                }
                if(typeof step.canenter === 'string'){
                    var splitFunction = step.canenter.split('(');
                    canEnter = eval('$scope.$parent.' + splitFunction[0] + '($scope.context' + splitFunction[1])
                } else {
                    canEnter = step.canenter($scope.context);
                }
                if(angular.isFunction(canEnter.then)){
                    defer = $q.defer();
                    canEnter.then(function(response){
                        defer.resolve(response);
                    });
                    return defer.promise;
                } else {
                    return canEnter === true;
                }
            }

            function canExitStep(step, stepTo) {
                var defer;
                var canExit;
                if(typeof(step.canexit) === 'undefined' || $scope.getStepNumber(stepTo) < $scope.currentStepNumber()){
                    return true;
                }
                if(typeof step.canexit === 'boolean'){
                    return step.canexit;
                }
                if(typeof step.canexit === 'string'){
                    var splitFunction = step.canexit.split('(');
                    canExit = eval('$scope.$parent.' + splitFunction[0] + '($scope.context' + splitFunction[1])
                } else {
                    canExit = step.canexit($scope.context);
                }
                if(angular.isFunction(canExit.then)){
                    defer = $q.defer();
                    canExit.then(function(response){
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
                return $scope.steps.filter(function(step){
                    return step && step.disabled !== 'true';
                });
            };

            function unselectAll() {
                angular.forEach($scope.getEnabledSteps(), function (step) {
                    step.selected = false;
                });
                $scope.selectedStep = null;
            }

            this.currentStepTitle = function(){
                return $scope.selectedStep.wzTitle;
            };

            this.currentStepDescription = function(){
                return $scope.selectedStep.description;
            };

            this.currentStep = function(){
                return $scope.selectedStep;
            };

            this.totalStepCount = function() {
                return $scope.getEnabledSteps().length;
            };

            this.getEnabledSteps = function(){
                return $scope.getEnabledSteps();
            };

            this.currentStepNumber = function(){
                return $scope.currentStepNumber();
            };
            this.next = function(callback) {
                var enabledSteps = $scope.getEnabledSteps();
                var index = stepIdx($scope.selectedStep);
                if(angular.isFunction(callback)){
                    if(callback()){
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
                $timeout(function() {
                    var enabledSteps = $scope.getEnabledSteps();
                    var stepTo;
                    if (angular.isNumber(step)) {
                        stepTo = enabledSteps[step];
                    } else {
                        stepTo = stepByTitle(step);
                    }
                    $scope.goTo(stepTo);
                });
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
                if ($scope.onCancel) {
                    $scope.onCancel();
                } else {
                    var index = stepIdx($scope.selectedStep);
                    if (index === 0) {
                        throw new Error("Can't go back. It's already in step 0");
                    } else {
                        $scope.goTo($scope.getEnabledSteps()[0]);
                    }
                }
            };

            this.reset = function(){
                angular.forEach($scope.getEnabledSteps(), function (step) {
                    step.completed = false;
                });
                this.goTo(0);
            };

            this.setEditMode = function(mode) {
                $scope.editMode = mode;
                handleEditModeChange();
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