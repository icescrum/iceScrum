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
--}%

<%@ page import="org.icescrum.core.domain.Story" %>
<is:tableView>
  <is:table id="story-table"
          editable="[controller:id,action:'update',params:[product:params.product],onExitCell:'submit']">
    <is:tableHeader width="5%" class="table-cell-checkbox" name="">
      <g:checkBox name="checkbox-header"/>
    </is:tableHeader>
    <is:tableHeader width="3%" name="${message(code:'is.backlogelement.id')}" />
    <is:tableHeader width="4%" name="${message(code:'is.story.rank')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.story.name')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.story.type')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.feature')}"/>
    <is:tableHeader width="4%" name="${message(code:'is.story.effort')}"/>
    <is:tableHeader width="19%" name="${message(code:'is.backlogelement.description')}"/>
    <is:tableHeader width="19%" name="${message(code:'is.backlogelement.notes')}"/>
    <is:tableHeader width="8%" name="${message(code:'is.story.date.accepted')}"/>
    <is:tableHeader width="8%" name="${message(code:'is.story.date.estimated')}"/>

    <g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>
    <g:set var="inProduct" value="${sec.access([expression:'inProduct()'], {true})}"/>

    <is:tableRows in="${stories}" var="story" elemID="id">
      <is:tableColumn class="table-cell-checkbox">
        <g:checkBox name="check-${story.id}" />
        <is:menu class="dropmenu-action" yoffset="4" id="${story.id}" contentView="window/postitMenu" params="[id:id,story:story]"/>
        <g:set var="comment" value="${story.totalComments}"/>
        <g:if test="${comment}">
          <span class="table-comment" title="${message(code:'is.postit.comment.count', args:[comment,comment > 1 ? 's' : ''])}"></span>
        </g:if>
        <g:set var="attachment" value="${story.totalAttachments}"/>
        <g:if test="${attachment}">
          <span class="table-attachment" title="${message(code:'is.postit.attachment', args:[attachment,attachment > 1 ? 's' : ''])}"></span>
        </g:if>
      </is:tableColumn>
      <is:tableColumn class="table-cell-postit-icon">
        <is:scrumLink id="${story.id}" controller="backlogElement">
          ${story.id}
        </is:scrumLink>
      </is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'rank',disabled:!productOwner,name:'rank',values:rankSelect]">${story.rank}</is:tableColumn>
      <is:tableColumn editable="[type:'text',disabled:!productOwner,name:'name']">${story.name.encodeAsHTML()}</is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'type',disabled:!productOwner,name:'type',values:typeSelect]"><is:bundleFromController bundle="typesBundle" value="${story.type}"/></is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'feature',disabled:!productOwner,detach:true,name:'feature.id',values:featureSelect]"><is:postitIcon name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/><g:message code="${story.feature?.name?.encodeAsHTML()?:message(code:'is.ui.productBacklog.choose.feature')}"/></is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'effort',disabled:!inProduct,name:'effort',values:suiteSelect]">${story.effort?:'?'}</is:tableColumn>
      <is:tableColumn editable="[type:'textarea',disabled:!productOwner,name:'description']">${story.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
      <is:tableColumn editable="[type:'richarea',disabled:!productOwner,name:'notes']"><wikitext:renderHtml markup="Textile">${story.notes}</wikitext:renderHtml></is:tableColumn>
      <is:tableColumn>${story.acceptedDate?g.formatDate(date:story.acceptedDate,formatName:'is.date.format.short',timezone:user?.preferences?.timezone?:null):''}</is:tableColumn>
      <is:tableColumn>${story.estimatedDate?g.formatDate(date:story.estimatedDate,formatName:'is.date.format.short',timezone:user?.preferences?.timezone?:null):''}</is:tableColumn>
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