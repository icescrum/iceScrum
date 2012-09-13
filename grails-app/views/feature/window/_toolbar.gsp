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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
%{--New--}%
<is:iconButton
        controller="feature"
        action="add"
        rendered="${request.productOwner}"
        shortcut="[key:'ctrl+n',scope:controllerName]"
        update="window-content-${controllerName}"
        icon="create"
        alt="${message(code:'is.ui.feature.toolbar.alt.new')}"
        title="${message(code:'is.ui.feature.toolbar.alt.new')}">
    <g:message code="is.ui.feature.toolbar.new"/>
</is:iconButton>

<is:separatorSmall rendered="${request.productOwner}"/>

%{--Delete button (note-view)--}%
<is:iconButton
        icon="delete"
        onclick="jQuery.icescrum.selectableAction(null,null,null,function(data){jQuery.event.trigger('remove_feature',[data]); jQuery.icescrum.renderNotice('${message(code:'is.feature.deleted')}'); });"
        history='false'
        rendered="${request.productOwner}"
        shortcut="[key:'del',scope:controllerName]"
        disabled="true"
        title="${message(code:'is.ui.feature.toolbar.alt.delete')}"
        alt="${message(code:'is.ui.feature.toolbar.alt.delete')}">
    <g:message code="is.ui.sandbox.toolbar.delete"/>
</is:iconButton>

<is:separator rendered="${request.productOwner}"/>

%{--View--}%

<is:panelButton alt="View" id="menu-display" arrow="true" icon="view">
    <ul>
        <li class="first">
            <a href="${createLink(action:'list',controller:controllerName,params:[product:params.product])}"
               data-default-view="postitsView"
               data-ajax-begin="$.icescrum.setDefaultView"
               data-ajax-update="#window-content-${controllerName}"
               data-ajax="true">${message(code:'is.view.postitsView')}</a>
        </li>
        <li class="last">
            <a href="${createLink(action:'list',controller:controllerName,params:[product:params.product, viewType:'tableView'])}"
               data-default-view="tableView"
               data-ajax-begin="$.icescrum.setDefaultView"
               data-ajax-update="#window-content-${controllerName}"
               data-ajax="true">${message(code:'is.view.tableView')}</a>
        </li>
    </ul>
</is:panelButton>

<is:separator/>

<is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
    <ul>
        <li class="first">
            <is:link
                    action="productParkingLotChart"
                    controller="feature"
                    update="window-content-${controllerName}"
                    title="${message(code:'is.ui.feature.charts.productParkingLot')}"
                    remote="true"
                    value="${message(code:'is.ui.feature.charts.productParkingLot')}"/>
        </li>
    </ul>
</is:panelButton>

<is:separatorSmall/>

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
<entry:point id="${controllerName}-${actionName}-toolbar"/>
%{--Search--}%
<is:panelSearch id="search-ui">
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="feature" action="list" update="window-content-${controllerName}"/>
</is:panelSearch>
