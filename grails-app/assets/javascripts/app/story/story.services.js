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

services.service("StoryService", ['$q', '$http', 'Story', 'Session', 'StoryStatesByName', 'IceScrumEventType', 'PushService', function($q, $http, Story, Session, StoryStatesByName, IceScrumEventType, PushService) {
    this.list = [];
    this.isListResolved = $q.defer();
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(story) {
        var existingStory = _.find(self.list, {id: story.id});
        if (existingStory) {
            angular.extend(existingStory, story);
        } else {
            self.list.push(new Story(story));
        }
    };
    crudMethods[IceScrumEventType.UPDATE] = function(story) {
        angular.extend(_.find(self.list, {id: story.id}), story);
    };
    crudMethods[IceScrumEventType.DELETE] = function(story) {
        _.remove(self.list, {id: story.id});
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('story', eventType, crudMethod);
    });
    this.addStories = function(stories) {
        angular.forEach(stories, function(story) {
            if (_.chain(self.list).where({id: story.id}).isEmpty().value()) {
                self.list.push(new Story(story));
            }
        });
        self.isListResolved.resolve(true);
    };
    this.save = function(story) {
        story.class = 'story';
        return Story.save(story, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.listByType = function(obj) {
        var alreadyLoadedStories = [];
        var mustLoad = false;
        angular.forEach(obj.stories_ids, function(story) {
            var alreadyLoadedStory = _.find(self.list, {id: story.id});
            if (!_.isEmpty(alreadyLoadedStory)) {
                alreadyLoadedStories.push(alreadyLoadedStory);
            } else {
                mustLoad = true;
            }
        });
        if (alreadyLoadedStories.length > 0) {
            obj.stories = alreadyLoadedStories;
        }
        if (mustLoad) {
            Story.query({typeId: obj.id, type: obj.class.toLowerCase()}, function(data) {
                if (obj.stories === undefined) {
                    obj.stories = [];
                }
                angular.forEach(data, function(story) {
                    if (_.isEmpty(self.list)) {
                        self.isListResolved.resolve(true);
                    }
                    if (_.chain(obj.stories).where({id: story.id}).isEmpty().value()) {
                        var newStory = new Story(story);
                        obj.stories.push(newStory);
                        self.list.push(newStory);
                    }
                });
            })
        } else {
            if (obj.stories === undefined) {
                obj.stories = [];
            }
        }
    };
    this.get = function(id) {
        return self.isListResolved.promise.then(function() {
            var story = _.find(self.list, function(rw) {
                return rw.id == id;
            });
            if (story) {
                return story;
            } else {
                throw Error('todo.is.ui.story.does.not.exist');
            }
        });
    };
    this.update = function(story) {
        return Story.update(story, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(story) {
        return story.$delete(crudMethods[IceScrumEventType.DELETE]);
    };
    this.like = function(story) {
        return Story.update({id: story.id, action: 'like'}, {}, function(resultStory) {
            story.liked = resultStory.liked;
            story.likers_count = resultStory.likers_count;
        }).$promise;
    };
    this.follow = function(story) {
        return Story.update({id: story.id, action: 'follow'}, {}, function(resultStory) {
            story.followed = resultStory.followed;
            story.followers_count = resultStory.followers_count;
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
    this.accept = function(story) {
        story.state = StoryStatesByName.ACCEPTED;
        return this.update(story);
    };
    this.acceptAs = function(story, target) {
        return Story.update({id: story.id, action: 'acceptAs' + target}, {}, function() {
            _.remove(self.list, {id: story.id});
        }).$promise;
    };
    this.copy = function(story) {
        return Story.update({id: story.id, action: 'copy'}, {}, function(story) {
            self.list.push(story);
        }).$promise;
    };
    this.getMultiple = function(ids) {
        return self.isListResolved.promise.then(function() {
            return _.filter(self.list, function(story) {
                return _.contains(ids, story.id.toString());
            });
        });
    };
    this.updateMultiple = function(ids, updatedFields) {
        return Story.updateArray({id: ids}, {story: updatedFields}, function(stories) {
            angular.forEach(stories, function(story) {
                var index = self.list.indexOf(_.find(self.list, {id: story.id}));
                if (index != -1) {
                    self.list.splice(index, 1, story);
                }
            });
        }).$promise;
    };
    this.deleteMultiple = function(ids) {
        return Story.delete({id: ids}, function() {
            _.remove(self.list, function(story) {
                return _.contains(ids, story.id.toString());
            });
        }).$promise;
    };
    this.copyMultiple = function(ids) {
        return Story.updateArray({id: ids, action: 'copy'}, {}, function(stories) {
            angular.forEach(stories, function(story) {
                self.list.push(new Story(story));
            });
        }).$promise;
    };
    this.acceptMultiple = function(ids) {
        var fields = {state: StoryStatesByName.ACCEPTED};
        return this.updateMultiple(ids, fields);
    };
    this.acceptAsMultiple = function(ids, target) {
        return Story.updateArray({id: ids, action: 'acceptAs' + target}, {}, function() {
            _.remove(self.list, function(story) {
                return _.contains(ids, story.id.toString());
            });
        }).$promise;
    };
    this.followMultiple = function(ids, follow) {
        return Story.updateArray({id: ids, action: 'follow'}, {follow: follow}, function(stories) {
            angular.forEach(stories, function(story) {
                var index = self.list.indexOf(_.find(self.list, {id: story.id}));
                if (index != -1) {
                    self.list.splice(index, 1, story);
                }
            });
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
                return Session.po();
            case 'delete':
                return (Session.po() && story.state < StoryStatesByName.PLANNED) ||
                    (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
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
            $http.get('story/templateEntries').success(function(templateEntries) {
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
    }
}]);
