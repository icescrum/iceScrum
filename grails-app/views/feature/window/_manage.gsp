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
<g:setProvider library="jquery"/>
<g:form action="save" method="post" name="${controllerName}-form" data-elemid="${feature?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <g:hiddenField name="manageAttachments" value="true"/>
    <g:hiddenField name="manageTags" value="true"/>

    <is:fieldset title="is.ui.feature.feature.properties.title">
        <is:fieldInput for="featurename" label="is.feature.name">
            <is:input id="featurename" name="feature.name" value="${feature?.name}"/>
        </is:fieldInput>

        <is:fieldArea for="featuredescription" label="is.backlogelement.description">
            <is:area id="featuredescription" large="true" name="feature.description" value="${feature?.description}"/>
        </is:fieldArea>

        <g:if test="${rankList}">
            <is:fieldSelect for="feature.rank" label="is.feature.rank">
                <is:select width="100"
                           from="${rankList}"
                           name="feature.rank"
                           value="${feature.rank}"/>
            </is:fieldSelect>
        </g:if>

        <is:fieldSelect for="feature.value" label="is.feature.value">
            <is:select width="100"
                       from="${valuesList}"
                       name="feature.value"
                       value="${feature?.value}"/>
        </is:fieldSelect>

        <is:fieldSelect for="feature.type" label="is.feature.type">
            <is:select width="100"
                       from="${typesNames}"
                       keys="${typesId}"
                       name="feature.type"
                       value="${feature?.type}"/>
        </is:fieldSelect>

        <entry:point id="${controllerName}-${actionName}" model="[feature:feature]"/>

        <is:fieldSelect for='feature.tags' label="is.backlogelement.tags">
            <input type="hidden" name="feature.tags" data-tag="true" value="${feature?.tags?.join(',')}" data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"/>
        </is:fieldSelect>

        <is:fieldSelect for="featureColor" label="is.feature.color" noborder="true">
            <is:select class="featureColor"
                       width="100"
                       from="${colorsLabels}"
                       keys="${colorsKeys}"
                       name="feature.color"
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
                                 class="attachments"
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
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.feature.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'feature', action:'save', params:[product:params.product]])}">
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
                   data-ajax-notice="${message(code: 'is.feature.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${controllerName}"
                   href="${createLink([controller:'feature', action:'save', params:[product:params.product]])}">
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
                       data-ajax-trigger="update_feature"
                       data-shortcut="shift+return"
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.feature.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? controllerName+'/edit/'+next : controllerName}"
                       href="${createLink([controller:'feature', action:'update', params:[product:params.product,id:feature.id]])}">
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
                       data-ajax-trigger="update_feature"
                       data-ajax-method="POST"
                       data-shortcut="return"
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input:not(.select2-input)"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.feature.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${controllerName}"
                       href="${createLink([controller:'feature', action:'update', params:[product:params.product,id:feature.id]])}">
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
<g:if test="${feature}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'feature',events:['update']]]"
            callback="if ( feature.id != jQuery(this).data('elemid') || jQuery(this).hasClass('updating') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.feature.updated')}','${createLink(controller:controllerName,action:'edit',id:feature.id,params:[product:params.product])}',false,'#window-content-${controllerName}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'feature',events:['remove']]]"
            callback="if ( feature.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.feature.deleted')}','${controllerName}',true);"/>
</g:if>