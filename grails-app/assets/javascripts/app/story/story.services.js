/*
 * Copyright (c) 2014 Kagilum SAS.
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
services.factory('Story', ['Resource', function($resource) {
    return $resource('story/:type/:typeId/:id/:action');
}]);

services.service("StoryService", ['$timeout', '$q', '$http', '$rootScope', '$state', 'Story', 'Session', 'FormService', 'ReleaseService', 'SprintService', 'StoryStatesByName', 'SprintStatesByName', 'IceScrumEventType', 'PushService', function($timeout, $q, $http, $rootScope, $state, Story, Session, FormService, ReleaseService, SprintService, StoryStatesByName, SprintStatesByName, IceScrumEventType, PushService) {
    this.list = [];
    var self = this;
    var crudMethods = {};
    var refreshReleasesAndSprints = function(oldStory, newStory) {
        var oldSprint = (oldStory && oldStory.parentSprint) ? oldStory.parentSprint.id : null;
        var newSprint = (newStory && newStory.parentSprint) ? newStory.parentSprint.id : null;
        if (Session.getProject().releases && (oldSprint || newSprint)) { // No need to do anything if releases are not loaded or no parent sprint
            if (oldSprint != newSprint || oldStory.effort != newStory.effort || oldStory.state != newStory.state) {
                ReleaseService.list(Session.getProject()).then(function(releases) { // Refreshes all the releases & sprints, which is probably overkill
                    $q.all(_.map(releases, SprintService.list));
                });
            }
        }
    };
    var queryWithContext = function(parameters, success, error) {
        if (!parameters) {
            parameters = {};
        }
        if ($rootScope.app.context) {
            _.merge(parameters,  {'context.type': $rootScope.app.context.type, 'context.id': $rootScope.app.context.id});
        }
        var args = [parameters];
        if (success) {
            args.push(success);
        }
        if (error) {
            args.push(error);
        }
        return Story.query.apply(this, args);
    };
    crudMethods[IceScrumEventType.CREATE] = function(story) {
        var existingStory = _.find(self.list, {id: story.id});
        if (existingStory) {
            angular.extend(existingStory, story);
        } else {
            self.list.push(story);
        }
    };
    crudMethods[IceScrumEventType.UPDATE] = function(story) {
        var existingStory = _.find(self.list, {id: story.id});
        refreshReleasesAndSprints(existingStory, story); // Must be done before local update to have proper before/after values and know if refresh must occur
        angular.extend(existingStory, story);
    };
    crudMethods[IceScrumEventType.DELETE] = function(story) {
        if ($state.includes("backlog.details", {id: story.id}) ||
            ($state.includes("backlog.multiple") && _.contains($state.params.listId.split(','), story.id.toString()))) {
            $state.go('backlog');
        }
        _.remove(self.list, {id: story.id});
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('story', eventType, crudMethod);
    });
    this.mergeStories = function(stories) {
        _.each(stories, function(story) {
            crudMethods[IceScrumEventType.CREATE](story);
        });
    };
    this.save = function(story) {
        story.class = 'story';
        return Story.save(story, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.listByType = function(obj) {
        obj.stories = [];
        _.each(obj.stories_ids, function(story) {
            var foundStory = _.find(self.list, {id: story.id});
            if (foundStory) {
                obj.stories.push(foundStory);
            }
        });
        var promise = queryWithContext({typeId: obj.id, type: obj.class.toLowerCase()}, function(stories) {
            obj.stories = stories;
            self.mergeStories(stories);
            return stories;
        }).$promise;
        return obj.stories.length === (obj.stories_ids ? obj.stories_ids.length : null) ? $q.when(obj.stories) : promise;
    };
    this.get = function(id) {
        var story = _.find(self.list, {id: id});
        return story ? $q.when(story) : Story.get({id: id}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.refresh = function(id) {
        return Story.get({id: id}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(story) {
        return Story.update(story, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(story) {
        return story.$delete(crudMethods[IceScrumEventType.DELETE]);
    };
    this.acceptToBacklog = function(story, rank) {
        var params = {story: {}};
        if (rank) {
            params.story.rank = rank;
        }
        return Story.update({id: story.id, action: 'acceptToBacklog'}, params, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.returnToSandbox = function(story, rank) {
        var params = {story: {}};
        if (rank) {
            params.story.rank = rank;
        }
        return Story.update({id: story.id, action: 'returnToSandbox'}, params, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.plan = function(story, sprint, rank) {
        var params = {story: {parentSprint: {id: sprint.id}}};
        if (rank) {
            params.story.rank = rank;
        }
        return Story.update({id: story.id, action: 'plan'}, params, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.unPlan = function(story) {
        return Story.update({id: story.id, action: 'unPlan'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.shiftToNext = function(story) {
        return Story.update({id: story.id, action: 'shiftToNextSprint'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.done = function(story) {
        return Story.update({id: story.id, action: 'done'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.unDone = function(story) {
        return Story.update({id: story.id, action: 'unDone'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.like = function(story) {
        return Story.update({id: story.id, action: 'like'}, {}, function(resultStory) {
            story.liked = resultStory.liked;
            story.likers_count = resultStory.likers_count;
            crudMethods[IceScrumEventType.UPDATE](story);
        }).$promise;
    };
    this.follow = function(story) {
        return Story.update({id: story.id, action: 'follow'}, {}, function(resultStory) {
            story.followed = resultStory.followed;
            story.followers_count = resultStory.followers_count;
            crudMethods[IceScrumEventType.UPDATE](story);
        }).$promise;
    };
    this.acceptAs = function(story, target) {
        return Story.update({id: story.id, action: 'acceptAs' + target}, {}, function() {
            crudMethods[IceScrumEventType.DELETE](story);
        }).$promise;
    };
    this.copy = function(story) {
        return Story.update({id: story.id, action: 'copy'}, {}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.getMultiple = function(ids) {
        if (ids.length == 1) {
            return self.get(ids[0]).then(function(story) {
                return [story];
            });
        } else {
            var foundStories = [];
            var notFoundStoryIds = [];
            _.each(ids, function(id) {
                var foundStory = _.find(self.list, {id: parseInt(id)});
                if (foundStory) {
                    foundStories.push(foundStory);
                } else {
                    notFoundStoryIds.push(id);
                }
            });
            return notFoundStoryIds.length > 0 ? Story.query({id: notFoundStoryIds}, self.mergeStories).$promise : $q.when(foundStories);
        }
    };
    this.updateMultiple = function(ids, updatedFields) {
        return Story.updateArray({id: ids}, {story: updatedFields}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.deleteMultiple = function(ids) {
        return Story.deleteArray({id: ids}, function() {
            _.each(ids, function(stringId) {
                crudMethods[IceScrumEventType.DELETE]({id: parseInt(stringId)});
            });
        }).$promise;
    };
    this.copyMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'copy'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.CREATE]);
        }).$promise;
    };
    this.acceptToBacklogMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'acceptToBacklog'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.acceptAsMultiple = function(ids, target) {
        return Story.updateArray({id: ids, action: 'acceptAs' + target}, {}, function() {
            _.each(ids, function(stringId) {
                crudMethods[IceScrumEventType.DELETE]({id: parseInt(stringId)});
            });
        }).$promise;
    };
    this.followMultiple = function(ids, follow) {
        return Story.updateArray({id: ids, action: 'follow'}, {follow: follow}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.listByBacklog = function(backlog) {
        return queryWithContext({type: 'backlog', typeId: backlog.id}, function(stories) {
            self.mergeStories(stories);
            return stories;
        }).$promise;
    };
    this.activities = function(story, all) {
        var params = {action: 'activities', id: story.id};
        if (all) {
            params.all = true;
        }
        return Story.query(params, function(activities) {
            story.activities = activities;
        }).$promise;
    };
    this.authorizedStory = function(action, story) {
        switch (action) {
            case 'copy':
            case 'create':
            case 'follow':
                return Session.authenticated();
            case 'createTemplate':
                return Session.inProduct();
            case 'upload':
            case 'update':
                return (Session.po() && story.state >= StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE) ||
                    (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            case 'updateEstimate':
                return Session.tmOrSm() && story.state > StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE;
            case 'updateParentSprint':
                return Session.poOrSm() && story.state > StoryStatesByName.ACCEPTED && story.state < StoryStatesByName.DONE;
            case 'accept':
                return Session.po() && story.state == StoryStatesByName.SUGGESTED;
            case 'updateTemplate':
            case 'rank':
                return Session.po() && (!story || story.state < StoryStatesByName.DONE);
            case 'delete':
                return (Session.po() && story.state < StoryStatesByName.PLANNED) ||
                    (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            case 'returnToSandbox':
                return Session.po() && _.contains([StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED], story.state);
            case 'unPlan':
                return Session.poOrSm() && story.state >= StoryStatesByName.PLANNED && story.state < StoryStatesByName.DONE;
            case 'shiftToNext':
                return Session.poOrSm() && story.state >= StoryStatesByName.PLANNED && story.state <= StoryStatesByName.IN_PROGRESS;
            case 'done':
                return Session.po() && story.state == StoryStatesByName.IN_PROGRESS;
            case 'unDone':
                return Session.po() && story.state == StoryStatesByName.DONE && story.parentSprint.state == SprintStatesByName.IN_PROGRESS;
            default:
                return false;
        }
    };
    this.authorizedStories = function(action, stories) {
        var self = this;
        switch (action) {
            case 'copy':
                return Session.po();
            default:
                return _.every(stories, function(story) {
                    return self.authorizedStory(action, story);
                });
        }
    };
    // Templates
    var cachedTemplateEntries;
    this.getTemplateEntries = function() {
        var deferred = $q.defer();
        if (angular.isArray(cachedTemplateEntries)) {
            deferred.resolve(cachedTemplateEntries);
        } else {
            FormService.httpGet('story/templateEntries').then(function(templateEntries) {
                cachedTemplateEntries = templateEntries;
                deferred.resolve(templateEntries);
            });
        }
        return deferred.promise;
    };
    this.saveTemplate = function(story, name) {
        return Story.update({id: story.id, action: 'saveTemplate', 'template.name': name}, {}).$promise.then(function(templateEntry) {
            if (angular.isArray(cachedTemplateEntries)) {
                cachedTemplateEntries.push(templateEntry);
            }
        });
    };
    this.deleteTemplate = function(templateId) {
        return $http.post('story/deleteTemplate?template.id=' + templateId).success(function() {
            _.remove(cachedTemplateEntries, {id: templateId});
        });
    };
    this.listByField = function(field) {
        return Story.get({action: 'listByField', field: field}).$promise
    };
    this.getDependenceEntries = function(story) {
        return FormService.httpGet('story/' + story.id + '/dependenceEntries');
    };
    this.getParentSprintEntries = function() {
        return FormService.httpGet('story/sprintEntries');
    };
    this.getTemplatePreview = function(templateId) {
        return FormService.httpGet('story/templatePreview', {params: {template: templateId}});
    };
    this.findDuplicates = function(term) {
        return FormService.httpGet('story/findDuplicates', {params: {term: term}});
    }
}]);
