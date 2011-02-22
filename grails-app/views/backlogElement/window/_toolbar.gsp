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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<%@ page import="org.icescrum.core.domain.Story;" %>
<g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>

<is:iconButton
        action="edit"
        controller="${story.state > Story.STATE_SUGGESTED ? 'productBacklog' : 'sandbox'}"
        id="${params.id}"
        rendered="${productOwner  || story.creator.id == user?.id}"
        history="false"
        params="['referrer.controller':id, 'referrer.action':'details', 'referrer.id':params.id, product:params.product]"
        title="${message(code:'is.ui.backlogelement.toolbar.update')}"
        alt="${message(code:'is.ui.backlogelement.toolbar.update')}"
        update="window-content-${id}">
        ${message(code:'is.ui.backlogelement.toolbar.update')}
</is:iconButton>

<is:separatorSmall rendered="${productOwner  || story.creator.id == user?.id}" />

%{--View--}%
<is:panelButton
        id="accept-display"
        arrow="true"
        text="${message(code:'is.ui.backlogelement.toolbar.accept')}"
        rendered="${productOwner && story.state == Story.STATE_SUGGESTED}">
  <ul>
    <li class="first">
      <is:link
              controller="backlogElement"
              action="accept"
              id="${params.id}"
              params="['acceptAs':0]"
              history="false"
              update="window-content-${id}"
              remote="true"
              onSuccess="\$.icescrum.renderNotice('${message(code:'is.story.acceptedAsStory').encodeAsJavaScript()}');
              \$('#window-toolbar').icescrum('toolbar').reload('${id}', {'id':'${params.id}'});"
              value="${message(code:'is.ui.backlogelement.toolbar.acceptAsStory')}"/>
    </li>

    <g:if test="${!sprint}">
      <li class="last">
    </g:if>
    <g:else>
      <li>
    </g:else>
      <is:link
              controller="backlogElement"
              action="accept"
              id="${params.id}"
              params="['acceptAs':1]"
              history="false"
              remote="true"
              onSuccess="\$.icescrum.openWindow('sandbox');
              \$.icescrum.renderNotice('${message(code:'is.story.acceptedAsFeature').encodeAsJavaScript()}');"
              value="${message(code:'is.ui.backlogelement.toolbar.acceptAsFeature')}"/>
    </li>

    <g:if test="${sprint}">
      <li class="last">
        <is:link
                controller="backlogElement"
                action="accept"
                id="${params.id}"
                params="['acceptAs':2]"
                history="false"
                remote="true"
                onSuccess="\$.icescrum.openWindow('sandbox');
                 \$.icescrum.renderNotice('${message(code:'is.story.acceptedAsUrgentTask').encodeAsJavaScript()}');"
                value="${message(code:'is.ui.backlogelement.toolbar.acceptAsUrgentTask')}"/>
      </li>
    </g:if>

  </ul>
</is:panelButton>

<is:separatorSmall rendered="${productOwner && story.state == Story.STATE_SUGGESTED}" />

<is:iconButton
        action="delete"
        controller="${story.state > Story.STATE_SUGGESTED ? 'productBacklog' : 'sandbox'}"
        id="${params.id}"
        rendered="${productOwner}"
        title="${message(code:'is.ui.backlogelement.toolbar.delete')}"
        alt="${message(code:'is.ui.backlogelement.toolbar.delete')}"
        confirmBeforeSubmit="${message(code:'is.ui.backlogelement.toolbar.delete.confirmation')}"
        onSuccess="\$.icescrum.openWindow('${story.state > Story.STATE_SUGGESTED ? 'productBacklog' : 'sandbox'}');
          \$.icescrum.renderNotice('${message(code:'is.story.deleted').encodeAsJavaScript()}');"
        icon="delete">
  ${message(code:'is.ui.backlogelement.toolbar.delete')}
</is:iconButton>

<is:separator rendered="${productOwner}" />

<is:iconButton
        onclick="jQuery.icescrum.openCommentTab('#comments');"
        title="${message(code:'is.ui.backlogelement.toolbar.comment')}"
        alt="${message(code:'is.ui.backlogelement.toolbar.comment')}"
        renderedOnAccess="isAuthenticated()"
        disabled="true">
  ${message(code:'is.ui.backlogelement.toolbar.comment')}
</is:iconButton>

<entry:point id="${id}-${actionName}-toolbar"/>

<div class="navigation-right-toolbar">

  <g:if test="${previous}">
    <is:iconButton
            href="#${id}/${previous.id}"
            title="${message(code:'is.ui.backlogelement.toolbar.previous')}"
            alt="${message(code:'is.ui.backlogelement.toolbar.previous')}">
      ${message(code:'is.ui.backlogelement.toolbar.previous')}
    </is:iconButton>
  </g:if>

  <is:separatorSmall rendered="${previous != null && next != null}"/>

  <g:if test="${next}">
    <is:iconButton
            href="#${id}/${next.id}"
            title="${message(code:'is.ui.backlogelement.toolbar.next')}"
            alt="${message(code:'is.ui.backlogelement.toolbar.next')}">
      ${message(code:'is.ui.backlogelement.toolbar.next')}
    </is:iconButton>
  </g:if>

</div>