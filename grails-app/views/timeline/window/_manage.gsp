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
<%@ page import="org.icescrum.core.domain.Release" %>
<g:setProvider library="jquery"/>
<g:form action="save" method="post" name="${id}-form" class="box-form box-form-250 box-form-200-legend" tabindex="1">

  <is:fieldset title="is.ui.timeline.release.properties.title">

    <is:fieldInput for="releasename" label="is.release.name">
      <is:input id="releasename" name="release.name" value="${release?.name}"/>
    </is:fieldInput>

    <is:fieldDatePicker for="startDate" label="is.release.startDate">
      <is:datePicker
              id="startDate"
              name="startDate"
              mode="read-input"
              changeMonth="true"
              changeYear="true"
              minDate="${previousRelease && !release ? previousRelease.endDate + 1 : (previousRelease && release ? previousRelease.endDate + 1: product.startDate)}"
              defaultDate="${release ? release.startDate : (previousRelease ? previousRelease.endDate + 1 : product.startDate)}"
              disabled="${release ? release.state == Release.STATE_DONE : false}"/>
    </is:fieldDatePicker>

    <is:fieldDatePicker for="endDate" label="is.release.endDate" noborder="true">
      <is:datePicker
              id="endDate"
              name="endDate"
              minDate="${previousRelease && !release ? previousRelease.endDate + 2 : (previousRelease && release ? previousRelease.endDate + 2: product.startDate + 1)}"
              defaultDate="${release ? release.endDate : (previousRelease ? previousRelease.endDate + 2 : product.startDate + 1)}"
              disabled="${release ? release.state == Release.STATE_DONE : false}"
              mode="read-input"
              changeMonth="true"
              changeYear="true"/>
    </is:fieldDatePicker>

  </is:fieldset>

  <is:fieldset title="is.ui.timeline.release.details.title">
    <is:fieldArea label="is.release.goal" noborder="true" for="releasegoal">
      <is:area id="releasegoal" name="release.goal" value="${release?.goal}" rows="3" />
    </is:fieldArea>
  </is:fieldset>
  
  <g:if test="${currentPanel == 'edit'}">
    <g:hiddenField name="release.version" value="${release.version}"/>
    <g:hiddenField name="release.id" value="${release.id}"/>
  </g:if>

  <is:buttonBar>
    <g:if test="${currentPanel == 'add'}">
      <is:button targetLocation="${controllerName+'/'+actionName}" id="submitAndContinueForm" type="submitToRemote" url="[controller:'timeline', action:'save', params:[continue:true,product:params.product]]" update="window-content-${id}" onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');">${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}</is:button>
      <is:button targetLocation="${controllerName}" id="submitForm" type="submitToRemote" url="[controller:'timeline', action:'save',params:[product:params.product]]" update="window-content-${id}" onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');">${message(code:'is.button.add')}</is:button>
    </g:if>
    <g:if test="${currentPanel == 'edit'}">
      <g:if test="${nextReleaseId}">
        <is:button targetLocation="${controllerName+'/'+actionName+'/'+nextReleaseId}" id="submitAndContinueForm" type="submitToRemote" url="[controller:'timeline', action:'update', params:[continue:true,product:params.product]]" update="window-content-${id}" onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');">${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}</is:button>
      </g:if>
      <is:button targetLocation="${controllerName}" id="submitForm" type="submitToRemote" url="[controller:'timeline', action:'update',params:[product:params.product]]" update="window-content-${id}" onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');">${message(code:'is.button.update')}</is:button>
    </g:if>
    <is:button targetLocation="${controllerName}" id="cancelForm" type="link" button="button-s button-s-black" remote="true" url="[controller:id, action:'index',params:[product:params.product]]" update="window-content-${id}" value="${message(code: 'is.button.cancel')}"/>
   </is:buttonBar>
</g:form>
<jq:jquery>
  $("#releasename").focus();
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  <is:renderNotice />  
</jq:jquery>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.cancelForm();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>