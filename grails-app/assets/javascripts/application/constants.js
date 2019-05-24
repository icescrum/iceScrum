/*
 * Copyright (c) 2017 Kagilum SAS.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

isApplication
    .constant('SERVER_ERRORS', {
        loginFailed: 'is:auth-login-failed',
        sessionTimeout: 'is:auth-session-timeout',
        notAuthenticated: 'is:auth-not-authenticated',
        notAuthorized: 'is:auth-not-authorized',
        clientError: 'is:client-error',
        serverError: 'is:server-error'
    })
    .constant('BacklogCodes', {
        SANDBOX: 'sandbox',
        BACKLOG: 'backlog',
        DONE: 'done',
        ALL: 'all'
    })
    .constant('StoryStatesByName', {
        SUGGESTED: 1,
        ACCEPTED: 2,
        ESTIMATED: 3,
        PLANNED: 4,
        IN_PROGRESS: 5,
        DONE: 7
    })
    .constant('StoryTypesByName', {
        USER_STORY: 0,
        DEFECT: 2,
        TECHNICAL_STORY: 3
    })
    .constant('TaskStatesByName', {
        TODO: 0,
        IN_PROGRESS: 1,
        DONE: 2
    })
    .constant('TaskTypesByName', {
        RECURRENT: 10,
        URGENT: 11
    })
    .constant('AcceptanceTestStatesByName', {
        TOCHECK: 1,
        FAILED: 5,
        SUCCESS: 10
    })
    .constant('SprintStatesByName', {
        TODO: 1,
        IN_PROGRESS: 2,
        DONE: 3
    })
    .constant('FeatureStatesByName', {
        TODO: 0,
        IN_PROGRESS: 1,
        DONE: 2
    })
    .constant('FeatureTypesByName', {
        FUNCTIONAL: 0,
        ARCHITECTURAL: 1
    })
    .constant('ReleaseStatesByName', {
        TODO: 1,
        IN_PROGRESS: 2,
        DONE: 3
    })
    .constant('IceScrumEventType', {
        CREATE: 'CREATE',
        UPDATE: 'UPDATE',
        DELETE: 'DELETE'
    })
    .constant('TaskConstants', {
        ORDER_BY: [function(task) { return -task.type }, 'parentStory.rank', 'state', 'rank']
    })
    .constant('ActivityCodeByName', {
        SAVE: 'save',
        UPDATE: 'update',
        DELETE: 'delete'
    });