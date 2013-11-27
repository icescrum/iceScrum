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
<g:form action="save" name="${controllerName}-form" method="post" data-elemid="${task?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <g:hiddenField name="manageAttachments" value="true"/>
    <g:hiddenField name="manageTags" value="true"/>

    <is:fieldset title="is.ui.sprintPlan.task.properties.title">

        <is:fieldInput for="taskname" label="is.task.name">
            <is:input id="taskname" name="task.name" value="${task?.name}"/>
        </is:fieldInput>

        <is:fieldSelect label="is.task.story">
            <is:select class="preserve" id="story_id" name="task.parentStory.id" container=".window-content" width="240" maxHeight="200"
                       styleSelect="dropdown" from="${stories}" value="${selected?.id}" optionValue="name"
                       optionKey="id"/>
        </is:fieldSelect>

        <is:fieldInput for="taskestimation" label="is.task.estimation">
            <is:input id="taskestimation" name="task.estimation" value="${task?.estimation}" typed="[type:'numeric',allow:'?.,']"/>
        </is:fieldInput>

        <is:fieldArea for="taskdescription" label="is.backlogelement.description">
            <is:area id="taskdescription" name="task.description" value="${task?.description}" large="true" rows="7"/>
        </is:fieldArea>

        <is:fieldFile for='task.tags' label="is.backlogelement.tags">
            <input type="hidden" name="task.tags" data-tag="true" value="${task?.tags?.join(',')}" data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"/>
        </is:fieldFile>

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
            </is:postit>
        </div>

    </is:fieldset>

    <is:fieldset title="is.ui.sprintPlan.task.attachment.title">
        <is:fieldFile for='task.attachments' label="is.backlogelement.attachment" noborder="true">
            <is:multiFilesUpload elementId="taskattachments"
                                 controller="task"
                                 class="attachments"
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
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.task.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'task', action:'save', params:[product:params.product]])}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}</span>
                    <span class="end"></span>
                </a>
            </td>
            <td>
                <a id="submitForm"  class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-notice="${message(code: 'is.task.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${controllerName+'/'+sprint.id}"
                   href="${createLink([controller:'task', action:'save', params:[product:params.product]])}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.add')}</span>
                    <span class="end"></span>
                </a>
            </td>
        </g:if>
        <g:else>
            <g:if test="${next}">
                <td>
                    <a id="submitAndContinueForm"  class="button-s clearfix"
                       data-ajax="true"
                       data-ajax-form="true"
                       data-ajax-method="POST"
                       data-shortcut="shift+return"
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.task.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? controllerName+(params.subid?'/'+params.id:'')+'/edit/'+next : controllerName+'/'+sprint.id}"
                       href="${createLink([controller:'task', action:'update', params:[product:params.product,id:task.id]])}">
                        <span class="start"></span>
                        <span class="content">${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}</span>
                        <span class="end"></span>
                    </a>
                </td>
            </g:if>
                <td>
                    <a id="submitForm"  class="button-s clearfix"
                       data-ajax="true"
                       data-ajax-form="true"
                       data-ajax-method="POST"
                       data-shortcut="return"
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.task.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${controllerName+'/'+sprint.id}"
                       href="${createLink([controller:'task', action:'update', params:[product:params.product,id:task.id]])}">
                        <span class="start"></span>
                        <span class="content">${message(code:'is.button.update')}</span>
                        <span class="end"></span>
                    </a>
                </td>
        </g:else>
        <td>
            <a  id="cancelForm"
                data-shortcut="esc"
                data-callback="jQuery.icescrum.form.cancel"
                data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                class="button-s button-s-black" href="#${referrerUrl ?: controllerName+'/'+sprint.id}">
                <span class="start"></span>
                <span class="content">${message(code: 'is.button.cancel')}</span>
                <span class="end"></span>
            </a>
        </td>
    </is:buttonBar>
</g:form>
<g:if test="${sprint}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'task',events:['update']]]"
            callback="if ( task.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.task.updated')}','${createLink(controller:controllerName,action:'edit',id:sprint.id,params:[product:params.product,subid:params.subid])}',false,'#window-content-${controllerName}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'task',events:['remove']]]"
            callback="if ( task.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.task.deleted')}','${controllerName}/${sprint.id}',true);"/>
</g:if>