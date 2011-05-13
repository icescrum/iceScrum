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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

icescrum.theme = 'is'

modules = {

  overrides {
     'jquery' {
        resource id:'js', url: [plugin: 'jquery', dir:'js/jquery', file:"jquery-1.5.1.min.js"]
     }

     'jquery-ui' {
          resource id:'js', disposition: 'head'
          resource id:'theme', url: [dir: "themes/$icescrum.theme/css", file: 'ui.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
     }
  }

  'app-css' {
    resource url: [dir: "themes/$icescrum.theme/css", file: 'reset.css'], attrs: [media: 'screen,projection'], bundle:'icescrum'
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

  'icescrum' {
    dependsOn 'app-css', 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.js'],disposition: 'head', bundle:'icescrum'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.postit.js'], disposition: 'head', bundle:'icescrum'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.multiFilesUpload.js'], disposition: 'head', bundle:'icescrum'
  }

  'qtip' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.qtip-1.0.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'history' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.history.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'pnotify' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.pnotify.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'ui-selectmenu' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.ui.selectmenu.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'mousewheel' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.mousewheel.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'hotkeys' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.hotkeys.js'],disposition: 'head',bundle:'jquery-plugins'
  }

  'dotimeout' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.dotimeout.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'jqplot' {
    dependsOn 'jquery'
    resource url: [dir: "js/jquery", file: 'excanvas.min.js'], wrapper: { s -> "<!--[if IE]>$s<![endif]-->" },disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: "js/jquery", file: 'jqplot/css/jquery.jqplot.min.css'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: "js/jquery", file: 'jqplot/jquery.jqplot.min.js'],disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.barRenderer.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.categoryAxisRenderer.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasTextRenderer.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.enhancedLegendRenderer.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.pointLabels.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.cursor.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.highlighter.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'eventline' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.eventline.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'browser' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'browser/const.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'progress' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.progress.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'table' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.table.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'dropmenu' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.dropmenu.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'jeditable' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.jeditable.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'ui-jeditable' {
    dependsOn 'jeditable'
    resource url: [dir: 'js/jquery', file: 'jquery.ui.jeditable.js'], disposition: 'head',bundle:'jquery-plugins'
  }
  'input' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.input.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'dnd' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.dnd.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'checkbox' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.checkbox.js'],disposition: 'head',bundle:'jquery-plugins'
  }
  'alphanumeric' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.alphanumeric.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'markitup' {
    resource url: [dir: 'js/markitup', file: 'jquery.markitup.js'],disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/markitup/sets/textile', file: 'set.js'],disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/markitup/sets/textile', file: 'style.css'], attrs:[media: 'screen,projection'],disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/markitup/skins/simple', file: 'style.css'], attrs:[media: 'screen,projection'],disposition: 'head',bundle:'jquery-plugins'
  }
  'resize' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.resize.min.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }
  'scrollbar' {
    dependsOn 'jquery'
    resource url: [dir: 'js/jquery', file: 'jquery.icescrum.scrollbar.js'],disposition: 'head',bundle:'jquery-plugins'
  }

  'datepicker-locales' {
    dependsOn 'jquery-ui'
    resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-en.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-fr.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-de.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-es.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
    resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-cn.js'], nominify: true,disposition: 'head',bundle:'jquery-plugins'
  }

  'timepicker' {
    dependsOn 'jquery-ui'
    resource url: [dir: 'js/jquery', file: 'jquery-ui.timepicker.js'], disposition: 'head',bundle:'jquery-plugins'
  }
}