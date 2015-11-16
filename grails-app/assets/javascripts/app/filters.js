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
            if (type == 2) {
                return 'defect';
            } else if (type == 3) {
                return 'functional';
            } else {
                return '';
            }
        };
    })
    .filter('featureType', function() {
        return function(type) {
            if (type == 1) {
                return 'architectural';
            }
            return '';
        };
    })
    .filter('contrastColor', function() {
        return function(bg) {
            if (bg) {
                //convert hex to rgb
                if (bg.indexOf('#') == 0){
                    var bigint = parseInt(bg.substring(1), 16);
                    var r = (bigint >> 16) & 255, g = (bigint >> 8) & 255, b = bigint & 255;
                    bg = 'rgb('+r+', '+g+', '+b+')';
                }
                //get r,g,b and decide
                var rgb = bg.replace(/^(rgb|rgba)\(/,'').replace(/\)$/,'').replace(/\s/g,'').split(',');
                var yiq = ((rgb[0]*299)+(rgb[1]*587)+(rgb[2]*114))/1000;
                return (yiq >= 169) ? '' : 'invert';
            } else {
                return '';
            }
        };
    })
    .filter('createGradientBackground', function() {
        return function(color) {
            if (color) {
                var ratio = 18;
                var num = parseInt(color.substring(1),16),
                    ra = (num >> 16) & 255, ga = (num >> 8) & 255, ba = num & 255,
                    amt = Math.round(2.55 * ratio),
                    R = ((num >> 16) & 255) + amt,
                    G = ((num >> 8) & 255) + amt,
                    B = (num & 255) + amt;
                return "background-image: -moz-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",1) 0%, rgba("+R+","+G+","+B+",0.7) 100%); " +
                    "   background-image: -o-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",1) 0%, rgba("+R+","+G+","+B+",0.7) 100%); " +
                    "   background-image: -webkit-linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",1) 0%, rgba("+R+","+G+","+B+",0.7) 100%); " +
                    "   background-image: linear-gradient(bottom, rgba("+ra+","+ga+","+ba+",1) 0%, rgba("+R+","+G+","+B+",0.7) 100%);"
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
    }).filter('stateProgress', ['StoryStatesByName', function(StoryStatesByName) {
        return function(storyState) {
            var percent;
            switch (storyState) {
                case StoryStatesByName.SUGGESTED:
                    percent = 1;
                    break;
                case StoryStatesByName.ACCEPTED:
                    percent = 2;
                    break;
                case StoryStatesByName.ESTIMATED:
                    percent = 3;
                    break;
                case StoryStatesByName.PLANNED:
                    percent = 4;
                    break;
                case StoryStatesByName.IN_PROGRESS:
                    percent = 5;
                    break;
                case StoryStatesByName.DONE:
                    percent = 6;
                    break;
                default:
                    percent = 0;
            }
            var stateCount = 6;
            return Math.floor((percent / stateCount) * 100);
        }
    }]).filter('dateToIso', ['dateFilter', function(dateFilter) {
        return function (date) {
            return dateFilter(date, 'yyyy-MM-ddTHH:mm:ssZ');
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
                    colorClass = 'text-default';
                    break;
                case AcceptanceTestStatesByName.FAILED:
                    colorClass = 'text-danger';
                    break;
                case AcceptanceTestStatesByName.SUCCESS:
                    colorClass = 'text-success';
                    break;
            }
            return colorClass;
        }
    }]);