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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
icescrum.theme = 'is'

modules = {


    'jquery-theme' {
        resource id: 'theme', url: [dir: "themes/$icescrum.theme/css", file: 'ui.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
    }

    'app-css' {
        dependsOn 'jquery-theme'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'reset.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'checkbox.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'styles.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'clearfix.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'forms.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'skin.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'text.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'css3.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'typo.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "js/jquery", file: 'jqplot/css/jquery.jqplot.min.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'bacasable.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
    }

    'icescrum' {
        dependsOn 'app-css', 'jquery-plugins', 'jquery-ui-plugins'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.form.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.menubar.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.postit.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.search.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.utils.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.widget.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.window.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.wizard.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.progress.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.scrollbar.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.multiFilesUpload.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.functions.js'], bundle: 'icescrum'
    }

    'jquery' {
        resource url:[dir:'js/jquery', file:"jquery-1.8.2.min.js"], nominify: true, disposition:'head'
    }

    'jquery-ui' {
        dependsOn 'jquery', 'jquery-theme'
        resource url:[dir:'js/jquery', file:"jquery-ui-1.8.23.custom.min.js"], nominify: true, bundle: 'icescrum'
    }

    'jquery-ui-plugins' {
        dependsOn 'jquery-ui'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-en.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-en_US.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-fr.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-es.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-de.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-ru.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-cn.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-pt.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery/datepicker', file: 'jquery.ui.datepicker-pt_BR.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery-ui.timepicker.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.checkbox.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.ui.selectmenu.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.ui.jeditable.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.ui.touch-punch.min.js'], nominify: true, bundle: 'icescrum'
    }

    'jqplot' {
        dependsOn 'jquery'
        resource url: [dir: 'js/jquery', file: 'jquery.unobtrusive-ajax.js'], bundle: 'icescrum'
        resource url: [dir: "js/jquery", file: 'jqplot/excanvas.min.js'],  nominify: true, wrapper: { s -> "<!--[if IE]>$s<![endif]-->" }, bundle: 'icescrum'
        resource url: [dir: "js/jquery", file: 'jqplot/jquery.jqplot.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.barRenderer.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.categoryAxisRenderer.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasTextRenderer.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.enhancedLegendRenderer.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.pointLabels.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.cursor.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.highlighter.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.toImage.js'], bundle: 'icescrum'
    }

    'jquery-plugins' {
        dependsOn 'jquery'
        resource url: [dir: 'js/jquery', file: 'jquery.pnotify.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.history.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.mousewheel.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.hotkeys.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.dotimeout.min.js'],nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.tipTip.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.eventline.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.dropmenu.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.dnd.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.alphanumeric.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.resize.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.atmosphere.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.jqote2.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.cookie.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.input.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.tablesorter.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.table.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.jeditable.min.js'], nominify:true, bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.fullscreen.min.js'], nominify: true, bundle: 'icescrum'
        resource url: [dir: 'js/markitup', file: 'jquery.markitup.js'], bundle: 'icescrum'
        resource url: [dir: 'js/markitup/sets/textile', file: 'set.js'], bundle: 'icescrum'
        resource url: [dir: 'js/markitup/sets/textile', file: 'style.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: 'js/markitup/skins/simple', file: 'style.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
    }

    'tagit' {
        dependsOn 'jquery-ui'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'tagit.css'], attrs: [media: 'screen,projection'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.tagit.js'], bundle: 'icescrum'
    }
}