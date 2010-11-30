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
  <is:table id="story-table"
          editable="[controller:id,action:'update',params:[product:params.product],onExitCell:'submit']">

    <is:tableHeader width="5%" class="table-cell-checkbox" name="">
      <g:checkBox name="checkbox-header"/>
    </is:tableHeader>
    <is:tableHeader width="3%" name="${message(code:'is.backlogelement.id')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.story.name')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.story.type')}"/>
    <is:tableHeader width="10%" name="${message(code:'is.feature')}"/>
    <is:tableHeader width="30%" name="${message(code:'is.backlogelement.description')}"/>
    <is:tableHeader width="32%" name="${message(code:'is.backlogelement.notes')}"/>

    <g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>

    <is:tableRows in="${stories}" var="story" elemID="id">


      <is:tableColumn class="table-cell-checkbox">
        <g:checkBox name="check-${story.id}" />
        <is:menu class="dropmenu-action" yoffset="4" id="${story.id}" contentView="window/postitMenu" params="[id:id, story:story, sprint:sprint, user:user]" />
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
      <is:tableColumn editable="[type:'text',highlight:true,disabled:!productOwner,name:'name']">${story.name}</is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'type',disabled:!productOwner,name:'type',values:typeSelect]"><is:bundleFromController bundle="typesBundle" value="${story.type}"/></is:tableColumn>
      <is:tableColumn editable="[type:'selectui',id:'feature',disabled:!productOwner,detach:true,name:'feature.id',values:featureSelect]"><is:postitIcon name="${story.feature?.name}" color="${story.feature?.color}"/><g:message code="${story.feature?.name?:message(code:'is.ui.sandbox.manage.chooseFeature')}"/></is:tableColumn>
      <is:tableColumn editable="[type:'textarea',disabled:!productOwner,name:'description']">${story.description?.encodeAsHTML()}</is:tableColumn>
      <is:tableColumn editable="[type:'richarea',disabled:!productOwner,name:'notes']"><wikitext:renderHtml markup="Textile">${story.notes}</wikitext:renderHtml></is:tableColumn>
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
        disabled="!jQuery('#backlog-layout-window-${id}, .view-table').is(':hidden')"
        group="${params.product}-${id}"
        listenOn="#window-content-${id}"/>
</jq:jquery>

<is:dropImport id="${id}" description="is.ui.sandbox.drop.import" action="dropImport"/>