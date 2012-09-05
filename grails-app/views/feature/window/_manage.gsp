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
<g:form action="save" method="post" name="${controllerName}-form" data-elemid="${feature?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <is:fieldset title="is.ui.feature.feature.properties.title">
        <is:fieldInput for="featurename" label="is.feature.name">
            <is:input id="featurename" name="feature.name" value="${feature?.name}" focus="true"/>
        </is:fieldInput>

        <is:fieldArea for="featuredescription" label="is.backlogelement.description">
            <is:area id="featuredescription" large="true" name="feature.description" value="${feature?.description}"/>
        </is:fieldArea>

        <g:if test="${rankList}">
            <is:fieldSelect for="feature.rank" label="is.feature.rank">
                <is:select container=".window-content" width="100" maxHeight="200" styleSelect="dropdown"
                           from="${rankList}" name="feature.rank" value="${feature.rank}"/>
            </is:fieldSelect>
        </g:if>

        <is:fieldSelect for="feature.value" label="is.feature.value">
            <is:select container=".window-content" width="100" maxHeight="200" styleSelect="dropdown"
                       from="${valuesList}" name="feature.value" value="${feature?.value}"/>
        </is:fieldSelect>

        <is:fieldSelect for="feature.type" label="is.feature.type">
            <is:select container=".window-content" width="100" maxHeight="200" styleSelect="dropdown"
                       from="${typesNames}" keys="${typesId}" name="feature.type" value="${feature?.type}"/>
        </is:fieldSelect>

        <entry:point id="${controllerName}-${actionName}" model="[feature:feature]"/>

        <is:fieldFile for='feature.tags' label="is.backlogelement.tags">
            <ul name="feature.tags">
              <g:each in="${feature?.tags}">
                <li>${it}</li>
              </g:each>
            </ul>
        </is:fieldFile>

        <is:fieldSelect for="featureColor" label="is.feature.color" noborder="true">
            <is:select class="featureColor" container=".window-content" width="100" maxHeight="200"
                       styleSelect="dropdown" from="${colorsLabels}" keys="${colorsKeys}" name="feature.color"
                       value="${feature?.color}"
                       onchange="jQuery('#postit-ipsum-1').find('.postit-layout').removeClass().addClass('postit-layout postit-'+this.value);"/>

        </is:fieldSelect>
        <div class="select-lorem">
            <is:postit color="${feature?.color ?: 'blue' }" title="Lorem ipsum dolor" id="1" miniId="1" type="ipsum"
                       stateBundle="Ipsum">
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

    <g:if test="${feature}">
        <g:hiddenField name="feature.version" value="${feature.version}"/>
    </g:if>

    <is:buttonBar>
        <g:if test="${!feature}">
            <is:button
                    id="submitAndContinueForm"
                    type="submitToRemote"
                    url="[controller:'feature', action:'save', params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.form.reset('#${controllerName}-form'); jQuery.icescrum.renderNotice('${message(code: 'is.feature.saved')}')"
                    before="if (jQuery.icescrum.uploading()) { jQuery.icescrum.renderNotice('${message(code:'is.upload.inprogress.wait')}', 'error'); return false; }"
                    value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'feature', action:'save', params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${message(code: 'is.feature.saved')}')"
                    before="if (jQuery.icescrum.uploading()) { jQuery.icescrum.renderNotice('${message(code:'is.upload.inprogress.wait')}', 'error'); return false; }"
                    value="${message(code:'is.button.add')}"/>
        </g:if>
        <g:else>
            <g:if test="${next}">
                <is:button
                        id="submitAndContinueForm"
                        type="submitToRemote"
                        url="[controller:'feature', action:'update', id:feature.id, params:[continue:true,product:params.product]]"
                        onSuccess="jQuery('#${controllerName}-form').unbind('.stream'); jQuery.event.trigger('update_feature',data.feature); data.next != null ? jQuery.icescrum.navigateTo('${controllerName+'/edit/'}'+data.next) : jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${message(code: 'is.feature.updated')}')"
                        before="if (jQuery.icescrum.uploading()) { jQuery.icescrum.renderNotice('${message(code:'is.upload.inprogress.wait')}', 'error'); return false; }"
                        value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
            </g:if>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'feature', action:'update', id:feature.id, params:[product:params.product]]"
                    before="if (jQuery.icescrum.uploading()) { jQuery.icescrum.renderNotice('${message(code:'is.upload.inprogress.wait')}', 'error'); return false; }"
                    onSuccess="jQuery('#${controllerName}-form').unbind('.stream'); jQuery.event.trigger('update_feature',data.feature); jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${message(code: 'is.feature.updated')}')"
                    value="${message(code:'is.button.update')}"/>
        </g:else>
        <is:button id="cancelForm"
                   type="link"
                   button="button-s button-s-black"
                   href="#${controllerName}"
                   value="${message(code: 'is.button.cancel')}"/>
    </is:buttonBar>

</g:form>
<is:shortcut key="shift+return" callback="jQuery('#submitAndContinueForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="return" callback="jQuery('#submitForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="esc" callback="jQuery.icescrum.form.cancel();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<g:if test="${feature}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'feature',events:['update']]]"
            callback="if ( feature.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.feature.updated')}','${createLink(controller:controllerName,action:'edit',id:feature.id,params:[product:params.product])}',false,'#window-content-${controllerName}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'feature',events:['remove']]]"
            callback="if ( feature.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.feature.deleted')}','${controllerName}',true);"/>
</g:if>
<jq:jquery>
    $("ul[name='feature.tags']").tagit({select:true, tagSource: "${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"});
</jq:jquery>