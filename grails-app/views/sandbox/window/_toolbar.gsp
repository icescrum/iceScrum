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
%{--Add button--}%
<g:if test="${!request.archivedProduct}">
    <li class="navigation-item button-ico button-create">
        <a class="tool-button button-n"
           href="#${controllerName}/add"
           data-shortcut="ctrl+n"
           data-shortcut-on="#window-id-${controllerName}"
           title="${message(code:'is.ui.sandbox.toolbar.alt.new')}"
           alt="${message(code:'is.ui.sandbox.toolbar.alt.new')}">
                <span class="start"></span>
                <span class="content">
                    <span class="ico"></span>
                    ${message(code: 'is.ui.sandbox.toolbar.new')}
                </span>
                <span class="end"></span>
        </a>
    </li>
</g:if>

<g:if test="${request.productOwner}">

    <li class="navigation-item separator-s"></li>

    %{--Accept button--}%
    <li class="navigation-item">
        <a class="tool-button button-n"
           data-ajax="true"
           href="${createLink(action:'openDialogAcceptAs',params:[product:params.product])}"
           data-shortcut="ctrl+shift+a"
           data-shortcut-on="#window-id-${controllerName}"
           alt="${message(code:'is.ui.sandbox.toolbar.alt.accept')}"
           title="${message(code:'is.ui.sandbox.toolbar.alt.accept')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.sandbox.toolbar.accept')}
                </span>
                <span class="end"></span>
        </a>
    </li>

    <li class="navigation-item separator-s"></li>

    <li class="navigation-item">
        <a class="tool-button button-n"
           onclick="jQuery.icescrum.selectableAction('story/copy',true,null,function(data){ jQuery.event.trigger('add_story',[data]); jQuery.icescrum.renderNotice('${message(code:'is.story.selection.cloned')}'); });"
           data-shortcut="ctrl+shift+c"
           data-shortcut-on="#window-id-${controllerName}"
           alt="${message(code:'is.ui.sandbox.toolbar.alt.clone')}"
           title="${message(code:'is.ui.sandbox.toolbar.alt.clone')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.sandbox.toolbar.clone')}
                </span>
                <span class="end"></span>
        </a>
    </li>

    <li class="navigation-item separator-s"></li>

    <li class="navigation-item">
        <a class="tool-button button-n"
           onclick="jQuery.icescrum.selectableAction('story/delete',null,null,function(data){ jQuery.event.trigger('remove_story',[data]); jQuery.icescrum.renderNotice('${message(code:'is.story.deleted')}'); });"
           data-shortcut="del"
           data-shortcut-on="#window-id-${controllerName}"
           alt="${message(code:'is.ui.sandbox.toolbar.alt.delete')}"
           title="${message(code:'is.ui.sandbox.toolbar.alt.delete')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.sandbox.toolbar.delete')}
                </span>
                <span class="end"></span>
        </a>
    </li>
</g:if>

<g:if test="${!request.archivedProduct}">
    <li class="navigation-item separator"></li>
</g:if>

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

<li class="navigation-item separator"></li>

<is:reportPanel
        action="print"
        text="${message(code: 'is.ui.toolbar.print')}"
        formats="[
                  ['PDF', message(code:'is.report.format.pdf')],
                  ['RTF', message(code:'is.report.format.rtf')],
                  ['DOCX', message(code:'is.report.format.docx')],
                  ['ODT', message(code:'is.report.format.odt')]
                ]"/>

<entry:point id="${controllerName}-${actionName}"/>
%{--Textfield for the auto completion search--}%
<is:panelSearch id="search-ui">
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="${controllerName}" action="list" update="window-content-${controllerName}"/>
</is:panelSearch>
