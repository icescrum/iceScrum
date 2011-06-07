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
    <entry:point id="${id}-${actionName}" model="[releases:releases]"/>
    <is:select
            width="160"
            rendered="${releases*.name.size() > 0}"
            maxHeight="200"
            styleSelect="dropdown"
            class="window-toolbar-selectmenu-button window-toolbar-selectmenu"
            from="${releases*.name}"
            keys="${releases*.id}"
            name="selectOnReleasePlan" value="${params.id}"
            history='false'
            onchange="\$.icescrum.openWindow('${id}/'+this.value)"/>
    <is:link
            rendered="${releases*.name.size() > 0}"
            class="ui-icon-triangle-1-w"
            disabled="true"
            title="${message(code:'is.ui.releasePlan.toolbar.alt.previous')}"
            onClick="jQuery('#selectOnReleasePlan').selectmenu('selectPrevious');"
            elementId="select-previous">&nbsp;</is:link>
    <is:link
            rendered="${releases*.name.size() > 0}"
            class="ui-icon-triangle-1-e"
            disabled="true"
            title="${message(code:'is.ui.releasePlan.toolbar.alt.next')}"
            onClick="jQuery('#selectOnReleasePlan').selectmenu('selectNext');"
            elementId="select-next">&nbsp;</is:link>
</li>

<is:onStream on="#window-title-bar-content-releasePlan" events="[[object:'release',events:['add','update','remove']]]"/>

<is:onStream on="#window-title-bar-content-releasePlan"
             events="[[object:'release',events:['remove']]]"
             constraint="release.id == ${params.id}"
             callback="alert('${message(code:'is.release.deleted')}'); jQuery.icescrum.navigateTo('${controllerName}');"/>

<is:onStream on="#window-title-bar-content-releasePlan"
             events="[[object:'release',events:['update']]]"
             constraint="release.id == ${params.id}"
             callback="jQuery('#window-title-bar-releasePlan .content').html('Release plan - '+release.name+'  - '+jQuery.icescrum.release.states[release.state]+' - ['+jQuery.icescrum.dateLocaleFormat(release.startDate)+' -&gt; '+jQuery.icescrum.dateLocaleFormat(release.endDate)+']');"/>