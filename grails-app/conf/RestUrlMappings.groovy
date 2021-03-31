import org.icescrum.core.domain.WorkspaceType

/*
 * Copyright (c) 2012 Kagilum.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

class RestUrlMappings {

    // Be careful, there is always a hidden mapping GET -> index even if not specified

    static mappings = {

        "/ws/openapi.json" {
            controller = 'scrumOS'
            action = [GET: 'openAPI']
        }
        "/ws/version" {
            controller = 'scrumOS'
            action = [GET: 'version']
            oapi = [queryParameters: [[name: 'verbose', description: 'Return detailed information alongside with the version', schema: [type: 'boolean', default: false]]]]
        }
        "/ws/textile" {
            controller = 'scrumOS'
            action = [POST: 'textileParser', PUT: 'textileParser']
            oapi = [description: 'Convert a rich text textile string to HTML']
        }
        // User
        "/ws/user" {
            controller = 'user'
            action = [GET: 'index', POST: 'save']
            oapi = [description: 'Requires an administrator account']
        }
        "/ws/user/$id" {
            controller = 'user'
            action = [GET: 'show', PUT: 'update', POST: 'update']
            constraints {
                id(matches: /\d*/)
            }
        }
        "/ws/user/$id/activities" {
            controller = 'user'
            action = [GET: 'activities']
            constraints {
                id(matches: /\d*/)
            }
        }
        "/ws/user/$id/replaceBy/$substitutedBy" { // Admin -- ReplaceBy instead of substitutedBy for the exposed API as it is more user friendly
            controller = 'user'
            action = [DELETE: 'delete']
            constraints {
                substitutedBy(matches: /\d*/)
            }
            oapi = [
                    description: 'Delete the user - Requires an administrator account',
                    queryParameters: [[name: 'deleteOwnedData', description: 'Whether the projects and teams created by this user should be deleted', schema: [type: 'boolean', default: false]]]
            ]
        }
        "/ws/user/current" {
            controller = 'user'
            action = [GET: 'current']
        }
        // Team (if user is admin all teams ELSE teams where user is owner
        "/ws/team" {
            controller = 'team'
            action = [GET: 'index']
        }
        "/ws/team/$id" {
            controller = 'team'
            action = [GET: 'show', DELETE: 'delete']
            constraints {
                id(matches: /\d*/)
            }
        }
        // Team of a project
        "/ws/team/project/$project" {
            controller = 'team'
            action = [GET: 'showByProject']
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/project" {
            controller = 'project'
            action = [GET: 'index']
            oapi = [description: 'Get the list of project - Requires an administrator account']
        }
        "/ws/project" {
            controller = 'project'
            action = [POST: 'save']
            oapi = [hide: true]
        }
        "/ws/createSample" {
            controller = 'project'
            action = [POST: 'createSample']
        }
        // (token must be admin if $id != currentUser.id // id can be string or int
        "/ws/project/user/$id?" {
            controller = 'project'
            action = [GET: 'listByUser']
        }
        // (token must be admin is $id != currentUser.id
        "/ws/project/user/$id/$role" {
            controller = 'project'
            action = [GET: 'listByUserAndRole']
            constraints {
                id(matches: /\d*/)
                role(inList: ['scrumMaster', 'productOwner', 'stakeHolder', 'teamMember'])
            }
        }
        "/ws/project/$project" {
            controller = 'project'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/project/$project/export/$format?" {
            controller = 'project'
            action = [GET: 'export']
            constraints {
                project(matches: /[0-9A-Z]*/)
                format(inList: ['zip', 'xml'])
            }
        }
        "/ws/project/$project/$action" {
            controller = 'project'
            constraints {
                action(inList: ['flowCumulative', 'velocityCapacity', 'velocity', 'parkingLot', 'burndown', 'burnup'])
            }
        }
        // Resources
        "/ws/project/$project/$controller" {
            action = [GET: 'index', POST: 'save']
            constraints {
                project(matches: /[0-9A-Z]*/)
                controller(inList: ['hook', 'story', 'acceptanceTest', 'feature', 'backlog', 'actor', 'task', 'release', 'sprint', 'timeBoxNotesTemplate'])
            }
        }
        "/ws/project/$project/$controller/$id" {
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                project(matches: /[0-9A-Z]*/)
                controller(inList: ['hook', 'story', 'acceptanceTest', 'feature', 'backlog', 'actor', 'task', 'release', 'sprint', 'timeBoxNotesTemplate'])
                id(matches: /\d*/)
            }
        }
        "/ws/project/$project/$controller/uid/$uid" {
            action = [GET: 'uid']
            constraints {
                project(matches: /[0-9A-Z]*/)
                controller(inList: ['story', 'acceptanceTest', 'feature', 'actor', 'task'])
                uid(matches: /\d*/)
            }
        }
        // Activities
        "/ws/project/$project/activity/$type/$fluxiableId" {
            controller = 'activity'
            action = [GET: 'index']
            constraints {
                project(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task', 'feature'])
                fluxiableId(matches: /\d*/)
            }
        }
        "/ws/project/$project/activities" {
            controller = 'project'
            action = [GET: 'activities']
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        // Comments
        "/ws/$workspaceType/$workspace/comment/$type" {
            controller = 'comment'
            action = [GET: 'index']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task', 'feature'])
            }
        }
        "/ws/$workspaceType/$workspace/comment/$type/$commentable" {
            controller = 'comment'
            action = [GET: 'index']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                type(inList: ['story', 'task', 'feature'])
                commentable(matches: /\d*/)
            }
        }
        "/ws/$workspaceType/$workspace/comment" {
            controller = 'comment'
            action = [POST: 'save']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/$workspaceType/$workspace/comment/$id" {
            controller = 'comment'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        // Meetings
        "/ws/$workspaceType/$workspace/meeting/$subjectType?/$subjectId?" {
            controller = 'meeting'
            action = [GET: 'index']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                subjectType(inList: ['story', 'task', 'feature'])
                subjectId(matches: /\d*/)
            }
        }
        "/ws/$workspaceType/$workspace/meeting" {
            controller = 'meeting'
            action = [POST: 'save']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/$workspaceType/$workspace/meeting/$id" {
            controller = 'meeting'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                workspaceType(inList: [WorkspaceType.PROJECT, WorkspaceType.PORTFOLIO])
                workspace(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        // Story nested actions
        "/ws/project/$project/story/$id/$action" {
            controller = 'story'
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['accept', 'returnToSandbox', 'turnIntoFeature', 'turnIntoTask', 'copy', 'unPlan', 'shiftToNextSprint', 'done', 'unDone'])
            }
            oapi = [method: 'PUT'] // Documentation only, impossible to restrict method when action(inList: ...) (method = 'PUT' is useless)
        }
        "/ws/project/$project/story/$id/plan" {
            controller = 'story'
            action = [PUT: 'plan', POST: 'plan']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
            oapi = [requestBody: [story: [type: 'object', properties: [parentSprint: [type: 'object', properties: [id: [type: 'integer']]]]]]]
        }
        // Story filter by backlog / actor / sprint / feature
        "/ws/project/$project/story/$type/$typeId" {
            controller = 'story'
            action = [GET: 'index']
            constraints {
                project(matches: /[0-9A-Z]*/)
                type(inList: ['backlog', 'actor', 'sprint', 'feature'])
                typeId(matches: /\d*/)
            }
        }
        "/ws/project/$project/story/backlog/$id/print/$format" {
            controller = 'story'
            action = [GET: 'printByBacklog']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        "/ws/project/$project/story/backlog/$id/printPostits" {
            controller = 'story'
            action = [GET: 'printPostitsByBacklog']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        "/ws/project/$project/story/sprint/$id/printPostits" {
            controller = 'story'
            action = [GET: 'printPostitsBySprint']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        "/ws/project/$project/task/sprint/$id/printPostits" {
            controller = 'task'
            action = [GET: 'printPostitsBySprint']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
        }
        // Feature nested actions
        "/ws/project/$project/feature/$action" {
            controller = 'feature'
            constraints {
                project(matches: /[0-9A-Z]*/)
                action(inList: ['print'])
            }
        }
        "/ws/project/$project/feature/$id/$action" {
            controller = 'feature'
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['copy'])
            }
            oapi = [method: 'PUT'] // Documentation only, impossible to restrict method when action(inList: ...) (method = 'PUT' is useless)
        }
        // Release nested actions
        "/ws/project/$project/release/$id/$action" {
            controller = 'release'
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['activate', 'close', 'unPlan', 'reactivate'])
            }
            oapi = [method: 'PUT'] // Documentation only, impossible to restrict method when action(inList: ...) (method = 'PUT' is useless)
        }
        // Plan a release with a plannedVelocity
        "/ws/project/$project/release/$id/autoPlan/$plannedVelocity" {
            controller = 'release'
            action = [POST: 'autoPlan', PUT: 'autoPlan']
            constraints {
                id(matches: /\d*/)
                project(matches: /[0-9A-Z]*/)
                plannedVelocity(matches: /\d*/)
            }
        }
        // Generate release notes
        "/ws/project/$project/release/$id/releaseNotes/$templateId" {
            controller = 'timeBoxNotesTemplate'
            action = [GET: 'releaseNotes']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d+/)
                templateId(matches: /\d+/)
            }
        }
        // Sprint actions
        "/ws/project/$project/sprint/currentOrNextOrLast" {
            controller = 'sprint'
            action = [GET: 'currentOrNextOrLast']
            constraints {
                project(matches: /[0-9A-Z]*/)
            }
        }
        "/ws/project/$project/sprint/$id/$action" {
            controller = 'sprint'
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['activate', 'reactivate', 'close', 'unPlan', 'copyRecurrentTasks'])
            }
            oapi = [method: 'PUT'] // Documentation only, impossible to restrict method when action(inList: ...) (method = 'PUT' is useless)
        }
        // Plan a sprint with a plannedVelocity
        "/ws/project/$project/sprint/$id/autoPlan/$plannedVelocity" {
            controller = 'sprint'
            action = [POST: 'autoPlan', PUT: 'autoPlan']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                plannedVelocity(matches: /\d*/)
            }
        }
        // Generate sprint for a release
        "/ws/project/$project/sprint/generateSprints/$releaseId" {
            controller = 'sprint'
            action = [POST: 'generateSprints']
            constraints {
                project(matches: /[0-9A-Z]*/)
                releaseId(matches: /\d*/)
            }
        }
        // Sprint filter by release
        "/ws/project/$project/sprint/release/$releaseId" {
            controller = 'sprint'
            action = [GET: 'index']
            type = 'release'
            constraints {
                project(matches: /[0-9A-Z]*/)
                releaseId(matches: /\d*/)
            }
        }
        // Generate sprint notes
        "/ws/project/$project/sprint/$id/sprintNotes/$templateId" {
            controller = 'timeBoxNotesTemplate'
            action = [GET: 'sprintNotes']
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d+/)
                templateId(matches: /\d+/)
            }
        }
        // Tasks nested actions
        "/ws/project/$project/task/$id/$action" {
            controller = 'task'
            constraints {
                project(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['makeStory', 'take', 'unassign', 'copy'])
            }
            oapi = [method: 'PUT'] // Documentation only, impossible to restrict method when action(inList: ...) (method = 'PUT' is useless)
        }
        // Task filter by sprint / story
        "/ws/project/$project/task/$type/$id" {
            controller = 'task'
            action = [GET: 'index']
            constraints {
                project(matches: /[0-9A-Z]*/)
                type(inList: ['sprint', 'story'])
                id(matches: /\d*/)
            }
        }
        // Filter acceptanceTests by story
        "/ws/project/$project/acceptanceTest/story/$parentStory" {
            controller = 'acceptanceTest'
            action = [GET: 'index']
            constraints {
                project(matches: /[0-9A-Z]*/)
                parentStory(matches: /\d*/)
            }
        }
        // Portfolio
        "/ws/portfolio" {
            controller = 'portfolio'
            action = [GET: 'index', POST: 'save']
            oapi = [hide: true]
        }
        "/ws/portfolio/$portfolio/$controller/$id?" {
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
                controller(inList: ['hook', 'portfolio'])
                id(matches: /\d*/)
            }
            oapi = [hide: true]
        }
        "/ws/portfolio/$portfolio/feature" {
            controller = 'portfolioFeature'
            action = [GET: 'index', POST: 'save']
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
            }
            oapi = [hide: true]
        }
        "/ws/portfolio/$portfolio/feature/$id" {
            controller = 'portfolioFeature'
            action = [GET: 'show', PUT: 'update', DELETE: 'delete', POST: 'update']
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
            }
            oapi = [hide: true]
        }
        "/ws/portfolio/$portfolio/feature/$id/$action" {
            controller = 'portfolioFeature'
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                action(inList: ['copy'])
            }
            oapi = [hide: true]
        }
        "/ws/portfolio/$portfolio/feature/$id/sendToProject/$targetProjectId" {
            controller = 'portfolioFeature'
            action = [PUT: 'sendToProject']
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
                id(matches: /\d*/)
                targetProjectId(matches: /\d*/)
            }
            oapi = [hide: true]
        }
        // Hook
        "/ws/hook" {
            controller = 'hook'
            action = [GET: 'index', POST: 'save']
        }
        "/ws/hook/$id" {
            controller = 'hook'
            action = [GET: 'show', PUT: 'update', POST: 'update', DELETE: 'delete']
            constraints {
                id(matches: /\d+(,\d+)*/)
            }
        }
    }
}
