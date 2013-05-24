%{--
- Copyright (c) 2013 Kagilum SAS.
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
<is:dialog width="400"
           valid="[action:'done',
                   controller:'story',
                   id: storyId,
                   button:'is.ui.releasePlan.menu.story.done',
                   onSuccess:'jQuery.event.trigger(\'done_story\',[data]); jQuery.icescrum.renderNotice(\''+message(code:'is.story.declaredAsDone')+'\');'
           ]">
    <form method="post" class="box-form" onsubmit="return false;">
        <input type="hidden" value="${params.product}" name="product"/>
        <is:fieldset title="is.dialog.acceptanceTestsSuggestStoryDone.title">
            <is:fieldInformation noborder="true">
                <g:message code="is.dialog.acceptanceTestsSuggestStoryDone"/>
            </is:fieldInformation>
        </is:fieldset>
    </form>
</is:dialog>