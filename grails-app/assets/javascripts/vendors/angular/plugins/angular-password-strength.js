'use strict';

/*global _*/

/**
 * @ngdoc directive
 * @name ngPasswordStrengthApp.directive:ngPasswordStrength
 * @description
 * # ngPasswordStrength HEAVILY CUSTOMISED DO NOT UPDATE
 */
angular.module('ngPasswordStrength', [
    'ui.bootstrap.progressbar',
    'uib/template/progressbar/progress.html',
    'uib/template/progressbar/progressbar.html'
]).directive('ngPasswordStrength', ['$compile', '$rootScope', function($compile, $rootScope) {
    return {
        restrict: 'A',
        require: 'ngModel',
        scope: {
            pwd: '=ngModel'
        },
        link: function(scope, elem, attrs, ngModel) {
            var mesureStrength = function(p) {
                var matches = {
                        pos: {},
                        neg: {}
                    },
                    counts = {
                        pos: {},
                        neg: {
                            seqLetter: 0,
                            seqNumber: 0,
                            seqSymbol: 0
                        }
                    },
                    tmp,
                    strength = 0,
                    letters = 'abcdefghijklmnopqrstuvwxyz',
                    numbers = '01234567890',
                    symbols = '\\!@#$%&/()=?¿',
                    back,
                    forth,
                    i;

                if (p) {
                    // Benefits
                    matches.pos.lower = p.match(/[a-z]/g);
                    matches.pos.upper = p.match(/[A-Z]/g);
                    matches.pos.numbers = p.match(/\d/g);
                    matches.pos.symbols = p.match(/[$-/:-?{-~!^_`\[\]]/g);
                    matches.pos.middleNumber = p.slice(1, -1).match(/\d/g);
                    matches.pos.middleSymbol = p.slice(1, -1).match(/[$-/:-?{-~!^_`\[\]]/g);

                    counts.pos.lower = matches.pos.lower ? matches.pos.lower.length : 0;
                    counts.pos.upper = matches.pos.upper ? matches.pos.upper.length : 0;
                    counts.pos.numbers = matches.pos.numbers ? matches.pos.numbers.length : 0;
                    counts.pos.symbols = matches.pos.symbols ? matches.pos.symbols.length : 0;

                    tmp = _.reduce(counts.pos, function(memo, val) {
                        // if has count will add 1
                        return memo + Math.min(1, val);
                    }, 0);

                    counts.pos.numChars = p.length;
                    tmp += (counts.pos.numChars >= 8) ? 1 : 0;

                    counts.pos.requirements = (tmp >= 3) ? tmp : 0;
                    counts.pos.middleNumber = matches.pos.middleNumber ? matches.pos.middleNumber.length : 0;
                    counts.pos.middleSymbol = matches.pos.middleSymbol ? matches.pos.middleSymbol.length : 0;

                    // Deductions
                    matches.neg.consecLower = p.match(/(?=([a-z]{2}))/g);
                    matches.neg.consecUpper = p.match(/(?=([A-Z]{2}))/g);
                    matches.neg.consecNumbers = p.match(/(?=(\d{2}))/g);
                    matches.neg.onlyNumbers = p.match(/^[0-9]*$/g);
                    matches.neg.onlyLetters = p.match(/^([a-z]|[A-Z])*$/g);

                    counts.neg.consecLower = matches.neg.consecLower ? matches.neg.consecLower.length : 0;
                    counts.neg.consecUpper = matches.neg.consecUpper ? matches.neg.consecUpper.length : 0;
                    counts.neg.consecNumbers = matches.neg.consecNumbers ? matches.neg.consecNumbers.length : 0;

                    var reverse = function(str) {
                        return str == null ? '' : str.split('').reverse().join('');
                    };

                    // sequential letters (back and forth)
                    for (i = 0; i < letters.length - 2; i++) {
                        var p2 = p.toLowerCase();
                        forth = letters.substring(i, parseInt(i + 3));
                        back = reverse(forth);
                        if (p2.indexOf(forth) !== -1 || p2.indexOf(back) !== -1) {
                            counts.neg.seqLetter++;
                        }
                    }

                    // sequential numbers (back and forth)
                    for (i = 0; i < numbers.length - 2; i++) {
                        forth = numbers.substring(i, parseInt(i + 3));
                        back = reverse(forth);
                        if (p.indexOf(forth) !== -1 || p.toLowerCase().indexOf(back) !== -1) {
                            counts.neg.seqNumber++;
                        }
                    }

                    // sequential symbols (back and forth)
                    for (i = 0; i < symbols.length - 2; i++) {
                        forth = symbols.substring(i, parseInt(i + 3));
                        back = reverse(forth);
                        if (p.indexOf(forth) !== -1 || p.toLowerCase().indexOf(back) !== -1) {
                            counts.neg.seqSymbol++;
                        }
                    }

                    // repeated chars
                    counts.neg.repeated = _.chain(p.toLowerCase().split('')).
                        countBy(function(val) {
                            return val;
                        })
                        .reject(function(val) {
                            return val === 1;
                        })
                        .reduce(function(memo, val) {
                            return memo + val;
                        }, 0)
                        .value();

                    // Calculations
                    strength += counts.pos.numChars * 4;
                    if (counts.pos.upper) {
                        strength += (counts.pos.numChars - counts.pos.upper) * 2;
                    }
                    if (counts.pos.lower) {
                        strength += (counts.pos.numChars - counts.pos.lower) * 2;
                    }
                    if (counts.pos.upper || counts.pos.lower) {
                        strength += counts.pos.numbers * 4;
                    }
                    strength += counts.pos.symbols * 6;
                    strength += (counts.pos.middleSymbol + counts.pos.middleNumber) * 2;
                    strength += counts.pos.requirements * 2;

                    strength -= counts.neg.consecLower * 2;
                    strength -= counts.neg.consecUpper * 2;
                    strength -= counts.neg.consecNumbers * 2;
                    strength -= counts.neg.seqNumber * 3;
                    strength -= counts.neg.seqLetter * 3;
                    strength -= counts.neg.seqSymbol * 3;

                    if (matches.neg.onlyNumbers) {
                        strength -= counts.pos.numChars;
                    }
                    if (matches.neg.onlyLetters) {
                        strength -= counts.pos.numChars;
                    }
                    if (counts.neg.repeated) {
                        strength -= (counts.neg.repeated / counts.pos.numChars) * 10;
                    }
                }

                return Math.max(0, Math.min(100, Math.round(strength)));
            },
            getClass = function(score) {
                if (score < 20) {
                    return "bad";
                } else if (score < 60) {
                    return "good";
                } else {
                    return "strong";
                }
            },
            getLabel = function(score) {
                if (score < 20) {
                    return 'veryweak'
                } else if (score < 40) {
                    return 'weak'
                } else if (score < 60) {
                    return 'good'
                } else if (score < 80) {
                    return 'strong'
                } else {
                    return 'verystrong'
                }
            };
            var template = '<div id="pass-strength-result" class="help-block {{class}}">{{ label }}</div>';
            scope.$watch('pwd', function() {
                if (!ngModel.$pristine) {
                    scope.value = mesureStrength(scope.pwd);
                    scope.label = $rootScope.message("todo.is.ui.password.strength." + getLabel(scope.value));
                    scope.class = getClass(scope.value);
                    var compiledTemplate = angular.element($compile(template)(scope));
                    elem.parent().find('#pass-strength-result').remove();
                    elem.after(compiledTemplate);
                }
            });
        }
    };
}]);