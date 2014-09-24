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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.utils.BundleUtils; grails.converters.JSON; org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState; org.icescrum.core.domain.Story.TestState" %>
<jq:jquery>
    jQuery.extend(true, jQuery.icescrum, {
        user:{
            id:${sec.loggedInUserInfo(field: 'id') ?: 'null'},
            productOwner:${request.productOwner},
            scrumMaster:${request.scrumMaster},
            teamMember:${request.teamMember},
            stakeHolder:${request.stakeHolder},
            i18n:{
                addRoleProduct:"${message(code:'is.user.role.added.product')}",
                updateRoleProduct:"${message(code:'is.user.role.updated.product')}",
                removeRoleProduct:"${message(code:'is.user.role.removed.product')}"
            },
            roles:${is.bundleLocaleToJs(bundle: BundleUtils.roles)}
    },
    story:{
        i18n : {
            stories:"${message(code:'is.ui.backlog.title.details.stories')}",
                points:"${message(code:'is.ui.backlog.title.details.points')}",
                dependsOnWarning:"${message(code:'is.ui.story.warning.dependsOn')}"
            },
            states: ${is.bundleLocaleToJs(bundle: BundleUtils.storyStates)},
            types: ${is.bundleLocaleToJs(bundle: BundleUtils.storyTypes)},
            testStates: {
                <g:each var="testStateEnum" status="index" in="${TestState.values()}">
                ${testStateEnum.name()}: ${testStateEnum.id}${index == TestState.values().size() - 1 ? '' : ','}
                </g:each>
            },
            testStateLabels: {
                <g:each var="testStateEnum" status="index" in="${TestState.values()}">
                "${testStateEnum.id}": "${message(code: testStateEnum.toString())}"${index == TestState.values().size() - 1 ? '' : ','}
                </g:each>
            }
        },
        sprint:{
            ${currentSprint ? 'current:' + (currentSprint as JSON) + ',' : ''}
            i18n:{
                   name:"${g.message(code: 'is.sprint')}",
                   noDropMessage:"${g.message(code:'is.ui.sprintPlan.no.drop')}",
                   noDropMessageLimitedTasks:"${g.message(code:'is.task.error.limitTasksUrgent')}",
                   totalRemaining:"${g.message(code:'is.ui.sprintPlan.totalRemaining')}",
                   points:"${g.message(code:'is.ui.sprintPlan.points')}",
                   filtered:"${g.message(code:'is.ui.sprintPlan.filtered')}"
            },
            states:${is.bundleLocaleToJs(bundle: BundleUtils.sprintStates)}
        },
        release:{
            states:${is.bundleLocaleToJs(bundle: BundleUtils.releaseStates)}
        },
        task:{
            BLOCKED:"${g.message(code: 'is.task.blocked')}",
            UNBLOCK:"${g.message(code: 'is.ui.sprintPlan.menu.task.unblock')}",
            BLOCK:"${g.message(code: 'is.ui.sprintPlan.menu.task.block')}"
        },
        actor:{
            instances:${is.bundleLocaleToJs(bundle: BundleUtils.actorInstances)},
            expertnessLevel:${is.bundleLocaleToJs(bundle: BundleUtils.actorLevels)},
            useFrequency:${is.bundleLocaleToJs(bundle: BundleUtils.actorFrequencies)}
        },
        feature:{
            types:${is.bundleLocaleToJs(bundle: BundleUtils.featureTypes)},
            states:${is.bundleLocaleToJs(bundle: BundleUtils.featureStates)}
        },
        <g:if test="${product}">
        product:{
            id:${product.id},
            pkey:"${product.pkey}",
            limitUrgentTasks:${product.preferences.limitUrgentTasks},
            hidden:${product.preferences.hidden},
            displayUrgentTasks:${product.preferences.displayUrgentTasks},
            displayRecurrentTasks:${product.preferences.displayRecurrentTasks},
            limitUrgentTasks:${product.preferences.limitUrgentTasks},
            assignOnBeginTask:${product.preferences.assignOnBeginTask},
            timezoneOffset:${TimeZone.getTimeZone(product.preferences.timezone).rawOffset/3600000},
            estimatedSprintsDuration:${product.preferences.estimatedSprintsDuration},
            i18n: {
                deleted:"${g.message(code: 'is.product.deleted')}",
                updated:"${g.message(code: 'is.product.updated')}",
                archived:"${g.message(code: 'is.product.archived')}",
                unArchived:"${g.message(code: 'is.product.unArchived')}"
            }
        },
        </g:if>
        comment:{
            i18n:{
                noComment:"${message(code:'is.ui.backlogelement.activity.comments.no')}"
            }
        },
        acceptancetest:{
            i18n:{
                noAcceptanceTest:"${message(code:'is.ui.acceptanceTest.empty')}"
            },
            <g:each var="stateEnum" in="${AcceptanceTestState.values()}">
            ${stateEnum.name()}: ${stateEnum.id},
            </g:each>
            stateLabels: {
                <g:each var="stateEnum" status="index" in="${AcceptanceTestState.values()}">
                "${stateEnum.id}": "${message(code: stateEnum.toString())}"${index == AcceptanceTestState.values().size() - 1 ? '' : ','}
                </g:each>
            }
        }
        <entry:point id="jquery-icescrum-js" model="[product:product]"/>
    });

    $.icescrum.init();
</jq:jquery>

<div class='templates'>
    <g:if test="${params.product}">
        <g:render template="/actor/js" model="[id:'actor']"/>
        <g:render template="/feature/js" model="[id:'feature']"/>
        <g:render template="/story/js" model="[product: product]"/>
        <g:render template="/task/js" model="[id:'sprintPlan']"/>
        <g:render template="/sprint/js" model="[id:'releasePlan']"/>
        <g:render template="/comment/js"/>
        <g:render template="/acceptanceTest/js"/>
        <g:render template="/attachment/js"/>
    </g:if>
    <g:render template="/user/js"/>
</div>