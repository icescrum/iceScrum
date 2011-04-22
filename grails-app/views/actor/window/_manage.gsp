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

<g:setProvider library="jquery"/>
<g:form action="save" method="post" name="${id}-form" class="box-form box-form-250 box-form-200-legend" tabindex="1">

  <is:fieldset title="is.ui.actor.actor.properties.title">
    <is:fieldInput label="is.actor" for="actorname">
      <is:input name="actor.name" id="actorname" value="${actor?.name}"/>
    </is:fieldInput>

    <is:fieldSelect label="is.actor.instances" for="actor.instances">
      <is:select container="#window-content-${id}" width="100" maxHeight="200" styleSelect="dropdown" from="${instancesValues}" keys="${instancesKeys}" name="actor.instances" value="${actor?.instances}"/>
    </is:fieldSelect>

    <is:fieldSelect label="is.actor.it.level" for="actor.expertnessLevel">
      <is:select container="#window-content-${id}" width="100" maxHeight="200" styleSelect="dropdown" from="${levelsValues}" keys="${levelsKeys}" name="actor.expertnessLevel" value="${actor?.expertnessLevel}"/>
    </is:fieldSelect>

    <is:fieldSelect label="is.actor.use.frequency" for="actor.useFrequency">
      <is:select container="#window-content-${id}" width="100" maxHeight="200" styleSelect="dropdown" from="${frequenciesValues}" keys="${frequenciesKeys}" name="actor.useFrequency" value="${actor?.useFrequency}"/>
    </is:fieldSelect>

    <is:fieldArea for="actordescription" label="is.backlogelement.description">
      <is:area id="actordescription" name="actor.description" value="${actor?.description}" rows="3"/>
    </is:fieldArea>

    <is:fieldArea for="actorsatisfactionCriteria" label="is.actor.satisfaction.criteria" noborder="true">
      <is:area id="actorsatisfactionCriteria" name="actor.satisfactionCriteria" value="${actor?.satisfactionCriteria}" rows="3"/>
    </is:fieldArea>

  </is:fieldset>

  <is:fieldset title="is.ui.actor.actor.attachment.title">
    <is:fieldFile for='actor.attachments' label="is.backlogelement.attachment" noborder="true">
        <is:multiFilesUpload elementId="actorattachments"
                      name="attachments"
                      bean="${actor}"
                      urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                      params="[product:params.product]"
                      progress="[
                        url:createLink(action:'uploadStatus',controller:'scrumOS'),
                        label:message(code:'is.upload.wait')
                      ]"/>
    </is:fieldFile>
  </is:fieldset>

  <is:fieldset title="is.ui.actor.actor.notes.title">
    <is:fieldArea for="actornotes" label="is.backlogelement.notes" noborder="true">
      <is:area
              rich="[preview:true,fillWidth:true,margin:250,height:250]"
              id="actornotes"
              name="actor.notes"
              value="${actor?.notes}"/>
    </is:fieldArea>
  </is:fieldset>

  <g:if test="${currentPanel == 'edit'}">
    <g:hiddenField name="actor.version" value="${actor?.version}"/>
    <g:hiddenField name="actor.id" value="${actor?.id}"/>
  </g:if>

  <is:buttonBar>
    <g:if test="${currentPanel == 'add'}">
      <is:button
              targetLocation="${controllerName+'/'+actionName}"
              id="submitAndContinueForm"
              type="submitToRemote"
              url="[controller:'actor', action:'save', params:[product:params.product,continue:true]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
      <is:button
              targetLocation="${controllerName}"
              id="submitForm"
              type="submitToRemote"
              url="[controller:'actor', action:'save', params:[product:params.product]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.add')}"/>
    </g:if>
    <g:if test="${currentPanel == 'edit'}">
      <g:if test="${nextActorId}"> 
        <is:button
                targetLocation="${controllerName+'/'+actionName+'/'+nextActorId}"
                id="submitAndContinueForm"
                type="submitToRemote"
                url="[controller:'actor', action:'update', params:[product:params.product,continue:true]]"
                update="window-content-${id}"
                before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
      </g:if>
      <is:button
              targetLocation="${controllerName}"
              id="submitForm"
              type="submitToRemote"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              url="[controller:'actor', action:'update', params:[product:params.product]]"
              update="window-content-${id}"
              value="${message(code:'is.button.update')}"/>
    </g:if>
    <is:button id="cancelForm" type="link" button="button-s button-s-black" remote="true" url="[controller:id, action:'list']" update="window-content-${id}" value="${message(code: 'is.button.cancel')}"/>
  </is:buttonBar>
</g:form>
<jq:jquery>
  $("#actorname").focus();
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  <is:renderNotice />
</jq:jquery>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.cancelForm();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>