<%@ page import="org.icescrum.core.domain.BacklogElement" %>
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
<is:panelTab id="comments" selected="${params.tab && 'comments' in params.tab ? 'true' : ''}">
    <div class="addorlogin">
        <sec:ifNotLoggedIn>
            <a href="${grailsApplication.config.grails.serverURL}/login?ref=p/${product.pkey}#${controllerName}/${commentable.id}?tab=comments">
                ${message(code: 'is.ui.backlogelement.comment.login')}
            </a>
        </sec:ifNotLoggedIn>
        <sec:ifLoggedIn>
            <is:link disabled="true"
                     onClick="jQuery.icescrum.openCommentTab('#comments');">${message(code: 'is.ui.backlogelement.comment.add')}</is:link>
        </sec:ifLoggedIn>
    </div>
    <is:cache cache="${controllerName}Cache" key="${controllerName}-comments-${commentable.id}-${commentable.class.findLastUpdatedComment(commentable)}">
        <isComment:render noEscape="true" product="${product}" bean="${commentable}" noComment="${message(code:'is.ui.backlogelement.activity.comments.no')}"/>
    </is:cache>
 </is:panelTab>