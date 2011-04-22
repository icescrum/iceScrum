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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<g:form action="save" name="${id}-form" method="post" class="box-form box-form-250 box-form-200-legend" tabindex="1">

  <is:fieldset title="is.ui.sprintBacklog.task.properties.title">

    <is:fieldInput for="taskname" label="is.task.name">
      <is:input id="taskname" name="task.name" value="${task?.name}"/>
    </is:fieldInput>

    <is:fieldSelect label="is.task.story">
      <is:select name="story.id" container="#window-content-${id}" width="240" maxHeight="200" styleSelect="dropdown" from="${stories}" value="${selected?.id}" optionValue="name" optionKey="id"/>
    </is:fieldSelect>

    <is:fieldInput for="taskestimation" label="is.task.estimation">
      <is:input id="taskestimation" name="task.estimation" value="${task?.estimation}" typed="[type:'numeric']"/>
    </is:fieldInput>

    <is:fieldArea for="taskdescription" label="is.backlogelement.description" noborder="true">
      <is:area id="taskdescription" name="task.description" value="${task?.description}" large="true" rows="7"/>
    </is:fieldArea>

  </is:fieldset>

  <is:fieldset title="is.ui.sprintBacklog.task.attachment.title">
    <is:fieldFile for='task.attachments' label="is.backlogelement.attachment" noborder="true">
        <is:multiFilesUpload elementId="taskattachments"
                      name="attachments"
                      bean="${task}"
                      urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                      params="[product:params.product]"
                      progress="[
                        url:createLink(action:'uploadStatus',controller:'scrumOS'),
                        label:message(code:'is.upload.wait')
                      ]"/>
    </is:fieldFile>
  </is:fieldset>

  <is:fieldset title="is.ui.sprintBacklog.task.notes.title">
    <is:fieldArea label="is.backlogelement.notes" noborder="true">
      <is:area
              rich="[preview:true,fillWidth:true,margin:250,height:250]"
              id="tasknotes"
              name="task.notes"
              value="${task?.notes}"/>
    </is:fieldArea>
  </is:fieldset>

  <g:if test="${currentPanel == 'edit'}">
    <g:hiddenField name="task.version" value="${task.version}"/>
    <g:hiddenField name="task.id" value="${task.id}"/>
  </g:if>

  <is:buttonBar>
    <g:if test="${currentPanel == 'add'}">
      <is:button
              targetLocation="${controllerName+'/'+actionName}/${sprint.id}"
              id="submitAndContinueForm"
              type="submitToRemote"
              url="[controller:'sprintBacklog', action:'save',id:sprint.id,params:[product:params.product,continue:true]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
      <is:button targetLocation="${controllerName+'/'+sprint.id}"
              id="submitForm"
              type="submitToRemote"
              url="[controller:'sprintBacklog', action:'save',id:sprint.id, params:[product:params.product]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.add')}"/>
    </g:if>
    <g:if test="${currentPanel == 'edit'}">
      <g:if test="${nextTaskId}">
        <is:button
                targetLocation="${controllerName+'/'+actionName}/${nextTaskId}"
                id="submitAndContinueForm"
                type="submitToRemote"
                url="[controller:'sprintBacklog', action:'update',params:[product:params.product,continue:true]]"
                update="window-content-${id}"
                before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
      </g:if>
      <is:button
              targetLocation="${controllerName+'/'+sprint.id}"
              id="submitForm"
              type="submitToRemote"
              url="[controller:'sprintBacklog', action:'update',params:[product:params.product]]"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              update="window-content-${id}"
              value="${message(code:'is.button.update')}"/>
    </g:if>
    <is:button
            targetLocation="${controllerName+'/'+sprint.id}"
            id="cancelForm"
            type="link"
            button="button-s button-s-black"
            remote="true"
            url="[controller:id, action:'index',id:sprint.id, params:[product:params.product]]"
            update="window-content-${id}"
            value="${message(code: 'is.button.cancel')}"/>
  </is:buttonBar>
  
</g:form>
<jq:jquery>
  $("#taskname").focus();
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  <is:renderNotice/>
</jq:jquery>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.cancelForm();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>