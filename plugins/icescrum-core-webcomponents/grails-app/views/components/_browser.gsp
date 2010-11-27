<div class='box-form box-form-250'>
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

<is:fieldset title="${titleLabel}" class="browse">
    <div class="colset-2 clearfix">
      <div class="col1">
        <div class="browse-legend"><g:message code="${browserLabel}"/></div>
        <div class="browse-filter clearfix">
          <label><g:message code="is.ui.autocompletechoose.filter"/></label>
          <is:autoCompleteSearch elementId="${name}-browse" update="${name}-column" controller="${controller}" action="${actionColumn}"/>
        </div>
        <span id="${name}-column">
        </span>
      </div>
      <div class="col2">

        <div class="browse-legend"><g:message code="${detailsLabel}"/></div>
        <div class="browse-content">
          <div id="${name}-details">
            <g:if test="${initContent}">${initContent}</g:if>
          </div>
        </div>
      </div>
    </div>
  </is:fieldset>
</div>
<jq:jquery>
  $("#${name}-browse").autocomplete('search');
  $("#${name}-details").tabs();
</jq:jquery>