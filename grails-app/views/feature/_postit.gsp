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
<g:set var="productOwner" value="${sec.access(expression:'productOwner()',{true})}"/>
<is:postit
        id="${feature.id}"
        miniId="${feature.id}"
        title="${feature.name}"
        color="${feature.color}"
        type="feature"
        attachment="${feature.totalAttachments}"
        sortable='[rendered:productOwner]'
        typeNumber="${feature.type}"
        typeTitle="${is.bundle(bundle:'featureTypes',value:feature.type)}"
        cacheKey="${feature.lastUpdated}"
        controller="feature">
    <is:truncated size="50" encodedHTML="true">${feature.description?.encodeAsHTML()}</is:truncated>

%{--Embedded menu--}%
    <is:postitMenu id="${feature.id}" contentView="/feature/menu" model="[id:id, feature:feature]"
                   rendered="${productOwner}"/>

    <g:if test="${feature.name?.length() > 17 || feature.description?.length() > 50}">
        <is:tooltipPostit
                type="feature"
                id="${feature.id}"
                title="${feature.name.encodeAsHTML()}"
                text="${feature.description?.encodeAsHTML()}"
                apiBeforeShow="if(jQuery('#dropmenu').is(':visible')){return false;}"
                container="jQuery('#window-content-${id}')"/>
    </g:if>
</is:postit>