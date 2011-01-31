%{--
- Copyright (c) 2010 iceScrum Technologies.
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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
  <input type="hidden" name="productd.id" value="${params.product}">
  <input type="hidden" name="product" value="${params.product}">
  <input type="hidden" name="productd.version" value="${product.version}">
  <is:fieldset title="is.dialog.project.properties.title">
    <is:fieldInput for="productname" label="is.product.name">
      <is:input id="productname" name="productd.name" value="${product.name}"/>
    </is:fieldInput>
    <is:fieldInput for="productkey" label="is.product.pkey">
      <is:input id="productkey" name="productd.pkey" value="${product.pkey}"/>
    </is:fieldInput>
    <is:fieldArea for="productdescription" label="is.product.description" noborder="true">
      <is:area
              rich="[preview:true,width:330]"
              id="productdescription"
              name="productd.description"
              value="${product.description}"/>
    </is:fieldArea>
  </is:fieldset>
  <is:fieldset nolegend="true" title="is.dialog.project.preferences.title">
    <is:accordion id="preferences" autoHeight="false">

      <is:accordionSection title="is.dialog.project.preferences.project.title">
        <is:fieldRadio rendered="${!privateOption}" for="productpreferenceshidden" label="is.product.preferences.project.hidden">
          <is:radio id="productpreferenceshidden" name="productd.preferences.hidden" value="${product.preferences.hidden}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesnewTeams" label="is.product.preferences.project.newTeams">
          <is:radio id="productpreferencesnewTeams" name="productd.preferences.newTeams" value="${product.preferences.newTeams}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferenceslockPo" label="is.product.preferences.project.lockPo">
          <is:radio id="productpreferenceslockPo" name="productd.preferences.lockPo" value="${product.preferences.lockPo}"/>
        </is:fieldRadio>
      </is:accordionSection>

      <is:accordionSection title="is.dialog.project.preferences.planification.title">
        <is:fieldSelect for="product.planningPokerGameType" label="is.product.preferences.planification.estimationSuite">
          <is:select from="${estimationSuitSelect.values().asList()}" keys="${estimationSuitSelect.keySet().asList()}" width="240" maxHeight="100" styleSelect="dropdown" name="productd.planningPokerGameType" value="${product.planningPokerGameType}"/>
        </is:fieldSelect>
        <is:fieldInput for="productpreferencesestimatedSprintsDuration" label="is.product.preferences.planification.estimatedSprintsDuration">
          <is:input id="productpreferencesestimatedSprintsDuration" typed="[type:'numeric']" name="productd.preferences.estimatedSprintsDuration" value="${product.preferences.estimatedSprintsDuration}"/>
        </is:fieldInput>
        <is:fieldRadio for="productpreferencesnoEstimation" label="is.product.preferences.planification.noEstimation">
          <is:radio id="productpreferencesnoEstimation" name="productd.preferences.noEstimation" value="${product.preferences.noEstimation}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferenceshideweekend" label="is.product.preferences.project.hideWeekend" noborder="true">
          <is:radio id="productpreferenceshideweekend" name="productd.preferences.hideWeekend" value="${product.preferences.hideWeekend}"/>
        </is:fieldRadio>
      </is:accordionSection>

      <is:accordionSection title="is.dialog.project.preferences.sprint.title">
        <is:fieldRadio for="productpreferencesautoDoneStory" label="is.product.preferences.sprint.autoDoneStory">
          <is:radio id="productpreferencesautoDoneStory" name="productd.preferences.autoDoneStory" value="${product.preferences.noEstimation}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesautoCreateTaskOnEmptyStory" label="is.product.preferences.sprint.autoCreateTaskOnEmptyStory">
          <is:radio id="productpreferencesautoCreateTaskOnEmptyStory" name="productd.preferences.autoCreateTaskOnEmptyStory" value="${product.preferences.autoCreateTaskOnEmptyStory}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesassignOnCreateTask" label="is.product.preferences.sprint.assignOnCreateTask">
          <is:radio id="productpreferencesassignOnCreateTask" name="productd.preferences.assignOnCreateTask" value="${product.preferences.assignOnCreateTask}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesassignOnBeginTask" label="is.product.preferences.sprint.assignOnBeginTask">
          <is:radio id="productpreferencesassignOnBeginTask" name="productd.preferences.assignOnBeginTask" value="${product.preferences.assignOnBeginTask}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesdisplayRecurrentTasks" label="is.product.preferences.sprint.displayRecurrentTasks" noborder="true">
          <is:radio id="productpreferencesdisplayRecurrentTasks" name="productd.preferences.displayRecurrentTasks" value="${product.preferences.displayRecurrentTasks}"/>
        </is:fieldRadio>
      </is:accordionSection>

      <is:accordionSection title="is.dialog.project.preferences.sprintTasks.title">
        <is:fieldRadio for="productpreferencesdisplayUrgentTasks" label="is.product.preferences.sprint.displayUrgentTasks">
          <is:radio id="productpreferencesdisplayUrgentTasks" name="productd.preferences.displayUrgentTasks" value="${product.preferences.displayUrgentTasks}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesLimitUrgentTasks" label="is.product.preferences.sprint.limitUrgentTasks" noborder="true">
          <is:input id="productpreferencesLimitUrgentTasks" name="productd.preferences.limitUrgentTasks" typed="[type:'numeric']" value="${product.preferences.limitUrgentTasks}"/>
        </is:fieldRadio>
      </is:accordionSection>

      <is:accordionSection title="is.dialog.project.preferences.meetingHours.title">
        <is:fieldTimePicker for="productpreferencesreleasePlanningHour" label="is.product.preferences.meetingHours.releasePlanningHour">
          <is:timePicker id="productpreferencesreleasePlanningHour" mode="read-input" hourGrid="4" stepMinute="15" minuteGrid="15" value="${product.preferences.releasePlanningHour}" timeFormat="h:mm" name="productd.preferences.releasePlanningHour"/>
        </is:fieldTimePicker>
        <is:fieldTimePicker for="productpreferencessprintPlanningHour" label="is.product.preferences.meetingHours.sprintPlanningHour">
          <is:timePicker id="productpreferencessprintPlanningHour" mode="read-input" hourGrid="4" stepMinute="15" minuteGrid="15" value="${product.preferences.sprintPlanningHour}" timeFormat="h:mm" name="productd.preferences.sprintPlanningHour"/>
        </is:fieldTimePicker>
        <is:fieldTimePicker for="productpreferencesdailyMeetingHour" label="is.product.preferences.meetingHours.dailyMeetingHour">
          <is:timePicker id="productpreferencesdailyMeetingHour" mode="read-input" hourGrid="4" stepMinute="15" minuteGrid="15" value="${product.preferences.dailyMeetingHour}" timeFormat="h:mm" name="productd.preferences.dailyMeetingHour"/>
        </is:fieldTimePicker>
        <is:fieldTimePicker for="productpreferencessprintReviewHour" label="is.product.preferences.meetingHours.sprintReviewHour">
          <is:timePicker id="productpreferencessprintReviewHour" mode="read-input" hourGrid="4" stepMinute="15" minuteGrid="15" value="${product.preferences.sprintReviewHour}" timeFormat="h:mm" name="productd.preferences.sprintReviewHour"/>
        </is:fieldTimePicker>
        <is:fieldTimePicker for="productpreferencessprintRetrospectiveHour" label="is.product.preferences.meetingHours.sprintRetrospectiveHour">
          <is:timePicker id="productpreferencessprintRetrospectiveHour" mode="read-input" hourGrid="4" stepMinute="15" minuteGrid="15" value="${product.preferences.sprintRetrospectiveHour}" timeFormat="h:mm" name="productd.preferences.sprintRetrospectiveHour"/>
        </is:fieldTimePicker>
      </is:accordionSection>
    </is:accordion>
  </is:fieldset>
  <sec:access expression="owner()">
    <is:fieldset title="is.dialog.project.others.title" nolegend="true">
      <button onClick="
        if (confirm('${message(code:'is.dialog.project.others.delete.button').encodeAsJavaScript()}')) {
          ${g.remoteFunction(action:'delete',
                             controller:'project',
                             params:[product:params.product],
                             onSuccess:'document.location=data.url;')
           };
        }
        return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
        <g:message code="is.dialog.project.others.delete.button"/>
      </button>
    </is:fieldset>
  </sec:access>
</form>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-project" listenOn="'#form-project input'"/>