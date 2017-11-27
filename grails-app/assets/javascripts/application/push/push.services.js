/*
 * Copyright (c) 2015 Kagilum SAS.
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

services.service("PushService", ['$rootScope', '$http', 'atmosphereService', 'IceScrumEventType', 'FormService', function($rootScope, $http, atmosphereService, IceScrumEventType, FormService) {
    var self = this;
    self.push = {};
    self.logLevel = 'info';
    this.enabled = true;
    this.listeners = {};
    var _canLog = function(level) {
        if (level == 'debug') {
            return self.logLevel === 'debug';
        } else if (level == 'info') {
            return self.logLevel === 'info' || self.logLevel === 'debug';
        } else if (level == 'warn') {
            return self.logLevel === 'warn' || self.logLevel === 'info' || self.logLevel === 'debug';
        } else if (level == 'error') {
            return self.logLevel === 'error' || self.logLevel === 'warn' || self.logLevel === 'info' || self.logLevel === 'debug';
        } else {
            return false;
        }
    };
    this.atmosphereRequest = null;
    this.initPush = function(workspaceId, workspaceType) {
        var options = {
            url: $rootScope.serverUrl + '/stream/app' + (workspaceId ? '/' + workspaceType + '-' + workspaceId : ''),
            contentType: 'application/json',
            logLevel: self.logLevel,
            transport: 'websocket',
            fallbackTransport: 'streaming',
            trackMessageLength: true,
            reconnectInterval: 5000,
            enableXDR: true,
            timeout: 60000
        };
        options.onOpen = function(response) {
            self.push.transport = response.transport;
            self.push.connected = true;
            self.push.uuid = response.request.uuid;
            $http.defaults.headers.common['X-Atmosphere-tracking-id'] = response.request.uuid;
            if (_canLog('debug')) {
                atmosphere.util.debug('Atmosphere connected using ' + response.transport);
            }
        };
        options.onClientTimeout = function(response) {
            self.push.connected = false;
            setTimeout(function() {
                atmosphereService.subscribe(options);
            }, options.reconnectInterval);
            if (_canLog('debug')) {
                atmosphere.util.debug('Client closed the connection after a timeout. Reconnecting in ' + options.reconnectInterval);
            }
        };
        options.onReopen = function(response) {
            self.push.connected = true;
            if (_canLog('debug')) {
                atmosphere.util.debug('Atmosphere re-connected using ' + response.transport);
            }
        };
        options.onTransportFailure = function(errorMsg, request) {
            if (_canLog('info')) {
                atmosphere.util.info(errorMsg);
            }
            if (_canLog('debug')) {
                atmosphere.util.debug('Default transport is WebSocket, fallback is ' + options.fallbackTransport);
            }
        };
        options.onMessage = function(response) {
            $rootScope.application.loading = true;
            _.each(response.responseBody.split('#-|-#'), function(text) {
                try {
                    var jsonBody = atmosphere.util.parseJSON(text);
                    if (jsonBody.eventType) {
                        if (jsonBody.object.ids) { //same update for multiple objects
                            var event = {
                                namespace: jsonBody.namespace,
                                eventType: jsonBody.eventType,
                                object: jsonBody.object.properties
                            };
                            var ids = jsonBody.object.ids;
                            delete jsonBody.object.ids;
                            _.each(ids, function(id) {
                                event.object.id = id;
                                self.publishEvent(event)
                            });
                        } else {
                            self.publishEvent(jsonBody);
                        }
                    }
                } catch (e) {
                    if (_canLog('debug')) {
                        atmosphere.util.debug("Error parsing JSON: " + text);
                    }
                }
            });
            $rootScope.application.loading = false;
        };
        options.onClose = function(response) {
            self.push.connected = false;
            if (_canLog('debug')) {
                atmosphere.util.debug('Server closed the connection after a timeout');
            }
        };
        options.onError = function(response) {
            if (_canLog('debug')) {
                atmosphere.util.debug("Sorry, but there's some problem with your socket or the server is down");
            }
        };
        options.onReconnect = function(request, response) {
            self.push.connected = false;
            if (_canLog('debug')) {
                atmosphere.util.debug('Connection lost. Trying to reconnect ' + request.reconnectInterval);
            }
        };
        this.atmosphereRequest = atmosphereService.subscribe(options);
    };
    this.registerListener = function(namespace, eventType, listener) {
        namespace = namespace.toLowerCase();
        if (_.isUndefined(self.listeners[namespace])) {
            self.listeners[namespace] = {};
        }
        if (_.isUndefined(self.listeners[namespace][eventType])) {
            self.listeners[namespace][eventType] = [];
        }
        var listeners = self.listeners[namespace][eventType];
        if (_canLog('debug')) {
            atmosphere.util.debug('Register listener on ' + eventType + ' ' + namespace);
        }
        listeners.push(listener);
        return {
            unregister: function() {
                if (_canLog('debug')) {
                    atmosphere.util.debug('Unregister listener on ' + eventType + ' ' + namespace);
                }
                _.remove(listeners, function(registeredListener) {
                    return registeredListener == listener;
                });
            }
        };
    };
    this.registerScopedListener = function(namespace, eventType, listener, $scope) {
        var registeredListener = self.registerListener(namespace, eventType, listener);
        $scope.$on('$destroy', function() {
            registeredListener.unregister();
        });
    };
    this.publishEvent = function(jsonBody) {
        if (this.enabled) {
            var object = jsonBody.object;
            var namespace = jsonBody.namespace.toLowerCase();
            if (!_.isEmpty(self.listeners[namespace])) {
                var eventType = jsonBody.eventType;
                _.each(self.listeners[namespace][eventType], function(listener) {
                    if (_canLog('debug')) {
                        atmosphere.util.debug('Call listener on ' + eventType + ' ' + namespace);
                    }
                    FormService.transformStringToDate(object);
                    listener(object);
                });
            }
        }
    };
}]);
