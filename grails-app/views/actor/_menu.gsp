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
- Vincent Barrier (vbarrier@kagilum.com)
--}%

<li class="first">
    <a href="#${controllerName}/edit/${actor.id}">
       <g:message code='is.ui.actor.menu.update'/>
    </a>
</li>
<li>
    <a href="${createLink(action:'delete',controller:'actor',params:[product:params.product],id:actor.id)}"
       data-ajax-trigger="remove_actor"
       data-ajax-notice="${message(code: 'is.actor.deleted')}"
       data-ajax="true">
       <g:message code='is.ui.actor.menu.delete'/>
    </a>
</li>
<entry:point id="${controllerName}-${actionName}-actorMenu" model="[actor:actor]"/>