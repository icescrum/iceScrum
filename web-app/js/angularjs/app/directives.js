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
                    scrollContainer:'#right'
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
}]).directive('isFixed', [function() {
    return {
        restrict: 'A',
        scope: {},
        link: function(scope, element, attrs) {
            var $this = element;
            var container = $(attrs['isFixed']);
            var initialTop = element.offset().top - container.offset().top + container.scrollTop();
            var id = 'scroll.fixed'+(new Date().getTime());
            var fixedFunction = function(event, manual) {
                //remove event
                if (!$this.is(':visible')){
                    container.off( id );
                    return;
                }
                var scrollTop = container.scrollTop();
                if(manual || (initialTop - scrollTop <= 0 && !$this.hasClass('fixed'))){
                    $this.next().css('margin-top', $this.outerHeight());
                    $this.addClass('fixed')
                        .css('top', container.offset().top + parseInt((attrs['isFixedOffsetTop'] ?  attrs['isFixedOffsetTop'] : 0)))
                        .css('width', $this.parent().outerWidth(true) + parseInt(attrs['isFixedOffsetWidth'] ?  attrs['isFixedOffsetWidth'] : 0))
                        .css('left', container.offset().left + parseInt((attrs['isFixedOffsetLeft'] ?  attrs['isFixedOffsetLeft'] : 0)))
                        .css('position', 'fixed');
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
        }
    };
}]).directive('showValidation', [function() {
    return {
        restrict: "A",
        link: function(scope, element, attrs, ctrl) {
            if (element.get(0).nodeName.toLowerCase() === 'form') {
                element.find('.form-group').each(function(i, formGroup) {
                    showValidation(angular.element(formGroup));
                });
            } else {
                showValidation(element);
            }
            function showValidation(formGroupEl) {
                var input = formGroupEl.find('input[ng-model],textarea[ng-model]');
                if (input.length > 0) {
                    scope.$watch(function() {
                        return input.hasClass('ng-invalid');
                    }, function(isInvalid) {
                        formGroupEl.toggleClass('has-error', isInvalid);
                    });
                }
            }
        }
    }
}]).directive('scrollToTab', ['$parse', function($parse) {
        return {
            restrict: 'A',
            link: function(scope, element, attrs) {
                var getActive = $parse(attrs.active);
                scope.$parent.$watch(getActive, function(value, oldVal){
                    if (value !== oldVal && value == true){
                        var container = attrs.scrollToTab ? $(attrs.scrollToTab) : $(element).parent();
                        var pos = $(element).position().top + container.scrollTop();
                        container.animate({
                            scrollTop : pos
                        }, 1000);
                    }
                });
            }
        }
}]).directive('formAutofillFix', function ($timeout) {
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
});