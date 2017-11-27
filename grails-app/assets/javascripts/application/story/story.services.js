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

services.service("StoryService", ['$timeout', '$q', '$http', '$rootScope', '$state', 'Story', 'Session', 'CacheService', 'FormService', 'ReleaseService', 'SprintService', 'StoryStatesByName', 'SprintStatesByName', 'IceScrumEventType', 'PushService', function($timeout, $q, $http, $rootScope, $state, Story, Session, CacheService, FormService, ReleaseService, SprintService, StoryStatesByName, SprintStatesByName, IceScrumEventType, PushService) {
    var self = this;
    Session.getProject().stories = CacheService.getCache('story');
    var queryWithContext = function(parameters, success, error) {
        if (!parameters) {
            parameters = {};
        }
        if ($rootScope.application.context) {
            _.merge(parameters, {'context.type': $rootScope.application.context.type, 'context.id': $rootScope.application.context.id});
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
    var crudMethods = {};
    this.crudMethods = crudMethods;
    crudMethods[IceScrumEventType.CREATE] = function(story) {
        CacheService.addOrUpdate('story', story);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(story) {
        CacheService.addOrUpdate('story', story);
    };
    crudMethods[IceScrumEventType.DELETE] = function(story) {
        if ($state.includes("backlog.backlog.story.details", {storyId: story.id}) || $state.includes("backlog.multiple.story.details", {storyId: story.id}) ||
            ($state.includes("backlog.backlog.story.multiple") || $state.includes("backlog.mutiple.story.multiple")) && _.includes($state.params.storyListId.split(','), story.id.toString())) {
            $state.go('backlog.backlog', {}, {location: 'replace'});
        }
        CacheService.remove('story', story.id);
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
        if (!_.isArray(obj.stories)) {
            obj.stories = [];
        }
        var promise = queryWithContext({typeId: obj.id, type: obj.class.toLowerCase()}, function(stories) {
            self.mergeStories(stories);
            _.each(stories, function(story) {
                if (!_.find(obj.stories, {id: story.id})) {
                    obj.stories.push(CacheService.get('story', story.id));
                }
            });
        }).$promise;
        return obj.stories.length == 0 ? promise : $q.when(obj.stories);
    };
    this.filter = function(filter) {
        var existingStories = self.filterStories(CacheService.getCache('story'), filter);
        var promise = Story.query({filter: {story: filter}}, function(stories) {
            self.mergeStories(stories);
            _.each(stories, function(story) {
                if (!_.find(existingStories, {id: story.id})) {
                    existingStories.push(CacheService.get('story', story.id));
                }
            });
        }).$promise;
        return existingStories.length > 0 ? $q.when(existingStories) : promise;
    };
    this.get = function(id) {
        var cachedStory = CacheService.get('story', id);
        return cachedStory ? $q.when(cachedStory) : self.refresh(id);
    };
    this.refresh = function(id) {
        return Story.get({id: id}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(story) {
        return Story.update(story, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(story) {
        return Story.delete({id: story.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.acceptToBacklog = function(story, rank) {
        var params = {story: {}};
        if (rank) {
            params.story.rank = rank;
        }
        return Story.update({id: story.id, action: 'accept'}, params, crudMethods[IceScrumEventType.UPDATE]).$promise;
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
    this.planMultiple = function(ids, sprint) {
        return Story.updateArray({id: ids, action: 'planMultiple'}, {parentSprint: {id: sprint.id}}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.CREATE]);
        }).$promise;
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
    this.follow = function(story) {
        return Story.update({id: story.id, action: 'follow'}, {}, function(resultStory) {
            story.followed = resultStory.followed;
            story.followers_count = resultStory.followers_count;
            crudMethods[IceScrumEventType.UPDATE](story);
        }).$promise;
    };
    this.acceptAs = function(story, target) {
        return Story.update({id: story.id, action: 'turnInto' + target}, {}, function() {
            crudMethods[IceScrumEventType.DELETE](story);
        }).$promise;
    };
    this.copy = function(story) {
        return Story.update({id: story.id, action: 'copy'}, {}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.getMultiple = function(ids) {
        ids = _.map(ids, function(id) {
            return parseInt(id);
        });
        var cachedStories = _.filter(_.map(ids, function(id) {
            return CacheService.get('story', id);
        }), _.identity);
        var notFoundStoryIds = _.difference(ids, _.map(cachedStories, 'id'));
        if (notFoundStoryIds.length > 0) {
            var promise;
            if (notFoundStoryIds.length == 1) {
                promise = self.get(notFoundStoryIds[0]).then(function(story) { return [story]; });
            } else {
                promise = Story.query({id: notFoundStoryIds}, self.mergeStories).$promise;
            }
            return promise.then(function(stories) {
                return _.concat(cachedStories, stories);
            });
        } else {
            return $q.when(cachedStories);
        }
    };
    this.updateMultiple = function(ids, updatedFields) {
        if (ids.length == 1) {
            return self.get(parseInt(ids[0])).then(function(story) {
                return self.update(_.merge({}, story, updatedFields)).then(function(story) {
                    return [story];
                });
            });
        } else {
            return Story.updateArray({id: ids}, {story: updatedFields}, function(stories) {
                _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
            }).$promise;
        }
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
        return Story.updateArray({id: ids, action: 'accept'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.returnToSandboxMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'returnToSandbox'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.acceptAsMultiple = function(ids, target) {
        return Story.updateArray({id: ids, action: 'turnInto' + target}, {}, function() {
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
    this.doneMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'done'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.unDoneMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'unDone'}, {}, function(stories) {
            _.each(stories, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.listByBacklog = function(backlog) {
        return queryWithContext({type: 'backlog', typeId: backlog.id}, function(stories) {
            self.mergeStories(stories);
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
            case 'createAccepted':
                return Session.po();
            case 'upload':
            case 'update':
                return (Session.po() && story.state >= StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE) ||
                       (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            case 'updateCreator':
                return Session.po() && story.state < StoryStatesByName.DONE;
            case 'updateEstimate':
                return Session.tmOrSm() && story.state > StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE;
            case 'updateParentSprint':
                return Session.poOrSm() && story.state > StoryStatesByName.ACCEPTED && story.state < StoryStatesByName.DONE;
            case 'accept':
                return Session.po() && story.state <= StoryStatesByName.SUGGESTED;
            case 'split':
                return story.state >= StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.PLANNED && Session.po();
            case 'rank':
                return Session.po() && (!story || story.state < StoryStatesByName.DONE);
            case 'delete':
                return (Session.po() && story.state < StoryStatesByName.PLANNED) ||
                       (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            case 'returnToSandbox':
                return Session.po() && _.includes([StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED], story.state);
            case 'unPlan':
                return Session.poOrSm() && story.state >= StoryStatesByName.PLANNED && story.state < StoryStatesByName.DONE;
            case 'shiftToNext':
                return Session.poOrSm() && story.state >= StoryStatesByName.PLANNED && story.state <= StoryStatesByName.IN_PROGRESS;
            case 'done':
                return Session.poOrSm() && story.state == StoryStatesByName.IN_PROGRESS;
            case 'unDone':
                return Session.poOrSm() && story.state == StoryStatesByName.DONE && story.parentSprint.state == SprintStatesByName.IN_PROGRESS;
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
    this.listByField = function(field) {
        return Story.get({action: 'listByField', field: field}).$promise
    };
    this.getDependenceEntries = function(story) {
        return FormService.httpGet('story/' + story.id + '/dependenceEntries');
    };
    this.getParentSprintEntries = function() {
        return FormService.httpGet('story/sprintEntries');
    };
    this.findDuplicates = function(term) {
        return FormService.httpGet('story/findDuplicates', {params: {term: term}});
    };
    this.getURL = function(id) {
        return FormService.httpGet('story/' + id + '/url');
    };
    this.filterStories = function(stories, storyFilter) {
        var getMatcher = function(key) {
            if (key == 'term') {
                return function(value) {
                    if (isNaN(value)) {
                        return function(story) {
                            var normalize = _.flow(_.deburr, _.toLower);
                            return _.some(['name', 'description', 'notes'], function(field) {
                                return normalize(story[field]).indexOf(normalize(value)) != -1;
                            });
                        }
                    } else {
                        return _.matchesProperty('uid', _.toNumber(value));
                    }
                }
            } else if (_.includes(['creator', 'feature', 'dependsOn', 'parentSprint'], key)) {
                return function(value) {
                    return _.matchesProperty(key + '.id', value);
                };
            } else if (key == 'parentRelease') {
                return function(value) {
                    return _.matchesProperty('parentSprint.parentReleaseId', value);
                };
            } else if (key == 'deliveredVersion') {
                return function(value) {
                    return _.matchesProperty('parentSprint.deliveredVersion', value);
                };
            } else if (key == 'tag') {
                return function(value) {
                    return function(story) {
                        return _.includes(story.tags, value);
                    }
                };
            } else if (key == 'actor') {
                return function(value) {
                    return function(story) {
                        var ids = _.map(story.actors_ids, function(actor) { return actor.id });
                        return _.includes(ids, value);
                    }
                };
            }
            else {
                return function(value) {
                    return _.matchesProperty(key, value);
                };
            }
        };
        return _.filter(stories, function(story) {
            return _.every(storyFilter, function(value, key) {
                var values = _.isArray(value) ? value : [value];
                var matcher = getMatcher(key);
                return _.some(values, function(val) {
                    return matcher(val)(story);
                });
            });
        });
    };
}]);
