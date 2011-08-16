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
--}%<is:objectAsXML object="${object}" node="product" root="${root}">
    <is:propertyAsXML
            name="['pkey','planningPokerGameType','startDate','endDate']"/>
    <is:propertyAsXML
            name="['name','description']"
            cdata="true"/>
    <is:propertyAsXML
            object="preferences"
            name="['hidden','url','noEstimation','autoDoneStory','displayRecurrentTasks','displayUrgentTasks','assignOnCreateTask','assignOnBeginTask','autoCreateTaskOnEmptyStory','limitUrgentTasks','estimatedSprintsDuration','hideWeekend','sprintPlanningHour','releasePlanningHour','dailyMeetingHour','sprintReviewHour','sprintRetrospectiveHour','timezone']"/>
    <% session.progress?.updateProgress(10, message(code: 'is.export.inprogress', args: [message(code: 'is.team')])) %>
    <is:listAsXML
            name="teams"
            template="/members/xml"
            deep="['team','user']"
            child="team"/>
    <% session.progress?.updateProgress(20, message(code: 'is.export.inprogress', args: [message(code: 'is.release')])) %>
    <is:listAsXML
            name="releases"
            child="release"
            deep="['release','sprint','task','cliche','story']"
            template="/release/xml"/>
    <% session.progress?.updateProgress(30, message(code: 'is.export.inprogress', args: [message(code: 'is.actor')])) %>
    <is:listAsXML
            name="actors"
            child="actor"
            template="/actor/xml"
            deep="['actor']"/>
    <% session.progress?.updateProgress(40, message(code: 'is.export.inprogress', args: [message(code: 'is.feature')])) %>
    <is:listAsXML
            name="features"
            child="feature"
            template="/feature/xml"
            deep="['feature']"/>
    <% session.progress?.updateProgress(50, message(code: 'is.export.inprogress', args: [message(code: 'is.story')])) %>
    <is:listAsXML
            expr="${{it.parentSprint == null}}"
            name="stories"
            template="/story/xml"
            child="story"
            deep="['story','task']"/>
    <% session.progress?.updateProgress(80, message(code: 'is.export.inprogress', args: [message(code: 'is.cliche')])) %>
    <is:listAsXML
            name="cliches"
            template="/project/cliche"
            child="cliche"/>
    <is:listAsXML
            name="productOwners"
            template="/user/xml"
            deep="true"
            child="productOwner"/>
</is:objectAsXML>