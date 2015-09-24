// https://github.com/spyboost/angular-atmosphere CUSTOMISED (injected $rootscope properly)
// 19/10/2013
angular.module('angular.atmosphere', [])
    .service('atmosphereService', ['$rootScope', function($rootScope) {
        var responseParameterDelegateFunctions = ['onOpen', 'onClientTimeout', 'onReopen', 'onMessage', 'onClose', 'onError'];
        var delegateFunctions = responseParameterDelegateFunctions;
        delegateFunctions.push('onTransportFailure');
        delegateFunctions.push('onReconnect');

        return {
            subscribe: function(options) {
                var result = {};
                angular.forEach(options, function(value, property) {
                    if (typeof value === 'function' && delegateFunctions.indexOf(property) >= 0) {
                        if (responseParameterDelegateFunctions.indexOf(property) >= 0)
                            result[property] = function(response) {
                                $rootScope.$apply(function() {
                                    options[property](response);
                                });
                            };
                        else if (property === 'onTransportFailure')
                            result.onTransportFailure = function(errorMsg, request) {
                                $rootScope.$apply(function() {
                                    options.onTransportFailure(errorMsg, request);
                                });
                            };
                        else if (property === 'onReconnect')
                            result.onReconnect = function(request, response) {
                                $rootScope.$apply(function() {
                                    options.onReconnect(request, response);
                                });
                            };
                    } else {
                        result[property] = options[property];
                    }
                });

                return atmosphere.subscribe(result);
            }
        };
    }]);