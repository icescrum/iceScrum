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
<%@ page import="org.icescrum.core.domain.Story" %>
<is:tableView>
    <is:table id="feature-table"
              style="${features ? '' : 'display:none'};"
              sortableCols="true"
              editable="[controller:id,action:'update',params:[product:params.product],onExitCell:'submit']">

        <is:tableHeader width="5%" class="table-cell-checkbox" name="">
            <g:checkBox name="checkbox-header"/>
        </is:tableHeader>
        <is:tableHeader width="5%"  name=""/>
        <is:tableHeader width="6%"  name="${message(code:'is.feature.rank')}"/>
        <is:tableHeader width="8%"  name="${message(code:'is.feature.value')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.feature.type')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.feature')}"/>
        <is:tableHeader width="24%" name="${message(code:'is.backlogelement.description')}"/>
        <is:tableHeader width="6%"  name="${message(code:'is.feature.effort')}"/>
        <is:tableHeader width="12%" name="${message(code:'is.feature.stories')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.feature.stories.finish')}"/>

        <is:tableRows in="${features}" var="feature" elemid="id">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${feature.id}"/>
                <is:menu class="dropmenu-action" yoffset="4" id="${feature.id}" contentView="/feature/menu"
                         params="[id:id, feature:feature]" rendered="${request.productOwner}"/>
                <g:set var="attachment" value="${feature.totalAttachments}"/>
                <g:if test="${attachment}">
                    <span class="table-attachment" title="${message(code: 'is.postit.attachment', args: [attachment, attachment > 1 ? 's' : ''])}"></span>
                </g:if>
            </is:tableColumn>
            <is:tableColumn class="table-cell-postit-icon">
                <is:postitIcon name="${feature.name.encodeAsHTML()}" color="${feature.color}"/>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'rank',name:'rank',values:rankSelect,disabled:!request.productOwner]">${feature.rank}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',disabled:!request.productOwner,name:'value',values:suiteSelect]">${feature.value}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type',values:typeSelect]"><is:bundle
                    bundle="featureTypes" value="${feature.type}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',disabled:!request.productOwner,name:'name']">${feature.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${feature.description?.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn>${effortFeature(feature)}</is:tableColumn>
            <is:tableColumn>${feature.stories?.size() ?: 0}</is:tableColumn>
            <is:tableColumn>${linkedDoneStories(feature)}</is:tableColumn>
        </is:tableRows>
    </is:table>
</is:tableView>

<g:include view="/feature/window/_blank.gsp" model="[features:features,id:id]"/>

<is:onStream
        on="#feature-table"
        events="[[object:'feature',events:['add','update','remove']]]"
        template="window"/>