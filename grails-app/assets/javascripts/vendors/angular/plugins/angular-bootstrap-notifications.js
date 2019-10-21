/*
 * Copyright (c) 2019 Kagilum SAS.
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

angular.module('notification-templates', []).run(['$templateCache', function($templateCache) {
    $templateCache.put('toast.container.html', '<div class="toast-container" aria-live="polite" aria-atomic="true"></div>');
    $templateCache.put('toast.html', '<div class="toast" role="alert" aria-live="assertive" aria-atomic="true">' +
                                     '    <div class="toast-header">' +
                                     '        <div class="toast-close" data-dismiss="toast" aria-label="Close"></div>' +
                                     '        <div class="toast-content">' +
                                     '            <div class="toast-icon {{:: \'toast-\' + type }}"></div>' +
                                     '            <div>' +
                                     '               <div ng-if="title"><strong>{{:: title }}</strong></div>' +
                                     '               {{:: message }}' +
                                     '            </div>' +
                                     '        </div>' +
                                     '    </div>' +
                                     '   <div class="mt-2" ng-if="::button">' +
                                     '       <a href ng-click="button.action()" class="btn btn-sm btn-{{::button.type}} float-right">{{::button.name}}</a>' +
                                     '   </div>' +
                                     '</div>');
}]);

angular.module('angular-notifications', ['notification-templates']).provider('notifications', function() {
    'use strict';

    this.$get = ['$rootScope', '$compile', '$templateCache', function($rootScope, $compile, $templateCache) {

        function notifyByType(type) {
            return function(title, message, options) {
                var $body = angular.element('body');
                var $container = angular.element('.toast-container');
                if (!$container.length) {
                    $body.append($templateCache.get('toast.container.html'));
                    $container = angular.element('.toast-container');
                }
                var scope = $rootScope.$new(true);
                scope.title = title;
                scope.message = message;
                scope.type = type;
                scope.button = options ? options.button : null;
                var toast = $compile($templateCache.get('toast.html'))(scope);
                $container.append(toast);
                var $toast = angular.element(toast);
                $toast.toast(_.merge({delay: 4500}, (options || {})));
                $toast.on('hidden.bs.toast', function() {
                    $toast.remove();
                });
                $toast.toast('show');
            };
        }

        return {
            error: notifyByType('error'),
            success: notifyByType('success'),
            warning: notifyByType('warning')
        };
    }];
});
