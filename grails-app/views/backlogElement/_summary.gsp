%{--
- Copyright (c) 2011 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<%@ page import="grails.plugin.fluxiable.Activity; org.grails.comments.Comment" %>

<is:panelTab id="summary" selected="${!params.tab || 'summary' in params.tab ? 'true' : ''}">
    <g:if test="${summary?.size() > 0}">
        <ul class="list-news">
            <g:each in="${summary}" var="entry" status="i">
                <g:if test="${entry instanceof Comment}">
                    <g:render template="/components/comment"
                              plugin="icescrum-core"
                              model="[last:summary.size() == (i + 1), noEscape:true, commentable:backlogElement, comment:entry, product:product, commentId:'summary']"/>
                </g:if>
                <g:elseif test="${entry instanceof Activity && entry.code != 'comment'}">
                    <li ${(summary.size() == (i + 1)) ? 'class="last"' : ''}>
                        <div class="news-item news-${entry.code}">
                            <p><is:scrumLink controller="user" action='profile'
                                             id="${entry.poster.username}">${entry.poster.firstName.encodeAsHTML()} ${entry.poster.lastName.encodeAsHTML()}</is:scrumLink>
                            <g:message code="is.fluxiable.${entry.code}"/>
                            %{-- Doesn't match against "acceptanceTest" alone because it's a legacy story activity --}%
                            <g:message code="is.${entry.code.startsWith('task') ? 'task' : entry.code =~ /acceptanceTest.+/ ? 'acceptanceTest' : 'story'}"/>
                                <strong>${entry.cachedLabel.encodeAsHTML()}</strong></p>

                            <p><g:formatDate date="${entry.dateCreated}" formatName="is.date.format.short.time"
                                             timeZone="${product.preferences.timezone}"/></p>
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