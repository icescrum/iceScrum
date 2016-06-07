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
    this.listeners = {};
    var logLevel = 'info';
    var _canLog = function(level) {
        if (level == 'debug') {
            return logLevel === 'debug';
        } else if (level == 'info') {
            return logLevel === 'info' || logLevel === 'debug';
        } else if (level == 'warn') {
            return logLevel === 'warn' || logLevel === 'info' || logLevel === 'debug';
        } else if (level == 'error') {
            return logLevel === 'error' || logLevel === 'warn' || logLevel === 'info' || logLevel === 'debug';
        } else {
            return false;
        }
    };
    this.initPush = function(projectId) {
        var options = {
            url: $rootScope.serverUrl + '/stream/app' + (projectId ? ('/product-' + projectId) : ''),
            contentType: 'application/json',
            logLevel: logLevel,
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
            $rootScope.app.loading = true;
            var textBody = response.responseBody;
            try {
                var jsonBody = atmosphere.util.parseJSON(textBody);
                if (jsonBody.eventType) {
                    self.publishEvent(jsonBody);
                }
            } catch (e) {
                if (_canLog('debug')) {
                    atmosphere.util.debug("Error parsing JSON: " + textBody);
                }
                throw e;
            } finally {
                $rootScope.app.loading = false;
            }
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
        atmosphereService.subscribe(options);
    };
    this.registerListener = function(domain, eventType, listener) {
        domain = domain.toLowerCase();
        if (_.isUndefined(self.listeners[domain])) {
            self.listeners[domain] = {};
        }
        if (_.isUndefined(self.listeners[domain][eventType])) {
            self.listeners[domain][eventType] = [];
        }
        var listeners = self.listeners[domain][eventType];
        if (_canLog('debug')) {
            atmosphere.util.debug('Register listener on ' + eventType + ' ' + domain);
        }
        listeners.push(listener);
        return {
            unregister: function() {
                if (_canLog('debug')) {
                    atmosphere.util.debug('Unregister listener on ' + eventType + ' ' + domain);
                }
                _.remove(listeners, function(registeredListener) {
                    return registeredListener == listener;
                });
            }
        };
    };
    this.publishEvent = function(jsonBody) {
        var object = jsonBody.object;
        var domain = object['class'].toLowerCase();
        if (!_.isEmpty(self.listeners[domain])) {
            var eventType = jsonBody.eventType;
            _.each(self.listeners[domain][eventType], function(listener) {
                if (_canLog('debug')) {
                    atmosphere.util.debug('Call listener on ' + eventType + ' ' + domain);
                }
                FormService.transformStringToDate(object);
                listener(object);
            });
        }
    };
    this.synchronizeItem = function(domain, item) {
        return self.registerListener(domain, IceScrumEventType.UPDATE, function(object) {
            if (item.id == object.id) {
                angular.extend(item, object);
            }
        });
    };
}]);