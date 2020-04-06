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
    $scope.providersPromoteList = function() {
        return _.map($scope.getMeetingProviders(), 'id');
    };
    $scope.createMeeting = function(subject, provider) {
        if (provider.enabled) {
            $scope.creating = true;
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
                    MeetingService.save(meeting, Session.getWorkspace(), subject).then(function() {
                        $scope.creating = false;
                    });
                } else {
                    $scope.creating = false;
                }
            });
        } else {
            $scope.showAppsModal($scope.message('is.ui.apps.tag.collaboration'), true);
        }
    };
    $scope.stopMeeting = function(meeting) {
        var provider = $scope.getMeetingProvider(meeting.provider);
        var stopMeetingFunction = function() {
            meeting.endDate = moment().format();
            if (provider.stopMeeting) {
                provider.stopMeeting(meeting, $scope).then(function() {
                    MeetingService.update(meeting, Session.getWorkspace());
                });
            } else {
                MeetingService.update(meeting, Session.getWorkspace());
            }
        };
        if ($scope.saveableMeeting(meeting)) {
            $scope.saveMeeting(meeting, stopMeetingFunction);
        } else {
            $scope.confirm({
                message: $scope.message('is.ui.collaboration.stop.confirm'),
                callback: stopMeetingFunction
            });
        }
    };
    $scope.renameMeeting = function(meeting) {
        var ctrlScope = $scope;
        var provider = $scope.getMeetingProvider(meeting.provider);
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
    $scope.saveMeeting = function(meeting, stopMeetingFunction) {
        var provider = $scope.getMeetingProvider(meeting.provider);
        var saveMeetingFunction = function() {
            if (provider.saveMeeting === true) {
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
                provider.saveMeeting(meeting, $scope);
            }
        };
        if (stopMeetingFunction) {
            $scope.dirtyChangesConfirm({
                confirmTitle: $scope.message('is.ui.collaboration.meeting.saveStopMeeting.title'),
                message: $scope.message('is.ui.collaboration.meeting.saveStopMeeting.description'),
                saveChangesCallback: function() {
                    saveMeetingFunction();
                    stopMeetingFunction();
                },
                dontSaveChangesCallback: function() {
                    stopMeetingFunction();
                }
            });
        } else {
            $scope.confirm({
                confirmTitle: $scope.message('is.ui.collaboration.meeting.saveMeeting.title'),
                message: $scope.message('is.ui.collaboration.meeting.saveMeeting.description'),
                callback: saveMeetingFunction
            });
        }
    };
    $scope.saveableMeeting = function(meeting) {
        if ($scope.getMeetingProvider(meeting.provider).saveableMeeting) {
            return (typeof $scope.getMeetingProvider(meeting.provider).saveableMeeting == "boolean" ? $scope.getMeetingProvider(meeting.provider).saveableMeeting : $scope.getMeetingProvider(meeting.provider).saveableMeeting(meeting));
        }
        return $scope.getMeetingProvider(meeting.provider).saveMeeting ? true : false;
    };
    $scope.editableMeetingTopic = function(meeting) {
        if ($scope.getMeetingProvider(meeting.provider).editableMeetingTopic) {
            return (typeof $scope.getMeetingProvider(meeting.provider).editableMeetingTopic == "boolean" ? $scope.getMeetingProvider(meeting.provider).editableMeetingTopic : $scope.getMeetingProvider(meeting.provider).editableMeetingTopic(meeting));
        }
        return $scope.getMeetingProvider(meeting.provider).renameMeeting ? true : false;
    };
    $scope.linkAttributeMeeting = function(providerId, attribute) {
        var linkAttribute = $scope.getMeetingProvider(providerId).link;
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
    MeetingService.list(Session.getWorkspace()).then(function(meetings) {
        $scope.meetings = meetings
    });
    $scope.getFilteredProviders = function() {
        var filteredProviders = _.filter($scope.getMeetingProviders(), ['enabled', true]);
        if (filteredProviders.length <= 3) {
            filteredProviders = _.take(_.sortBy($scope.getMeetingProviders(), [function(o) { return !o.enabled; }]), 3);
        }
        return filteredProviders;
    };
    $scope.$watch('project.simpleProjectApps', function() {
        _.each($scope.getMeetingProviders(), function(provider) {
            provider.enabled = AppService.authorizedApp('use', provider.id, $scope.project);
        });
        $scope.providers = $scope.getMeetingProviders();
    }, true);
}]);