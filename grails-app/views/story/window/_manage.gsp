<%@ page import="org.icescrum.core.domain.Story" %>
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

<g:form action="save" method="post" name="${referrer}-form" data-elemid="${story?.id?:null}" data-state="${story?.state?:Story.STATE_SUGGESTED}" data-rank="${story?.rank?:'null'}" class="box-form box-form-250 box-form-200-legend"
        tabindex="1">
    <is:fieldset title="is.ui.backlog.story.properties.title">
        <is:fieldInput for="storyname" label="is.story.name">
            <is:input id="storyname" name="story.name" value="${story?.name}"/>
        </is:fieldInput>

    %{-- Type --}%
        <is:fieldSelect for="story.type" label="is.story.type">
            <is:select
                    container=".window-content"
                    width="195"
                    maxHeight="200"
                    change="this.value == '${Story.TYPE_DEFECT}' ? jQuery('#storyaffectVersion-field-input').show() : jQuery('#storyaffectVersion-field-input').hide();"
                    styleSelect="dropdown"
                    from="${typesLabels}"
                    keys="${typesKeys}"
                    name="story.type"
                    value="${story?.type}"/>
        </is:fieldSelect>

        <is:fieldInput for="storyaffectVersion" label="is.story.affectVersion" id="storyaffectVersion-field-input" style="display:${story?.type == Story.TYPE_DEFECT ? 'block' : 'none'}">
            <is:input id="storyaffectVersion" name="story.affectVersion" value="${story?.affectVersion}"/>
        </is:fieldInput>

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

        <g:if test="${storiesSelect}">
            <is:fieldSelect label="is.story.dependsOn" for="story.dependsOn">
                <is:select container=".window-content" width="195" maxHeight="200"
                           styleSelect="dropdown"
                           name="dependsOn.id" noSelection="['':message(code:'is.ui.backlog.choose.dependsOn')]"
                           optionValue="${{ el -> el.uid+' - '+el.name }}" optionKey="id" from="${storiesSelect}"
                           disabled="${!request.productOwner && !request.scrumMaster}"
                           value="${story?.dependsOn?.id}"/>
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
                                 class="attachments"
                                 bean="${story}"
                                 urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                                 params="[product:params.product]"
                                 progress="[
                        url:createLink(action:'uploadStatus',controller:'scrumOS'),
                        label:message(code:'is.upload.wait')
                      ]"/>
        </is:fieldFile>
    </is:fieldset>
    <g:hiddenField name="manageAttachments" value="true"/>

    <is:fieldset title="is.ui.backlog.story.notes.title">
        <is:fieldArea for="storynotes" label="is.backlogelement.notes" noborder="true">
            <is:area rich="[preview:true,fillWidth:true,margin:250,height:250]"
                     id="storynotes"
                     name="story.notes"
                     value="${story?.notes}"/>
        </is:fieldArea>
    </is:fieldset>

    <entry:point id="${referrer}-${actionName}" model="[story:story]"/>

    <g:if test="${story}">
        <g:hiddenField name="story.version" value="${story?.version}"/>
    </g:if>

    <is:buttonBar>
        <g:if test="${!story}">
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-ajax-trigger="add_story"
                   data-shortcut-on="#${referrer}-form, #${referrer}-form input"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.story.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'story', action:'save', params:[product:params.product]])}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.suggest')} ${message(code:'is.button.andContinue')}</span>
                    <span class="end"></span>
                </a>
            </td>
            <td>
                <a id="submitForm"  class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="return"
                   data-shortcut-on="#${referrer}-form, #${referrer}-form input:not([name='story.textAs'])"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-notice="${message(code: 'is.story.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${referrer+(params.subid?'/'+params.id:'')}"
                   href="${createLink([controller:'story', action:'save', params:[product:params.product]])}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.suggest')}</span>
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
                       data-shortcut-on="#${referrer}-form, #${referrer}-form input"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.story.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? referrer+(params.subid?'/'+params.id:'')+'/editStory/'+next : referrer}"
                       href="${createLink([controller:'story', action:'update', params:[product:params.product,id:story.id]])}">
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
                       data-shortcut-on="#${referrer}-form, #${referrer}-form input:not([name='story.textAs'])"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.story.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${referrerUrl?:referrer+(params.subid?'/'+params.id:'')}"
                       href="${createLink([controller:'story', action:'update', params:[product:params.product,id:story.id]])}">
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
                data-shortcut-on="#${referrer}-form, #${referrer}-form input:not([name='story.textAs'])"
                class="button-s button-s-black" href="#${referrerUrl?:referrer}">
                <span class="start"></span>
                <span class="content">${message(code: 'is.button.cancel')}</span>
                <span class="end"></span>
            </a>
        </td>
    </is:buttonBar>

</g:form>

<is:onStream
        on="#${referrer}-form"
        events="[[object:'story',events:['add','update','estimate','unPlan','plan','done','unDone','inProgress','associated','dissociated']]]"
        callback="if ( story.id != jQuery(this).data('elemid') ){ jQuery.icescrum.story.manageDependencies.apply(story); return; } jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.story.updated')}','${createLink(controller:controllerName,action:'edit',id:params.id,params:[product:params.product,subid:params.subid,referrer:referrer])}',false,'#window-content-${referrer}');"/>
<is:onStream
        on="#${referrer}-form"
        events="[[object:'story',events:['remove']]]"
        callback="if ( story.id != jQuery(this).data('elemid') ){ jQuery.icescrum.story.manageDependencies.apply(story); return; } jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.story.deleted')}','${referrer+(params.subid?'/'+params.id:'')}',true);"/>
<jq:jquery>
    $("ul[name='story.tags']").tagit({select:true, tagSource: "${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"});
    $( "#storyaffectVersion" ).autocomplete({
        source: "${g.createLink(controller:'project', action: 'versions', params:[product:params.product])}",
        minLength: 2
    });
</jq:jquery>