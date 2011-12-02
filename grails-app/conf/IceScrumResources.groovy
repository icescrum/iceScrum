/*
 * Copyright (c) 2011 Kagilum / 2010 iceScrum Technlogies.
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
 *
 */
icescrum.theme = 'is'

modules = {

    overrides {

        'jquery-theme' {
            resource id: 'theme', url: [dir: "themes/$icescrum.theme/css", file: 'ui.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        }
    }

    'app-css' {
        resource url: [dir: "themes/$icescrum.theme/css", file: 'reset.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'checkbox.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'styles.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'clearfix.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'forms.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'skin.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'text.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'css3.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'typo.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'bacasable.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie8.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 8]>$s<![endif]-->" }
        resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie7.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 7]>$s<![endif]-->" }
        resource url: [dir: "themes/$icescrum.theme/css", file: 'ie/ie6.css'], attrs: [media: 'screen,projection'], wrapper: { s -> "<!--[if IE 6]>$s<![endif]-->" }
        resource url: [dir: "js/jquery", file: 'jqplot/css/jquery.jqplot.min.css'], attrs: [media: 'screen,projection'], undle: 'icescrum'
    }

    'icescrum' {
        dependsOn 'app-css', 'jquery-plugins'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.form.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.history.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.menubar.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.postit.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.qtip.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.search.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.touch.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.utils.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.widget.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.window.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.wizard.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.progress.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.scrollbar.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.multiFilesUpload.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.functions.js'], bundle: 'icescrum'
    }

    'jqplot' {
        dependsOn 'jquery'
        resource url: [dir: "js/jquery", file: 'excanvas.min.js'], wrapper: { s -> "<!--[if IE]>$s<![endif]-->" }, bundle: 'jquery-plugins'
        resource url: [dir: "js/jquery", file: 'jqplot/jquery.jqplot.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.barRenderer.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.categoryAxisRenderer.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasTextRenderer.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.enhancedLegendRenderer.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.pointLabels.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.cursor.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.highlighter.min.js'], bundle: 'jquery-plugins'
    }

    'jquery-plugins' {
        dependsOn 'jquery'
        resource url: [dir: 'js/jquery', file: 'jquery.pnotify.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.history.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.mousewheel.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.hotkeys.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.dotimeout.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.qtip-1.0.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.eventline.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.dropmenu.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.dnd.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.alphanumeric.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.resize.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.stream-1.2.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.jqote2.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.cookie.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.input.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.tablesorter.min.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.table.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.jeditable.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/markitup', file: 'jquery.markitup.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/markitup/sets/textile', file: 'set.js'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/markitup/sets/textile', file: 'style.css'], attrs: [media: 'screen,projection'], bundle: 'jquery-plugins'
        resource url: [dir: 'js/markitup/skins/simple', file: 'style.css'], attrs: [media: 'screen,projection'], bundle: 'jquery-plugins'
    }

    'jquery-ui-plugins' {
        dependsOn 'jquery-ui'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-en.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-fr.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-es.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-de.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-cn.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery-ui.timepicker.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.checkbox.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.ui.selectmenu.js'], bundle: 'jquery-ui-plugins'
        resource url: [dir: 'js/jquery', file: 'jquery.ui.jeditable.js'], bundle: 'jquery-ui-plugins'
    }
}