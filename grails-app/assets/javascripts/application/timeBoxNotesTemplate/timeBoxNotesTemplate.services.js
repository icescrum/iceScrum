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

services.factory('TimeBoxNotesTemplate', ['Resource', function($resource) {
    return $resource('timeBoxNotesTemplate/:id');
}]);

services.service("TimeBoxNotesTemplateService", ['Session', 'FormService', '$q', 'TimeBoxNotesTemplate', function(Session, FormService, $q, TimeBoxNotesTemplate) {
    this.save = function(timeBoxNotesTemplate) {
        timeBoxNotesTemplate.class = 'timeBoxNotesTemplate';
        timeBoxNotesTemplate.configsData = JSON.stringify(timeBoxNotesTemplate.configs);
        return TimeBoxNotesTemplate.save(timeBoxNotesTemplate, function(timeBoxNotesTemplate) {
            Session.getProject().timeBoxNotesTemplates.push(timeBoxNotesTemplate);
            Session.getProject().timeBoxNotesTemplates_count = Session.getProject().timeBoxNotesTemplates.length;
            return timeBoxNotesTemplate;
        }).$promise;
    };
    this.get = function(id) {
        return TimeBoxNotesTemplate.get({id: id}).$promise;
    };
    this.update = function(timeBoxNotesTemplate) {
        timeBoxNotesTemplate.configsData = JSON.stringify(timeBoxNotesTemplate.configs);
        return TimeBoxNotesTemplate.update({}, timeBoxNotesTemplate, function(timeBoxNotesTemplate) {
            delete timeBoxNotesTemplate.configsData;
            return timeBoxNotesTemplate;
        }).$promise;
    };
    this['delete'] = function(timeBoxNotesTemplate) {
        return TimeBoxNotesTemplate.delete({id: timeBoxNotesTemplate.id}, function() {
            var toDelete = _.find(Session.getProject().timeBoxNotesTemplates, ['id', timeBoxNotesTemplate.id]);
            var index = Session.getProject().timeBoxNotesTemplates.indexOf(toDelete);
            if (index > -1) {
                Session.getProject().timeBoxNotesTemplates.splice(index, 1);
                Session.getProject().timeBoxNotesTemplates_count = Session.getProject().timeBoxNotesTemplates.length;
            }
        }).$promise;
    };
    this.list = function(project) {
        return _.isEmpty(project.timeBoxNotesTemplates) ?
               TimeBoxNotesTemplate.query({}, function(timeBoxNotesTemplates) {
                   project.timeBoxNotesTemplates = timeBoxNotesTemplates;
                   project.timeBoxNotesTemplates_count = project.timeBoxNotesTemplates.length;
               }).$promise : $q.when(project.timeBoxNotesTemplates);
    };
    this.getReleaseNotes = function(release, template) {
        return FormService.httpGet('release/' + release.id + '/releaseNotes/' + template.id);
    };
    this.getSprintNotes = function(sprint, template) {
        return FormService.httpGet('sprint/' + sprint.id + '/sprintNotes/' + template.id);
    };
}]);
