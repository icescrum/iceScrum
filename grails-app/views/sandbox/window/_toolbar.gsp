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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<g:if test="${request.productOwner}">
    %{--Accept button--}%
    <li class="navigation-item">
        <a class="tool-button button-n on-selectable-disabled on-selectable-window-${controllerName}"
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

    <li class="navigation-item">
        <a class="tool-button button-n on-selectable-disabled on-selectable-window-${controllerName}"
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

    <li class="navigation-item">
        <a class="tool-button button-n on-selectable-disabled on-selectable-window-${controllerName}"
           onclick="jQuery.icescrum.selectableAction('story/openDialogDelete',true,null,null);"
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

%{--Export--}%
<is:panelButton alt="Export" id="menu-export" arrow="true" text="${message(code: 'is.ui.toolbar.export')}">
    <ul>
        <g:each in="${exportFormats}" var="format">
            <li>
                <div class="file-icon ${format.code.toLowerCase()}-format" style="display:inline-block">
                    <a data-ajax="true" href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}">${format.name}</a>
                </div>
            </li>
        </g:each>
    </ul>
</is:panelButton>

<entry:point id="${controllerName}-${actionName}"/>
