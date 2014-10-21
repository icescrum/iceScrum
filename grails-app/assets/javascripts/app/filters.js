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

var filters = angular.module('filters', []);

filters
    .filter('userFullName', function() {
        return function(user) {
            return user ? user.firstName+' '+user.lastName : '';
        };
    })
    .filter('userAvatar', ['$rootScope', function($rootScope) {
        return function(user) {
            return user ?  ($rootScope.serverUrl + '/user/avatar/'+ user.id + '?test=' + new Date(user.lastUpdated).getTime()) : $rootScope.serverUrl + '/assets/avatars/avatar.png';
        };
    }])
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
        };
    })
    .filter('descriptionHtml', function() {
        return function(story) {
            return story.description ? story.description.formatLine().replace(/A\[(.+?)-(.*?)\]/g, '<a href="#/actor/$1">$2</a>') : "";
        };
    })
    .filter('i18n', ['StoryStates', 'FeatureStates', function(StoryStates, FeatureStates) {
        return function(id, type){
            if (type == 'storyState'){
                return StoryStates[id].value;
            }
            if (type == 'featureState') {
                return FeatureStates[id].value;
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
        return function(id) {
            return $rootScope.serverUrl + '/'+ Session.project.pkey +'-' + id;
        };
    }])
    .filter('flowFilesNotCompleted', function () {
        return function (items) {
            var filtered = [];
            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                if (!item.isComplete()) {
                    filtered.push(item);
                }
            }
            return filtered;
        };
    });
