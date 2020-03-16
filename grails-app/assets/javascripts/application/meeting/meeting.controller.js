/*
 * Copyright (c) 2020 Kagilum SAS.
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
extensibleController('meetingCtrl', ['$scope', '$injector', 'AppService', 'MeetingService', 'Meeting', 'Session', function($scope, $injector, AppService, MeetingService, Meeting, Session) {
    // Functions
    $scope.createMeeting = function(subject, provider) {
        if (provider.enabled) {
            var meeting = new Meeting();
            meeting.provider = provider.id;
            meeting.topic = subject.name ? subject.name : $scope.message('is.ui.collaboration.meeting.default');
            meeting.startDate = moment().format();
            if (subject) {
                meeting.subjectId = subject.id;
                meeting.subjectType = subject.class;
            }
            provider.createMeeting(subject, meeting, $scope).then(function(meetingData) {
                if (meetingData.videoLink || meetingData.phone) {
                    meeting.videoLink = meetingData.videoLink;
                    meeting.phone = meetingData.phone ? meetingData.phone : null;
                    meeting.pinCode = meetingData.pinCode ? meetingData.pinCode : null;
                    meeting.providerEventId = meetingData.providerEventId;
                    MeetingService.save(meeting, Session.getWorkspace(), subject).then(function(meeting) {
                        $scope.meetings.push(meeting);
                    });
                }
            });
        } else {
            $scope.showAppsModal($scope.message('is.ui.apps.tag.collaboration'), true)
        }
    };
    $scope.stopMeeting = function(meeting) {
        var provider = _.find(isSettings.meeting.providers, {id: meeting.provider});
        meeting.endDate = moment().format();
        provider.stopMeeting(meeting, $scope).then(function() {
            MeetingService.update(meeting, Session.getWorkspace()).then(function() {
                $scope.meetings = _.filter($scope.meetings, {endDate: null});
            });
        });
    };
    $scope.authorizedMeeting = MeetingService.authorizedMeeting;
    // Init
    $scope.injector = $injector;
    $scope.$watch('project.simpleProjectApps', function() {
        $scope.providers = _.each(isSettings.meeting.providers, function(provider) {
            provider.enabled = AppService.authorizedApp('use', provider.id, $scope.project);
        });
    }, true);
    $scope.subject = $scope.selected;
    MeetingService.list(Session.getWorkspace(), $scope.subject).then(function(meetings) {
        $scope.meetings = meetings
    });
}]);