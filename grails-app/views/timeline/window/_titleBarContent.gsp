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
            rendered="${releasesName.size() > 0}"
            name="selectOnTimeline"
            from="${releasesName}"
            keys="${releasesDate}"
            optionId="${releasesIds}"
            value="${currentRelease}"
            width="200"
            class="title-bar-select2"
            data-dropdown-css-class="title-bar-select2"
            onChange="timelineTl.getBand(0).setMinVisibleDate(parseInt(this.value.split('-')[0]));"/>
</li>
<is:onStream on="#window-title-bar-content-timeline"
             events="[[object:'release',events:['add','update','remove']],[object:'sprint',events:['add','update','remove']]]"/>