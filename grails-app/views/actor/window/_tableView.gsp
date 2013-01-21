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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<%@ page import="org.icescrum.core.domain.Story" %>

<is:tableView>
    <is:table id="actor-table"
              style="${actors ? '' : 'display:none'};"
              sortableCols="true"
              editable="[controller:controllerName,action:'update',params:[product:params.product],onExitCell:'submit']">
        <is:tableHeader width="6%" class="table-cell-checkbox" name="">
            <g:checkBox name="checkbox-header"/>
        </is:tableHeader>
        <is:tableHeader width="10%" name="${message(code:'is.actor.name')}"/>
        <is:tableHeader width="20%" name="${message(code:'is.backlogelement.description')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.actor.it.level')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.actor.satisfaction.criteria')}"/>
        <is:tableHeader width="14%" name="${message(code:'is.actor.use.frequency')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.actor.instances')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.actor.nb.stories')}"/>

        <is:tableRows in="${actors}" var="actor" elemid="id" rowid="table-row-actor-">
            <is:tableColumn class="table-cell-checkbox">
                <g:if test="${!request.readOnly}">
                    <g:checkBox name="check-${actor.id}"/>
                </g:if>
                <g:if test="${request.productOwner}">
                    <div class="dropmenu-action">
                        <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-actor-${actor.id}">
                            <span class="dropmenu-arrow">!</span>
                            <div class="dropmenu-content ui-corner-all">
                                <ul class="small">
                                    <g:render template="/actor/menu" model="[actor:actor]"/>
                                </ul>
                            </div>
                        </div>
                    </div>
                </g:if>
                <g:set var="attachment" value="${actor.totalAttachments}"/>
                <g:if test="${attachment}">
                    <span class="table-attachment"
                          title="${message(code: 'is.postit.attachment', args: [attachment, attachment instanceof Integer && attachment > 1 ? 's' : ''])}"></span>
                </g:if>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',disabled:!request.productOwner,name:'name']">${actor.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${actor.description?.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'level',name:'expertnessLevel',values:levelsSelect,disabled:!request.productOwner]"><is:bundle
                    bundle="actorLevels" value="${actor.expertnessLevel}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'satisfactionCriteria']">${actor.satisfactionCriteria?.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'useFrequency',name:'useFrequency',values:frequenciesSelect,disabled:!request.productOwner]"><is:bundle
                    bundle="actorFrequencies" value="${actor.useFrequency}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'instances',name:'instances',values:instancesSelect,disabled:!request.productOwner]"><is:bundle
                    bundle="actorInstances" value="${actor.instances}"/></is:tableColumn>
            <is:tableColumn>${actor.stories.size() ?: 0}</is:tableColumn>
        </is:tableRows>
    </is:table>
</is:tableView>

<g:render template="/actor/window/blank" model="[show:actors ? false : true]"/>

<is:onStream
        on="#actor-table"
        events="[[object:'actor',events:['add','update','remove']]]"
        template="window"/>

<jq:jquery>
    jQuery('#window-title-bar-${controllerName} .content .details').html(' (<span id="actors-size">${actors?.size()}</span>)');
</jq:jquery>

