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
%{-- Sprints lists --}%
<g:if test="${sprint?.id}">
    <li>
        <entry:point id="${id}-${actionName}" model="[sprintsName:sprintsName]"/>
        <is:select
                rendered="${sprintsName.size() > 0}"
                maxHeight="200"
                styleSelect="dropdown"
                class="window-toolbar-selectmenu-button window-toolbar-selectmenu"
                from="${sprintsName}"
                keys="${sprintsId}"
                value="${sprint.id}"
                history='false'
                name="selectOnSprintPlan"
                onchange=" \$.icescrum.openWindow('${id}/'+this.value)"/>
        <is:link
                rendered="${sprintsName.size() > 0}"
                class="ui-icon-triangle-1-w"
                disabled="true"
                title="${message(code:'is.ui.sprintPlan.toolbar.alt.previous')}"
                onClick="jQuery('#selectOnSprintPlan').selectmenu('selectPrevious');"
                elementId="select-previous">&nbsp;</is:link>
        <is:link
                rendered="${sprintsName.size() > 0}"
                class="ui-icon-triangle-1-e"
                disabled="true"
                title="${message(code:'is.ui.sprintPlan.toolbar.alt.next')}"
                onClick="jQuery('#selectOnSprintPlan').selectmenu('selectNext');"
                elementId="select-next">&nbsp;</is:link>
    </li>

    <is:onStream on="#window-title-bar-content-sprintPlan"
                 events="[[object:'sprint',events:['add','update','remove']]]"/>

    <is:onStream on="#window-title-bar-content-sprintPlan"
                 events="[[object:'sprint',events:['remove']]]"
                 constraint="sprint.id == ${sprint.id}"
                 callback="alert('${message(code:'is.sprint.deleted')}'); jQuery.icescrum.navigateTo('${controllerName}');"/>

    <is:onStream on="#window-title-bar-content-sprintPlan"
                 events="[[object:'sprint',events:['update','activate','close']]]"
                 constraint="sprint.id == ${sprint.id}"
                 callback="jQuery('#window-title-bar-sprintPlan .content').html('Sprint plan - ${message(code:'is.sprint')} ' + sprint.orderNumber + ' - ' + jQuery.icescrum.sprint.states[sprint.state] + ' - [' + jQuery.icescrum.dateLocaleFormat(sprint.startDate) + ' -&gt; ' + jQuery.icescrum.dateLocaleFormat(sprint.endDate) + ']');"/>
</g:if>
