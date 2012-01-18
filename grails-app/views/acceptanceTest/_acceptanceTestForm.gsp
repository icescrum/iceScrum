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
<div id="acceptance-test-form-container${acceptanceTest?.id ?: ''}" ${hidden ? 'style="display:none;"' : ''}>
    <g:form action="saveAcceptanceTest" name="acceptanceTestForm${acceptanceTest?.id ?: ''}">

        <is:fieldInput for="acceptance-test-name-field" label="">
            <is:input id="acceptance-test-name-field${acceptanceTest?.id ?: ''}" name="acceptanceTest.name" value="${acceptanceTest?.name}"/>
        </is:fieldInput>

        <markitup:editor id="acceptance-test-description-field${acceptanceTest?.id ?: ''}" name="acceptanceTest.description">
            ${acceptanceTest?.description}
        </markitup:editor>

        <g:if test="${acceptanceTest}">
            <g:hiddenField name="acceptanceTest.id" value="${acceptanceTest?.id}"/>
        </g:if>
        <g:else>
            <g:hiddenField name="parentStoryId" value="${parentStory.id}"/>
        </g:else>

        <g:if test="${acceptanceTest}">
            <is:button
                id="acceptance-test-edit-button" type="submitToRemote"
                url="[controller:'backlogElement', action:'updateAcceptanceTest', params:[product:params.product]]"
                onSuccess="jQuery('#acceptance-test-editor-wrapper${acceptanceTest.id}').hide();
                           jQuery('#acceptance-test${acceptanceTest.id} .acceptance-test-content').show();
                           jQuery.event.trigger('update_acceptancetest',data);"
                value="${message(code:'is.ui.acceptanceTest.edit')}"
                history="false"/>
        </g:if>
        <g:else>
        <is:button
            id="acceptance-test-add-button" type="submitToRemote"
            url="[controller:'backlogElement', action:'saveAcceptanceTest', params:[product:params.product]]"
            onSuccess="jQuery('#acceptance-test-form-container').hide();
                       jQuery('#acceptance-test-description-field').val('');
                       jQuery('#acceptance-test-name-field').val('');
                       jQuery.event.trigger('add_acceptancetest',data);"
            value="${message(code:'is.button.add')}"
            history="false"/>
        </g:else>

    </g:form>
</div>
