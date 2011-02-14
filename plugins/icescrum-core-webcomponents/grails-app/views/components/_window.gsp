%{--
  - Copyright (c) 2010 iceScrum Technologies.
  -
  - This file is part of iceScrum.
  -
  - iceScrum is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Lesser General Public License as published by
  - the Free Software Foundation, either version 3 of the License.
  -
  - iceScrum is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU General Public License for more details.
  -
  - You should have received a copy of the GNU Lesser General Public License
  - along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
  --}%

%{-- tabindex to active shortcuts on div --}%
<div id="${type}-id-${id}" class="box-${type}${sortable?'-sortable':''} box" tabindex="0">

  %{-- Headbar --}%
  <g:if test="${titleBarActions?.maximizeable}">
    <div id="${type}-title-bar-${id}" class="box-title resizable">
  </g:if>
  <g:elseif test="${titleBarActions?.windowable}">
    <div id="${type}-title-bar-${id}" class="box-title resizable">
  </g:elseif>
  <g:else>
    <div id="${type}-title-bar-${id}" class="box-title">
  </g:else>

    <span class="start"></span><p class="content">${title}</p><span class="end"></span>

    %{-- Title bar content options --}%
    <g:if test="${hasTitleBarContent}">
    <ul id="${type}-title-bar-content-${id}" class="box-title-content">
      ${titleBarContent}
    </ul>
    </g:if>

    %{-- Title bar naivgation actions --}%
    <ul id="${type}-button-${id}" class="box-title-buttons">
      <g:if test="${help}">
        <is:helpButton id="${type}-help-${id}" text="${message(code:'?')}">
          ${message(code: help)}
        </is:helpButton>
      </g:if>
      <g:if test="${titleBarActions?.widgetable}">
        <li>
            <span class="${type}-minimize minimize" alt="Minimize" ></span>
        </li>
      </g:if>
      <g:if test="${titleBarActions?.maximizeable}">
        <li>
            <span class="${type}-maxicon maxicon" alt="Expand" ></span>
        </li>
      </g:if>
      <g:if test="${titleBarActions?.windowable}">
        <li>
            <span class="${type}-maxicon minimize" alt="Expand" ></span>
        </li>
      </g:if>
      <g:if test="${titleBarActions?.closeable}">
      <li>
          <span class="${type}-close close" alt="Close" ></span>
      </li>
      </g:if>
    </ul>

  </div>

  %{-- Toolbar --}%
  <g:if test="${hasToolbar}">
    <is:toolbar type="${type}">
      ${toolbar}
    </is:toolbar>
  </g:if>

  %{-- Content --}%
  <div id="${type}-content-${id}" class="box-content ${type}-content ${hasStatusbar ? type+'-content-statusbar' : ''} ${!hasToolbar ? type+'-content-without-toolbar' : ''}">
    ${windowContent}
  </div>

  %{-- Status bar --}%
  <g:if test="${hasStatusbar}">
    <div id="${type}-status-bar-${id}" class="status-bar nav clearfix">
      ${statusBar}
    </div>
  </g:if>


</div>
<g:if test="${type == 'window'}">
  <jq:jquery>
    $("#${type}-id-${id}").isWindow({
            maximizeable:${titleBarActions?.maximizeable},
            widgetable:${titleBarActions?.widgetable},
            closeable:${titleBarActions?.closeable}
          }
    );
    document.title = 'iceScrum - ${title.encodeAsJavaScript()} - '+ ($.icescrum.o.currentProductName ? $.icescrum.o.currentProductName : ($.icescrum.o.currentTeamName ? $.icescrum.o.currentTeamName : ''));
    $("#${type}-id-${id}").focus();
  </jq:jquery>
</g:if>
<g:if test="${type == 'widget'}">
  <jq:jquery>
    jQuery("#${type}-id-${id}").isWidget({
            windowable:${titleBarActions?.windowable},
            closeable:${titleBarActions?.closeable},
            height:${height}
        }
    );
  </jq:jquery>
</g:if>
