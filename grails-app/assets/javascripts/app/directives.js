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
directives.directive('isMarkitup', ['$http', function($http) {
    return {
        restrict: 'A',
        scope: {
            show: '=ngShow',
            html: '=isModelHtml',
            model: '=ngModel'
        },
        link: function(scope, element) {
            var settings = $.extend({
                    resizeHandle: false,
                    scrollContainer: '#main-content .details:first',
                    afterInsert: function() {
                        element.triggerHandler('input');
                    }
                },
                textileSettings);
            var markitup = element.markItUp(settings);
            var container = markitup.parents('.markItUp');
            container.hide();

            scope.$watch('show', function(value) {
                if (value === true) {
                    container.show();
                    setTimeout(function() {
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
                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                    data: 'data=' + val
                }).success(function(data) {
                    scope.html = data;
                }));
            });
        }
    };
}]).directive('showValidation', ['$compile', '$rootScope', function($compile, $rootScope) {
    return {
        restrict: "A",
        link: function(scope, element, attrs) {
            scope.$watch(function() {
                return scope.$eval(attrs.name);
            }, function(form) {
                if (form == undefined) {
                    return;
                }
                var inputs = element.find('input[ng-model]:not([validation-watched]):not(.ui-select-search), textarea[ng-model]:not([validation-watched])');
                angular.forEach(inputs, function(it) {
                    var input = angular.element(it);
                    input.attr('validation-watched', '');
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
                                return _.transform(errors, function(errorMessages, value, key) {
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
}]).directive('notMatch', function() {
    return {
        require: 'ngModel',
        restrict: 'A',
        scope: {
            notMatch: '='
        },
        link: function(scope, element, attrs, modelCtrl) {
            modelCtrl.$validators.notMatch = function(modelValue, viewValue) {
                var value = modelValue || viewValue;
                var notMatch = scope.notMatch;
                return value != notMatch;
            };
            scope.$watch('notMatch', function() {
                modelCtrl.$validate();
            });
        }
    };
}).directive('isMatch', function() {
    return {
        require: 'ngModel',
        restrict: 'A',
        scope: {
            isMatch: '='
        },
        link: function(scope, element, attrs, modelCtrl) {
            modelCtrl.$validators.isMatch = function(modelValue, viewValue) {
                var value = modelValue || viewValue;
                var isMatch = scope.isMatch;
                return value === isMatch;
            };
            scope.$watch('isMatch', function() {
                modelCtrl.$validate();
            });
        }
    };
}).directive('formAutofillFix', ['$timeout', function($timeout) {
    return function(scope, element, attrs) {
        element.prop('method', 'post');
        if (attrs.ngSubmit) {
            $timeout(function() {
                element
                    .unbind('submit')
                    .bind('submit', function(event) {
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
}]).directive('ellipsis', [function() {
    return {
        restrict: 'A',
        priority: 100,
        link: function(scope, element) {
            element.on('mouseenter', function() {
                _.each(element.find('.ellipsis-el'), function(el) {
                    el = angular.element(el);
                    var data = el.data('jqae');
                    if (!data || (data && data.wrapperElement.parent().length == 0)) {
                        el.data('jqae', null);
                        el.ellipsis();
                    }
                });
            });
        }
    };
}]).directive('timeago', [function() {
    return {
        restrict: 'A',
        link: function(scope, element) {
            element.data('hasTimeago', false);
            scope.$watch("", function() {
                // apply only once
                if (!element.data('hasTimeago')) {
                    element.data('hasTimeago', true);
                    element.timeago();
                }
            });
        }
    };
}]).directive('at', [function() {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
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
                if (inputValue == undefined) inputValue = '';
                if (attrs.noSpace) {
                    inputValue = inputValue.replace(/[\s]/g, '');
                }
                var capitalized = inputValue.toUpperCase();
                if (capitalized !== inputValue) {
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
            element.on('mousedown', function() {
                modelCtrl.$setDirty();
                modelCtrl.$setTouched();
            });
        }
    };
}).directive('selectOnFocus', function() {
    return {
        restrict: 'A',
        link: function(scope, element) {
            element.on('focus', function() {
                this.select();
            });
        }
    };
}).directive('isProgress', ['$rootScope', '$timeout', '$http', function($rootScope, $timeout, $http) {
    return {
        restrict: 'E',
        scope: {
            start: '='
        },
        templateUrl: 'is.progress.html',
        link: function(scope, element, attrs) {
            var status;

            scope.progress = {
                value: -1,
                label: "",
                type: 'primary'
            };

            scope.$watch('start', function(value) {
                stopProgress();
                if (value === true) {
                    $timeout(progress, 500);
                }
            });

            var progress = function() {
                $http({
                    method: "get",
                    url: $rootScope.serverUrl + "/progress"
                }).then(function(response) {
                    var data = response.data;
                    scope.progress = data;
                    if (!data.error && !data.complete) {
                        status = $timeout(progress, 500);
                    }
                    if (data.error) {
                        scope.progress.type = 'danger';
                    } else if (data.complete) {
                        scope.progress.type = 'success';
                    }
                }, function() {
                    scope.progress.type = 'danger';
                    scope.progress.label = scope.message(attrs.errorMessage ? attrs.errorMessage : 'todo.is.ui.error');
                    scope.progress.value = 100;
                });
            };

            var stopProgress = function() {
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
}]).directive('onRepeatCompleted', function() {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            if (scope.$last === true) {
                scope.$evalAsync(attrs.onRepeatCompleted);
            }
        }
    }
}).directive('circle', function() {
    var polarToCartesian = function(centerX, centerY, radius, angleInDegrees) {
        var angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
        return {
            x: centerX + (radius * Math.cos(angleInRadians)),
            y: centerY + (radius * Math.sin(angleInRadians))
        };
    };
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var coords = attrs.circleCoords.split(',');
            _.each(coords, function(val, index) {
                coords[index] = parseInt(val);
            });
            var end = polarToCartesian(coords[0], coords[1], coords[2], coords[3]);
            scope.$watch(attrs.circle, function(value) {
                var endAngle = 360 * value / 100;
                var start = polarToCartesian(coords[0], coords[1], coords[2], endAngle);
                var arcSweep = endAngle - coords[3] <= 180 ? "0" : "1";
                var d = [
                    "M", start.x, start.y,
                    "A", coords[2], coords[2], 0, arcSweep, 0, end.x, end.y
                ].join(" ");
                element.attr('d', d);
            });
        }
    }
}).directive('asSortableItemHandleIf', ['$compile', function($compile) {
    return {
        restrict: 'A',
        priority: 1000,
        link: function(scope, element, attrs) {
            if (scope.$eval(attrs.asSortableItemHandleIf)) {
                element.attr('as-sortable-item-handle', '');
            }
            element.removeAttr("as-sortable-item-handle-if"); // avoid infinite loop
            $compile(element)(scope);
        }
    };
}]).directive('projectTimeline', ['ProjectService', '$window',function(ProjectService, $window){
    return {
        restrict: 'A',
        link:function(scope, element, attrs){
            var margin = {top: 0, right: 15, bottom: 15, left: 15},
                width = element.width() - margin.left - margin.right,
                height = element.height() - margin.top - margin.bottom,
                brush, x;

            var rootSvg = d3.select(element[0])
                .append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom);

            var svg = rootSvg
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            scope.$watch(attrs.projectTimeline, function(project){
                x.domain([new Date(_.first(project.releases).startDate), new Date(_.last(project.releases).endDate)]);

                var releaseMargin = 15;
                svg.select(".releases")
                    .selectAll('rect')
                    .data(project.releases)
                    .enter()
                    .append("rect")
                    .attr("y", releaseMargin)
                    .attr("height", height - releaseMargin*2)
                    .attr('x', function(d) { return x(d.startDate); })
                    .attr('width', function(d) { return x(d.endDate) - x(d.startDate); })
                    .attr("class", function(d){ return "release release-"+({ 1: 'default', 2: 'progress', 3: 'done' }[d.state]); });

                var sprintMargin = 10;
                svg.select(".sprints")
                    .selectAll('rect')
                    .data(ProjectService.getAllSprintsSorted(project))
                    .enter()
                    .append("rect")
                    .attr("y", sprintMargin+releaseMargin)
                    .attr('x', function(d) { return x(d.startDate); })
                    .attr("height", height - releaseMargin*2-sprintMargin*2)
                    .attr('width', function(d) { return x(d.endDate) - x(d.startDate); })
                    .attr("class", function(d){ return "sprint sprint-"+({ 1: 'default', 2: 'progress', 3: 'done' }[d.state]); });

                svg.select(".axis")
                    .call(d3.svg.axis()
                        .scale(x)
                        .orient("bottom"))
                    .selectAll("text")
                    .attr('y', 7)
                    .attr('x', -15)
                    .style("text-anchor", null);

                //should be added as parameter
                var currentOrNextSprint = ProjectService.getCurrentOrNextSprint(project);
                if(currentOrNextSprint){
                    d3.select(".brush").transition()
                        .call(brush.extent([currentOrNextSprint.startDate,currentOrNextSprint.endDate]))
                        .call(brush.event);
                }
            });

            //background
            svg.append("rect")
                .attr("class", "timeline-background")
                .attr("width", width)
                .attr("height", height);

            //x date axis
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")");

            //group releases
            var releases = svg.append("g")
                .attr("class", "releases");

            //group sprints
            var sprints = svg.append("g")
                .attr("class", "sprints");

            //brush rect
            svg.append("g")
                .attr("class", "brush");

            //x axis
            x = d3.time.scale()
                .range([0, width]);

            //brush selector
            brush = d3.svg.brush()
                .x(x)
                .on("brushend", brushended);

            svg.selectAll(".brush")
                .call(brush)
                .call(brush.event);

            svg.selectAll(".brush").selectAll("rect")
                .attr("height", height);

            //snap to sprint
            function brushended() {
                if (!d3.event.sourceEvent) return; // only transition after input
                var extent0 = brush.extent(),
                    extent1 = extent0.map(d3.time.day.round);
                // if empty when rounded, use floor & ceil instead
                if (extent1[0] >= extent1[1]) {
                    var release, sprint;
                    release = _.find(releases.selectAll("rect").data(), function(release) {
                        return release.startDate <= extent1[0] && release.endDate >= extent1[1];
                    });
                    if(release){
                        sprint = _.find(sprints.selectAll("rect").data(), function(sprint) {
                            return sprint.startDate <= extent1[0] && sprint.endDate >= extent1[1];
                        });
                    }
                    var result = sprint ? sprint : release ? release : null;
                    extent1[0] = result ? result.startDate : d3.time.day.floor(extent0[0]);
                    extent1[1] = result ? result.endDate : d3.time.day.ceil(extent0[1]);
                } else {
                    var ssprints = _.filter(sprints.selectAll("rect").data(), function(sprint) {
                        return sprint.startDate >= extent1[0] && sprint.endDate <= extent1[1];
                    });
                    console.log(ssprints);
                }
                d3.select(this).transition()
                    .call(brush.extent(extent1))
                    .call(brush.event);
            }
        }
    }
}]).directive('storyMenu', ['$compile', function($compile) { // For 140 stories, reduce display time by 1 s. and initial watchers by 1700 by loading menu only on first hover
    return {
        restrict: 'A',
        link: function(scope, element) {
            element.closest('.postit').one('mouseenter', function() {
                var newElement = element.clone();
                newElement.removeAttr('story-menu');
                newElement.attr('uib-dropdown', '');
                newElement.html('<a uib-dropdown-toggle><i class="fa fa-cog"></i></a><ul class="uib-dropdown-menu" ng-include="\'story.menu.html\'"></ul>');
                element.replaceWith(angular.element($compile(newElement)(scope)));
            });
        }
    }
}]).directive('fastTooltip', ['$compile', function($compile) { // For 140 stories, reduce display time by 0,8 s.
    return {
        restrict: 'A',
        link: function(scope, element) {
            element.on('mouseenter', function() { // Executed on each mouseenter because new dom elements may have appeared since the last time (e.g. with ng-if)
                var tooltipAttr = 'fast-tooltip-el';
                _.each(element.find('[' + tooltipAttr + ']'), function(tooltipElement) {
                    tooltipElement = angular.element(tooltipElement);
                    var newTooltipElement = tooltipElement.clone();
                    // Tooltip content must be a static string, it cannot be an angular expression "{{ foo }}"
                    // because the original expression and the associated watcher will be lost in the process so the value will never be synced if it changes
                    var tooltipContent = newTooltipElement.attr(tooltipAttr);
                    newTooltipElement.removeAttr(tooltipAttr); // Remove attr to prevent doing it again on next mouseenter for elements already processed
                    newTooltipElement.attr('uib-tooltip', tooltipContent);
                    tooltipElement.replaceWith(angular.element($compile(newTooltipElement)(scope)));
                });
            });
        }
    }
}]).directive('selectable', ['$document', '$rootScope', function($document, $rootScope) {
    return {
        restrict: 'A',
        scope: {
            selectable: '='
        },
        link: function(scope, element) {
            var selectableOptions = scope.selectable;
            var selectedClass = 'is-selected';
            var selectedIdAttr = 'selectable-id';
            var selectedSelector = '[' + selectedIdAttr + '].' + selectedClass;
            var lastSelected;
            element.on('click', function(event) { // Listen only on the container element rather than on each element: allow deselecting and avoid the need to listen to new elements
                var target = angular.element(event.target);
                if (!selectableOptions.notSelectableSelector || target.closest(selectableOptions.notSelectableSelector).length == 0) {
                    $document[0].getSelection().removeAllRanges(); // prevents text-selection when doing shift + click
                    var selectedIds = [];
                    if (!event.ctrlKey && !event.metaKey && !event.shiftKey && !$rootScope.app.selectableMultiple) {
                        element.find(selectedSelector).removeClass(selectedClass);
                    }
                    var selectableElement = target.closest('[' + selectedIdAttr + ']');
                    if (selectableElement.length != 0) {
                        if (lastSelected && event.shiftKey) { // Dark magic to emulate shift+click behavior observed in OS
                            var elementsBetween = function(el1, el2) {
                                var elements = el1.parent().children('[' + selectedIdAttr + ']');
                                var index1 = elements.index(el1);
                                var index2 = elements.index(el2);
                                var slice = [];
                                if (index1 != -1 && index2 != -1 && index1 != index2) {
                                    var sortedIndexes = [index1, index2].sort();
                                    slice = elements.slice(sortedIndexes[0], sortedIndexes[1] + 1);
                                }
                                return slice;
                            };
                            var selectedElementsNextTo = function(el) {
                                var notSelectedSelector = '[' + selectedIdAttr + ']:not(.' + selectedClass + ')';
                                var before = el.prevUntil(notSelectedSelector);
                                var after = el.nextUntil(notSelectedSelector);
                                return jQuery.merge(before, after);
                            };
                            _.each(selectedElementsNextTo(lastSelected), function(el) {
                                angular.element(el).removeClass(selectedClass);
                            });
                            _.each(elementsBetween(selectableElement, lastSelected), function(el) {
                                el = angular.element(el);
                                if (!el.hasClass(selectedClass)) {
                                    el.addClass(selectedClass);
                                }
                            });
                        } else {
                            selectableElement.toggleClass(selectedClass);
                            lastSelected = selectableElement.hasClass(selectedClass) ? selectableElement : null;
                        }
                        selectedIds = _.map(element.find(selectedSelector), function(selected) {
                            return angular.element(selected).attr(selectedIdAttr);
                        });
                    } else {
                        lastSelected = null;
                    }
                    selectableOptions.selectionUpdated(selectedIds);
                }
            });
        }
    }
}]);
