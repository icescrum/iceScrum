%{--
- Copyright (c) 2011 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState" %>
<div id="acceptance-test-form-container${acceptanceTest?.id ?: ''}" ${hidden ? 'style="display:none;"' : ''} class="box-form box-form-250 box-form-200-legend">
    <form method="post" name="acceptanceTestForm${acceptanceTest?.id ?: ''}" onSubmit="return false;">
        <is:fieldset title="">
            <is:fieldInput for="acceptanceTest.name" label="is.backlogelement.name">
                <is:input id="acceptance-test-name-field${acceptanceTest?.id ?: ''}" name="acceptanceTest.name" value="${acceptanceTest?.name}"/>
            </is:fieldInput>
            <g:if test="${parentStory.state == Story.STATE_INPROGRESS}">
                <g:set var="acceptanceTestIcons" value="${AcceptanceTestState.values().collect { 'select-icon-acceptance-test icon-acceptance-test' + it.id }}"/>
                <is:fieldSelect for="acceptanceTest.state" label="is.ui.acceptanceTest.state">
                    <is:select
                            icons="${acceptanceTestIcons}"
                            id="acceptance-test-state-field${acceptanceTest?.id ?: ''}"
                            name="acceptanceTest.state"
                            from="${AcceptanceTestState.values().collect{ message(code: it.toString()) }}"
                            keys="${AcceptanceTestState.values().id}"
                            value="${acceptanceTest?.state ?: ''}" />
                </is:fieldSelect>
            </g:if>

            <is:fieldArea for="acceptanceTest.description" label="is.backlogelement.description" noborder="true">
                <span class="area-rich">
                    <markitup:editor id="acceptance-test-description-field${acceptanceTest?.id ?: ''}"
                                     class="${acceptanceTest ? '' : 'selectallonce'}" notrim="true" name="acceptanceTest.description" height="150"
                                     value="${acceptanceTest ? acceptanceTest.description : is.generateAcceptanceTestTemplate()}"/>
                </span>
            </is:fieldArea>
        </is:fieldset>

        <g:if test="${acceptanceTest}">
            <a id="acceptance-test-edit-button" class="button-s clearfix"
               data-ajax="true"
               data-ajax-form="true"
               data-ajax-method="POST"
               data-ajax-trigger='{"update_acceptancetest":"acceptanceTest"}'
               data-ajax-success="jQuery('#acceptance-test-editor-wrapper${acceptanceTest.id}').hide();
                                  jQuery('#acceptance-test${acceptanceTest.id} .acceptance-test-content').show();"
               href="${createLink([action: 'updateAcceptanceTest', params:[product:params.product]])}">
                <span class="start"></span>
                <span class="content">${message(code:'is.ui.acceptanceTest.edit')}</span>
                <span class="end"></span>
            </a>
        </g:if>
        <g:else>
            <a  id="acceptance-test-add-button" class="button-s clearfix"
               data-ajax="true"
               data-ajax-form="true"
               data-ajax-method="POST"
               data-ajax-trigger="add_acceptancetest"
               data-ajax-success="jQuery('#acceptance-test-form-container').hide();
                                  jQuery('#acceptance-test-description-field').val('${is.generateAcceptanceTestTemplate().replaceAll('\n', '\\\\n')}');
                                  jQuery('textarea.selectallonce').one('click',function() { jQuery(this).select(); });
                                  jQuery('#acceptance-test-name-field').val('');"
               href="${createLink([id:parentStory.id, action: 'saveAcceptanceTest', params:[product:params.product]])}">
                <span class="start"></span>
                <span class="content">${message(code:'is.button.add')}</span>
                <span class="end"></span>
            </a>
        </g:else>

        <g:if test="${acceptanceTest}">
            <g:hiddenField name="acceptanceTest.id" value="${acceptanceTest?.id}"/>
        </g:if>
    </form>
</div>
