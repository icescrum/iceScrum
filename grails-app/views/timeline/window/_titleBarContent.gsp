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
<li>
    <entry:point id="${controllerName}-${actionName}" model="[currentRelease:currentRelease]"/>
    <is:select
            width="200"
            rendered="${releasesName.size() > 0}"
            maxHeight="200"
            styleSelect="dropdown"
            name="selectOnTimeline"
            from="${releasesName}"
            keys="${releasesDate}"
            optionId="${releasesIds}"
            value="${currentRelease}"
            onChange="timelineTl.getBand(0).setMinVisibleDate(parseInt(this.value.split('-')[0]));"/>
    <is:link
            rendered="${releasesName.size() > 0}"
            class="ui-icon-triangle-1-w"
            disabled="true"
            title="${message(code:'is.ui.timeline.toolbar.alt.previous')}"
            onClick="jQuery('#selectOnTimeline').selectmenu('selectPrevious');"
            elementId="select-previous">&nbsp;</is:link>
    <is:link
            rendered="${releasesName.size() > 0}"
            class="ui-icon-triangle-1-e"
            disabled="true"
            title="${message(code:'is.ui.timeline.toolbar.alt.next')}"
            onClick="jQuery('#selectOnTimeline').selectmenu('selectNext');"
            elementId="select-next">&nbsp;</is:link>
</li>
<is:onStream on="#window-title-bar-content-timeline"
             events="[[object:'release',events:['add','update','remove']],[object:'sprint',events:['add','update','remove']]]"/>