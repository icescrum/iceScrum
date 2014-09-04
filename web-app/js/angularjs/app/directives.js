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
directives.directive('focusMe', function($timeout) {
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
}).directive('isMarkitup', ['$http',function($http) {
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
                    scrollContainer:'#right',
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
                    element[0].focus();
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
                if (!$this.is(':visible')){
                    container.off( id );
                    $(window).off( idR );
                    return;
                }
                var scrollTop = container.scrollTop();
                if(manual || (initialTop - scrollTop <= 0)){
                    $this.css('width', $this.parent().outerWidth(true) + parseInt(attrs['fixedOffsetWidth'] ?  attrs['fixedOffsetWidth'] : 0))
                         .css('left', container.offset().left + parseInt((attrs['fixedOffsetLeft'] ?  attrs['fixedOffsetLeft'] : 0)));
                    if (!$this.hasClass('fixed')){
                        $this.next().css('margin-top', $this.outerHeight());
                        $this.addClass('fixed')
                            .css('top', container.offset().top + parseInt((attrs['fixedOffsetTop'] ?  attrs['fixedOffsetTop'] : 0)))
                            .css('position', 'fixed');
                    }
                } else if (initialTop - scrollTop > 0 && $this.hasClass('fixed')) {
                    $this.removeClass('fixed')
                        .css('top', '')
                        .css('width', '')
                        .css('left','')
                        .css('position', '');
                    $this.next().css('margin-top', '');
                }
            };

            container.on(id, fixedFunction);
            container.scroll();

            //when resize
            $(window).on(idR, function(e) {
                fixedFunction(null);
            });

            //when transition
            $('#main, #sidebar').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',
                function(e) {
                    fixedFunction(null);
                }
            );

        }
    };
}]).directive('showValidation', [function() {
    return {
        restrict: "A",
        link: function(scope, element, attrs, ctrl) {
            var inputs = element.find('input[ng-model], textarea[ng-model]');
            angular.forEach(inputs, function(it) {
                var input = angular.element(it);
                scope.$watch(function() {
                    return input.hasClass('ng-invalid') && input.hasClass('ng-dirty');
                }, function(newIsInvalid, oldIsInvalid) {
                    if (newIsInvalid && !oldIsInvalid) {
                        input.parent().addClass('has-error');
                        input.parent().append('<div class="help-block bg-danger">error</div>');
                    } else if (!newIsInvalid && oldIsInvalid) {
                        input.parent().removeClass('has-error');
                        input.parent().find('.help-block').remove();
                    }
                });
            });
        }
    }
}]).directive('formAutofillFix', ['$timeout', function($timeout) {
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
        required: 'ngBindHtml',
        restrict: 'A',
        priority: 100,
        link: function (scope, element) {
            element.data('hasEllipsis', false);
            scope.$watch(element.html(), function(value) {
                // apply only once
                if (!element.data('hasEllipsis')) {
                    element.data('hasEllipsis',true);
                    element.ellipsis();
                }
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
            scope.$watch(element.val(), function(value) {
                // apply only once
                if (!element.data('hasAt')) {
                    element.data('hasAt',true);
                    var atOptions = scope.$eval(attrs.at);
                    element.atwho(atOptions);
                }
            });
        }
    };

}]);


//.directive('scrollToTab', ['$parse', function($parse) {
//    return {
//        restrict: 'A',
//        link: function(scope, element, attrs) {
//            var getActive = $parse(attrs.active);
//            scope.$parent.$watch(getActive, function(value, oldVal){
//                if (value !== oldVal && value == true){
//                    var container = attrs.scrollToTab ? $(attrs.scrollToTab) : $(element).parent();
//                    var pos = $(element).position().top + container.scrollTop();
//                    container.animate({
//                        scrollTop : pos
//                    }, 1000);
//                }
//            });
//        }
//    }
//}])

//.directive('ajax2', ['$http', function ($http) {
//    return {
//        restrict: 'A',
//        scope: {
//            success:  '&ajaxSuccess'
//        },
//        link: function (scope, element, attrs) {
//            element.on("click", function (event) {
//                var options = {
//                    method: attrs.ajaxMethod ? attrs.ajaxMethod : 'GET',
//                    url: attrs.href
//                };
//                $http(options).success(function(data){
//                    scope.success({data: data});
//                });
//                return false;
//            });
//        }
//    };
//}]);