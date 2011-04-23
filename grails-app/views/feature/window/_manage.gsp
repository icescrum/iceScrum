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

  <is:fieldset title="is.ui.feature.feature.properties.title">
    <is:fieldInput for="featurename" label="is.feature.name">
      <is:input id="featurename" name="feature.name" value="${feature?.name}"/>
    </is:fieldInput>

    <is:fieldArea for="featuredescription" label="is.backlogelement.description">
      <is:area id="featuredescription" large="true" name="feature.description" value="${feature?.description}"/>
    </is:fieldArea>

    <is:fieldSelect for="feature.rank" label="is.feature.rank">
      <is:select container="#window-content-feature" width="100" maxHeight="200" styleSelect="dropdown" from="${rankList}" name="feature.rank" value="${feature?.rank?:rankList.last()}"/>
    </is:fieldSelect>

    <is:fieldSelect for="feature.value" label="is.feature.value">
      <is:select container="#window-content-${id}" width="100" maxHeight="200" styleSelect="dropdown" from="${valuesList}" name="feature.value" value="${feature?.value}"/>
    </is:fieldSelect>

    <is:fieldSelect for="feature.type" label="is.feature.type">
      <is:select container="#window-content-feature" width="100" maxHeight="200" styleSelect="dropdown" from="${typesNames}" keys="${typesId}" name="feature.type" value="${feature?.type}"/>
    </is:fieldSelect>


    <is:fieldSelect for="featureColor" label="is.feature.color" noborder="true">
      <is:select class="featureColor" container="#window-content-feature" width="100" maxHeight="200" styleSelect="dropdown" from="${colorsLabels}" keys="${colorsKeys}" name="feature.color" value="${feature?.color}" onchange="\$('#postit-ipsum-1').find('.postit-layout').removeClass().addClass('postit-layout postit-'+this.value);"/>

    </is:fieldSelect>
    <div class="select-lorem">
    <is:postit color="${feature?.color ?: 'blue' }" title="Lorem ipsum dolor" id="1" miniId="1" type="ipsum" stateBundle="Ipsum">
      Lorem ipsum dolor sit amet, consectetur...
    </is:postit>
    </div>
  </is:fieldset>

  <is:fieldset title="is.ui.feature.feature.attachment.title">
    <is:fieldFile for='feature.attachments' label="is.backlogelement.attachment" noborder="true">
        <is:multiFilesUpload elementId="featureattachments"
                      name="attachments"
                      bean="${feature}"
                      urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                      params="[product:params.product]"
                      progress="[
                        url:createLink(action:'uploadStatus',controller:'scrumOS'),
                        label:message(code:'is.upload.wait')
                      ]"/>
    </is:fieldFile>
  </is:fieldset>

  <is:fieldset title="is.ui.feature.feature.notes.title">
    <is:fieldArea for="featurenotes" label="is.backlogelement.notes" noborder="true">
      <is:area
              rich="[preview:true,fillWidth:true,margin:250,height:250]"
              id="featurenotes"
              name="feature.notes"
              value="${feature?.notes}"/>
    </is:fieldArea>
  </is:fieldset>

  <g:if test="${currentPanel == 'edit'}">
    <g:hiddenField name="feature.version" value="${feature.version}"/>
    <g:hiddenField name="feature.id" value="${feature.id}"/>
  </g:if>

  <is:buttonBar>
    <g:if test="${currentPanel == 'add'}">
      <is:button
              targetLocation="${controllerName+'/'+actionName}"
              id="submitAndContinueForm"
              type="submitToRemote"
              url="[controller:'feature', action:'save', params:[continue:true,product:params.product]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
      <is:button
              targetLocation="${controllerName}"
              id="submitForm"
              type="submitToRemote"
              url="[controller:'feature', action:'save',params:[product:params.product]]"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              update="window-content-${id}"
              value="${message(code:'is.button.add')}"/>
    </g:if>
    <g:if test="${currentPanel == 'edit'}">
      <g:if test="${nextFeatureId}">
        <is:button
                targetLocation="${controllerName+'/'+actionName+'/'+nextFeatureId}"
                id="submitAndContinueForm"
                type="submitToRemote"
                url="[controller:'feature', action:'update', params:[continue:true,product:params.product]]"
                update="window-content-${id}"
                before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
      </g:if>
      <is:button
              targetLocation="${controllerName}"
              id="submitForm"
              type="submitToRemote"
              url="[controller:'feature', action:'update',params:[product:params.product]]"
              update="window-content-${id}"
              before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
              value="${message(code:'is.button.update')}"/>
    </g:if>
    <is:button id="cancelForm"
            type="link"
            button="button-s button-s-black"
            remote="true"
            url="[controller:id, action:'list',params:[product:params.product]]"
            update="window-content-${id}"
            value="${message(code: 'is.button.cancel')}"/>
  </is:buttonBar>
  
</g:form>
<jq:jquery>
  $("#featurename").focus();
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  <is:renderNotice />  
</jq:jquery>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.cancelForm();" scope="${id}" listenOn="'#${id}-form, #${id}-form input'"/>