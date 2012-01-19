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
<%@ page import="org.icescrum.core.domain.Story" %>
<is:panelTab id="comments" selected="${params.tab && 'comments' in params.tab ? 'true' : ''}">
    <div class="addorlogin">
        <sec:ifNotLoggedIn>
            <g:link
                    controller="login"
                    onClick="this.href=this.href+'?ref='+decodeURI('${params.product?'p/'+story.backlog.pkey:params.team?'t/'+params.team:''}')+decodeURI(document.location.hash.replace('#','@'));">
                ${message(code: 'is.ui.backlogelement.comment.login')}
            </g:link>
        </sec:ifNotLoggedIn>
        <sec:ifLoggedIn>
            <is:link disabled="true"
                     onClick="jQuery.icescrum.openCommentTab('#comments');">${message(code: 'is.ui.backlogelement.comment.add')}</is:link>
        </sec:ifLoggedIn>
    </div>
    <is:cache cache="storyCache" key="story-comments-${story.id}-${Story.findLastUpdatedComment(story.id)}">
        <isComment:render noEscape="true" bean="${story}" noComment="${message(code:'is.ui.backlogelement.activity.comments.no')}"/>
    </is:cache>
 </is:panelTab>