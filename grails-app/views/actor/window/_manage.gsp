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
--}%
<g:form action="save" method="post" name="${controllerName}-form" data-elemid="${actor?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <g:hiddenField name="manageAttachments" value="true"/>
    <g:hiddenField name="manageTags" value="true"/>

    <is:fieldset title="is.ui.actor.actor.properties.title">
        <is:fieldInput label="is.actor" for="actorname">
            <is:input name="actor.name" id="actorname" value="${actor?.name}"/>
        </is:fieldInput>

        <is:fieldSelect label="is.actor.instances" for="actor.instances">
            <is:select width="100"
                       from="${instancesValues}"
                       keys="${instancesKeys}"
                       name="actor.instances"
                       value="${actor?.instances}"/>
        </is:fieldSelect>

        <is:fieldSelect label="is.actor.it.level" for="actor.expertnessLevel">
            <is:select width="100"
                       from="${levelsValues}"
                       keys="${levelsKeys}"
                       name="actor.expertnessLevel"
                       value="${actor?.expertnessLevel}"/>
        </is:fieldSelect>

        <is:fieldSelect label="is.actor.use.frequency" for="actor.useFrequency">
            <is:select width="100"
                       from="${frequenciesValues}"
                       keys="${frequenciesKeys}"
                       name="actor.useFrequency"
                       value="${actor?.useFrequency}"/>
        </is:fieldSelect>

        <is:fieldArea for="actordescription" label="is.backlogelement.description">
            <is:area id="actordescription" name="actor.description" value="${actor?.description}" rows="3"/>
        </is:fieldArea>

        <is:fieldArea for="actorsatisfactionCriteria" label="is.actor.satisfaction.criteria">
            <is:area id="actorsatisfactionCriteria" name="actor.satisfactionCriteria"
                     value="${actor?.satisfactionCriteria}" rows="3"/>
        </is:fieldArea>

        <is:fieldSelect for='actor.tags' label="is.backlogelement.tags" noborder="true">
            <input type="hidden" name="actor.tags" data-tag="true" value="${actor?.tags?.join(',')}" data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"/>
        </is:fieldSelect>

    </is:fieldset>

    <is:fieldset title="is.ui.actor.actor.attachment.title">
        <is:fieldFile for='actor.attachments' label="is.backlogelement.attachment" noborder="true">
            <is:multiFilesUpload elementId="actorattachments"
                                 name="attachments"
                                 class="attachments"
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

    <g:if test="${actor}">
        <g:hiddenField name="actor.version" value="${actor?.version}"/>
    </g:if>

    <is:buttonBar>
        <g:if test="${!actor}">
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.actor.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'actor', action:'save', params:[product:params.product]])}">
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
                   data-ajax-notice="${message(code: 'is.actor.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${controllerName}"
                   href="${createLink([controller:'actor', action:'save', params:[product:params.product]])}">
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
                       data-ajax-notice="${message(code: 'is.actor.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? controllerName+'/edit/'+next : controllerName}"
                       href="${createLink([controller:'actor', action:'update', params:[product:params.product,id:actor.id]])}">
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
                       data-ajax-notice="${message(code: 'is.actor.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${controllerName}"
                       href="${createLink([controller:'actor', action:'update', params:[product:params.product,id:actor.id]])}">
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
                class="button-s button-s-black" href="#${controllerName}">
                <span class="start"></span>
                <span class="content">${message(code: 'is.button.cancel')}</span>
                <span class="end"></span>
            </a>
        </td>
    </is:buttonBar>
</g:form>

<g:if test="${actor}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'actor',events:['update']]]"
            callback="if ( actor.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.actor.updated')}','${createLink(controller:controllerName,action:'edit',id:actor.id,params:[product:params.product])}',false,'#window-content-${controllerName}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'actor',events:['remove']]]"
            callback="if ( actor.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.actor.deleted')}','${controllerName}',true);"/>
</g:if>