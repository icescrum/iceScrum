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

var contrastColorCache = {}, gradientBackgroundCache = {};
var filters = angular.module('filters', []);

filters
    .filter('userFullName', function() {
        return function(user) {
            return user ? user.firstName+' '+user.lastName : '';
        };
    })
    .filter('userAvatar', ['$rootScope', function($rootScope) {
        return function(user) {
            return user ?  ($rootScope.serverUrl + '/user/avatar/'+ user.id + '?cache=' + new Date(user.lastUpdated ? user.lastUpdated : null).getTime()) : $rootScope.serverUrl + '/assets/avatars/avatar.png';
        };
    }])
    .filter('storyType', function() {
        return function(type) {
            switch(type) {
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
            switch(type) {
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
    .filter('featureTypeIcon', function() {
        return function(type) {
            return type == 1 ? 'cogs' : '';
        };
    })
    .filter('contrastColor', function() {
        return function(bg) {
            if(bg && contrastColorCache[bg] != undefined){
                return contrastColorCache[bg];
            }
            else if (bg && contrastColorCache[bg] == undefined) {
                //convert hex to rgb
                var color;
                if (bg.indexOf('#') == 0){
                    var bigint = parseInt(bg.substring(1), 16);
                    var r = (bigint >> 16) & 255, g = (bigint >> 8) & 255, b = bigint & 255;
                    color = 'rgb('+r+', '+g+', '+b+')';
                } else {
                    color = bg;
                }
                //get r,g,b and decide
                var rgb = color.replace(/^(rgb|rgba)\(/,'').replace(/\)$/,'').replace(/\s/g,'').split(',');
                var yiq = ((rgb[0]*299)+(rgb[1]*587)+(rgb[2]*114))/1000;
                contrastColorCache[bg] = (yiq >= 169) ? '' : 'invert';
                return contrastColorCache[bg];
            } else {
                return '';
            }
        };
    })
    .filter('createGradientBackground', function() {
        return function(color) {
            if(color && gradientBackgroundCache[color] != undefined){
                return gradientBackgroundCache[color];
            }
            else if (color) {
                var ratio = 18;
                var num = parseInt(color.substring(1),16),
                    ra = (num >> 16) & 255, ga = (num >> 8) & 255, ba = num & 255,
                    amt = Math.round(2.55 * ratio),
                    R = ((num >> 16) & 255) + amt,
                    G = ((num >> 8) & 255) + amt,
                    B = (num & 255) + amt;
                gradientBackgroundCache[color] = "background-image: -moz-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",0.8) 0%, rgba("+R+","+G+","+B+",0.8) 100%); " +
                    "   background-image: -o-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",0.8) 0%, rgba("+R+","+G+","+B+",0.8) 100%); " +
                    "   background-image: -webkit-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",0.8) 0%, rgba("+R+","+G+","+B+",0.8) 100%); " +
                    "   background-image: linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",0.8) 0%, rgba("+R+","+G+","+B+",0.8) 100%);";
                return gradientBackgroundCache[color];
            }
        };
    })
    .filter('storyDescriptionHtml', function() {
        return function(story) {
            return story.description ? story.description.formatLine().replace(/A\[(.+?)-(.*?)\]/g, '<a href="#/actor/$1">$2</a>') : "";
        };
    })
    .filter('storyDescription', function() {
        return function(story) {
            return story.description ? story.description.formatLine().replace(/A\[(.+?)-(.*?)\]/g, '$2') : "";
        };
    })
    .filter('i18n', ['BundleService', function(BundleService) {
        return function(key, bundleName) {
            if (key != undefined && key != null && BundleService.getBundle(bundleName)) {
                return BundleService.getBundle(bundleName)[key];
            }
        }
    }])
    .filter('lineReturns', function() {
        return function(text) {
            return text ? text.replace(/\n/g, '<br/>') : "";
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
            if (ext.indexOf('.') > -1){
                ext = ext.substring(ext.indexOf('.') + 1);
            }
            var icon;
            switch (ext){
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
    })
    .filter('sanitize', ['$sce', function($sce) {
        return function(html) {
            return html ? $sce.trustAsHtml(html) : "";
        };
    }])
    .filter('reverse', function() {
        return function(items) {
            return items.slice().reverse();
        };
    })
    .filter('permalink', ['$rootScope', 'Session', function($rootScope, Session) {
        return function(uid) {
            return $rootScope.serverUrl + '/'+ Session.getProject().pkey +'-' + uid;
        };
    }])
    .filter('flowFilesNotCompleted', function () {
        return function (items) {
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
    }).filter('activityIcon', function () {
        return function (activity) {
            if (activity) {
                switch (activity.code) {
                    case 'save':
                    case 'taskSave':
                    case 'acceptanceTestSave':
                        return "fa fa-plus";
                    case 'update':
                        return "fa fa-pencil";
                    case 'delete':
                    case 'taskDelete':
                    case 'acceptanceTestDelete':
                        return "fa fa-times";
                    case "acceptAs":
                        return "fa fa-thumbs-up";
                    case "comment":
                        return "fa fa-comment";
                    case "icebox":
                        return "fa fa-askerisk";
                    case "restored":
                        return "fa fa-repeat";
                    case "estimate":
                        return "fa fa-calculator";
                    case "returnToSandbox":
                        return "fa fa-undo";
                    case "done":
                        return "fa fa-check";
                    case "unDone":
                        return "fa fa-undo";
                    case "plan":
                        return "fa fa-calendar";
                    case "unPlan":
                        return "fa fa-calendar-o";
                    case "taskInProgress":
                        return "fa fa-?";
                    case "taskWait":
                        return "fa fa-?";
                }
            }
        };
    }).filter('percentProgress', [function() {
        return function(current, count) {
            return Math.floor((current * 100) / count);
        }
    }]).filter('dateToIso', ['dateFilter', function(dateFilter) {
        return function (date) {
            return dateFilter(date, 'yyyy-MM-ddTHH:mm:ssZ');
        };
    }]).filter('dateTime', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
        return function (date) {
            return dateFilter(date, $rootScope.message('is.date.format.short.time'));
        };
    }]).filter('dateShort', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
        return function (date) {
            return dateFilter(date, $rootScope.message('is.date.format.short'));
        };
    }]).filter('dateShorter', ['$rootScope', 'dateFilter', function($rootScope, dateFilter) {
        return function (date) {
            return dateFilter(date, $rootScope.message('is.date.format.shorter'));
        };
    }]).filter('orElse', [function() {
        return function (value, defaultValue) {
            return (!_.isUndefined(value) && !_.isNull(value)) ? value : defaultValue;
        };
    }]).filter('orFilter', [function() {
        return function(items, patternObject) {
            if (angular.isArray(items)) {
                return _.filter(items, function(item) {
                    return _.any(_.pairs(patternObject), function(objectProperty) {
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
        return function(items, fields) {
            var term = $rootScope.app.search;
            if (!_.isEmpty(items) && !_.isEmpty(term) && !_.isEmpty(fields)) {
                var searchTerm = _.deburr(_.trim(term.toLowerCase()));
                return _.filter(items, function(item) {
                    return _.any(fields, function (field) {
                        var value = _.get(item, field);
                        if (!_.isEmpty(value) && _.isString(value)) {
                            return _.deburr(value.toLowerCase()).indexOf(searchTerm) != -1;
                        } else {
                            return false;
                        }
                    });
                });
            } else {
                return items;
            }
        }
    }]).filter('dependsOnLabel', [function() {
        return function(dependsOn) {
            if (dependsOn) {
                return dependsOn.name + ' (' + dependsOn.uid + ')';
            }
        }
    }]).filter('parentSprintLabel', ['$rootScope', function($rootScope) {
        return function(parentSprint) {
            if (parentSprint) {
                return $rootScope.message('is.sprint') + ' ' + parentSprint.orderNumber;
            }
        }
    }]).filter('acceptanceTestColor', ['AcceptanceTestStatesByName', function(AcceptanceTestStatesByName) {
        return function (state) {
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
        return function (object, defaultObject) {
            return _.merge(object, defaultObject);
        }
    }]).filter('taskStateIcon', ['TaskStatesByName', function(TaskStatesByName) {
        return function (state) {
            var iconByState = 'fa-hourglass-';
            switch (state) {
                case TaskStatesByName.WAIT:
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
    }]);