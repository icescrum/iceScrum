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
            return user && user.id ? ($rootScope.serverUrl + '/user/' + (initials ? 'initialsAvatar' : 'avatar') + '/' + user.id + '?cache=' + new Date(user.lastUpdated ? user.lastUpdated : null).getTime()) : $rootScope.serverUrl + '/assets/avatars/avatar.png';
        };
    }])
    .filter('userInitialsAvatar', ['$rootScope', 'FormService', function($rootScope, FormService) {
        return function(user) {
            return $rootScope.serverUrl + '/user/initialsAvatar/?firstName=' + user.firstName + '&lastName=' + user.lastName;
        };
    }])
    .filter('userColorRoles', ['$rootScope', 'Session', function($rootScope, Session) {
        return function(user) {
            var classes = "img-circle user-role";
            var project = Session.getProject();
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
    .filter('storyType', function() {
        return function(type) {
            switch (type) {
                case 2:
                    return 'defect';
                case 3:
                    return 'functional';
                default:
                    return '';
            }
        };
    })
    .filter('storyTypeIcon', function() {
        return function(type) {
            switch (type) {
                case 2:
                    return 'bug';
                case 3:
                    return 'cogs';
                default:
                    return '';

            }
        }
    })
    .filter('featureType', function() {
        return function(type) {
            return type == 1 ? 'architectural' : '';
        };
    })
    .filter('join', function() {
        return function(array) {
            return _.join(array, ', ');
        };
    })
    .filter('featureTypeIcon', function() {
        return function(type) {
            return type == 1 ? 'cogs' : '';
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
            if (disabled) {
                return {'border-left': "8px solid " + color};
            } else if (color) {
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
                return {'background-image': gradientBackgroundCache[color]};
            }
        };
    })
    .filter('actorTag', ['$state', 'ContextService', function($state, ContextService) {
        return function(description, actor) {
            var contextUrl = $state.href($state.current.name, $state.params);
            var actorTpl = actor ? '<a href="' + contextUrl + '?context=actor' + ContextService.contextSeparator + actor.id + '">$2</a>' : '$2';
            return description ? description.replace(/A\[(.+?)-(.+?)\]/g, actorTpl) : '';
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
            return $rootScope.serverUrl + '/' + (projectKey ? projectKey : Session.getProject().pkey) + '-' + prefixByType[type] + uid;
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
}]).filter('i18nName', ['$rootScope', function($rootScope) {
    return function(object) {
        if (object) {
            return object.name.indexOf('is.ui') === 0 || object.name.indexOf('todo.is.ui') === 0 ? $rootScope.message(object.name) : object.name;
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
}).filter('randomValueInArray', function() {
    return function(array) {
        return array[_.random(0, array.length - 1)];
    }
}).filter('parens', function() {
    return function(inside) {
        return inside ? '(' + inside + ')' : '';
    }
}).filter('ellipsis', ['limitToFilter', function(limitToFilter) {
    return function(text, limit) {
        return text ? limitToFilter(text, limit) + (text.length > limit ? '...' : '') : text;
    }
}]);