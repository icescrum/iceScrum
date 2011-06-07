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
<%@ page import="org.icescrum.core.utils.BundleUtils; grails.converters.JSON;" %>
<g:set var="productOwner" value="${sec.access(expression:'productOwner()',{true})}"/>
<g:set var="scrumMaster" value="${sec.access(expression:'scrumMaster()',{true})}"/>
<g:set var="teamMember" value="${sec.access(expression:'teamMember()',{true})}"/>
<jq:jquery type="text/javascript">
    jQuery.extend(true, jQuery.icescrum, {
        user:{
            id:${sec.loggedInUserInfo(field: 'id') ?: 'null'},
            productOwner:${productOwner ? true : false},
            scrumMaster:${scrumMaster ? true : false},
            teamMember:${teamMember ? true : false}
    },
story:{
    states: ${is.bundleLocaleToJs(bundle: BundleUtils.storyStates)},
            types: ${is.bundleLocaleToJs(bundle: BundleUtils.storyTypes)}
    },
    sprint:{
    ${currentSprint ? 'current:' + (currentSprint as JSON) + ',' : ''}
    i18n:{ name:'${g.message(code: 'is.sprint')}' },
            states:${is.bundleLocaleToJs(bundle: BundleUtils.sprintStates)}
    },
release:{
    states:${is.bundleLocaleToJs(bundle: BundleUtils.releaseStates)}
    },
task:{
    BLOCKED:'${g.message(code: 'is.task.blocked')}',
            UNBLOCK:'${g.message(code: 'is.ui.sprintPlan.menu.task.unblock')}',
            BLOCK:'${g.message(code: 'is.ui.sprintPlan.menu.task.block')}'
        },
        actor:{
            instances:${is.bundleLocaleToJs(bundle: BundleUtils.actorInstances)},
            expertnessLevel:${is.bundleLocaleToJs(bundle: BundleUtils.actorLevels)},
            useFrequency:${is.bundleLocaleToJs(bundle: BundleUtils.actorFrequencies)},
        },
        feature:{
            types:${is.bundleLocaleToJs(bundle: BundleUtils.featureTypes)}
    }
    });
</jq:jquery>

<div class='templates'>
    <g:include view="/actor/_js.gsp" model="[id:'actor']" params="[product:params.product]"/>
    <g:include view="/feature/_js.gsp" model="[id:'feature']" params="[product:params.product]"/>
    <g:include view="/story/_js.gsp" params="[product:params.product]"/>
    <g:include view="/task/_js.gsp" model="[id:'sprintPlan']" params="[product:params.product]"/>
    <g:include view="/sprint/_js.gsp" model="[id:'releasePlan']" params="[product:params.product]"/>
</div>