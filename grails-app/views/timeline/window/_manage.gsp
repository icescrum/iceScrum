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
            <is:input id="releasename" name="release.name" value="${release?.name}"/>
        </is:fieldInput>

        <is:fieldArea label="is.release.goal" for="releasegoal">
            <is:area large="true" id="releasegoal" name="release.goal" value="${release?.goal}"/>
        </is:fieldArea>

        <is:fieldDatePicker for="startDate" label="is.release.startDate">
            <is:datePicker
                    id="startDate"
                    name="release.startDate"
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
                    name="release.endDate"
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
            <td>
                <a id="submitAndContinueForm" class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-shortcut="shift+return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form input"
                   data-ajax-begin="jQuery.icescrum.form.checkUploading"
                   data-ajax-success="jQuery.icescrum.form.reset"
                   data-ajax-notice="${message(code: 'is.release.saved').encodeAsJavaScript()}"
                   href="${createLink([controller:'release', action:'save', params:[product:params.product]])}">
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
                   data-ajax-notice="${message(code: 'is.release.saved').encodeAsJavaScript()}"
                   data-ajax-success="#${controllerName}"
                   href="${createLink([controller:'release', action:'save', params:[product:params.product]])}">
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
                       data-ajax-notice="${message(code: 'is.release.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${next ? controllerName+(params.subid?'/'+params.id:'')+'/edit/'+next : controllerName}"
                       href="${createLink([controller:'release', action:'update', params:[product:params.product,id:release.id]])}">
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
                       data-ajax-notice="${message(code: 'is.release.updated').encodeAsJavaScript()}"
                       data-ajax-success="#${controllerName}"
                       href="${createLink([controller:'release', action:'update', params:[product:params.product,id:release.id]])}">
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
                class="button-s button-s-black" href="#${referrerUrl ?: controllerName}">
                <span class="start"></span>
                <span class="content">${message(code: 'is.button.cancel')}</span>
                <span class="end"></span>
            </a>
        </td>
    </is:buttonBar>
</g:form>

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