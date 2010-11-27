/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

icescrum.theme = 'is'

modules = {
  'app-css' {
    resource url: [dir: "themes/$icescrum.theme/css", file: 'reset.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'ui.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'checkbox.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'styles.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'clearfix.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'forms.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'skin.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'text.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'css3.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'typo.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'bacasable.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
    resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie8.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 8]>$s<![endif]-->" }
    resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie7.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 7]>$s<![endif]-->" }
    resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie6.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 6]>$s<![endif]-->" }
  }
  //'timeline' {
  //  resource url: [dir: 'js/timeline/timeline_ajax', file: 'simile-ajax-api.js?bundle=true'], defaultBundle : false, nohashandcache:true, disposition: 'head'
  //  resource url: [dir: 'js/timeline/timeline_js', file: 'timeline-api.js?bundle=true'], defaultBundle : false, nohashandcache:true, disposition: 'head'
  //  resource url: [dir: 'js/timeline', file: 'icescrum-painter.js'],disposition: 'head'
  //}
  'icescrum' {
    dependsOn 'app-css', 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.js'], disposition: 'head',bundle:'icescrum'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.postit.js'], disposition: 'head',bundle:'icescrum'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.multiFilesUpload.js'], disposition: 'head',bundle:'icescrum'
  }
}