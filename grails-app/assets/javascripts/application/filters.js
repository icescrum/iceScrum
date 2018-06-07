/*
 * Copyright (c) 2015 Kagilum SAS.
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

var contrastColorCache = {}, gradientBackgroundCache = {}, userVisualRolesCache = {};
var filters = angular.module('filters', []);

filters
    .filter('userNamesFromEmail', function() {
        return function(email) {
            var namesFromEmail = {email: email};
            var emailPrefix = email.split('@')[0];
            namesFromEmail.firstName = emailPrefix;
            var dotPosition = emailPrefix.indexOf('.');
            if (dotPosition != -1) {
                namesFromEmail.firstName = _.capitalize(emailPrefix.substring(0, dotPosition));
                namesFromEmail.lastName = _.capitalize(emailPrefix.substring(dotPosition + 1));
            }
            return namesFromEmail;
        };
    })
    .filter('displayNames', function() {
        return function(users) {
            return _.chain(users).map(function(user) {
                return _.capitalize(user.firstName) + ' ' + _.upperCase(user.lastName.substring(0, 1)) + '.';
            }).join(', ').value();
        };
    })
    .filter('userFullName', ['$filter', function($filter) {
        return function(user) {
            var firstName = '';
            var lastName = '';
            if (user) {
                if (user.id) {
                    firstName = user.firstName;
                    lastName = user.lastName;
                } else if (user.email) {
                    var namesFromEmail = $filter('userNamesFromEmail')(user.email);
                    firstName = namesFromEmail.firstName;
                    lastName = namesFromEmail.lastName;
                }
            }
            return firstName + (lastName ? ' ' + lastName : '');
        };
    }])
    .filter('userAvatar', ['$rootScope', 'Session', function($rootScope, Session) {
        return function(user, initials) {
            if (Session.current(user)) {
                user = Session.user; // Bind to current user to see avatar change immediately
            }
            return user && user.id ? ($rootScope.serverUrl + '/user/' + (initials ? 'initialsAvatar' : 'avatar') + '/' + user.id) : $rootScope.serverUrl + '/assets/avatars/avatar.png';
        };
    }])
    .filter('userInitialsAvatar', ['$rootScope', 'FormService', function($rootScope, FormService) {
        return function(user) {
            return $rootScope.serverUrl + '/user/initialsAvatar/?firstName=' + user.firstName + '&lastName=' + user.lastName;
        };
    }])
    .filter('userColorRoles', ['$rootScope', function($rootScope) {
        return function(user, project) {
            var classes = "img-rounded user-role";
            if (!project) {
                project = $rootScope.getProjectFromState();
            }
            if (!project || !project.pkey) {
                return classes;
            }
            if (!userVisualRolesCache[project.pkey]) {
                userVisualRolesCache[project.pkey] = {};
            }
            if (!userVisualRolesCache[project.pkey][user.id]) {
                if (_.find(project.productOwners, {id: user.id})) {
                    classes += " po";
                }
                if (_.find(project.team.scrumMasters, {id: user.id})) {
                    classes += " sm";
                }
                userVisualRolesCache[project.pkey][user.id] = classes;
            }
            return userVisualRolesCache[project.pkey][user.id];
        };
    }])
    .filter('storyType', ['StoryTypesClasses', function(StoryTypesClasses) {
        return function(type) {
            var cssClass = StoryTypesClasses[type];
            if (cssClass) {
                cssClass += ' postit-type';
            }
            return cssClass;
        };
    }])
    .filter('storyTypeIcon', ['StoryTypesIcons', function(StoryTypesIcons) {
        return function(type) {
            return StoryTypesIcons[type];
        }
    }])
    .filter('featureType', ['FeatureTypesByName', function(FeatureTypesByName) {
        return function(type) {
            return type == FeatureTypesByName.ARCHITECTURAL ? 'architectural postit-type' : '';
        };
    }])
    .filter('featureTypeIcon', ['FeatureTypesByName', function(FeatureTypesByName) {
        return function(type) {
            return type == FeatureTypesByName.ARCHITECTURAL ? 'cogs' : '';
        };
    }])
    .filter('join', function() {
        return function(array) {
            return _.join(array, ', ');
        };
    })
    .filter('contrastColor', function() {
        return function(bg, invert) {
            if (bg && contrastColorCache[bg] != undefined) {
                return invert ? (contrastColorCache[bg] == 'invert' ? '' : 'invert') : contrastColorCache[bg];
            }
            else if (bg && contrastColorCache[bg] == undefined) {
                //convert hex to rgb
                var color;
                if (bg.indexOf('#') == 0) {
                    var bigint = parseInt(bg.substring(1), 16);
                    var r = (bigint >> 16) & 255, g = (bigint >> 8) & 255, b = bigint & 255;
                    color = 'rgb(' + r + ', ' + g + ', ' + b + ')';
                } else {
                    color = bg;
                }
                //get r,g,b and decide
                var rgb = color.replace(/^(rgb|rgba)\(/, '').replace(/\)$/, '').replace(/\s/g, '').split(',');
                var yiq = ((rgb[0] * 299) + (rgb[1] * 587) + (rgb[2] * 114)) / 1000;
                contrastColorCache[bg] = (yiq >= 169) ? '' : 'invert';
                return invert ? (contrastColorCache[bg] == 'invert' ? '' : 'invert') : contrastColorCache[bg];
            } else {
                return '';
            }
        };
    })
    .filter('createGradientBackground', function() {
        return function(color, disabled) {
            if (!gradientBackgroundCache[color]) {
                var ratio = 18;
                var num = parseInt(color.substring(1), 16),
                    ra = (num >> 16) & 255, ga = (num >> 8) & 255, ba = num & 255,
                    amt = Math.round(2.55 * ratio),
                    R = ((num >> 16) & 255) + amt,
                    G = ((num >> 8) & 255) + amt,
                    B = (num & 255) + amt;
                gradientBackgroundCache[color] = "linear-gradient(to top, rgba(" + ra + "," + ga + "," + ba + ",0.8) 0%, rgba(" + R + "," + G + "," + B + ",0.8) 100%)";
            }
            return {'background-image': gradientBackgroundCache[color], 'border-left': "10px solid " + color};
        };
    })
    .filter('actorTag', ['$state', 'ContextService', function($state, ContextService) {
        return function(description, actors) {
            var contextUrl = $state.href($state.current.name, $state.params);
            return description ? description.replace(/A\[(.+?)-(.+?)\]/g, function(actorTag, actorUid, actorName) {
                if (actors) {
                    var actorId = _.find(actors, {uid: parseInt(actorUid)}).id;
                    return '<a href="' + contextUrl + '?context=actor' + ContextService.contextSeparator + actorId + '">' + actorName + '</a>';
                } else {
                    return actorName;
                }
            }) : '';
        };
    }])
    .filter('i18n', ['I18nService', function(I18nService) {
        return function(key, bundleName) {
            if (key != undefined && key != null && I18nService.getBundle(bundleName)) {
                return I18nService.getBundle(bundleName)[key];
            }
        }
    }])
    .filter('lineReturns', function() {
        return function(text) {
            return text ? _.escape(text).replace(/\r\n/g, "<br/>").replace(/\n/g, '<br/>') : "";
        }
    })
    .filter('filesize', function() {
        return function(size) {
            var string;
            if (size >= 1024 * 1024 * 1024 * 1024 / 10) {
                size = size / (1024 * 1024 * 1024 * 1024 / 10);
                string = "TiB";
            } else if (size >= 1024 * 1024 * 1024 / 10) {
                size = size / (1024 * 1024 * 1024 / 10);
                string = "GiB";
            } else if (size >= 1024 * 1024 / 10) {
                size = size / (1024 * 1024 / 10);
                string = "MiB";
            } else if (size >= 1024 / 10) {
                size = size / (1024 / 10);
                string = "KiB";
            } else {
                size = size * 10;
                string = "b";
            }
            return (Math.round(size) / 10) + string;
        }
    })
    .filter('fileicon', function() {
        return function(ext) {
            if (ext) {
                ext = ext.toLowerCase();
                if (ext.indexOf('.') > -1) {
                    ext = ext.substring(ext.indexOf('.') + 1);
                }
                var icon;
                switch (ext) {
                    case 'xls':
                    case 'csv':
                    case 'xlsx':
                        icon = 'file-excel-o';
                        break;
                    case 'pdf':
                        icon = 'file-pdf-o';
                        break;
                    case 'txt':
                        icon = 'file-text-o';
                        break;
                    case 'doc':
                    case 'docx':
                        icon = 'file-word-o';
                        break;
                    case 'ppt':
                    case 'pptx':
                        icon = 'file-powerpoint-o';
                        break;
                    case 'zip':
                    case 'rar':
                    case 'gz':
                    case 'gzip':
                        icon = 'file-archive-o';
                        break;
                    case 'png':
                    case 'gif':
                    case 'jpg':
                    case 'jpeg':
                    case 'bmp':
                        icon = 'file-image-o';
                        break;
                    case 'mp3':
                    case 'wave':
                    case 'aac':
                        icon = 'file-audio-o';
                        break;
                    case 'avi':
                    case 'flv':
                    case 'mp4':
                    case 'mpg':
                    case 'mpeg':
                        icon = 'file-movie-o';
                        break;
                    default :
                        icon = 'file-o';
                }
                return icon;
            }
        }
    })
    .filter('reverse', function() {
        return function(items) {
            return items.slice().reverse();
        };
    })
    .filter('permalink', ['$rootScope', 'Session', function($rootScope, Session) {
        return function(uid, type, projectKey) {
            var prefixByType = {
                story: '',
                feature: 'F',
                task: 'T'
            };
            return $rootScope.serverUrl + '/' + (projectKey ? projectKey : $rootScope.getProjectFromState().pkey) + '-' + prefixByType[type] + uid;
        };
    }])
    .filter('projectUrl', ['$rootScope', function($rootScope) {
        return function(projectKey) {
            return $rootScope.serverUrl + '/p/' + projectKey + '/';
        };
    }])
    .filter('flowFilesNotCompleted', function() {
        return function(items) {
            var filtered = [];
            if (items) {
                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    if (!item.isComplete()) {
                        filtered.push(item);
                    }
                }
            }
            return filtered;
        };
    })
    .filter('activityName', ['$rootScope', function($rootScope) {
        return function(activity, hideType) {
            if (hideType) {
                var code = activity.code == 'update' ? 'updateField' : activity.code;
                return $rootScope.message('is.fluxiable.' + code);
            } else {
                var type = activity.parentType;
                if (activity.code == 'acceptanceTestDelete') {
                    type = 'acceptanceTest';
                } else if (activity.code == 'taskDelete') {
                    type = 'task';
                } else if (activity.code == 'delete') {
                    type = 'story'
                }
                return $rootScope.message('is.fluxiable.' + activity.code) + ' ' + $rootScope.message('is.' + type);
            }
        };
    }])
    .filter('percentProgress', [function() {
        return function(current, count) {
            return Math.floor((current * 100) / count);
        }
    }]).filter('dateToIso', ['dateFilter', function(dateFilter) {
    return function(date) {
        return dateFilter(date, 'yyyy-MM-ddTHH:mm:ssZ');
    };
}]).filter('dateTime', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
    return function(date) {
        return dateFilter(date, $rootScope.message('is.date.format.short.time'));
    };
}]).filter('dayShort', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
    return function(date) {
        return dateFilter(date, $rootScope.message('is.date.format.short'), 'utc');
    };
}]).filter('dayShorter', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
    return function(date) {
        return dateFilter(date, $rootScope.message('is.date.format.shorter'), 'utc');
    };
}]).filter('orElse', [function() {
    return function(value, defaultValue) {
        return (!_.isUndefined(value) && !_.isNull(value)) ? value : defaultValue;
    };
}]).filter('orFilter', [function() {
    return function(items, patternObject) {
        if (angular.isArray(items)) {
            return _.filter(items, function(item) {
                return _.some(_.toPairs(patternObject), function(objectProperty) {
                    var key = objectProperty[0];
                    var value = objectProperty[1].toString().toLowerCase();
                    return item[key].toString().toLowerCase().indexOf(value) !== -1;
                });
            });
        } else {
            return items;
        }
    }
}]).filter('search', ['$rootScope', function($rootScope) {
    return function(items) {
        var term = $rootScope.application.search;
        var fields = ['name', 'description', 'notes', 'uid']; // Hardcoded for the moment because it is always the same
        if (!_.isEmpty(items) && !_.isEmpty(term) && !_.isEmpty(fields)) {
            var searchTerm = _.deburr(_.trim(term.toString().toLowerCase()));
            return _.filter(items, function(item) {
                return _.some(fields, function(field) {
                    var value = _.get(item, field);
                    if (!_.isUndefined(value) && !_.isNull(value)) {
                        return _.deburr(value.toString().toLowerCase()).indexOf(searchTerm) != -1;
                    } else {
                        return false;
                    }
                });
            });
        } else {
            return items;
        }
    }
}]).filter('storyLabel', [function() {
    return function(story, after) {
        if (story) {
            return after ? story.name + ' - ' + story.uid : story.uid + ' - ' + story.name;
        }
    }
}]).filter('sprintName', ['$rootScope', function($rootScope) {
    return function(sprint) {
        if (sprint) {
            return $rootScope.message('is.sprint') + ' ' + sprint.index;
        }
    }
}]).filter('sprintNameWithState', ['$rootScope', 'sprintNameFilter', 'SprintStatesByName', function($rootScope, sprintNameFilter, SprintStatesByName) {
    return function(sprint) {
        if (sprint) {
            return sprintNameFilter(sprint) + (sprint.state === SprintStatesByName.IN_PROGRESS ? ' (' + $rootScope.message('is.sprint.state.inprogress') + ')' : '');
        }
    }
}]).filter('computePercentage', [function() {
    return function(object, value, onValue) {
        var val = Math.round((object[value] * 100) / object[onValue]);
        return val > 100 ? 100 : val;
    }
}]).filter('stripTags', [function() {
    return function(input, disallowed) {
        disallowed = (((disallowed || '') + '')
                          .toLowerCase()
                          .match(/<[a-z][a-z0-9]*>/g) || [])
            .join(''); // making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
        var tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi;
        return input.replace(tags, function($0, $1) {
            return disallowed.indexOf('<' + $1.toLowerCase() + '>') > -1 ? ' ' : $0;
        });
    }
}]).filter('truncateAndSeeMore', ['$rootScope', '$filter', function($rootScope, $filter) {
    return function(text, key, length, url) {
        var filteredText = $filter('stripTags')(text, '<br><p>');
        var limit = length ? length : 350;
        if (filteredText.length > limit) {
            var permalink = $rootScope.serverUrl + '/p/' + key + (url ? url : '');
            filteredText = $filter('ellipsis')(filteredText, limit, '&hellip;') + ' <a href="' + permalink + '">' + $rootScope.message('todo.is.ui.more') + '</a>';
        }
        return filteredText;
    }
}]).filter('allMembers', [function() {
    return function(project) {
        return _.unionBy(project.team.members, project.productOwners, 'id');
    }
}]).filter('acceptanceTestColor', ['AcceptanceTestStatesByName', function(AcceptanceTestStatesByName) {
    return function(state) {
        var colorClass;
        switch (state) {
            case AcceptanceTestStatesByName.TOCHECK:
                colorClass = 'default';
                break;
            case AcceptanceTestStatesByName.FAILED:
                colorClass = 'danger';
                break;
            case AcceptanceTestStatesByName.SUCCESS:
                colorClass = 'success';
                break;
        }
        return colorClass;
    }
}]).filter('merge', [function() {
    return function(object, defaultObject) {
        return _.merge(object, defaultObject);
    }
}]).filter('taskStateIcon', ['TaskStatesByName', function(TaskStatesByName) {
    return function(state) {
        var iconByState = 'fa-hourglass-';
        switch (state) {
            case TaskStatesByName.TODO:
                iconByState += 'start';
                break;
            case TaskStatesByName.IN_PROGRESS:
                iconByState += 'half';
                break;
            case TaskStatesByName.DONE:
                iconByState += 'end';
                break;
        }
        return iconByState;
    }
}]).filter('sprintStateColor', ['SprintStatesByName', function(SprintStatesByName) {
    return function(state, prefix) {
        var colorState = (prefix ? prefix + '-' : '') + 'sprint-';
        switch (state) {
            case SprintStatesByName.TODO:
                colorState += 'todo';
                break;
            case SprintStatesByName.IN_PROGRESS:
                colorState += 'inProgress';
                break;
            case SprintStatesByName.DONE:
                colorState += 'done';
                break;
        }
        return colorState;
    }
}]).filter('releaseStateColor', ['ReleaseStatesByName', function(ReleaseStatesByName) {
    return function(state) {
        var colorState = 'release-';
        switch (state) {
            case ReleaseStatesByName.TODO:
                colorState += 'todo';
                break;
            case ReleaseStatesByName.IN_PROGRESS:
                colorState += 'inProgress';
                break;
            case ReleaseStatesByName.DONE:
                colorState += 'done';
                break;
        }
        return colorState;
    }
}]).filter('i18nName', ['$rootScope', function($rootScope) {
    return function(object) {
        if (object) {
            return _.startsWith(object.name, 'is.') || _.startsWith(object.name, 'todo.is.') ? $rootScope.message(object.name) : object.name;
        }
    }
}]).filter('sumBy', [function() {
    return function(objs, property) {
        return _.sumBy(objs, property);
    }
}]).filter('roundNumber', [function() {
    return function(number, nbDecimals) {
        var multiplicator = Math.pow(10, nbDecimals);
        return Math.round(number * multiplicator) / multiplicator;
    }
}]).filter('preciseFloatSum', [function() {
    return function(numbers) {
        var multiplicator = Math.pow(10, _.max(_.map(numbers, function(number) {
            var parts = number.toString().split('.');
            return parts.length > 1 ? parts[1].length : 0;
        })));
        return _.sumBy(numbers, function(number) {
            return number * multiplicator;
        }) / multiplicator;
    }
}]).filter('yesNo', ['$rootScope', function($rootScope) {
    return function(boolean) {
        return $rootScope.message(boolean ? 'is.yes' : 'is.no');
    }
}]).filter('visibleMenuElement', function() {
    return function(menus, item) {
        return _.filter(menus, function(menuElement) {
            return menuElement.visible(item);
        })
    };
}).filter('contextIcon', function() {
    return function(contextType) {
        return {
            feature: 'fa-puzzle-piece',
            tag: 'fa-tag',
            actor: 'fa-child'
        }[contextType];
    }
}).filter('contextStyle', function() {
    return function(context) {
        return context && context.color ? {
            "background-color": context.color,
            "border-color": context.color
        } : '';
    }
}).filter('parens', function() {
    return function(inside) {
        return inside ? '(' + inside + ')' : '';
    }
}).filter('ellipsis', ['limitToFilter', function(limitToFilter) {
    return function(text, limit, moreSign) {
        if (!moreSign) {
            moreSign = '...';
        }
        return text ? limitToFilter(text, limit) + (text.length > limit ? moreSign : '') : text;
    }
}]).filter('retrieveBacklog', function() {
    return function(project, code) {
        var backlog = _.find(project.backlogs, {'code': code});
        backlog.project = project;
        return backlog;
    }
}).filter('newStoryTypes', function() { // Can be overrided by plugins
    return function(storyTypes) {
        return storyTypes;
    }
}).filter('followedByUser', ['Session', function(Session) {
    return function(story, returnIfTrue, returnIfFalse) {
        return Session.user ? (_.find(story.followers_ids, {id: Session.user.id}) ? (returnIfTrue ? returnIfTrue : true) : (returnIfFalse ? returnIfFalse : false)) : (returnIfFalse ? returnIfFalse : false);
    }
}]);