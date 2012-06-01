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
- Nicolas Noullet (nnoullet@kagilum.com)
- Jeroen Broekhuizen (Jeroen.Broekhuizen@quintiq.com)
--}%
<g:form action="save" name="${controllerName}-form" method="post" elemid="${task?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <is:fieldset title="is.ui.sprintPlan.task.properties.title">

        <is:fieldInput for="taskname" label="is.task.name">
            <is:input id="taskname" name="task.name" value="${task?.name}" focus="true"/>
        </is:fieldInput>

        <is:fieldSelect label="is.task.story">
            <is:select name="task.parentStory.id" container=".window-content" width="240" maxHeight="200"
                       styleSelect="dropdown" from="${stories}" value="${selected?.id}" optionValue="name"
                       optionKey="id"/>
        </is:fieldSelect>

        <is:fieldInput for="taskestimation" label="is.task.estimation">
            <is:input id="taskestimation" name="task.estimation" value="${task?.estimation}" typed="[type:'numeric',allow:'?.,']"/>
        </is:fieldInput>

        <is:fieldArea for="taskdescription" label="is.backlogelement.description">
            <is:area id="taskdescription" name="task.description" value="${task?.description}" large="true" rows="7"/>
        </is:fieldArea>

        <is:fieldSelect for="taskcolor" label="is.task.color" noborder="true">
            <is:select id="taskcolor" name="task.color" container=".window-content" width="100" maxHeight="200"
                       styleSelect="dropdown" from="${colorsLabels}" keys="${colorsKeys}" value="${task?.color}"
                       onchange="jQuery('#postit-ipsum-1').find('.postit-layout').removeClass().addClass('postit-layout postit-'+this.value);"/>
        </is:fieldSelect>
        <div class="select-lorem-rect">
            <is:postit color="${task?.color}"
                       title="Lorem ipsum dolor"
                       id="1"
                       miniId="1"
                       type="ipsum"
                       stateBundle="Ipsum"
                       rect="true">
                Lorem ipsum dolor sit amet, consectetur...
            </is:postit>
        </div>

    </is:fieldset>

    <is:fieldset title="is.ui.sprintPlan.task.attachment.title">
        <is:fieldFile for='task.attachments' label="is.backlogelement.attachment" noborder="true">
            <is:multiFilesUpload elementId="taskattachments"
                                 controller="task"
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

    <is:fieldset title="is.ui.sprintPlan.task.notes.title">
        <is:fieldArea label="is.backlogelement.notes" noborder="true">
            <is:area
                    rich="[preview:true,fillWidth:true,margin:250,height:250]"
                    id="tasknotes"
                    name="task.notes"
                    value="${task?.notes}"/>
        </is:fieldArea>
    </is:fieldset>

    <g:if test="${task}">
        <g:hiddenField name="task.version" value="${task.version}"/>
    </g:if>
    <g:else>
        <g:hiddenField name="task.sprint.id" value="${sprint.id}"/>
    </g:else>

    <is:buttonBar>
        <g:if test="${!task}">
            <is:button
                    id="submitAndContinueForm"
                    type="submitToRemote"
                    url="[controller:'task', action:'save',params:[product:params.product]]"
                    before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    onSuccess="jQuery.icescrum.form.reset('#${controllerName}-form',['story_id']); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.saved')}')"
                    value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'task', action:'save',params:[product:params.product]]"
                    before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName+'/'+sprint.id}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.saved')}')"
                    value="${message(code:'is.button.add')}"/>
        </g:if>
        <g:else>
            <g:if test="${next}">
                <is:button
                        id="submitAndContinueForm"
                        type="submitToRemote"
                        url="[controller:'task', action:'update', id:task.id, params:[product:params.product,continue:true]]"
                        before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                        onSuccess="data.next != null ? jQuery.icescrum.navigateTo('${controllerName+(params.subid?'/'+params.id:'')+'/edit/'}'+data.next) : jQuery.icescrum.navigateTo('${controllerName+'/'+sprint.id}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.updated')}')"
                        value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
            </g:if>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'task', action:'update',id:task.id, params:[product:params.product]]"
                    before='if (\$.icescrum.uploading()) {${is.notice(text:message(code:"is.upload.inprogress.wait"))} return false; }'
                    onSuccess="jQuery.icescrum.navigateTo('${referrerUrl ?: controllerName+'/'+sprint.id}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.updated')}')"
                    value="${message(code:'is.button.update')}"/>
        </g:else>
        <is:button
                id="cancelForm"
                type="link"
                button="button-s button-s-black"
                href="#${referrerUrl ?: controllerName+'/'+sprint.id}"
                value="${message(code: 'is.button.cancel')}"/>
    </is:buttonBar>

</g:form>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.form.cancel();" scope="${controllerName}" listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<g:if test="${sprint}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'task',events:['update']]]"
            callback="if ( task.id != jQuery(this).attr('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.task.updated')}','${createLink(controller:controllerName,action:'edit',id:sprint.id,params:[product:params.product,subid:params.subid])}',false,'#window-content-${controllerName}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'task',events:['remove']]]"
            callback="if ( task.id != jQuery(this).attr('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.task.deleted')}','${controllerName}/${sprint.id}',true);"/>
</g:if>