%{--
- Copyright (c) 2020 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
--}%
<script type="text/ng-template" id="meeting.comments.html">
<div ng-controller="meetingCtrl" class="meetings-container">
    <div ng-if="providers && authorizedMeeting('create')"
         class="align-items-center"
         ng-class="{'d-flex':(context && !meetings.length) || (!context && meetings.length), 'd-none':context && meetings,'justify-content-between':!meetings.length, 'justify-content-end':meetings.length}">
        <div class="font-size-sm" ng-if="!meetings.length">
            <b>${message(code: 'is.ui.collaboration.start')}</b>
        </div>
        <div ng-class="{'meetings-provider-sm': meetings.length}">
            <a href
               ng-repeat="provider in ::providers"
               ng-click="createMeeting(selected, provider)"
               class="meeting-provider-container"
               ng-class="{'disabled': !provider.enabled}">
                <span class="meeting-provider meeting-provider-{{:: provider.id }}" title="{{:: provider.name }}"></span>
            </a>
        </div>
    </div>
    <div ng-repeat="meeting in meetings" ng-if="authorizedMeeting('view') && meeting && !meeting.endDate" class="d-flex align-items-center">
        <span class="meeting-provider meeting-provider-current float-left mr-2 mt-1 meeting-provider-{{:: meeting.provider }}" title="{{:: provider.name }}"></span>
        <div class="font-size-sm flex-grow-1">
            <div>
                <a href="{{:: meeting.videoLink }}" class="link"><b>${message(code: 'is.ui.collaboration.meeting.title')} {{:: meeting.subject}}</b></a><br/>
                <span ng-if="::meeting.phone">${message(code: 'is.ui.collaboration.join.phone')} <b><a class="link" href="tel:{{:: meeting.phone }}">{{:: meeting.phone }}</b></a></span>
                <span ng-if="::meeting.pinCode">- {{:: meeting.pinCode }}#</span>
            </div>
            ${message(code: 'is.ui.collaboration.by')} {{:: meeting.owner.firstName }} {{:: meeting.owner.lastName }} (<span class="time-stamp"><time timeago datetime="{{ meeting.startDate }}">{{ meeting.startDate | dateTime }}</time></span>)
        </div>
        <a class="btn btn-secondary btn-sm hover-display"
           target="_blank"
           href="{{:: meeting.videoLink }}">${message(code: 'is.ui.collaboration.join')}</a>
        <a class="btn btn-secondary btn-danger ml-2 btn-sm hover-display"
           target="_blank"
           ng-if="authorizedMeeting('update', meeting)"
           ng-click="stopMeeting(meeting)" href>${message(code: 'is.ui.collaboration.stop')}</a>
    </div>
</div>
</script>