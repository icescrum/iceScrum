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
<%@ page import="org.icescrum.core.domain.Story" %>

<is:tableView>
  <is:table id="feature-table"
          editable="[controller:id,action:'update',params:[product:params.product],onExitCell:'submit']">
    <is:tableHeader width="5%" class="table-cell-checkbox" name="">
      <g:checkBox name="checkbox-header"/>
    </is:tableHeader>
    <is:tableHeader width="10%" name="${message(code:'is.actor.name')}"/>
    <is:tableHeader width="20%" name="${message(code:'is.backlogelement.description')}"/>
    <is:tableHeader width="15%" name="${message(code:'is.actor.it.level')}"/>
    <is:tableHeader width="15%" name="${message(code:'is.actor.satisfaction.criteria')}"/>
    <is:tableHeader width="14%" name="${message(code:'is.actor.use.frequency')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.actor.instances')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.actor.nb.stories')}"/>

    <g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>

    <is:tableRows in="${actors}" var="actor" elemID="id">
      <is:tableColumn class="table-cell-checkbox">
        <g:checkBox name="check-${actor.id}" />
        <is:menu class="dropmenu-action" yoffset="4" id="${actor.id}" contentView="window/postitMenu" params="[id:id, actor:actor]" rendered="${productOwner}"/>
        <g:set var="attachment" value="${actor.totalAttachments}"/>
        <g:if test="${attachment}">
          <span class="table-attachment" title="${message(code:'is.postit.attachment', args:[attachment,attachment > 1 ? 's' : ''])}"></span>
        </g:if>
      </is:tableColumn>
      <is:tableColumn editable="[type:'text',disabled:!productOwner,name:'name']">${actor.name.encodeAsHTML()}</is:tableColumn>
      <is:tableColumn editable="[type:'textarea',disabled:!productOwner,name:'description']">${actor.description?.encodeAsHTML()}</is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'level',name:'expertnessLevel',values:levelsSelect,disabled:!productOwner]"><is:bundleFromController bundle="levelsBundle" value="${actor.expertnessLevel}"/></is:tableColumn>
      <is:tableColumn editable="[type:'textarea',disabled:!productOwner,name:'satisfactionCriteria']">${actor.satisfactionCriteria?.encodeAsHTML()}</is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'useFrequency',name:'useFrequency',values:frequenciesSelect,disabled:!productOwner]"><is:bundleFromController bundle="frequenciesBundle" value="${actor.useFrequency}"/></is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'instances',name:'instances',values:instancesSelect,disabled:!productOwner]"><is:bundleFromController bundle="instancesBundle" value="${actor.instances}"/></is:tableColumn>
      <is:tableColumn>${actor.stories.size()?:0}</is:tableColumn>
    </is:tableRows>
  </is:table>
</is:tableView>
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