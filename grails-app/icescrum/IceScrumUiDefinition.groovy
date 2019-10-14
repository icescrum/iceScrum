import org.icescrum.core.utils.ServicesUtils

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
        help                        default: ''                   | String (i18n key)
        secured                     default: "permitAll()"        | String (spEl expression)
        workspace                   default: "project"            | String (project or portfolio or ...)
        templatePath                default: "windowName/window"  | String (full path to template)
        menu { => default: null
            title                   default: ''                   | String or Closure (i18n key)
            defaultPosition         default:null                  | Integer
        }
        flex =                      default: true                 | true/false
        details =                   default: false                | true/false
        printable =                 default: true                 | true/false
        exportFormats =             default: {[]}                 | Closure return Array of Maps: [name:'i18n.code',params:[]]
        before        =             default:null                  | Closure
    }
 */

windows = {
    // No workspace
    'home' {
        workspace null // Master window : no menu, no workspace
        secured 'isAuthenticated()'
    }
    // Project workspace
    'backlog' {
        details true
        workspace 'project'
        help 'is.ui.backlog.help'
        secured 'stakeHolder() or inProject()'
        menu {
            title 'is.ui.backlogs'
            defaultPosition 2
        }
        exportFormats = {
            [
                    [name: message(code: 'is.report.format.stickynotes'), action: 'printPostits', params: [project: params.project]],
                    [name: message(code: 'is.report.format.pdf'), params: [project: params.project]],
                    [name: message(code: 'is.report.format.rtf'), params: [project: params.project, format: 'RTF']],
                    [name: message(code: 'is.report.format.docx'), params: [project: params.project, format: 'DOCX']],
                    [name: message(code: 'is.report.format.odt'), params: [project: params.project, format: 'ODT']]
            ]
        }
    }
    'feature' {
        details true
        workspace 'project'
        help 'is.ui.feature.help'
        secured 'stakeHolder() or inProject()'
        menu {
            title 'is.ui.feature'
            defaultPosition 5
        }
        exportFormats = {
            [
                    [name: message(code: 'is.report.format.pdf'), params: [project: params.project]],
                    [name: message(code: 'is.report.format.rtf'), params: [project: params.project, format: 'RTF']],
                    [name: message(code: 'is.report.format.docx'), params: [project: params.project, format: 'DOCX']],
                    [name: message(code: 'is.report.format.odt'), params: [project: params.project, format: 'ODT']]
            ]
        }
    }
    'project' {
        workspace 'project'
        flex false
        help 'is.ui.project.help'
        secured 'stakeHolder() or inProject()'
        menu {
            title 'is.ui.project'
            defaultPosition 1
        }
    }
    'planning' {
        details true
        workspace 'project'
        help 'todo.is.ui.planning.help'
        secured 'stakeHolder() or inProject()'
        menu {
            title 'todo.is.ui.planning'
            defaultPosition 3
        }
    }
    'taskBoard' {
        details true
        workspace 'project'
        help 'todo.is.ui.taskBoard.help'
        secured 'inProject() or (isAuthenticated() and stakeHolder())'
        menu {
            title 'todo.is.ui.taskBoard'
            defaultPosition 4
        }
        exportFormats = {
            [
                    [name: "${message(code: 'todo.is.ui.stories')} - ${message(code: 'is.report.format.stickynotes')}", action: "printPostits", resource: 'story', params: ["project": params.project]],
                    [name: "${message(code: 'todo.is.ui.tasks')} - ${message(code: 'is.report.format.stickynotes')}", action: "printPostits", resource: 'task', params: ["project": params.project]]
            ]
        }
    }
}

/*
    'widgetName' {
        title                       default: name                 | String (i18n key or ...)
        secured                     default: "permitAll()"        | String (spEl expression)
        workspace                   default: null                 | String (project or portfolio or ...)
        ngController                default: null                 | String
        templatePath                default: "/widgets/widgetName/widget"| String (full path to template)

        allowDuplicate              default: true                 | true/false
        allowRemove                 default: true                 | true/false
        defaultSettings (=)         default: [:]                  | Map

        onSave                      default: nothing              | Closure(widgetInstance)
        onUpdate                    default: nothing              | Closure(widgetInstance, newSettingsValues)
        onDelete                    default: nothing              | Closure(widgetInstance)

        Others custom settings can be added as field and will be added to options property (Map [fieldName:fieldValue])

        Automatically:
        name                        is.ui.widget. widgetName .name
        help                        is.ui.widget. widgetName .help
        description                 is.ui.widget. widgetName .description
   }
 */

widgets = {
    'feed' {
        height 1
        width 2
        title '{{ holder.feed.title }}'
        secured 'isAuthenticated()'
        ngController 'feedWidgetCtrl'
        defaultSettings = [
                feeds: [
                        [url: 'https://www.icescrum.com/blog/feed/', title: 'iceScrum', selected: true]
                ]
        ]
        onUpdate { widget, settings ->
            settings.feeds?.findAll { !it.title }?.each {
                try {
                    it.title = new XmlSlurper().parse(it.url).channel.title.text()
                } catch (Exception e) {}
            }
            settings.feeds = settings.feeds?.findAll { it.title }.unique { it.url }
        }
    }
    'notes' {
        height 1
        width 2
        secured 'isAuthenticated()'
        defaultSettings = [text: '']
        onUpdate { widget, settings ->
            settings.text_html = ServicesUtils.textileToHtml(settings.text)
        }
    }
    'tasks' {
        height 2
        width 2
        allowDuplicate false
        secured 'isAuthenticated()'
        ngController 'taskWidgetCtrl'
    }
    'chart' {
        height 2
        width 2
        title '<a href="{{ getUrl() }}">{{ getTitle() }}</a>'
        secured 'isAuthenticated()'
        ngController 'projectChartWidgetCtrl'
        defaultSettings = [:]
    }
    'backlogChart' {
        height 1
        width 1
        title '<a href="{{ getUrl() }}">{{ getTitle() }}</a>'
        secured 'isAuthenticated()'
        ngController = "backlogChartWidgetCtrl"
        defaultSettings = [:]
    }
}