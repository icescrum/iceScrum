/*
 * Copyright (c) 2020 Kagilum.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Meeting
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.security.WorkspaceSecurity
import org.icescrum.core.utils.DateUtils

@Secured('permitAll()')
class MeetingController implements ControllerErrorHandler, WorkspaceSecurity {

    def springSecurityService
    def meetingService

    def index(long workspace, String workspaceType, Long contextId, String contextType) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def meetings = []
        Class<?> WorkspaceClass = grailsApplication.getDomainClass('org.icescrum.core.domain.' + workspaceType.capitalize()).clazz
        if (contextId && contextType) {
            meetings = Meeting."findAllBy${workspaceType.capitalize()}AndContextIdAndContextTypeIlikeAndEndDateIsNull"(WorkspaceClass.load(workspace), contextId, contextType)
        } else {
            meetings = Meeting."findAllBy${workspaceType.capitalize()}AndEndDateIsNull"(WorkspaceClass.load(workspace))
        }
        render(status: 200, contentType: 'application/json', text: meetings as JSON)
    }

    def show(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def meeting = Meeting.withMeetings(params, 'id', workspaceType).first()
        render(status: 200, contentType: 'application/json', text: meeting as JSON)
    }

    def save(long workspace, String workspaceType) {
        if (!checkPermission(
                project: '((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def meetingParams = params.meeting
        if (!meetingParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        if (meetingParams.startDate) {
            meetingParams.startDate = DateUtils.parseDateISO8601(meetingParams.startDate)
        }
        if (meetingParams.endDate) {
            meetingParams.endDate = DateUtils.parseDateISO8601(meetingParams.endDate)
        }
        Meeting meeting = new Meeting()
        Meeting.withTransaction {
            bindData(meeting, meetingParams, [include: ['subject', 'videoLink', 'phone', 'pinCode', 'contextId', 'contextType', 'startDate', 'endDate', 'provider', 'providerEventId']])
            User user = (User) springSecurityService.currentUser
            Class<?> WorkspaceClass = grailsApplication.getDomainClass('org.icescrum.core.domain.' + workspaceType.capitalize()).clazz
            meetingService.save(meeting, WorkspaceClass.load(workspace), user)
            render(status: 201, contentType: 'application/json', text: meeting as JSON)
        }
    }

    def update(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'isAuthenticated() and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        // TODO CHECK OWNER OR PO OR SM
        Meeting meeting = Meeting.withMeetings(params, 'id', workspaceType).first()
        def meetingParams = params.meeting
        if (meetingParams.endDate) {
            meetingParams.endDate = DateUtils.parseDateISO8601(meetingParams.endDate)
        }
        Meeting.withTransaction {
            bindData(meeting, meetingParams, [include: ['subject', 'endDate']])
            meetingService.update(meeting)
            render(status: 200, contentType: 'application/json', text: meeting as JSON)
        }
    }
}