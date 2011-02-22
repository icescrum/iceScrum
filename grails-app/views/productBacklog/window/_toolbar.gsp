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
- Vincent Barrier (vincent.barrier@icescrum.com)
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>
<g:set var="inProduct" value="${sec.access([expression:'inProduct()'], {true})}"/>

<is:iconButton
        rendered="${inProduct}"
        action="cloneStory"
        shortcut="[key:'ctrl+shift+c',scope:id]"
        onclick="\$.icescrum.selectableAction('sandbox/cloneStory',true,'id',function(data){jQuery.icescrum.renderNotice(data.notice.text);});"
        disablable="true"
        disabled="true"
        alt="${message(code:'is.ui.productBacklog.toolbar.alt.clone')}"
        title="${message(code:'is.ui.productBacklog.toolbar.alt.clone')}">
  ${message(code: 'is.ui.productBacklog.toolbar.clone')}
</is:iconButton>

<is:separatorSmall rendered="${inProduct}"/>

%{--Delete button--}%
<is:iconButton
        icon="delete"
        rendered="${productOwner}"
        onclick="\$.icescrum.selectableAction();"
        history='false'
        shortcut="[key:'del',scope:id]"
        disabled="true"
        disablable="true"
        title="${message(code:'is.ui.productBacklog.toolbar.alt.delete')}"
        alt="${message(code:'is.ui.productBacklog.toolbar.alt.delete')}">
  ${message(code:'is.ui.productBacklog.toolbar.delete')}
</is:iconButton>

<is:separator rendered="${productOwner}"/>

%{--View--}%
<is:panelButton alt="View" id="menu-display" arrow="true" icon="view" text="${message(code:'is.view.'+currentView)}">
  <ul>
    <li class="first">
      <is:link
              controller="scrumOS"
              action="changeView"
              params="'product=${params.product}&view=postitsView&window=${id}&actionWindow=list&term='+\$(\'#autoCmpTxt\').val()"
              history="false"
              update="window-content-${id}"
              remote="true"
              onSuccess="\$.icescrum.displayView('${message(code:'is.view.postitsView')}')"
              value="${message(code:'is.view.postitsView')}"/>
    </li>
    <li class="last">
      <is:link controller="scrumOS"
              action="changeView"
              params="'product=${params.product}&view=tableView&window=${id}&actionWindow=list&term='+\$(\'#autoCmpTxt\').val()"
              update="window-content-${id}"
              history="false"
              onSuccess="\$.icescrum.displayView('${message(code:'is.view.tableView')}')"
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
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="productBacklog" action="list" update="window-content-${id}"/>
</is:panelSearch>
