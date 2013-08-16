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
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:form action="save" method="post" name="${controllerName}-form" data-elemid="${sprint?.id ?: null}" class="box-form box-form-250 box-form-200-legend" tabindex="1">
    <is:fieldset title="is.ui.releasePlan.sprint.properties.title">
        <is:fieldArea for="sprintgoal" label="is.sprint.goal">
            <is:area id="sprintgoal" large="true" name="sprint.goal" value="${sprint?.goal}"/>
        </is:fieldArea>

    %{-- Start Date --}%
        <is:fieldDatePicker for="startDate" label="is.sprint.startDate">
            <is:datePicker id="startDate" name="sprint.startDate" mode="read-input" changeMonth="true" changeYear="true"
                           minDate="${previousSprint && !sprint ? previousSprint.endDate + 1 : release.startDate}"
                           maxDate="${release.endDate}"
                           defaultDate="${sprint ? sprint.startDate : (previousSprint ? previousSprint.endDate + 1 : release.startDate)}"
                           disabled="${sprint ? sprint.state >= org.icescrum.core.domain.Sprint.STATE_INPROGRESS : false}"/>
        </is:fieldDatePicker>

    %{-- End Date --}%
        <is:fieldDatePicker for="endDate" label="is.sprint.endDate">
            <is:datePicker id="endDate" name="sprint.endDate" mode="read-input" changeMonth="true" changeYear="true"
                           minDate="${previousSprint && !sprint ? previousSprint.endDate + 2 : release.startDate+1}"
                           maxDate="${release.endDate}"
                           defaultDate="${sprint ? sprint.endDate : (previousSprint ? previousSprint.endDate : release.startDate) + product.preferences.estimatedSprintsDuration}"/>
        </is:fieldDatePicker>

        <is:fieldInput for="sprintDeliveredVersion" label="is.sprint.deliveredVersion" noborder="true">
            <is:input id="sprintDeliveredVersion" class="small" name="sprint.deliveredVersion" value="${sprint?.deliveredVersion}"/>
        </is:fieldInput>

    </is:fieldset>
    <is:buttonBar>
        <g:if test="${!sprint}">
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.sprint.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'sprint', action:'save', params:[product:params.product, 'parentRelease.id':release.id]])}">
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
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-notice="${message(code: 'is.sprint.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${controllerName+'/'+release.id}"
                   href="${createLink([controller:'sprint', action:'save', params:[product:params.product, 'parentRelease.id':release.id]])}">
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
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.sprint.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? controllerName+(params.subid?'/'+params.id:'')+'/edit/'+next : controllerName+'/'+release.id}"
                       href="${createLink([mapping:'urlProduct', controller:'sprint', action:'update', params:[product:params.product,id:sprint.id]])}">
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
                       data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                       data-ajax-begin="jQuery.icescrum.form.checkUploading"
                       data-ajax-notice="${message(code: 'is.sprint.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${controllerName+'/'+release.id}"
                       href="${createLink([mapping:'urlProduct', controller:'sprint', action:'update', params:[product:params.product,id:sprint.id]])}">
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
                data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                class="button-s button-s-black" href="#${referrerUrl ?: controllerName+'/'+release.id}">
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
            events="[[object:'sprint',events:['update']]]"
            callback="alert('${message(code:'is.sprint.updated')}'); jQuery.icescrum.navigateTo('${controllerName+(params.subid?'/'+params.id:'')+'/edit/'+sprint.id}');"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'sprint',events:['remove']]]"
            callback="alert('${message(code:'is.sprint.deleted')}'); jQuery.icescrum.navigateTo('${controllerName+'/'+release.id}');"/>
</g:if>

<g:if test="${sprint}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'sprint',events:['update','activate','close']]]"
            callback="if ( sprint.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.sprint.updated')}','${controllerName}/${release.id}',true);"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'sprint',events:['remove']]]"
            callback="if ( sprint.id != jQuery(this).data('elemid') ) return; jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.sprint.deleted')}','${controllerName}/${release.id}',true);"/>
</g:if>
