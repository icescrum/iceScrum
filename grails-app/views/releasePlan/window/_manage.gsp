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
            <is:area id="sprintgoal" large="true" name="sprint.goal" value="${sprint?.goal}" focus="true"/>
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

        <is:fieldInput for="sprintDeliveredVersion" label="is.sprint.deliveredVersion">
            <is:input id="sprintDeliveredVersion" class="small" name="sprint.deliveredVersion" value="${sprint?.deliveredVersion}"/>
        </is:fieldInput>

        <is:fieldInput for="sprintresource" label="is.sprint.resource" noborder="true">
            <is:input id="sprintresource" class="small" name="sprint.resource" value="${sprint?.resource}" typed="[type:'numeric']"/>
        </is:fieldInput>
    </is:fieldset>

    <is:buttonBar>
        <g:if test="${!sprint}">
            <is:button
                    id="submitAndContinueForm"
                    type="submitToRemote"
                    url="[controller:'sprint', action:'save', params:[product:params.product, 'parentRelease.id':release.id]]"
                    onSuccess="jQuery.icescrum.form.reset('#${controllerName}-form'); jQuery.icescrum.updateStartDateDatePicker(data); jQuery.icescrum.updateEndDateDatePicker(data,${product.preferences.estimatedSprintsDuration}); jQuery.icescrum.renderNotice('${message(code: 'is.sprint.saved')}')"
                    value="${message(code:'is.button.add')} ${message(code:'is.button.andContinue')}"/>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'sprint', action:'save', params:[product:params.product, 'parentRelease.id':release.id]]"
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName}/${release.id}'); jQuery.icescrum.renderNotice('${message(code: 'is.sprint.saved')}')"
                    value="${message(code:'is.button.add')}"/>
        </g:if>
        <g:else>
            <g:hiddenField name="sprint.version" value="${sprint.version}"/>
            <g:hiddenField name="sprint.id" value="${sprint.id}"/>
            <g:if test="${next}">
                <is:button
                        id="submitAndContinueForm"
                        type="submitToRemote"
                        url="[mapping:'pUrl', controller:'sprint', action:'update', id:sprint.id, params:[continue:true,product:params.product]]"
                        onSuccess="data.next != null ? jQuery.icescrum.navigateTo('${controllerName+(params.subid?'/'+params.id:'')+'/edit/'}'+data.next) : jQuery.icescrum.navigateTo('${controllerName+'/'+release.id}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.sprint.updated')}')"
                        value="${message(code:'is.button.update')} ${message(code:'is.button.andContinue')}"/>
            </g:if>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[mapping:'pUrl', controller:'sprint', action:'update', id:sprint.id,params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName+'/'+release.id}'); jQuery.icescrum.renderNotice('${message(code: 'is.sprint.updated')}')"
                    value="${message(code:'is.button.update')}"/>
        </g:else>
        <is:button
                id="cancelForm"
                type="link"
                button="button-s button-s-black"
                href="#${controllerName+'/'+release.id}"
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
