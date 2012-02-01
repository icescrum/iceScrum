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
<jq:jquery type="text/javascript">
    jQuery.extend(true, jQuery.icescrum, {
        user:{
            id:${sec.loggedInUserInfo(field: 'id') ?: 'null'},
            productOwner:${request.productOwner},
            scrumMaster:${request.scrumMaster},
            teamMember:${request.teamMember},
            i18n:{
                addRoleProduct:"${message(code:'is.user.role.added.product')}",
                updateRoleProduct:"${message(code:'is.user.role.updated.product')}",
                removeRoleProduct:"${message(code:'is.user.role.removed.product')}"
            }
        },
        story:{
            i18n : {
                stories:"${message(code:'is.ui.backlog.title.details.stories')}",
                points:"${message(code:'is.ui.backlog.title.details.points')}"
            },
            states: ${is.bundleLocaleToJs(bundle: BundleUtils.storyStates)},
            types: ${is.bundleLocaleToJs(bundle: BundleUtils.storyTypes)}
        },
        sprint:{
            ${currentSprint ? 'current:' + (currentSprint as JSON) + ',' : ''}
            i18n:{
                   name:"${g.message(code: 'is.sprint')}",
                   noDropMessage:"${g.message(code:'is.ui.sprintPlan.no.drop')}",
                   noDropMessageLimitedTasks:"${g.message(code:'is.task.error.limitTasksUrgent')}",
                   totalRemainingHours:"${g.message(code:'is.ui.sprintPlan.totalRemainingHours')}",
                   hours:"${g.message(code:'is.ui.sprintPlan.hours')}"
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
            types:${is.bundleLocaleToJs(bundle: BundleUtils.featureTypes)}
        },
        <g:if test="${product}">
        product:{
            currentProduct:${product.id},
            limitUrgentTasks:${product.preferences.limitUrgentTasks},
            hidden:${product.preferences.hidden},
            displayUrgentTasks:${product.preferences.displayUrgentTasks},
            displayRecurrentTasks:${product.preferences.displayRecurrentTasks},
            limitUrgentTasks:${product.preferences.limitUrgentTasks},
            assignOnBeginTask:${product.preferences.assignOnBeginTask},
            timezoneOffset:${TimeZone.getTimeZone(product.preferences.timezone).rawOffset/3600000},
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
            }
        }
    });
</jq:jquery>

<div class='templates'>
    <g:include view="/actor/_js.gsp" model="[id:'actor']" params="[product:params.product]"/>
    <g:include view="/feature/_js.gsp" model="[id:'feature']" params="[product:params.product]"/>
    <g:include view="/story/_js.gsp" params="[product:params.product]"/>
    <g:include view="/task/_js.gsp" model="[id:'sprintPlan']" params="[product:params.product]"/>
    <g:include view="/sprint/_js.gsp" model="[id:'releasePlan']" params="[product:params.product]"/>
    <g:include view="/comment/_js.gsp" params="[product:params.product]"/>
    <g:include view="/acceptanceTest/_js.gsp" params="[product:params.product]"/>
    <g:include view="/user/_js.gsp"/>
</div>