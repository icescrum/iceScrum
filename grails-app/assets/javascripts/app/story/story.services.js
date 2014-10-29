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
    return $resource('story/:type/:typeId/:id/:action',
        {},
        {
            activities: {method: 'GET', isArray: true, params: {action: 'activities'}}
        });
}]);

services.service("StoryService", ['$q', '$http', 'Story', 'Session', 'StoryStatesByName', function($q, $http, Story, Session, StoryStatesByName) {
    this.list = [];
    this.isListResolved = $q.defer();

    var self = this;

    this.addStories = function(stories) {
        var listWasEmpty = _.isEmpty(self.list);
        angular.forEach(stories, function(story) {
            if (_.chain(self.list).where({ id: story.id }).isEmpty().value()) {
                self.list.push(new Story(story));
            }
        });
        if (listWasEmpty) {
            self.isListResolved.resolve(true);
        }
    };
    this.save = function(story) {
        story.class = 'story';
        return Story.save(story, function(story) {
            self.list.push(story);
        }).$promise;
    };
    this.listByType = function(obj) {
        var alreadyLoadedStories = [];
        var mustLoad = false;
        angular.forEach(obj.stories_ids, function(story) {
            var alreadyLoadedStory = _.find(self.list, { id: story.id });
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
            Story.query({ typeId: obj.id, type: obj.class.toLowerCase() }, function(data) {
                if (obj.stories === undefined) {
                    obj.stories = [];
                }
                angular.forEach(data, function(story) {
                    if (_.isEmpty(self.list)) {
                        self.isListResolved.resolve(true);
                    }
                    if (_.chain(obj.stories).where({ id: story.id }).isEmpty().value()) {
                        var newStory = new Story(story);
                        obj.stories.push(newStory);
                        self.list.push(newStory);
                    }
                });
            })
        }
    };
    this.get = function(id) {
        return self.isListResolved.promise.then(function() {
            var st = _.find(self.list, function(rw) {
                return rw.id == id;
            });
            if(st){
               return st;
            } else {
                throw Error('todo.is.ui.story.does.not.exist');
            }
        });
    };
    this.update = function(story) {
        return story.$update(function(updatedStory) {
            var index = self.list.indexOf(_.findWhere(self.list, { id: story.id }));
            if (index != -1) {
                self.list.splice(index, 1, updatedStory);
            }
        });
    };
    this['delete'] = function(story) {
        return story.$delete(function() {
            _.remove(self.list, { id: story.id });
        });
    };
    this.like = function(story) {
        return story.$update({ action: 'like' }, function(result){
            story.liked = result.liked;
        });
    };
    this.follow = function(story) {
        return story.$update({ action: 'follow' }, function(result){
            story.followed = result.followed;
        });
    };
    this.activities = function(story, all) {
        var params = { id: story.id };
        if (all) {
            params.all = true;
        }
        return Story.activities(params, function(activities) {
            story.activities = activities;
        }).$promise;
    };
    this.saveTemplate = function(story, name) {
        return story.$update({ action: 'saveTemplate', 'template.name': name});
    };
    this.deleteTemplate = function(templateId) {
        return $http.post('story/deleteTemplate?template.id=' + templateId);
    };
    this.accept = function(story) {
        story.state = StoryStatesByName.ACCEPTED;
        return this.update(story);
    };
    this.acceptAs = function(story, target) {
        return story.$update({ action: 'acceptAs' + target}, function() {
            _.remove(self.list, { id: story.id });
        });
    };
    this.copy = function(story) {
        return Story.update({ id: story.id, action: 'copy'}, {}, function(story) {
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
        return Story.updateArray({ id: ids }, { story: updatedFields }, function(stories) {
            angular.forEach(stories, function(story) {
                var index = self.list.indexOf(_.findWhere(self.list, { id: story.id }));
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
        return Story.updateArray({ id: ids, action: 'copy'}, {}, function(stories) {
            angular.forEach(stories, function(story) {
                self.list.push(new Story(story));
            });
        }).$promise;
    };
    this.acceptMultiple = function(ids) {
        var fields = { state : StoryStatesByName.ACCEPTED };
        return this.updateMultiple(ids, fields);
    };
    this.acceptAsMultiple = function(ids, target) {
        return Story.updateArray({ id: ids, action: 'acceptAs' + target}, {}, function() {
            _.remove(self.list, function(story) {
                return _.contains(ids, story.id.toString());
            });
        }).$promise;
    };
    this.followMultiple = function(ids, follow) {
        return Story.updateArray({ id: ids, action: 'follow' }, { follow: follow }, function(stories) {
            angular.forEach(stories, function(story) {
                var index = self.list.indexOf(_.findWhere(self.list, { id: story.id }));
                if (index != -1) {
                    self.list.splice(index, 1, story);
                }
            });
        }).$promise;
    };
    this.authorizedStory = function(action, story) {
        switch (action) {
            case 'create':
            case 'followMultiple':
                return Session.authenticated();
            case 'createTemplate':
                return Session.inProduct();
            case 'upload':
            case 'update':
                return (Session.po() && story.state >= StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE) ||
                       (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            case 'updateMultiple':
                return Session.po() && story.state >= StoryStatesByName.SUGGESTED && story.state < StoryStatesByName.DONE;
            case 'accept':
                return Session.po() && story.state == StoryStatesByName.SUGGESTED;
            case 'copyMultiple':
            case 'updateTemplate':
                return Session.po();
            case 'delete':
            case 'deleteMultiple':
                return (Session.po() && story.state < StoryStatesByName.PLANNED) ||
                       (Session.creator(story) && story.state == StoryStatesByName.SUGGESTED);
            default:
                return false;
        }
    }
}]);
