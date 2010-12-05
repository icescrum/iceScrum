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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<div class="dashboard">
  <div class="colset-2 clearfix">
    <div class="col1">
      <div class="panel-box">
        <h3 class="panel-box-title">
<g:message code="is.team.description"/></h3>
        <div class="panel-box-content">
          <g:if test="${team.description}">
              <wikitext:renderHtml markup="Textile">${is.truncated(value:team.description,size:1000,encodedHTML:false)}</wikitext:renderHtml>
            </g:if>
            <g:else>
              <g:message code="is.team.empty.description"/>
            </g:else>
        </div>
      </div>
    </div>
    <div class="col2">
      <div class="panel-box">
        <h3 class="panel-box-title"><g:message code="is.ui.project.activity.title"/></h3>
        <g:if test="${storyActivities.size() > 0}">
          <ul class="list-news">
            <g:each in="${storyActivities}" var="a" status="i">
              <li ${(storyActivities.size() == (i + 1)) ? 'class="last"' : ''}>
                <div class="news-item news-${a.code}">
                  <p><is:scrumLink controller="user" action='profile' id="${a.poster.username}">${a.poster.firstName.encodeAsHTML()} ${a.poster.lastName.encodeAsHTML()}</is:scrumLink>
                    <g:message code="is.fluxiable.${a.code}"/> <g:message code="is.story"/>
                    <g:link class="scrum-link" action="idURL"  controller="backlogElement" id="${a.cachedId}">${a.cachedLabel.encodeAsHTML()}</g:link></p>
                  <p><g:formatDate date="${a.dateCreated}" formatName="is.date.format.short.time"/></p>
                </div>
              </li>
            </g:each>
          </ul>
        </g:if>
        <g:else>
          <div class="panel-box-empty">
            <g:message code="is.fluxiable.no"/>
          </div>
        </g:else>
      </div>
    </div>
  </div>
</div>

<jq:jquery>
  $('.list-news .news-item').hover(function(){
    $(this).addClass('news-item-hover');
  }, function(){
    $(this).removeClass('news-item-hover');
  });
  <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'dashboard',params:[team:params.team]]"
        group="${params.team}-team"
        listenOn="#window-content-${id}"/>
</jq:jquery>