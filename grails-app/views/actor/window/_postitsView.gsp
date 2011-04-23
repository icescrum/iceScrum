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

<g:set var="productOwner" value="${sec.access(expression:'productOwner()',{true})}"/>

<is:backlogElementLayout
        id="window-${id}"
        selectable="[rendered:productOwner,
                    filter:'div.postit-actor',
                    selected:'\$.icescrum.dblclickSelectable(ui,300,function(obj){'+is.quickLook(params:'\'actor.id=\'+\$(obj.selected).icescrum(\'postit\').id()')+';})',
                    cancel:'a',
                    onload:'\$(\'.window-toolbar\').icescrum(\'toolbar\', \'buttons\', 1).toggleEnabled(\'.backlog\');']"
        value="${actors}"
        dblclickable='[rendered:!productOwner,selector:".postit",callback:is.quickLook(params:"\"actor.id=\"+obj.attr(\"elemId\")")]'
        var="actor">

  <is:postit id="${actor.id}"
          miniId="${actor.id}"
          title="${actor.name}"
          type="actor"
          attachment="${actor.totalAttachments}"
          controller="actor">
    <is:truncated size="50" encodedHTML="true">${actor.description?.encodeAsHTML()}</is:truncated>

  %{--Embedded menu--}%
    <is:postitMenu id="${actor.id}" contentView="window/postitMenu" params="[id:id, actor:actor]" rendered="${productOwner}"/>

    <g:if test="${actor.name?.length() > 17 || actor.description?.length() > 50}">
    <is:tooltipPostit
            type="actor"
            id="${actor.id}"
            title="${actor.name.encodeAsHTML()}"
            text="${actor.description.encodeAsHTML()}"
            apiBeforeShow="if(\$('#dropmenu').is(':visible')){return false;}"
            container="\$('#window-content-${id}')"/>
    </g:if>

  </is:postit>

</is:backlogElementLayout>
<jq:jquery>
  jQuery("#window-content-${id}").removeClass('window-content-toolbar');
  if(!jQuery("#dropmenu").is(':visible')){
    jQuery("#window-id-${id}").focus();
  }
  <is:renderNotice />
  <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'list',params:[product:params.product]]"
        disabled="jQuery('#backlog-layout-window-${id}, .view-table').length"
        group="${params.product}-${id}"
        listenOn="#window-content-${id}"/>
</jq:jquery>
<is:shortcut key="ctrl+n" callback="\$.icescrum.openWindow('${id}/add');" scope="${id}" listenOn="#window-id-${id}"/>
<is:shortcut key="space" callback="if(\$('#dialog').dialog('isOpen') == true){\$('#dialog').dialog('close'); return false;}\$.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'actor.id=\'+jQuery(obj.selected).icescrum(\'postit\').id()')}},true);" scope="${id}"/>
<is:shortcut key="ctrl+a" callback="\$('#backlog-layout-window-${id} .ui-selectee').addClass('ui-selected');"/>