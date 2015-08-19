/**
 * Created by msoltani on 19/08/2015.
 */

services.factory('Mood', ['Resource', function ($resource) {
    return $resource(icescrum.grailsServer + '/mood/:id/:action',
        {},
        {
            listByUser: {method: 'GET', isArray: true, params: {action: 'listByUser'}}
        });
}]);

services.service("MoodService", ['$q', 'Mood', function ($q, Mood) {
    this.save = function (mood) {
         mood.class ='mood'
        return Mood.save(mood).$promise;
    };

    this.listByUser = function () {
        return Mood.listByUser().$promise;
    }
}]);


