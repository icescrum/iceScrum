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

<g:set var="access" value="${access ?: sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>
<li id="comment${comment.id}${commentId ? '-'+commentId : ''}" class="comment">
  <div class="comment-avatar">
    <is:avatar userid="${comment.poster.id}" class="ico"/>
  </div>

  <div class="comment-details">
    <is:scrumLink controller="user" action='profile' id="${comment.poster?.username}"><strong>${comment.poster?.firstName?.encodeAsHTML()} ${comment.poster?.lastName?.encodeAsHTML()}</strong></is:scrumLink>,
    <g:formatDate date="${comment.dateCreated}" formatName="is.date.format.short.time"/>
    <g:if test="${moderation && (access || user?.id == comment.poster?.id)}">
      (
      <is:link history="false"
              remote="true"
              controller="backlogElement"
              action="editCommentEditor"
              id="${comment.id}"
              update="comment${comment.id}"
              params="[commentable:backlogelement]"
              onSuccess="\$('#commentEditorContainer').hide();"
              rendered="${(access || user?.id == comment.poster?.id) ? 'true' : 'false'}">
        ${message(code:'is.ui.backlogelement.comment.edit')}
      </is:link>
      <g:if test="${access}">
        -
        <is:link history="false"
                remote="true"
                update="activities-wrapper"
                controller="backlogElement"
                action="deleteComment"
                id="${comment.id}"
                params="[backlogelement:backlogelement]">
          ${message(code:'is.ui.backlogelement.comment.delete')}
        </is:link>
      </g:if>
      )
    </g:if>
    <g:if test="${comment.lastUpdated && comment.lastUpdated.time >= (comment.dateCreated.time + 5000)}">
      <em>${message(code:'is.ui.backlogelement.comment.last.update')} <g:formatDate date="${comment.lastUpdated}" formatName="is.date.format.short.time"/></em>
    </g:if>
  </div>

  <div class='comment-body'>
    <wikitext:renderHtml markup="Textile">${comment.body}</wikitext:renderHtml>
  </div>

</li>
