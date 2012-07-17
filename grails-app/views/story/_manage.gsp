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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<g:form action="save" method="post" name="${referrer}-form" elemid="${story?.id?:null}" class="box-form box-form-250 box-form-200-legend"
        tabindex="1">
    <is:fieldset title="is.ui.backlog.story.properties.title">
        <is:fieldInput for="storyname" label="is.story.name">
            <is:input id="storyname" name="story.name" value="${story?.name}" focus="true"/>
        </is:fieldInput>

    %{-- Type --}%
        <is:fieldSelect for="story.type" label="is.story.type">
            <is:select
                    container=".window-content"
                    width="240"
                    maxHeight="200"
                    styleSelect="dropdown"
                    from="${typesLabels}"
                    keys="${typesKeys}"
                    name="story.type"
                    value="${story?.type}"/>
        </is:fieldSelect>

        <is:fieldSelect label="is.feature" for="story.feature">
            <is:select container=".window-content" width="195" maxHeight="200"
                       styleSelect="dropdown"
                       name="feature.id" noSelection="['':message(code:'is.ui.backlog.choose.feature')]"
                       optionValue="name" optionKey="id" from="${featureSelect}"
                       value="${story?.feature?.id}"/>
        </is:fieldSelect>

        <g:if test="${rankList}">
            <is:fieldSelect label="is.story.rank" for="story.rank">
                <is:select container=".window-content" width="100" maxHeight="200"
                           styleSelect="dropdown"
                           from="${rankList}" name="story.rank" value="${story.rank}"/>
            </is:fieldSelect>
        </g:if>

        <g:if test="${sprints}">
            <is:fieldSelect label="is.sprint" for="sprint.id">
                <is:select container=".window-content" width="195" maxHeight="200"
                           styleSelect="dropdown"
                           keys="${sprints*.id}"
                           noSelection="['':message(code:'is.ui.backlog.choose.sprint')]"
                           from="${sprints*.name}" name="sprint.id" value="${story.parentSprint?.id}"/>
            </is:fieldSelect>
        </g:if>

        <is:fieldArea for="storydescription" label="${message(code:'is.backlogelement.description')}">
            <is:area id="storydescription" large="true" name="story.description"
                     value="${story?.description}"
                     rows="7"/>
        </is:fieldArea>

        <is:fieldFile for='story.tags' label="is.backlogelement.tags" noborder="true">
            <ul name="story.tags">
              <g:each in="${story?.tags}">
                <li>${it}</li>
              </g:each>
            </ul>
        </is:fieldFile>

    </is:fieldset>

    <is:textTemplate
            title="is.story.template"
            id="story-template"
            label="is.ui.backlog.story.template"
            checked="${isUsedTemplate}">

        <is:textTemplateRow title="${message(code:'is.story.template.as')}" for="story-textAs">
            <is:autoCompleteSkin
                    controller="actor"
                    action="search"
                    id="story-textAs"
                    name="story.textAs"
                    minLength="1"
                    value="${story?.actor?.name ?: story?.textAs ?: ''}"/>
        </is:textTemplateRow>

        <is:textTemplateRow title="${message(code:'is.story.template.ican')}">
            <is:area id="storytextICan" name="story.textICan" value="${story?.textICan}"/>
        </is:textTemplateRow>

        <is:textTemplateRow title="${message(code:'is.story.template.to')}">
            <is:area id="storytextTo"
                     name="story.textTo"
                     value="${story?.textTo}"/>
        </is:textTemplateRow>
    </is:textTemplate>

    <is:fieldset title="is.ui.backlog.story.attachment.title">
        <is:fieldFile for='story.attachments' label="is.backlogelement.attachment" noborder="true">
            <is:multiFilesUpload elementId="storyattachments"
                                 name="attachments"
                                 bean="${story}"
                                 urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                                 params="[product:params.product]"
                                 progress="[
                        url:createLink(action:'uploadStatus',controller:'scrumOS'),
                        label:message(code:'is.upload.wait')
                      ]"/>
        </is:fieldFile>
    </is:fieldset>

    <is:fieldset title="is.ui.backlog.story.notes.title">
        <is:fieldArea for="storynotes" label="is.backlogelement.notes" noborder="true">
            <is:area rich="[preview:true,fillWidth:true,margin:250,height:250]"
                     id="storynotes"
                     name="story.notes"
                     value="${story?.notes}"/>
        </is:fieldArea>
    </is:fieldset>

    <g:if test="${story}">
        <g:hiddenField name="story.version" value="${story?.version}"/>
    </g:if>

    <is:buttonBar>
        <g:if test="${!story}">
            <is:button
                    id="submitAndContinueForm"
                    type="submitToRemote"
                    before='if (jQuery.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    url="[controller:'story', action:'save', params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.renderNotice('${message(code: 'is.story.saved')}'); jQuery.icescrum.form.reset('#${referrer}-form')"
                    value="${message(code:'is.button.suggest')} ${message(code:'is.button.andContinue')}"/>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    onSuccess="jQuery.icescrum.navigateTo('${referrer+(params.subid?'/'+params.id:'')}'); jQuery.icescrum.renderNotice('${message(code: 'is.story.saved')}')"
                    before='if (jQuery.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    url="[controller:'story', action:'save',params:[product:params.product]]"
                    value="${message(code:'is.button.suggest')}"/>
        </g:if>
        <g:else>
            <g:if test="${next}">
                <is:button
                        id="submitAndContinueForm"
                        type="submitToRemote"
                        url="[controller:'story', action:'update', params:[continue:true,product:params.product,id:story.id]]"
                        before='if (jQuery.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                        onSuccess="data.next != null ? jQuery.icescrum.navigateTo('${referrer+(params.subid?'/'+params.id:'')+'/editStory/'}'+data.next) : jQuery.icescrum.navigateTo('${referrer}'); jQuery.icescrum.renderNotice('${message(code: 'is.story.updated')}')"
                        value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
            </g:if>
            <is:button
                    id="submitForm" type="submitToRemote"
                    url="[controller:'story', action:'update', params:[product:params.product,id:story.id]]"
                    value="${message(code:'is.button.update')}"
                    before='if (jQuery.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    onSuccess="jQuery.icescrum.navigateTo('${referrerUrl?:referrer+(params.subid?'/'+params.id:'')}'); jQuery.icescrum.renderNotice('${message(code: 'is.story.updated')}')"/>
        </g:else>
        <is:button
                id="cancelForm"
                type="link"
                button="button-s button-s-black"
                href="#${referrerUrl?:referrer}"
                value="${message(code: 'is.button.cancel')}"/>
    </is:buttonBar>

</g:form>
<is:shortcut key="shift+return" callback="jQuery('#submitAndContinueForm').click();" scope="${referrer}"
             listenOn="'#${referrer}-form, #${referrer}-form input'"/>
<is:shortcut key="return"
             callback="if(e.currentTarget.referrer == 'story-textAs'){return false;}jQuery('#submitForm').click();"
             scope="${referrer}" listenOn="'#${referrer}-form, #${referrer}-form input'"/>
<is:shortcut key="esc" callback="jQuery.icescrum.form.cancel();" scope="${referrer}"
             listenOn="'#${referrer}-form, #${referrer}-form input'"/>

<g:if test="${story}">
    <is:onStream
            on="#${referrer}-form"
            events="[[object:'story',events:['update','estimate','unPlan','plan','done','unDone','inProgress','associated','dissociated']]]"
            callback="if ( story.id != jQuery(this).attr('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.story.updated')}','${createLink(controller:controllerName,action:'edit',id:params.id,params:[product:params.product,subid:params.subid,referrer:referrer])}',false,'#window-content-${referrer}');"/>
    <is:onStream
            on="#${referrer}-form"
            events="[[object:'story',events:['remove']]]"
            callback="if ( story.id != jQuery(this).attr('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.story.deleted')}','${referrer+(params.subid?'/'+params.id:'')}',true);"/>
</g:if>
<jq:jquery>
    $("ul[name='story.tags']").tagit({select:true, tagSource: "${g.createLink(controller:'tag', action: 'find', params:[product:params.product])}"});
</jq:jquery>