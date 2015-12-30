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

uiDefinitions = {
    'backlog' {
        icon = 'fa fa-inbox'
        menuBar {
            title 'is.ui.backlog'
            defaultVisibility true
            defaultPosition 2
            spaceDynamicBar true
        }
        window {
            details true
            init 'view'
            title 'is.ui.backlog'
            help 'is.ui.backlog.help'
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
    'story' {
        menuBar {
            title 'is.ui.backlogelement'
            show {
                false
            }
        }
        window {
            init 'index'
            title 'is.ui.story.details'
        }
    }
    'feature' {
        icon = 'fa fa-puzzle-piece'
        menuBar {
            title 'is.ui.feature'
            defaultVisibility true
            defaultPosition 5
            spaceDynamicBar true
        }
        window {
            details true
            init 'view'
            title 'is.ui.feature'
            help 'is.ui.feature.help'
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
        icon = 'fa fa-dashboard'
        menuBar {
            title 'is.ui.project'
            defaultVisibility true
            defaultPosition 1
            spaceDynamicBar true
        }
        window {
            flex false
            init 'view'
            title 'is.ui.project'
            help 'is.ui.projedt.help'
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
    'releasePlan' {
        icon = 'fa fa-calendar'
        menuBar {
            title 'is.ui.releasePlan'
            defaultVisibility true
            defaultPosition 3
            spaceDynamicBar true
        }
        window {
            details true
            init 'view'
            title 'is.ui.releasePlan'
            help 'is.ui.releasePlan.help'
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
    'sprintPlan' {
        icon = 'fa fa-tasks'
        menuBar {
            title 'is.ui.sprintPlan'
            defaultVisibility true
            defaultPosition 4
            spaceDynamicBar true
        }
        window {
            details true
            init 'view'
            title 'is.ui.sprintPlan'
            help 'is.ui.sprintPlan.help'
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
    'finder' {
        icon = ' fa fa-search'
        menuBar {
            title 'is.ui.finder'
            defaultVisibility false
            defaultPosition 1
            spaceDynamicBar true
        }
        window {
            init 'index'
            title 'is.ui.finder'
        }
    }
    'task' {
        menuBar {
            title 'is.ui.backlogelement'
            show {
                false
            }
        }
        window {
            init 'index'
            title 'is.ui.task.details'
        }
    }
}