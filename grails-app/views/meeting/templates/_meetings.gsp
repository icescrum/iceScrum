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
<script type="text/ng-template" id="meetings.html">
<div ng-repeat="meeting in meetings | relevantMeetings: subject"
     ng-if="authorizedMeeting('view') && meeting && !meeting.endDate">
    <div class="d-flex align-items-center hover-container">
        <span class="meeting-provider meeting-provider-current float-left mr-2 mt-1 meeting-provider-{{:: meeting.provider }}" title="{{:: provider.name }}"></span>
        <div class="font-size-sm flex-grow-1">
            <div>
                <a href="{{:: meeting.videoLink }}"
                   title="{{ meeting.topic }}"
                   target="_blank"
                   class="link"
                   rel="{{:: linkAttributeMeeting(meeting.provider, 'rel') }}"
                   referrerpolicy="{{:: linkAttributeMeeting(meeting.provider, 'referrerpolicy') }}">
                    <b>{{ meeting.topic |ellipsis:60 }}</b>
                </a><br/>
                <span ng-if="::meeting.phone">
                    ${message(code: 'is.ui.collaboration.join.phone')} <b><a class="link" href="tel:{{:: meeting.phone }}">{{:: meeting.phone }}</a></b>
                </span>
                <span ng-if="::meeting.pinCode">- {{:: meeting.pinCode }}#</span>
            </div>
            ${message(code: 'is.ui.collaboration.by')} {{:: meeting.owner | userFullName }} (<span class="time-stamp"><time timeago datetime="{{ meeting.startDate }}">{{ meeting.startDate | dateTime }}</time></span>)
        </div>
        <a class="btn btn-secondary btn-sm hover-display mr-2"
           ng-if="saveableMeeting(meeting) && authorizedMeeting('update', meeting)"
           ng-click="saveMeeting(meeting)"
           href>${message(code: 'is.ui.collaboration.meeting.save')}</a>
        <a class="btn btn-secondary btn-sm hover-display mr-2"
           ng-if="editableMeetingTopic(meeting) && authorizedMeeting('update', meeting)"
           ng-click="renameMeeting(meeting)"
           href>${message(code: 'is.ui.collaboration.meeting.rename')}</a>
        <a class="btn btn-secondary btn-sm hover-display mr-2"
           ng-click="copyLink(meeting)"
           href>${message(code: 'is.ui.collaboration.meeting.link')}</a>
        <a class="btn btn-secondary btn-sm hover-display mr-2"
           target="_blank"
           rel="{{:: linkAttributeMeeting(meeting.provider, 'rel') }}"
           referrerpolicy="{{:: linkAttributeMeeting(meeting.provider, 'referrerpolicy') }}"
           href="{{:: meeting.videoLink }}">${message(code: 'is.ui.collaboration.join')}</a>
        <a class="meeting-icon meeting-stop-red ml-2 hover-display"
           target="_blank"
           ng-if="authorizedMeeting('update', meeting)"
           title="${message(code: 'is.ui.collaboration.stop')}"
           ng-click="stopMeeting(meeting)" href></a>
    </div>
    <hr ng-if="!$last" class="w-50"/>
</div>
</script>
<script type="text/ng-template" id="renameMeeting.modal.html">
<is:modal form="submit()"
          validate="true"
          name="renameMeetingForm"
          submitButton="${message(code: 'is.ui.collaboration.meeting.rename')}"
          submitButtonColor="primary"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.ui.collaboration.meeting.rename.title')}">
    <input type="text"
           class="form-control"
           autofocus
           required
           name="newTopic"
           ng-model="newTopic"/>
</is:modal>
</script>