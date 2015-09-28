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

services.service("PushService", ['$rootScope', 'atmosphereService', 'IceScrumEventType', function($rootScope, atmosphereService, IceScrumEventType) {
    var self = this;
    self.push = {};
    this.listeners = {};
    this.initPush = function(projectId) {
        var options = {
            url: $rootScope.serverUrl + '/stream/app' + (projectId ? ('/product-' + projectId) : ''),
            contentType: 'application/json',
            logLevel: 'info', // Set 'debug' to debug
            transport: 'websocket',
            trackMessageLength: true,
            reconnectInterval: 5000,
            enableXDR: true,
            timeout: 60000
        };
        options.onOpen = function(response) {
            self.push.transport = response.transport;
            self.push.connected = true;
            atmosphere.util.debug('Atmosphere connected using ' + response.transport);
        };
        options.onClientTimeout = function(response) {
            self.push.connected = false;
            setTimeout(function() {
                atmosphereService.subscribe(options);
            }, options.reconnectInterval);
            atmosphere.util.debug('Client closed the connection after a timeout. Reconnecting in ' + options.reconnectInterval);
        };
        options.onReopen = function(response) {
            self.push.connected = true;
            atmosphere.util.debug('Atmosphere re-connected using ' + response.transport);
        };
        options.onTransportFailure = function(errorMsg, request) {
            atmosphere.util.info(errorMsg);
            request.fallbackTransport = 'streaming';
            atmosphere.util.debug('Default transport is WebSocket, fallback is ' + request.fallbackTransport);
        };
        options.onMessage = function(response) {
            var textBody = response.responseBody;
            try {
                var jsonBody = atmosphere.util.parseJSON(textBody);
                if (jsonBody.eventType) {
                   self.publishEvent(jsonBody);
                }
            } catch (e) {
                atmosphere.util.debug("Error parsing JSON: " + textBody);
                throw e;
            }
        };
        options.onClose = function(response) {
            self.push.connected = false;
            atmosphere.util.debug('Server closed the connection after a timeout');
        };
        options.onError = function(response) {
            atmosphere.util.debug("Sorry, but there's some problem with your socket or the server is down");
        };
        options.onReconnect = function(request, response) {
            self.push.connected = false;
            atmosphere.util.debug('Connection lost. Trying to reconnect ' + request.reconnectInterval);
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
        console.log('register listener on ' + eventType + ' ' + domain);
        listeners.push(listener);
        return {
            unregister: function() {
                console.log('unregister listener on ' + eventType + ' ' + domain);
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
                console.log('call listener on ' + eventType + ' ' + domain);
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