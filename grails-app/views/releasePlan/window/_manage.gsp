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
- Vincent Barrier (vbarrier@kagilum.com)
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:setProvider library="jquery"/>
<g:form action="save" method="post" name="${id}-form" class="box-form box-form-250 box-form-200-legend" tabindex="1">
  <is:fieldset title="is.ui.releasePlan.sprint.properties.title">
    <is:fieldArea for="sprintgoal" label="is.sprint.goal">
      <is:area id="sprintgoal" large="true" name="sprint.goal" value="${sprint?.goal}"/>
    </is:fieldArea>

    %{-- Start Date --}%
    <is:fieldDatePicker for="startDate" label="is.sprint.startDate">
      <is:datePicker id="startDate" name="startDate" mode="read-input" changeMonth="true" changeYear="true" minDate="${previousSprint && !sprint ? previousSprint.endDate + 1 : release.startDate}" maxDate="${release.endDate}" defaultDate="${sprint ? sprint.startDate : (previousSprint ? previousSprint.endDate + 1 : release.startDate)}" disabled="${sprint ? sprint.state >= org.icescrum.core.domain.Sprint.STATE_INPROGRESS : false}"/>
    </is:fieldDatePicker>

    %{-- End Date --}%
    <is:fieldDatePicker for="endDate" label="is.sprint.endDate">
      <is:datePicker id="endDate" name="endDate" mode="read-input" changeMonth="true" changeYear="true" minDate="${previousSprint && !sprint ? previousSprint.endDate + 2 : release.startDate+1}" maxDate="${release.endDate}" defaultDate="${sprint ? sprint.endDate : (previousSprint ? previousSprint.endDate : release.startDate) + product.preferences.estimatedSprintsDuration}"/>
    </is:fieldDatePicker>

    <is:fieldInput for="sprintresource" label="is.sprint.resource" noborder="true">
        <is:input id="sprintresource" name="sprint.resource" value="${sprint?.resource}" typed="[type:'numeric']"/>
    </is:fieldInput>
  </is:fieldset>                         

  <is:buttonBar>
    <g:if test="${currentPanel == 'add'}">
      <is:button targetLocation="${controllerName+'/'+actionName}/${release.id}" id="submitAndContinueForm" type="submitToRemote" url="[controller:id, action:'save',id:release.id, params:[continue:true,product:params.product]]" update="window-content-${id}" value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
      <is:button targetLocation="${controllerName+'/'+release.id}" id="submitForm" type="submitToRemote" url="[controller:id, action:'save',id:release.id,params:[product:params.product]]" update="window-content-${id}" value="${message(code:'is.button.add')}"/>
    </g:if>
    <g:if test="${currentPanel == 'edit'}">
      <g:hiddenField name="sprint.version" value="${sprint.version}"/>
      <g:hiddenField name="sprint.id" value="${sprint.id}"/>
      <g:if test="${nextSprintId}">
        <is:button targetLocation="${controllerName+'/'+actionName}/${nextSprintId}" id="submitAndContinueForm" type="submitToRemote" url="[controller:id, action:'update',id:sprint.id, params:[continue:true,product:params.product]]" update="window-content-${id}" value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
      </g:if>
      <is:button targetLocation="${controllerName+'/'+release.id}" id="submitForm" type="submitToRemote" url="[controller:id, action:'update',id:sprint.id,params:[product:params.product]]" update="window-content-${id}" value="${message(code:'is.button.update')}"/>
    </g:if>
    <is:button targetLocation="${controllerName+'/'+release.id}" id="cancelForm" type="link" button="button-s button-s-black" remote="true" url="[controller:id, action:'index',id:release.id, params:[product:params.product]]" update="window-content-${id}" value="${message(code: 'is.button.cancel')}"/>
  </is:buttonBar>
</g:form>
<jq:jquery>
  $("#sprintresource").focus();
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  <is:renderNotice />
</jq:jquery>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.cancelForm();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
