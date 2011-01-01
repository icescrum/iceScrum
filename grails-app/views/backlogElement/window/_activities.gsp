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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<%@ page import="grails.plugin.fluxiable.Activity; grails.plugin.fluxiable.ActivityLink; org.grails.comments.Comment" %>
<is:panel id="panel-activity">
  <is:panelTitle>${message(code: 'is.ui.backlogelement.activity')}</is:panelTitle>
  <is:panelTabButton id="panel-box-1">
    <a rel="#summary" href="../" class="${!params.tab || 'summary' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.summary')}</a>
    <a rel="#tasks" href="../" class="${params.tab && 'tasks' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.task')}</a>
    <a rel="#history" href="../" class="${params.tab && 'history' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.history')}</a>
    <a rel="#comments" href="../"class="${params.tab && 'comments' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.comments')}</a>
  </is:panelTabButton>
  <div id="panel-tab-contents-1" class="panel-tab-contents">
    
  %{--Panel Summary--}%
    <is:panelTab id="summary"  selected="${!params.tab || 'summary' in params.tab ? 'true' : ''}">
      <g:if test="${summary?.size() > 0}">
        <ul class="list-news">
          <g:each in="${summary}" var="entry" status="i">
            <g:if test="${entry instanceof Comment}">
              <g:render template="/components/comment"
                      plugin="icescrum-core-webcomponents"
                      model="[noEscape:true, backlogelement:story.id, comment:entry, commentId:'summary']"/>
            </g:if>
            <g:elseif test="${entry instanceof Activity && entry.code != 'comment'}">
              <li ${(summary?.size() == (i + 1)) ? 'class="last"' : ''}>
                <div class="news-item news-${entry.code}">
                  <p><is:scrumLink controller="user" action='profile' id="${entry.poster.username}">${entry.poster.firstName.encodeAsHTML()} ${entry.poster.lastName.encodeAsHTML()}</is:scrumLink>
                  <g:message code="is.fluxiable.${entry.code}"/>
                  <g:message code="is.${entry.code.startsWith('task') ? 'task' : 'story'}"/>
                    <strong>${entry.cachedLabel.encodeAsHTML()}</strong></p>
                  <p><g:formatDate date="${entry.dateCreated}" formatName="is.date.format.short.time"/></p>
                </div>
              </li>
            </g:elseif>
          </g:each>
        </ul>
      </g:if>
      <g:else>
        <div class="panel-box-empty">
          ${message(code: 'is.ui.backlogelement.activity.all.no')}
        </div>
      </g:else>
    </is:panelTab>

  %{--Tasks panel--}%
    <is:panelTab id="tasks"  selected="${params.tab && 'tasks' in params.tab ? 'true' : ''}">
      <g:if test="${story.tasks}">
        <is:tableView>
          <is:table id="task-table">
            <is:tableHeader name="${message(code:'is.task.name')}"/>
            <is:tableHeader name="${message(code:'is.task.estimation')}"/>
            <is:tableHeader name="${message(code:'is.task.creator')}"/>
            <is:tableHeader name="${message(code:'is.task.responsible')}"/>
            <is:tableHeader name="${message(code:'is.task.state')}"/>

            <is:tableRows in="${story.tasks}" rowClass="${{task -> task.blocked?'ico-task-1':''}}" var="task">
              <is:tableColumn>${task.name.encodeAsHTML()}</is:tableColumn>
              <is:tableColumn>${task.estimation >= 0 ? task.estimation : '?'}</is:tableColumn>
              <is:tableColumn>${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}</is:tableColumn>
              <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
              <is:tableColumn>${message(code: taskStateBundle[task.state])}</is:tableColumn>
            </is:tableRows>
          </is:table>
        </is:tableView>
      </g:if>
      <g:else><div class="panel-box-empty">${message(code: 'is.ui.backlogelement.activity.task.no')}</div></g:else>
    </is:panelTab>
    
    %{--History panel--}%
    <is:panelTab id="history"  selected="${params.tab && 'history' in params.tab ? 'true' : ''}">
      <g:if test="${activities?.size() > 0}">
        <ul class="list-news">
          <g:each in="${activities}" var="a" status="i">
            <li ${(activities?.size() == (i + 1)) ? 'class="last"' : ''}>
              <div class="news-item news-${a.code}">
                <p><is:scrumLink controller="members" action='profile' id="${a.posterId}">${a.poster.firstName.encodeAsHTML()} ${a.poster.lastName.encodeAsHTML()}</is:scrumLink>
                <g:message code="is.fluxiable.${a.code}"/>
                <g:message code="is.${a.code.startsWith('task') ? 'task' : 'story'}"/>
                  <strong>${a.cachedLabel.encodeAsHTML()}</strong></p>
                <p><g:formatDate date="${a.dateCreated}" formatName="is.date.format.short.time"/></p>
              </div>
            </li>
          </g:each>
        </ul>
      </g:if>
      <g:else>
        <div class="panel-box-empty">
          ${message(code: 'is.ui.backlogelement.activity.history.no')}
        </div>
      </g:else>
    </is:panelTab>

    <is:panelTab id="comments" selected="${params.tab && 'comments' in params.tab ? 'true' : ''}">
      <div class="addorlogin">
       <sec:ifNotLoggedIn>
          <g:link
            controller="login"
            onClick="this.href=this.href+'?ref='+decodeURI('${params.product?'p/'+story.backlog.pkey:params.team?'t/'+params.team:''}')+decodeURI(document.location.hash.replace('#','@'));">
            ${message(code:'is.ui.backlogelement.comment.login')}
          </g:link>
        </sec:ifNotLoggedIn>
        <sec:ifLoggedIn>
          <is:link disabled="true" onClick="jQuery.icescrum.openCommentTab('#comments');">${message(code:'is.ui.backlogelement.comment.add')}</is:link>
        </sec:ifLoggedIn>
      </div>
      <isComment:render noEscape="true" bean="${story}" noComment="${message(code:'is.ui.backlogelement.activity.comments.no')}"/>
    </is:panelTab>
  </div>

  <jq:jquery>
    $("#panel-box-1 a").each(function() {
      var item = $(this);
      var rel = $(item.attr('rel'));
      item.click(function(){
        $("#panel-tab-contents-1 .tab-selected").hide();
        $("#panel-tab-contents-1 .tab-selected").removeClass("tab-selected");
        $("#panel-box-1 .selected").removeClass("selected");
        item.addClass("selected");
        rel.addClass("tab-selected");
        rel.show();
        return false;
      });
    });
  </jq:jquery>

</is:panel>