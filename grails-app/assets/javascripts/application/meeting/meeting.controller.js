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
extensibleController('meetingCtrl', ['$scope', '$injector', '$uibModal', 'AppService', 'MeetingService', 'FormService', 'AttachmentService', 'Meeting', 'Session', 'relevantMeetingsFilter', function($scope, $injector, $uibModal, AppService, MeetingService, FormService, AttachmentService, Meeting, Session, relevantMeetingsFilter) {
    // Functions
    $scope.createMeeting = function(subject, provider) {
        if (provider.enabled) {
            var meeting = new Meeting();
            meeting.provider = provider.id;
            if (subject) {
                meeting.topic = $scope.message('is.' + subject.class.toLowerCase()) + (subject.uid ? ' ' + subject.uid + ' ' : '') + ' - ' + subject.name;
            } else {
                meeting.topic = $scope.message('is.ui.collaboration.meeting.default');
            }
            meeting.startDate = moment().format();
            if (subject) {
                meeting.subjectId = subject.id;
                meeting.subjectType = subject.class;
            }
            provider.createMeeting(subject, meeting, $scope).then(function(meetingData) {
                if (meetingData && (meetingData.videoLink || meetingData.phone)) {
                    meeting.videoLink = meetingData.videoLink;
                    meeting.phone = meetingData.phone ? meetingData.phone : null;
                    meeting.pinCode = meetingData.pinCode ? meetingData.pinCode : null;
                    meeting.providerEventId = meetingData.providerEventId;
                    MeetingService.save(meeting, Session.getWorkspace(), subject);
                }
            });
        } else {
            $scope.showAppsModal($scope.message('is.ui.apps.tag.collaboration'), true)
        }
    };
    $scope.stopMeeting = function(meeting) {
        var provider = _.find($scope.getMeetingProviders(), {id: meeting.provider});
        meeting.endDate = moment().format();
        if (provider.saveAsAttachment) {
            $scope.confirm({
                confirmTitle: $scope.message('is.ui.collaboration.meeting.saveAsAttachment.title'),
                buttonTitle: $scope.message('is.ui.collaboration.meeting.saveAsAttachment.save'),
                message: $scope.message('is.ui.collaboration.meeting.saveAsAttachment.description'),
                callback: function() {
                    if (provider.saveAsAttachment === true) {
                        var attachmentBaseUrl = $scope.serverUrl + '/' + Session.workspaceType + '/' + Session.workspace.id + '/attachment/';
                        var file = {
                            url: meeting.videoLink,
                            name: meeting.topic,
                            provider: meeting.provider,
                            length: 0
                        };
                        FormService.httpPost(attachmentBaseUrl + meeting.subjectType + '/' + $scope.attachmentable.id + '/flow', file).then(function(attachment) {
                            AttachmentService.addToAttachmentable(attachment, $scope.attachmentable);
                        });
                    } else {
                        provider.saveAsAttachment(meeting, $scope);
                    }
                }
            })
        }
        if (provider.stopMeeting) {
            provider.stopMeeting(meeting, $scope).then(function() {
                MeetingService.update(meeting, Session.getWorkspace());
            });
        } else {
            MeetingService.update(meeting, Session.getWorkspace());
        }
    };
    $scope.renameMeeting = function(meeting) {
        var ctrlScope = $scope;
        var provider = _.find($scope.getMeetingProviders(), {id: meeting.provider});
        if (provider.renameMeeting) {
            var modal = $uibModal.open({
                templateUrl: 'renameMeeting.modal.html',
                size: 'sm',
                controller: ["$scope", "hotkeys", function($scope, hotkeys) {
                    $scope.newTopic = meeting.topic;
                    $scope.submit = function() {
                        meeting.topic = $scope.newTopic;
                        provider.renameMeeting(meeting, ctrlScope).then(function() {
                            MeetingService.update(meeting, Session.getWorkspace());
                        });
                        $scope.$close(true);
                    };
                }]
            });
        }
    };
    $scope.editableMeetingTopic = function(providerId) {
        return _.find($scope.getMeetingProviders(), function(provider) {
            return provider.id == providerId;
        }).renameMeeting ? true : false;
    };
    $scope.linkAttributeMeeting = function(providerId, attribute) {
        var linkAttribute = _.find($scope.getMeetingProviders(), function(provider) {
            return provider.id == providerId
        }).link;
        return linkAttribute && linkAttribute[attribute] ? linkAttribute[attribute] : '';
    };
    $scope.copyLink = function(meeting) {
        FormService.copyToClipboard(meeting.videoLink).then(function() {
            $scope.notifySuccess('is.ui.colloboration.meeting.link.success');
        }, function(text) {
            $scope.notifyError(message('is.ui.colloboration.meeting.link.error', [text]));
        });
    };
    $scope.hasMeetings = function() {
        return relevantMeetingsFilter($scope.meetings, $scope.subject).length;
    };
    $scope.authorizedMeeting = MeetingService.authorizedMeeting;
    // Init
    $scope.injector = $injector;
    $scope.$watch('project.simpleProjectApps', function() {
        $scope.providers = _.each($scope.getMeetingProviders(), function(provider) {
            provider.enabled = AppService.authorizedApp('use', provider.id, $scope.project);
        });
    }, true);
    MeetingService.list(Session.getWorkspace()).then(function(meetings) {
        $scope.meetings = meetings
    });
}]);