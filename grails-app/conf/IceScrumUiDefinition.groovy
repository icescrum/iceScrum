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
*
*/

windows = {
    'backlog' {
        init 'view'
        details true
        icon = 'fa fa-inbox'
        title 'is.ui.backlogs'
        help 'is.ui.backlog.help'
        menu {
            title 'is.ui.backlogs'
            defaultVisibility true
            defaultPosition 2
            spaceDynamicBar true
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
        init 'view'
        details true
        title 'is.ui.feature'
        help 'is.ui.feature.help'
        icon = 'fa fa-puzzle-piece'
        menu {
            title 'is.ui.feature'
            defaultVisibility true
            defaultPosition 5
            spaceDynamicBar true
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
        flex false
        init 'view'
        title 'is.ui.project'
        icon = 'fa fa-dashboard'
        help 'is.ui.project.help'
        menu {
            title 'is.ui.project'
            defaultVisibility true
            defaultPosition 1
            spaceDynamicBar true
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
        init 'view'
        icon = 'fa fa-calendar'
        title 'todo.is.ui.planning'
        help 'todo.is.ui.planning.help'
        menu {
            title 'todo.is.ui.planning'
            defaultVisibility true
            defaultPosition 3
            spaceDynamicBar true
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
        init 'view'
        details true
        icon = 'fa fa-tasks'
        title 'todo.is.ui.taskBoard'
        help 'todo.is.ui.taskBoard.help'
        menu {
            title 'todo.is.ui.taskBoard'
            defaultVisibility true
            defaultPosition 4
            spaceDynamicBar true
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
        init 'index'
        title 'is.ui.search'
        icon = 'fa fa-search'
        menu {
            title 'is.ui.search'
            defaultVisibility false
            defaultPosition 1
            spaceDynamicBar true
        }
    }
}

widgets = {
    'chart' {
        title 'is.ui.widget.chart.title'
    }
    'feeds' {
        title 'is.ui.widget.feedsdd.title'
    }
}