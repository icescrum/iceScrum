/**
 * BEEN CUSTOMISEDDDDD !!! Easy to use Wizard library for AngularJS
 * @version v0.4.2 - 2015-01-01 * @link https://github.com/mgonto/angular-wizard
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
            "    <ul class=\"steps-indicator col-sm-3 steps-{{steps.length}} nav nav-list\" ng-if=\"!hideIndicators\">\n" +
            "      <li ng-class=\"{default: !step.completed && !step.selected, current: step.selected && !step.completed, done: step.completed && !step.selected, editing: step.selected && step.completed}\" ng-repeat=\"step in steps\">\n" +
            "        <a ng-click=\"goTo(step)\"><i ng-if=\"step.icon\" class=\"{{ step.icon }}\"></i> <i class=\"fa fa-check text-success\" ng-show=\"step.completed\"></i> {{step.title || step.wzTitle}}</a>\n" +
            "      </li>\n" +
            "    </ul>\n" +
            "    <div class=\"steps col-sm-9\" ng-transclude></div>\n" +
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
            title: '@',
            canenter : '=',
            canexit : '=',
            icon: '@'
        },
        require: '^wizard',
        templateUrl: function(element, attributes) {
            return attributes.template || "step.html";
        },
        link: function($scope, $element, $attrs, wizard) {
            $scope.title = $scope.title || $scope.wzTitle;
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
        controller: ['$scope', '$element', '$log', 'WizardHandler', function($scope, $element, $log, WizardHandler) {

            var firstRun = true;
            WizardHandler.addWizard($scope.name || WizardHandler.defaultName, this);
            $scope.$on('$destroy', function() {
                WizardHandler.removeWizard($scope.name || WizardHandler.defaultName);
            });

            $scope.steps = [];

            $scope.context = {};

            $scope.$watch('currentStep', function(step) {
                if (!step) return;
                var stepTitle = $scope.selectedStep.title || $scope.selectedStep.wzTitle;
                if ($scope.selectedStep && stepTitle !== $scope.currentStep) {
                    $scope.goTo(_.find($scope.steps, {title: $scope.currentStep}));
                }

            });

            $scope.$watch('[editMode, steps.length]', function() {
                var editMode = $scope.editMode;
                if (_.isUndefined(editMode) || _.isNull(editMode)) return;

                if (editMode) {
                    _.each($scope.steps, function(step) {
                        step.completed = true;
                    });
                }
            }, true);

            this.addStep = function(step) {
                $scope.steps.push(step);
                if ($scope.steps.length === 1) {
                    $scope.goTo($scope.steps[0]);
                }
            };

            this.context = $scope.context;

            $scope.getStepNumber = function(step) {
                return _.indexOf($scope.steps, step) + 1;
            };

            $scope.goTo = function(step) {
                if(firstRun){
                    unselectAll();
                    $scope.selectedStep = step;
                    if (!_.isUndefined($scope.currentStep)) {
                        $scope.currentStep = step.title || step.wzTitle;
                    }
                    step.selected = true;
                    $scope.$emit('wizard:stepChanged', {step: step, index: _.indexOf($scope.steps , step)});
                    firstRun = false;
                } else {
                    var thisStep;
                    var exitallowed = false;
                    var enterallowed = false;
                    if($scope.currentStepNumber() > 0){
                        thisStep = $scope.currentStepNumber() - 1;
                    } else if ($scope.currentStepNumber() === 0){
                        thisStep = 0;
                    }
                    if(typeof($scope.steps[thisStep].canexit) === 'undefined' || $scope.steps[thisStep].canexit($scope.context) === true){
                        exitallowed = true;
                    }
                    if($scope.getStepNumber(step) < $scope.currentStepNumber()){
                        exitallowed = true;
                    }
                    if(exitallowed && step.canenter === undefined || exitallowed && step.canenter($scope.context) === true){
                        enterallowed = true;
                    }

                    if(exitallowed && enterallowed){
                        unselectAll();

                        $scope.selectedStep = step;
                        if (!_.isUndefined($scope.currentStep)) {
                            $scope.currentStep = step.title || step.wzTitle;
                        }
                        step.selected = true;
                        $scope.$emit('wizard:stepChanged', {step: step, index: _.indexOf($scope.steps , step)});
                    } else {
                        return;
                    }
                }
            };

            $scope.currentStepNumber = function() {
                return _.indexOf($scope.steps , $scope.selectedStep) + 1;
            };

            function unselectAll() {
                _.each($scope.steps, function (step) {
                    step.selected = false;
                });
                $scope.selectedStep = null;
            }

            this.currentStepNumber = function(){
                return $scope.currentStepNumber();
            };
            this.next = function(callback) {
                var index = _.indexOf($scope.steps , $scope.selectedStep);
                if(angular.isFunction(callback)){
                    if(callback()){
                        if (index === $scope.steps.length - 1) {
                            this.finish();
                        } else {
                            $scope.goTo($scope.steps[index + 1]);
                        }
                    } else {
                        return;
                    }
                }
                if (!callback) {
                    $scope.selectedStep.completed = true;
                }
                if (index === $scope.steps.length - 1) {
                    this.finish();
                } else {
                    $scope.goTo($scope.steps[index + 1]);
                }
            };

            this.goTo = function(step) {
                var stepTo;
                if (_.isNumber(step)) {
                    stepTo = $scope.steps[step];
                } else {
                    stepTo = _.find($scope.steps, {title: step});
                }
                $scope.goTo(stepTo);
            };

            this.finish = function() {
                if ($scope.onFinish) {
                    $scope.onFinish();
                }
            };

            this.cancel = this.previous = function() {
                var index = _.indexOf($scope.steps , $scope.selectedStep);
                if (index === 0) {
                    throw new Error("Can't go back. It's already in step 0");
                } else {
                    $scope.goTo($scope.steps[index - 1]);
                }
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
