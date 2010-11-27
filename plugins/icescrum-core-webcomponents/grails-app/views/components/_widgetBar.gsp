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
<div class="widget-bar">
  <g:if test="${product != null}">
    <div class="box-simple box-simple-last ui-corner-all" id="project-details">
      <g:render template="/grails-app/views/project/dialogs/details" model="[user:user,currentProduct:product]"/>
    </div>
  </g:if>
  <g:if test="${team != null}">
    <div class="box-simple box-simple-last ui-corner-all" id="team-details">
      <g:render template="/grails-app/views/team/dialogs/details" model="[user:user, currentTeam:team]"/>
    </div>
  </g:if>
  <div id="widget-list">
    <g:each in="${widgetsList}" var="widget">
      <is:widget attrs="${widget}"/>
    </g:each>
  </div>
</div>
<jq:jquery>
  $("#widget-list").sortable({
    handle:".box-title",
    items:".box-widget-sortable"
  });

  $("#local").droppable({
    drop:function(event, ui){
      var id = ui.draggable.attr('id').replace('elem_','');
      if (id != ui.draggable.attr('id')){
        if($("#window-id-"+id).is(':visible')){
          $.icescrum.windowToWidget($("#window-id-"+id),event);
        }else{
          $.icescrum.addToWidgetBar(id);
        }
      }
    },
    hoverClass: 'local-active',
    accept: '.widgetable'
  });

</jq:jquery>

