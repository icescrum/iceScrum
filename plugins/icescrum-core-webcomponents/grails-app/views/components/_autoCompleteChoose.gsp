<div class="field-choose clearfix">
  <div class="field-choose-left">
    <div class="field-choose-legend">%{--
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

${message(code: 'is.ui.autocompletechoose.selected')} - ${message(code: elementLabel)}</div>
    <div class="field-choose-content">
      <div id='${target}' class="field-choose-list clearfix">

      </div>
    </div>
  </div>

  <div class="field-choose-right">
    <div class="field-choose-legend">${message(code: 'is.ui.autocompletechoose.find')} - ${message(code: elementLabel)}</div>
    <div class="field-choose-content">
      <div class="field-choose-search">
        <label>${message(code: 'is.ui.autocompletechoose.filter')} :</label>
        <is:autoComplete init='true'  controller="${controller}" action="${action ?: 'index'}"  minLength="${minLength ?: 1}" elementId="${id}-autocmp"
                  sourceOptions="${[idfieldname: resultId, selectId: source, listId: target]}" class='input-filters' source='\$.icescrum.autoCompleteChoose'/>

      </div>
      <div id='${source}' class="field-choose-finder list-selectable clearfix">

      </div>
      <ul class="pagination clearfix">
        <li class="pagination-action"><a href="#"
                onclick="$.icescrum.chooseSelected('${source}', '${target}', '${resultId}');return false;">
          <g:message code='is.ui.autocompletechoose.add' /></a>
        </li>
      </ul>
    </div>
  </div>

</div>

<jq:jquery>
$('#${target}').droppable({
      hoverClass: 'field-choose-state-hover',
      drop: function(event, ui) {
        ui.draggable.addClass('ui-selected');
        $.icescrum.chooseSelected('${source}','${target}','${resultId}');
      }
});
</jq:jquery>