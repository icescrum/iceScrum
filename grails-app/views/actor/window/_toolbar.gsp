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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<is:shortcut key="ctrl+f" callback="jQuery('#search-ui').mouseover();" scope="${controllerName}"/>
<is:shortcut key="esc" callback="jQuery('#search-ui').mouseout();" scope="${controllerName}" listenOn="'#autoCmpTxt'"/>

<sec:access expression="productOwner()">

    <is:iconButton
            controller="actor"
            action="add"
            shortcut="[key:'ctrl+n',scope:controllerName]"
            update="window-content-${controllerName}"
            icon="create"
            alt="${message(code:'is.ui.actor.toolbar.alt.new')}"
            title="${message(code:'is.ui.actor.toolbar.alt.new')}">
        <g:message code="is.ui.actor.toolbar.new"/>
    </is:iconButton>

    <is:separatorSmall/>

%{--Delete button (note-view)--}%
    <is:iconButton icon="delete"
                   onclick="jQuery.icescrum.selectableAction(null,null,null,function(data){jQuery.event.trigger('remove_actor',[data]); jQuery.icescrum.renderNotice('${message(code:'is.actor.deleted')}'); });"
                   history='false'
                   shortcut="[key:'del',scope:controllerName]"
                   disabled="true"
                   title="${message(code:'is.ui.actor.toolbar.alt.delete')}"
                   alt="${message(code:'is.ui.actor.toolbar.alt.delete')}">
        <g:message code="is.ui.actor.toolbar.delete"/>
    </is:iconButton>

    <is:separator/>

</sec:access>

%{--View--}%
<is:panelButton alt="View" id="menu-display" arrow="true" icon="view" text="${message(code:'is.view.'+currentView)}">
    <ul>
        <li class="first">
            <is:link
                    controller="scrumOS"
                    action="changeView"
                    params="'product=${params.product}&view=postitsView&window=${controllerName}&actionWindow=list&term='+jQuery(\'#autoCmpTxt\').val()"
                    history="false"
                    update="window-content-${controllerName}"
                    remote="true"
                    onSuccess="jQuery.icescrum.displayView('${message(code:'is.view.postitsView')}','postitsView')"
                    value="${message(code:'is.view.postitsView')}"/>
        </li>
        <li class="last">
            <is:link controller="scrumOS"
                     action="changeView"
                     params="'product=${params.product}&view=tableView&window=${controllerName}&actionWindow=list&term='+jQuery(\'#autoCmpTxt\').val()"
                     update="window-content-${controllerName}"
                     history="false"
                     onSuccess="jQuery.icescrum.displayView('${message(code:'is.view.tableView')}','tableView')"
                     remote="true"
                     value="${message(code:'is.view.tableView')}"/>
        </li>
    </ul>
</is:panelButton>

<is:separator/>

%{--Print button--}%
<is:reportPanel
        action="print"
        text="${message(code: 'is.ui.toolbar.print')}"
        formats="[
                  ['PDF', message(code:'is.report.format.pdf')],
                  ['RTF', message(code:'is.report.format.rtf')],
                  ['DOCX', message(code:'is.report.format.docx')],
                  ['ODT', message(code:'is.report.format.odt')]
                ]"/>

%{--Search--}%

<entry:point id="${controllerName}-${actionName}-toolbar"/>

<is:panelSearch id="search-ui">
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="actor" action="list" update="window-content-${controllerName}"/>
</is:panelSearch>
