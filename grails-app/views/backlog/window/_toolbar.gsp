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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<is:iconButton
        rendered="${request.inProduct}"
        shortcut="[key:'ctrl+shift+c',scope:id]"
        onclick="jQuery.icescrum.selectableAction('story/copy',true,'id',function(data){jQuery.icescrum.renderNotice('${message(code:'is.story.selection.cloned')}');})"
        disabled="true"
        alt="${message(code:'is.ui.backlog.toolbar.alt.clone')}"
        title="${message(code:'is.ui.backlog.toolbar.alt.clone')}">
    ${message(code: 'is.ui.backlog.toolbar.clone')}
</is:iconButton>

<is:separatorSmall rendered="${request.inProduct}"/>

%{--Delete button--}%
<is:iconButton
        icon="delete"
        rendered="${request.productOwner}"
        onclick="jQuery.icescrum.selectableAction('story/delete',null,null,function(data){jQuery.event.trigger('remove_story',[data]); jQuery.icescrum.renderNotice('${message(code:'is.story.deleted')}'); });"
        history='false'
        shortcut="[key:'del',scope:id]"
        disabled="true"
        title="${message(code:'is.ui.backlog.toolbar.alt.delete')}"
        alt="${message(code:'is.ui.backlog.toolbar.alt.delete')}">
    ${message(code: 'is.ui.backlog.toolbar.delete')}
</is:iconButton>

<is:separator rendered="${request.productOwner}"/>

%{--View--}%
<is:panelButton alt="View" id="menu-display" arrow="true" icon="view" text="${message(code:'is.view.'+currentView)}">
    <ul>
        <li class="first">
            <is:link
                    controller="scrumOS"
                    action="changeView"
                    params="'product=${params.product}&view=postitsView&window=${id}&actionWindow=list&term='+jQuery(\'#autoCmpTxt\').val()"
                    history="false"
                    update="window-content-${id}"
                    remote="true"
                    onSuccess="jQuery.icescrum.displayView('${message(code:'is.view.postitsView')}')"
                    value="${message(code:'is.view.postitsView')}"/>
        </li>
        <li class="last">
            <is:link controller="scrumOS"
                     action="changeView"
                     params="'product=${params.product}&view=tableView&window=${id}&actionWindow=list&term='+jQuery(\'#autoCmpTxt\').val()"
                     update="window-content-${id}"
                     history="false"
                     onSuccess="jQuery.icescrum.displayView('${message(code:'is.view.tableView')}')"
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

<entry:point id="${id}-${actionName}"/>

<is:panelSearch id="search-ui">
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="backlog" action="list" update="window-content-${id}"/>
</is:panelSearch>
