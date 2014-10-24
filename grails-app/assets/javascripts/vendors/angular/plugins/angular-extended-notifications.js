/* customized - angular-extended-notifications - v1.0.4 */
angular.module("notification.html", []).run(["$templateCache", function($templateCache) {
    $templateCache.put("notification.html","<div class=\"notification\"><div ng-class=\"'notification-' + data.type\"><i class=\"fa fa-fw\" ng-class=\"data.faIcon\" ng-if=\"data.faIcon\"></i>{{data.title}}{{data.title?':':''}} {{data.message}} <a ng-repeat=\"action in data.actions\" ng-click=\"action.fn()\" ng-class=\"action.className\">{{action.label}}</a><i class=\"fa fa-fw fa-times notification-close\" ng-click=\"close()\" ng-if=\"data.faIcon && data.closeButton\"></i></div></div>");
}]);

angular.module('angular-extended-notifications', ['notification.html']).
    provider('notifications', function () {
        'use strict';

        // notifications.info(title, message, data);
        // notifications.info(title, message, {faIcon: 'fa-heart'});
        // notifications.info(data);

        // notifications.error(…);
        // notifications.success(…);
        // notifications.warning(…);
        // notifications.notify(data);

        // Possible data options:
        // ---------------------
        //
        // data = {
        //   actions: [{
        //     label: string
        //     fn: function
        //   }]
        //   closeButton: bool
        //   title: title of the message
        //   message: message
        //   webkitNotifications: {
        //     iconFile: icon file
        //     notificationUrl: url to load as a webkit notification base (replaces default behavior)
        //   }
        //   attachTo: angular/jquery element or function
        //   className: className to apply on the template's root element
        //   duration: int in ms
        //   faIcon: font-awesome faIcon classname (fa-info for example)
        //   template: filename without extension
        //   templateFile: filename
        //   templatesDir: path
        //   show: function
        //   close: function
        // }

        var faIcons = {
            info: 'fa-info',
            error: 'fa-exclamation-circle',
            success: 'fa-check',
            warning: 'fa-exclamation-triangle'
        };

        this.setFaIcons = function (map) {
            for (var i in map)
                faIcons[i] = map[i];
            return this;
        };

        var defaults = {
            attachTo: 'body',
            className: '',
            duration: 2500,
            webkitNotifications: false,
            close: angular.noop,
            show: angular.noop,
            closeButton: true,
            templateFile: 'global-notification.html',
            templatesDir: null
        };

        this.setDefaults = function (def) {
            for (var i in def)
                defaults[i] = def[i];
            return this;
        };

        this.$get = ['$timeout', '$templateCache', '$http', '$rootScope', '$compile', '$q',
            function($timeout, $templateCache, $http, $rootScope, $compile, $q) {

                var queue = [];

                function notify(data) {
                    var notif;

                    // complete data with default values
                    for (var i in defaults)
                        if (data[i] === undefined)
                            data[i] = defaults[i];

                    if (data.template)
                        data.templateFile = data.template + '.html';

                    var wkn = window.webkitNotifications;

                    // message & title may be promises, let's resolve them
                    var promise = $q
                        .all([
                            $q.when(data.message),
                            $q.when(data.title)
                        ])
                        .then(function (d) {
                            data.message = d[0];
                            data.title = d[1];

                            // webkitNotifications mode
                            if (data.webkitNotifications && wkn && !wkn.checkPermission()) {
                                if (typeof data.webkitNotifications !== 'object')
                                    throw new Error('data.webkitNotifications should either be false or an object');

                                if (data.webkitNotifications.notificationUrl)
                                // TODO: add data object as url params (use url module from node)
                                    notif = wkn.createHTMLNotification(data.webkitNotifications.notificationUrl);
                                else
                                    notif = wkn.createNotification(
                                        data.webkitNotifications.iconFile,
                                        data.title,
                                        data.content
                                    );

                                notif.ondisplay = data.show;
                                notif.close = data.close;
                                notif.show();
                                return notif;
                            }
                        });

                    // wait until promises are resolved for webkitNotifications
                    if (data.webkitNotifications && wkn && !wkn.checkPermission())
                        return promise;

                    notif = {
                        data: data,
                        close: function () {
                            notif.closed = true;

                            // remove timeout in case of user action
                            if (notif.$timeoutPromise)
                                $timeout.cancel(notif.$timeoutPromise);

                            // user callback
                            if (data.close() === false)
                                return;

                            // remove from queue
                            queue.splice(queue.indexOf(notif), 1);

                            // remove from DOM
                            notif.templateElement.remove();
                        },
                        templateElement: {
                            remove: angular.noop
                        },
                        closed: false
                    };

                    var createFromTemplate = function(template) {
                        if (notif.closed)
                            return;

                        // create scope & copy data elements in it
                        var scope = $rootScope.$new(true);
                        scope.close = notif.close;
                        scope.data = data;

                        // compile template element
                        notif.templateElement = $compile(template)(scope);

                        // add className
                        notif.templateElement.addClass(data.className);

                        // get element from string
                        if (typeof data.attachTo === 'string')
                            data.attachTo = angular.element(document.querySelector(data.attachTo));

                        // attach it on the DOM
                        if (typeof data.attachTo === 'object' && data.attachTo.prepend)
                            data.attachTo.prepend(notif.templateElement);
                        else if (typeof data.attachTo === 'function')
                            data.attachTo(notif.templateElement);
                        else
                            throw new Error('Invalid value for attachTo. It should be either a function ' +
                                'or an object with a prepend method');

                        // add it to the notifications queue
                        queue.push(notif);

                        if (data.closeOnRouteChange) {
                            if (!angular.isString(data.closeOnRouteChange))
                                throw new Error('Invalid property closeOnRouteChange. Should be a string, like "route" to match an event like "routeChangeStart"');

                            var removeListener = $rootScope.$on('$' + data.closeOnRouteChange + 'ChangeStart', function () {
                                notif.close();
                                removeListener();
                            });
                        }

                        // start the timer
                        if (~data.duration)
                            notif.$timeoutPromise = $timeout(notif.close.bind(notif), data.duration);

                        // user callback
                        data.show();
                    };

                    // retrieve template file
                    if (data.templatesDir != null){
                        $http
                            .get(data.templatesDir + data.templateFile, {cache: $templateCache})
                            .success(createFromTemplate)
                            .error(function(data) {
                                throw new Error('Template specified for notifications (' + data.template + ') could not be loaded. ' + data);
                            });
                    } else {
                        createFromTemplate($templateCache.get("notification.html"));
                    }

                    return notif;
                }


                function notifyByType(type) {
                    return function (title, message, data) {
                        data = data || {};

                        if (typeof title === 'object')
                            data = title;
                        else {
                            data.title = title;
                            data.message = message;
                        }
                        data.type = type;

                        for (var i in defaults)
                            if (data[i] === undefined)
                                data[i] = defaults[i];

                        // set type fa-icon
                        if (data.faIcons && (type in faIcons))
                            data.faIcon = faIcons[type];

                        return notify(data);
                    };
                }

                return {
                    queue: queue,

                    info: notifyByType('info'),
                    error: notifyByType('error'),
                    success: notifyByType('success'),
                    warning: notifyByType('warning'),
                    notify: notify
                };

            }];
    });