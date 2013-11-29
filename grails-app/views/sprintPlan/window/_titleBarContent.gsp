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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
%{-- Sprints lists --}%
<g:if test="${sprint?.id}">
    <li>
        <entry:point id="${controllerName}-${actionName}" model="[sprintsName:sprintsName]"/>
        <is:select
                rendered="${sprintsName.size() > 0}"
                from="${sprintsName}"
                keys="${sprintsId}"
                value="${sprint.id}"
                name="selectOnSprintPlan"
                width="200"
                class="title-bar-select2"
                data-dropdown-css-class="title-bar-select2"
                onchange="document.location.hash = '${controllerName}/'+this.value;"/>
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
                 callback="jQuery.icescrum.sprint.updateWindowTitle(sprint);"/>
</g:if>
