/*
 * Copyright (c) 2011 Kagilum.
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
    'app-css' {
        resource url: [dir: "css", file: 'jquery-ui-1.10.4.custom.min.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'jquery.atwho.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'bootstrap.min.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "themes/$icescrum.theme/css", file: 'todc-bootstrap.min.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'font-awesome.min.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'select2.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'select2-bootstrap.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'jquery.jqplot.min.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'angular-hotkeys.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'angular-colorpicker.css'], attrs: [media: 'print,screen,projection'], bundle: 'icescrum'
        resource url: [dir: "css", file: 'styles.less'], attrs: [rel: "stylesheet/less", type:'css', media: 'print,screen,projection'], bundle: 'icescrum'
    }

    'icescrum' {
        dependsOn 'app-css', 'jquery-plugins'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.menubar.js'], bundle: 'icescrum'
        //todo remove ?
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.utils.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.widget.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.window.js'], bundle: 'icescrum'
        //todo remove
        resource url: [dir: 'js/jquery', file: 'jquery.html5data.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.unobtrusive-ajax.js'], bundle: 'icescrum'
        resource url: [dir: 'js/lib', file: 'dropzone.js'], bundle: 'icescrum'
        resource url: [dir: 'js/lib', file: 'underscore.js'], bundle: 'icescrum'
        resource url: [dir: 'js/lib', file: 'underscore.string.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/lib', file: 'fastclick.js'], bundle: 'icescrum'
    }

    'objects' {
        dependsOn 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.object.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.attachment.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.project.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.release.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.sprint.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.story.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.task.js'], bundle: 'icescrum'
        resource url: [dir: 'js/icescrum', file: 'jquery.icescrum.user.js'], bundle: 'icescrum'
    }

    'jquery' {
        resource url:[dir:'js/jquery', file:"jquery-1.11.0.min.js"], disposition:'head'
        resource url:[dir:'js/jquery', file:"jquery-migrate-1.2.1.min.js"], disposition:'head'
        resource url:[dir:'js/jquery', file:"jquery-ui-1.10.4.custom.min.js"], bundle: 'icescrum'
    }

    'bootstrap' {
        dependsOn 'jquery'
        resource url:[dir:'js/lib', file:"bootstrap.min.js"], disposition:'head'
    }

    'angularjs' {
        resource url:[dir:'js/angularjs/lib', file:"angular.min.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-route.min.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-resource.min.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-elastic.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-bootstrap-0.11.0.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-router.min.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-select2.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-colorpicker.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-selectable.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-ui-sortable.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-hotkeys.js"], disposition:'head'
        resource url:[dir:'js/angularjs/lib', file:"angular-password-strength.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app', file:"controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app', file:"services.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app', file:"filters.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app', file:"directives.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app', file:"app.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/user', file:"user.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/user', file:"user.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/project', file:"project.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/project', file:"project.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/story', file:"story.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/story', file:"story.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/actor', file:"actor.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/actor', file:"actor.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/feature', file:"feature.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/feature', file:"feature.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/task', file:"task.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/task', file:"task.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/comment', file:"comment.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/comment', file:"comment.services.js"], disposition:'head'

        resource url:[dir:'js/angularjs/app/acceptanceTest', file:"acceptanceTest.controllers.js"], disposition:'head'
        resource url:[dir:'js/angularjs/app/acceptanceTest', file:"acceptanceTest.services.js"], disposition:'head'

        resource url:[dir:'js/lib', file:"bootstrap-wizard.min.js"], disposition:'head'
    }

    'jqplot' {
        dependsOn 'jquery'
        resource url: [dir: "js/jquery", file: 'jqplot/jquery.jqplot.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.barRenderer.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.categoryAxisRenderer.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasTextRenderer.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.enhancedLegendRenderer.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.pointLabels.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.cursor.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.highlighter.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jqplot/plugins/jqplot.toImage.js'], bundle: 'icescrum'
    }

    'jquery-plugins' {
        dependsOn 'jquery'
        resource url: [dir: 'js/jquery', file: 'jquery-ui.selectableScroll.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.dotimeout.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.atmosphere.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.timeago.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.timeago.fr.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.notify.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.fullscreen.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.select2.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.select2.fr.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.caret.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.atwho.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/jquery', file: 'jquery.autoellipsis-1.0.10.min.js'], bundle: 'icescrum'
        resource url: [dir: 'js/markitup', file: 'jquery.markitup.js'], bundle: 'icescrum'
        resource url: [dir: 'js/markitup/sets/textile', file: 'set.js'], bundle: 'icescrum'
    }
}