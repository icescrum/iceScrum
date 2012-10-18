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
<is:postit
        id="${feature.id}"
        miniId="${feature.uid}"
        title="${feature.name}"
        rect="${rect?:false}"
        color="${feature.color}"
        type="feature"
        menu="[id:'feature-'+feature.id,template:'/feature/menu',params:[feature:feature],rendered:request.productOwner]"
        miniValue="${rect?feature.value:null}"
        attachment="${feature.totalAttachments}"
        sortable='[rendered:request.productOwner]'
        typeNumber="${feature.type}"
        stateText="${is.bundle(bundle:'featureStates',value:feature.state)}"
        typeTitle="${is.bundle(bundle:'featureTypes',value:feature.type)}"
        controller="feature">
        <g:if test="${!rect}">
            <is:truncated size="50" encodedHTML="true">${feature.description?.encodeAsHTML()}</is:truncated>
        </g:if>
        <g:if test="${feature.name?.length() > 17 || feature.description?.length() > 50}">
            <div class="tooltip">
                <span class="tooltip-title">${feature.name}</span>
                ${feature.description?.encodeAsHTML()?:''}
            </div>
        </g:if>
</is:postit>