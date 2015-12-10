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
<is:dialog width="400" valid="[action:'close',
                               controller:controllerName,
                               id:sprint.id,
                               onSuccess:'jQuery.event.trigger(\'close_sprint\',data.sprint); jQuery.event.trigger(\'done_story\',[data.stories]); jQuery.event.trigger(\'update_story\',[data.unDoneStories]);jQuery.icescrum.renderNotice(\''+g.message(code:'is.sprint.closed')+'\')',
                               button:'is.dialog.closeSprint.button']">
    <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
        <input type="hidden" value="true" name="confirm"/>
        <input type="hidden" value="${params.product}" name="product"/>
        <is:fieldset title="is.dialog.closeSprint.title">
            <g:if test="${stories}">
                <is:fieldInformation noborder="true">
                    <g:message code="is.dialog.closeSprint.description"/>
                </is:fieldInformation>
                <div style="max-height:250px;overflow:auto;">
                    <g:each in="${stories}" var="story" status="u">
                        <is:fieldRadio noborder="${(u + 1) == stories.size()?'true':'false'}" for="undonestory-${story.id}"
                                       label="${story.id} - ${story.name.encodeAsHTML()} (${story.effort} ${story.effort > 1 ? 'pts' : 'pt'})">
                            <is:radio
                                    from="[(message(code: 'is.dialog.closeSprint.done')): '1', (message(code: 'is.dialog.closeSprint.notDone')): '0']"
                                    id="undonestory-${story.id}" value="0" name="story.id.${story.id}"/>
                        </is:fieldRadio>
                    </g:each>
                </div>
            </g:if>
            <g:if test="${!sprint.deliveredVersion}">
                <is:fieldInformation noborder="true">
                    <g:message code="is.dialog.closeSprintVersion.description"/>
                </is:fieldInformation>
                <is:fieldInput for="sprintDeliveredVersion" label="is.sprint.deliveredVersion" noborder="true">
                    <is:input id="sprintDeliveredVersion" class="small" name="sprint.deliveredVersion" value="${sprint?.deliveredVersion}"/>
                </is:fieldInput>
            </g:if>
        </is:fieldset>
    </form>
</is:dialog>