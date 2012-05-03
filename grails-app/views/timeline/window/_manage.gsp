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
--}%
<%@ page import="org.icescrum.core.domain.Release" %>
<g:setProvider library="jquery"/>
<g:form action="save" method="post" name="${controllerName}-form" class="box-form box-form-250 box-form-200-legend" tabindex="1">

    <is:fieldset title="is.ui.timeline.release.properties.title">

        <is:fieldInput for="releasename" label="is.release.name">
            <is:input id="releasename" name="release.name" value="${release?.name}" focus="true"/>
        </is:fieldInput>

        <is:fieldArea label="is.release.goal" for="releasegoal">
            <is:area large="true" id="releasegoal" name="release.goal" value="${release?.goal}"/>
        </is:fieldArea>

        <is:fieldDatePicker for="startDate" label="is.release.startDate">
            <is:datePicker
                    id="startDate"
                    name="startDate"
                    mode="read-input"
                    changeMonth="true"
                    changeYear="true"
                    minDate="${previousRelease && !release ? previousRelease.endDate + 1 : (previousRelease && release ? previousRelease.endDate + 1: product.startDate)}"
                    defaultDate="${release ? release.startDate : (previousRelease ? previousRelease.endDate + 1 : product.startDate)}"
                    disabled="${release ? release.state == Release.STATE_DONE : false}"/>
        </is:fieldDatePicker>

        <is:fieldDatePicker for="endDate" label="is.release.endDate" noborder="true">
            <is:datePicker
                    id="endDate"
                    name="endDate"
                    minDate="${previousRelease && !release ? previousRelease.endDate + 2 : (previousRelease && release ? previousRelease.endDate + 2: product.startDate + 1)}"
                    defaultDate="${release ? release.endDate : (previousRelease ? previousRelease.endDate + 2 : product.startDate + 1)}"
                    disabled="${release ? release.state == Release.STATE_DONE : false}"
                    mode="read-input"
                    changeMonth="true"
                    changeYear="true"/>
        </is:fieldDatePicker>

    </is:fieldset>

    <g:if test="${release}">
        <g:hiddenField name="release.version" value="${release.version}"/>
    </g:if>

    <is:buttonBar>
        <g:if test="${!release?.id}">
            <is:button
                    id="submitAndContinueForm"
                    type="submitToRemote"
                    url="[controller:'release', action:'save', params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.form.reset('#${controllerName}-form'); jQuery.icescrum.updateStartDateDatePicker(data); jQuery.icescrum.updateEndDateDatePicker(data,90); jQuery.icescrum.renderNotice('${g.message(code: 'is.release.saved')}')">
                ${message(code: 'is.button.add')} ${message(code: 'is.button.andContinue')}
            </is:button>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'release', action:'save',params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.release.saved')}')">
                ${message(code: 'is.button.add')}
            </is:button>
        </g:if>
        <g:else>
            <g:if test="${next}">
                <is:button
                        id="submitAndContinueForm"
                        type="submitToRemote"
                        url="[controller:'release', action:'update', id:release.id, params:[continue:true,product:params.product]]"
                        onSuccess="data.next != null ? jQuery.icescrum.navigateTo('${controllerName+'/edit/'}'+data.next) : jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${message(code: 'is.release.updated')}')">
                    ${message(code: 'is.button.update')} ${message(code: 'is.button.andContinue')}
                </is:button>
            </g:if>
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'release', action:'update', id:release.id, params:[product:params.product]]"
                    onSuccess="jQuery.icescrum.navigateTo('${controllerName}'); jQuery.icescrum.renderNotice('${g.message(code: 'is.release.updated')}')">
                ${message(code: 'is.button.update')}
            </is:button>
        </g:else>
        <is:button
                id="cancelForm"
                type="link"
                button="button-s button-s-black"
                href="#${controllerName}"
                value="${message(code: 'is.button.cancel')}"/>
    </is:buttonBar>
</g:form>
<is:shortcut key="shift+return" callback="\$('#submitAndContinueForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="return" callback="\$('#submitForm').click();" scope="${controllerName}"
             listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>
<is:shortcut key="esc" callback="\$.icescrum.form.cancel();" scope="${controllerName}" listenOn="'#${controllerName}-form, #${controllerName}-form input'"/>

<g:if test="${release}">
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'release',events:['update','close','activate']]]"
            callback="jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.release.updated')}','${controllerName}',false);"/>
    <is:onStream
            on="#${controllerName}-form"
            events="[[object:'release',events:['remove']]]"
            callback="jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.release.deleted')}','${controllerName}',false);"/>
</g:if>