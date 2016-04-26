/*
* Copyright (c) 2015 Kagilum SAS
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
* Nicolas Noullet (nnoullet@kagilum.com)
* Vincent BARRIER (vbarrier@kagilum.com)
*
*/


/*
    'windowName' {
        icon                        default: ''                   | String (fontawesome)
        title                       default: ''                   | String (i18n key)
        help                        default: ''                   | String (i18n key)
        secured                     default: "permitAll()"        | String (spEl expression)
        context                     default: "product"            | String (product or ...)
        templatePath                default: "windowName/window"  | String (full path to template)
        menu { => default: null
            defaultPosition         default:null                  | Integer
            defaultVisibility       default:null                  | true/false
        }
        flex =                      default: true                 | true/false
        details =                   default: false                | true/false
        printable =                 default: true                 | true/false
        fullScreen =                default: true                 | true/false
        exportFormats =             default: []                   | Array of Maps: [code:extension,name:'i18n.code',params:[]]
        before        =             default:null                  | Closure
    }
 */

windows = {
    //Master window : no menu, no context
    'home' {
        context null
    }
    'backlog' {
        details true
        context 'product'
        icon    'inbox'
        help    'is.ui.backlog.help'
        title   'is.ui.backlogs'
        secured 'stakeHolder() or inProduct()'
        menu {
            defaultPosition 2
            defaultVisibility true
            title 'is.ui.backlogs'
        }
        embedded = [
                view:'list',
                viewTypes:['postits','table']
        ]
        exportFormats = {
            [
                [code:'rtf',name:message(code:'is.report.format.rtf'), params:[product:params.product, format:'RTF']],
                [code:'docx',name:message(code:'is.report.format.docx'), params:[product:params.product, format:'DOCX']],
                [code:'odt',name:message(code:'is.report.format.odt'), params:[product:params.product, format:'ODT']]
            ]
        }
    }
    'feature' {
        details true
        context 'product'
        icon    'puzzle-piece'
        help    'is.ui.feature.help'
        title   'is.ui.feature'
        secured 'isAuthenticated()'
        menu {
            defaultPosition 5
            defaultVisibility true
            title 'is.ui.feature'
        }
        embedded = [
                view:'list',
                viewTypes:['postits','table','productParkingLotChart']
        ]
        exportFormats = {
            [[code:'rtf',name:message(code:'is.report.format.rtf'), params:[product:params.product, format:'RTF']],
                    [code:'docx',name:message(code:'is.report.format.docx'), params:[product:params.product, format:'DOCX']],
                    [code:'odt',name:message(code:'is.report.format.odt'), params:[product:params.product, format:'ODT']]]
        }
    }
    'project' {
        context 'product'
        flex    false
        icon    'dashboard'
        help    'is.ui.project.help'
        title   'is.ui.project'
        menu {
            defaultPosition 1
            defaultVisibility true
            title 'is.ui.project'
        }
        embedded = [
                view:'productCumulativeFlowChart',
                viewTypes:['productCumulativeFlowChart','productVelocityCapacityChart','productBurnupChart','productBurndownChart','productVelocityChart','productParkingLotChart'],
        ]
        exportFormats = {
            [
                    [code:'pdf',name:message(code:'is.report.format.pdf'), action:'printPostits', params:[product:params.product, format:'PDF']],
                    [code:'rtf',name:message(code:'is.report.format.rtf'), params:[product:params.product, format:'RTF', locationHash:params.actionWindow?:'']],
                    [code:'docx',name:message(code:'is.report.format.docx'), params:[product:params.product, format:'DOCX', locationHash:params.actionWindow?:'']],
                    [code:'odt',name:message(code:'is.report.format.odt'), params:[product:params.product, format:'ODT', locationHash:params.actionWindow?:'']]
            ]
        }
    }
    'planning' {
        details true
        context 'product'
        icon    'calendar'
        help    'todo.is.ui.planning.help'
        title   'todo.is.ui.planning'
        secured '(isAuthenticated() and stakeHolder()) or inProduct()'
        menu {
            defaultPosition 3
            defaultVisibility true
            title 'todo.is.ui.planning'
        }
        embedded = [
                view:'index',
                viewTypes:['postits','notes','releaseBurndownChart','releaseParkingLotChart'],
                id:{ product ->
                    def id = [label:message(code:'is.release'), select:[[key:'', value:message(code:'is.ui.releasePlan.id.empty')]]]
                    product.releases?.sort({a, b -> a.orderNumber <=> b.orderNumber} as Comparator)?.each {
                        id.select << [key:it.id, value:"${it.name}"]
                    }
                    id
                }
        ]
    }
    'taskBoard' {
        details true
        context 'product'
        icon    'tasks'
        help    'todo.is.ui.taskBoard.help'
        title   'todo.is.ui.taskBoard'
        secured 'inProduct() or (isAuthenticated() and stakeHolder())'
        menu {
            defaultPosition 4
            defaultVisibility true
            title 'todo.is.ui.taskBoard'
        }
        embedded = [
                view:'index',
                viewTypes:['postits','table','notes','sprintBurndownRemainingChart','sprintBurnupTasksChart','sprintBurnupStoriesChart','sprintBurnupPointsChart'],
                id:{ product ->
                    def id = [label:message(code:'is.sprint'), select:[[key:'', value:message(code:'is.ui.sprintPlan.id.empty')]]]
                    product.releases?.sort({a, b -> a.orderNumber <=> b.orderNumber} as Comparator)?.each {
                        it.sprints?.collect {v -> id.select << [key:v.id, value:"${it.name} - Sprint ${v.orderNumber}"]}
                    }
                    id
                }
        ]
        exportFormats = {
            [
                    [code:'pdf',name:message(code:'is.report.format.pdf'), action:'printPostits', params:[product:params.product, format:'PDF', id:params.id]],
                    [code:'rtf',name:message(code:'is.report.format.rtf'), params:[product:params.product, format:'RTF', id:params.id]],
                    [code:'docx',name:message(code:'is.report.format.docx'), params:[product:params.product, format:'DOCX', id:params.id]],
                    [code:'odt',name:message(code:'is.report.format.odt'), params:[product:params.product, format:'ODT', id:params.id]]
            ]
        }
    }
    'search' {
        context 'product'
        icon    'search'
        title   'is.ui.search'
        menu {
            defaultPosition 1
            defaultVisibility false
            title 'is.ui.search'
        }
    }
}

/*
    'widgetName' {
        icon                        default: ''                   | String (fontawesome)
        title                       default: ''                   | String (i18n key)
        help                        default: ''                   | String (i18n key)
        secured                     default: "permitAll()"        | String (spEl expression)
        context                     default: null                 | String (product or ...)
        templatePath                default: "widgetName/window"  | String (full path to template)
    }
 */

widgets = {
    'feed' {
        icon    'rss'
        title   'is.panel.feed'
        secured 'isAuthenticated()'
    }
    'login' {
        icon    'user'
        title   'is.dialog.login'
        secured '!isAuthenticated()'
        templatePath '/widgets/login'
     }
    'notes' {
        icon    'pencil-square-o'
        title   'is.panel.notes'
        secured 'isAuthenticated()'
        templatePath '/widgets/notes'
    }
    'publicProjects' {
        icon    'folder-open'
        title   'is.panel.project.public'
        templatePath '/widgets/publicProjects'
    }
    'mood' {
        icon    'smile-o'
        title   'is.panel.mood'
        secured 'isAuthenticated()'
        templatePath '/widgets/mood'
    }
    'tasks' {
        icon 'tasks'
        title 'is.panel.mytask'
        secured 'isAuthenticated()'
        templatePath '/widgets/tasks'
    }
    'userProjects' {
        secured 'isAuthenticated()'
        templatePath '/widgets/quickProjects'
    }
}