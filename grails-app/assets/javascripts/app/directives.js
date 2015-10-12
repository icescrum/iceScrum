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

var directives = angular.module('directives', []);
directives.directive('focusMe', ["$timeout", function($timeout) {
    return {
        scope: { trigger: '@focusMe' },
        link: function(scope, element) {
            scope.$watch('trigger', function(value) {
                if(value === "true") {
                    $timeout(function() {
                        element[0].focus();
                    });
                }
            });
        }
    };
}]).directive('isMarkitup', ['$http', function($http) {
    return {
        restrict: 'A',
        scope: {
            show:  '=ngShow',
            html:  '=isModelHtml',
            model: '=ngModel'
        },
        link: function(scope, element, attrs) {
            var settings = $.extend({
                    resizeHandle:false,
                    scrollContainer:'#main-content .details:first',
                    afterInsert: function() {
                        element.triggerHandler('input');
                    }
                },
                textileSettings);
            var markitup = element.markItUp(settings);
            var container = markitup.parents('.markItUp');
            container.hide();

            scope.$watch('show', function(value) {
                if (value === true){
                    container.show();
                    setTimeout(function(){
                        element[0].focus();
                    }, 50);
                } else {
                    container.hide();
                }
            });
            element.bind('blur', function() {
                var val = element.val();
                scope.$apply($http({
                    method: 'POST',
                    url: 'textileParser',
                    headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
                    data: 'data='+val
                }).success(function(data) {
                    scope.html = data;
                }));
            });
        }
    };
}]).directive('fixed', [function() {
    return {
        restrict: 'A',
        scope: {},
        link: function(scope, element, attrs) {
            var $this = element;
            var container = $(attrs['fixed']);
            var initialTop = element.offset().top - container.offset().top + container.scrollTop();
            var id = 'scroll.fixed'+(new Date().getTime());
            var idR = 'resize.fixed'+(new Date().getTime());
            var fixedFunction = function(event, manual) {
                //remove event
                $this.removeClass('hidden');

                if (!$this.is(':visible')){
                    container.off( id );
                    $(window).off( idR );
                    return;
                }
                if(attrs['fixedBottom']){
                    $this.css('width', $this.parent().outerWidth(true) + parseInt(attrs['fixedOffsetWidth'] ?  attrs['fixedOffsetWidth'] : 0))
                        .css('left', container.offset().left + parseInt((attrs['fixedOffsetLeft'] ?  attrs['fixedOffsetLeft'] : 0)))
                        .css('top', $(window).height() - $this.height() - parseInt((attrs['fixedOffsetBottom'] ?  attrs['fixedOffsetBottom'] : 0)))
                    if (!$this.hasClass('fixed')){
                        container.addClass('has-fixed-bottom');
                        $this.css('position', 'fixed');
                        $this.addClass('fixed');
                    }
                }else {
                    var scrollTop = container.scrollTop();
                    if(manual || (initialTop - scrollTop < 0)){
                        $this.css('width', $this.parent().outerWidth(true) + parseInt(attrs['fixedOffsetWidth'] ?  attrs['fixedOffsetWidth'] : 0))
                            .css('left', container.offset().left + parseInt((attrs['fixedOffsetLeft'] ?  attrs['fixedOffsetLeft'] : 0)));
                        if (!$this.hasClass('fixed')){
                            $this.addClass('fixed')
                                .css('top', container.offset().top + parseInt((attrs['fixedOffsetTop'] ?  attrs['fixedOffsetTop'] : 0)))
                                .css('position', 'fixed');
                            container.addClass('has-fixed-top');
                        }
                    } else if (initialTop - scrollTop >= 0 && $this.hasClass('fixed')) {
                        $this.removeClass('fixed')
                            .css('top', '')
                            .css('width', '')
                            .css('left','')
                            .css('position', '');
                        $this.next().css('margin-top', '');
                        container.removeClass('has-fixed-top');
                    }
                }
            };

            container.on(id, fixedFunction);
            container.scroll();

            //when resize
            $(window).on(idR, function(e) {
                fixedFunction(e);
            }).resize();

            //when transition
            $('#main').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',
                function(e) {
                    fixedFunction(null);
                }
            );
        }
    };
}]).directive('showValidation', ['$compile', '$rootScope', function($compile, $rootScope) {
    return {
        restrict: "A",
        link: function(scope, element, attrs) {
            scope.$watch(function() {
                return scope.$eval(attrs.name);
            }, function(form, oldForm) {
                var inputs = element.find('input[ng-model]:not([validation-watched]), textarea[ng-model]:not([validation-watched])');
                angular.forEach(inputs, function(it) {
                    var input = angular.element(it);
                    input.attr('validation-watched','');
                    var container = input.parent();
                    if (container.hasClass('input-group')) {
                        container = container.parent();
                    }
                    var inputModel = form[input.attr('name')];
                    scope.$watch(function() {
                        return inputModel.$invalid && (inputModel.$dirty || inputModel.$touched);
                    }, function(newIsInvalid, oldIsInvalid) {
                        if (newIsInvalid && !oldIsInvalid) {
                            var childScope = scope.$new();
                            childScope.inputModel = inputModel;
                            childScope.errorMessages = function(errors) {
                                return  _.transform(errors, function(errorMessages, value, key) {
                                    if (value) {
                                        var name = input.siblings("label[for='" + input.attr('name') + "']").text();
                                        var errorMessage = '';
                                        if (key == 'required') {
                                            errorMessage = $rootScope.message('default.blank.message');
                                        } else if (key == 'min') {
                                            errorMessage = $rootScope.message('default.invalid.min.message', ['', '', '', input.attr(key)]);
                                        } else if (key == 'max') {
                                            errorMessage = $rootScope.message('default.invalid.max.message', ['', '', '', input.attr(key)]);
                                        } else if (key == 'minlength') {
                                            errorMessage = $rootScope.message('default.invalid.min.size.message', ['', '', '', input.attr('ng-' + key)]);
                                        } else if (key == 'maxlength') {
                                            errorMessage = $rootScope.message('default.invalid.max.size.message', ['', '', '', input.attr('ng-' + key)]);
                                        } else if (key == 'pattern') {
                                            errorMessage = $rootScope.message('default.doesnt.match.message', ['', '', '', input.attr('ng-' + key)]);
                                        } else if (key == 'url') {
                                            errorMessage = $rootScope.message('default.invalid.url.message');
                                        } else if (key == 'email') {
                                            errorMessage = $rootScope.message('default.invalid.email.message');
                                        } else if (key == 'number') {
                                            errorMessage = $rootScope.message('typeMismatch.java.lang.Integer');
                                        } else if (key == 'match') {
                                            errorMessage = $rootScope.message('is.user.password.check');
                                        } else if (key == 'unique') {
                                            errorMessage = $rootScope.message('default.unique.message');
                                        }
                                        errorMessages.push(errorMessage);
                                    }
                                }, []);
                            };
                            childScope.input = input;
                            container.addClass('has-error');
                            var template = '<div class="help-block bg-danger"><span ng-repeat="errorMessage in errorMessages(inputModel.$error)">{{ errorMessage }}</span></div>';
                            var compiledTemplate = angular.element($compile(template)(childScope));
                            container.append(compiledTemplate);
                        } else if (!newIsInvalid && oldIsInvalid) {
                            container.removeClass('has-error');
                            container.find('.help-block').remove();
                        }
                    });
                });
            }, true);
        }
    }
}]).directive('notMatch', function () {
    return {
        require: 'ngModel',
        restrict: 'A',
        scope: {
            notMatch: '='
        },
        link: function(scope, elem, attrs, ngModel) {
            ngModel.$validators.notMatch = function(modelValue, viewValue) {
                var value = modelValue || viewValue;
                var notMatch = scope.notMatch;
                return value != notMatch;
            };
            scope.$watch('notMatch', function() {
                ngModel.$validate();
            });
        }
    };
}).directive('isMatch', function () {
    return {
        require: 'ngModel',
        restrict: 'A',
        scope: {
            isMatch: '='
        },
        link: function(scope, elem, attrs, ngModel) {
            ngModel.$validators.isMatch = function(modelValue, viewValue) {
                var value = modelValue || viewValue;
                var isMatch = scope.isMatch;
                return value === isMatch;
            };
            scope.$watch('isMatch', function() {
                ngModel.$validate();
            });
        }
    };
}).directive('formAutofillFix', ['$timeout', function($timeout) {
    return function (scope, element, attrs) {
        element.prop('method', 'post');
        if (attrs.ngSubmit) {
            $timeout(function () {
                element
                    .unbind('submit')
                    .bind('submit', function (event) {
                        event.preventDefault();
                        element
                            .find('input, textarea, select')
                            .trigger('input')
                            .trigger('change')
                            .trigger('keydown');
                        scope.$apply(attrs.ngSubmit);
                    });
            });
        }
    };
}]).directive('ellipsis', [function () {
    return {
        required: 'ngModel', // explicit ng-model is required even in presence ng-bind-html because it creates the ng-model only when the field is updated
        restrict: 'A',
        priority: 100,
        scope:{
            ngModel:'='
        },
        link: function (scope, element) {
            scope.$watch(function() {
                return scope.ngModel + element.width(); // ugly hack but it seems to work
            }, function() {
                element.data('jqae', null);
                element.ellipsis();
            });
        }
    };
}]).directive('timeago', [function() {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            element.data('hasTimeago', false);
            var dateTimeNotParsed = attrs.datetime;
            scope.$watch(dateTimeNotParsed, function(value) {
                // apply only once
                if (!element.data('hasTimeago')) {
                    element.data('hasTimeago',true);
                    element.timeago();
                }
            });
        }
    };
}]).directive('at', [function() {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            element.data('hasAt', false);
            scope.$watch(function() {
                // Cannot use isolated scope (e.g. scope { at: '=' } because there are already isolated scope on the element)
                return scope.$eval(attrs.at);
            }, function(newOptions) {
                if (element.data('hasAt')) {
                    // recreate if options has changed, eg. promise completed for data
                    element.atwho('destroy');
                } else {
                    element.data('hasAt', true);
                }
                element.atwho(newOptions);
            }, true);
        }
    };
}]).directive('capitalize', function() {
        return {
            require: 'ngModel',
            link: function(scope, element, attrs, modelCtrl) {
                var capitalize = function(inputValue) {
                    if(inputValue == undefined) inputValue = '';
                    if(attrs.noSpace){
                        inputValue = inputValue.replace(/[\s]/g, '');
                    }
                    var capitalized = inputValue.toUpperCase();
                    if(capitalized !== inputValue) {
                        modelCtrl.$setViewValue(capitalized);
                        modelCtrl.$render();
                    }
                    return capitalized;
                };
                modelCtrl.$parsers.push(capitalize);
                capitalize(scope[attrs.ngModel]);
            }
        };
}).directive('btnModel', function() {
    return {
        restrict: 'C',
        require: 'ngModel',
        link: function(scope, element, attrs, modelCtrl) {
            element.on('click', function(){
                modelCtrl.$setDirty();
                modelCtrl.$setTouched();
            });
        }
    };
}).directive('selectOnFocus', function () {
    return {
        restrict: 'A',
        link: function (scope, element) {
            element.on('focus', function () {
                this.select();
            });
        }
    };
}).directive('isProgress',['$rootScope', '$timeout', '$http', function($rootScope, $timeout, $http) {
    return {
        restrict: 'E',
        scope: {
            start:'='
        },
        templateUrl: 'is.progress.html',
        link: function (scope, element, attrs) {
            var status;

            scope.progress = {
                value: -1,
                label: "",
                type:'primary'
            };

            scope.$watch('start', function( value ) {
                stopProgress();
                if (value === true){
                    $timeout(progress, 500);
                }
            });

            var progress = function() {
                $http({
                    method: "get",
                    url: $rootScope.serverUrl + "/progress"
                }).then(function (response) {
                    scope.progress = response.data;
                    if (!response.data.error && !response.data.complete) {
                        status = $timeout(progress, 500);
                    }
                    if (response.data.error){
                        scope.progress.type = 'danger';
                    }else if (response.data.complete){
                        scope.progress.type = 'success';
                    }
                }, function(){
                    scope.progress.type = 'danger';
                    scope.progress.label = scope.message(attrs.errorMessage?attrs.errorMessage:'todo.is.ui.error');
                    scope.progress.value = 100;
                });
            };

            var stopProgress = function(){
                if (angular.isDefined(status)) {
                    $timeout.cancel(status);
                    status = undefined;
                }
            };

            element.on('$destroy', function() {
                stopProgress();
            });
        }
    };
}]);