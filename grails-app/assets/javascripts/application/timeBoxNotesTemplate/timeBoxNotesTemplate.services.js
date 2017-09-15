/*
 * Copyright (c) 2017 Kagilum SAS.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

services.factory('TimeBoxNotesTemplate', ['Resource', function ($resource) {
    return $resource('timeBoxNotesTemplate/:id');
    //TODO: :action needed ?
    //TODO: projectId needed ?
}]);

services.service("TimeBoxNotesTemplateService", ['FormService', '$timeout', '$q', '$http', '$rootScope', '$state', 'TimeBoxNotesTemplate', function (FormService, $timeout, $q, $http, $rootScope, $state, TimeBoxNotesTemplate) {

    this.save = function (timeBoxNoteTemplate) {
        timeBoxNoteTemplate.class = 'timeBoxNoteTemplate';
        timeBoxNoteTemplate.configsData = JSON.stringify(timeBoxNoteTemplate.configs);
        return TimeBoxNotesTemplate.save(timeBoxNoteTemplate, function(timeBoxNoteTemplate){
            timeBoxNoteTemplate.configs = timeBoxNoteTemplate.configsData ? JSON.parse(timeBoxNoteTemplate.configsData) : undefined;
            delete timeBoxNoteTemplate.configsData;
        }).$promise;
    };
    this.get = function (id) {
        return TimeBoxNotesTemplate.get({id: id}).$promise;
    };
    this.update = function (timeBoxNoteTemplate) {
        timeBoxNoteTemplate.configsData = JSON.stringify(timeBoxNoteTemplate.configs);
        return TimeBoxNotesTemplate.update({}, timeBoxNoteTemplate, function(timeBoxNoteTemplate) {
            timeBoxNoteTemplate.configs = timeBoxNoteTemplate.configsData ? JSON.parse(timeBoxNoteTemplate.configsData) : undefined;
            delete timeBoxNoteTemplate.configsData;
        }).$promise;
    };
    this['delete'] = function (timeBoxNoteTemplate) {
        return TimeBoxNotesTemplate.delete({id: timeBoxNoteTemplate.id}).$promise;
    };
    this.list = function (project) {
        return _.isEmpty(project.timeBoxNotesTemplates) ?
            TimeBoxNotesTemplate.query({}, function (timeBoxNotesTemplates) {
                project.timeBoxNotesTemplates = timeBoxNotesTemplates;
                project.timeBoxNotesTemplates_count = project.timeBoxNotesTemplates.length;
            }).$promise : $q.when(project.timeBoxNotesTemplates);
    };

    this.getReleaseNotes = function (release, template) {
        return FormService.httpGet('release/' + release.id + '/releaseNotes/' + template.id);
    }
}]);
