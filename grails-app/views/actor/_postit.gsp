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
<is:postit id="${actor.id}"
           miniId="${actor.id}"
           title="${actor.name}"
           type="actor"
           attachment="${actor.totalAttachments}"
           controller="actor">
    <is:truncated size="50" encodedHTML="true">${actor.description?.encodeAsHTML()}</is:truncated>

%{--Embedded menu--}%
    <is:postitMenu id="actor-${actor.id}" contentView="/actor/menu" model="[id:id, actor:actor]" rendered="${request.productOwner}"/>

    <g:if test="${actor.name?.length() > 17 || actor.description?.length() > 50}">
        <is:tooltipPostit
                type="actor"
                id="${actor.id}"
                title="${actor.name.encodeAsHTML()}"
                text="${actor.description?.encodeAsHTML()}"
                apiBeforeShow="if(jQuery('#dropmenu').is(':visible')){return false;}"
                container="jQuery('#window-content-${id}')"/>
    </g:if>

</is:postit>