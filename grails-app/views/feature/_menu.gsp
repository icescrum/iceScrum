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
- Vincent Barrier (vbarrier@kagilum.com)
--}%
<li class="first">
    <a href="#feature/edit/${feature.id}">
       <g:message code='is.ui.feature.menu.update'/>
    </a>
</li>
<li>
    <a href="${createLink(action:'copyFeatureToBacklog',controller:'feature',id:feature.id,params:[product:params.product])}"
       data-ajax-trigger="accept_story"
       data-ajax-notice="${message(code: 'is.feature.copy')}"
       data-ajax="true">
       <g:message code='is.ui.feature.menu.copy'/>
    </a>
</li>

<li>
    <a href="${createLink(action:'delete',controller:'feature',id:feature.id, params:[product:params.product])}"
       data-ajax-trigger="remove_feature"
       data-ajax-notice="${message(code: 'is.feature.deleted')}"
       data-ajax="true">
       <g:message code='is.ui.feature.menu.delete'/>
    </a>
</li>
<entry:point id="feature-postitMenu" model="[feature:feature,controllerName:controllerName]"/>