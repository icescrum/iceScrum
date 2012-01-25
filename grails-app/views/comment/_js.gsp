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
<%@ page import="org.grails.comments.Comment" %>

<g:set var="comment" value="[id:'?**=this.id**?',
                             poster:[username:'?**=this.poster.username**?',firstName:'?**=this.poster.firstName**?',lastName:'?**=this.poster.lastName**?',id:'?**=this.poster.id**?'],
                             dateCreated:'?**=jQuery.icescrum.serverDate(this.dateCreated, true)**?',
                             lastUpdated:'?**=jQuery.icescrum.serverDate(this.lastUpdated, true)**?',
                             body:'?**=this.body**?']"/>

<g:set var="backlogelement" value="[id:'?**=this.backlogElement**?']"/>

<template id="comment-storydetail-tmpl">
      <g:render template="/components/comment"
          plugin="icescrum-core"
          model="[comment:comment, backlogelement:backlogelement, moderation:true, access:true, template:true]"/>
</template>

<template id="comment-storydetailsummary-tmpl">
      <g:render template="/components/comment"
          plugin="icescrum-core"
          model="[comment:comment, backlogelement:backlogelement, moderation:true, access:false, template:true, commentId:'summary']"/>
</template>