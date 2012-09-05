/*
* Copyright (c) 2012 Kagilum SAS
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

    'actor' {
        menuBar {
            title 'is.ui.actor'
            defaultVisibility false
            defaultPosition 3
            productDynamicBar true
        }
        window {
            title 'is.ui.actor'
            help 'is.ui.actor.help'
            init 'list'
            toolbar true
        }
        widget {
            title 'is.ui.actor'
            init 'list'
            toolbar true
            resizable = [defaultHeight:143,minHeight:26]
        }
        shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.actor.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.actor.ctrla.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.actor.ctrln.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.actor.space.text']
        ]
    }

    'backlog' {
        menuBar {
            title 'is.ui.backlog'
            defaultVisibility true
            defaultPosition 3
            productDynamicBar true
        }

        window {
            title 'is.ui.backlog'
            help 'is.ui.backlog.help'
            init 'list'
            toolbar true
        }
        widget {
            title 'is.ui.backlog'
            init 'list'
            toolbar false
            resizable = [defaultHeight:143,minHeight:26]
        }
        shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.backlog.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.backlog.ctrla.text'],
            [code: 'is.ui.shortcut.ctrlshiftc.code', text: 'is.ui.shortcut.backlog.ctrlshiftc.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.backlog.space.text']
        ]
    }

    'story' {
        menuBar {
            title 'is.ui.backlogelement'
            show {
                false
            }
        }

        window {
            title 'is.ui.story.details'
            toolbar true
            init 'index'
        }
    }

    'feature' {
        menuBar {
            title 'is.ui.feature'
            defaultVisibility false
            defaultPosition 2
            productDynamicBar true
        }

        window {
            title 'is.ui.feature'
            help 'is.ui.feature.help'
            init 'list'
            toolbar true
        }
        widget {
            title 'is.ui.feature'
            init 'list'
            toolbar true
            resizable = [defaultHeight:143,minHeight:26]
        }

        shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.feature.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.feature.ctrla.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.feature.ctrln.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.feature.space.text']
        ]
    }

    'project' {
        menuBar {
            title 'is.ui.project'
            defaultVisibility true
            defaultPosition 1
            productDynamicBar true
        }

        window {
            title 'is.ui.project'
            help 'is.ui.project.help'
            toolbar true
            init 'dashboard'
        }
    }

    'releasePlan' {
        menuBar {
            title 'is.ui.releasePlan'
            defaultVisibility true
            defaultPosition 4
            productDynamicBar true
        }

        window {
            title 'is.ui.releasePlan'
            help 'is.ui.releasePlan.help'
            init 'index'
            toolbar true
            titleBarContent true
        }
        shortcuts = [
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.releasePlan.ctrln.text'],
            [code: 'is.ui.shortcut.ctrlg.code', text: 'is.ui.shortcut.releasePlan.ctrlg.text'],
            [code: 'is.ui.shortcut.ctrlshifta.code', text: 'is.ui.shortcut.releasePlan.ctrlshifta.text'],
            [code: 'is.ui.shortcut.ctrlshiftv.code', text: 'is.ui.shortcut.releasePlan.ctrlshiftv.text'],
            [code: 'is.ui.shortcut.ctrlshiftd.code', text: 'is.ui.shortcut.releasePlan.ctrlshiftd.text']
        ]
    }

    'sandbox' {
        menuBar {
            title 'is.ui.sandbox'
            defaultVisibility true
            defaultPosition 2
            productDynamicBar true
        }

        window {
            title 'is.ui.sandbox'
            help 'is.ui.sandbox.help'
            init 'list'
            toolbar true
        }
        widget {
            title 'is.ui.sandbox'
            init 'list'
            toolbar true
            resizable = [defaultHeight:143,minHeight:26]
        }
        shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.sandbox.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.sandbox.ctrla.text'],
            [code: 'is.ui.shortcut.ctrlshifta.code', text: 'is.ui.shortcut.sandbox.ctrlshifta.text'],
            [code: 'is.ui.shortcut.ctrlshiftc.code', text: 'is.ui.shortcut.sandbox.ctrlshiftc.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.sandbox.ctrln.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.sandbox.space.text']
        ]
    }

    'sprintPlan' {
        menuBar {
            title 'is.ui.sprintPlan'
            defaultVisibility true
            defaultPosition 5
            productDynamicBar true
        }

        window {
            title 'is.ui.sprintPlan'
            help 'is.ui.sprintPlan.help'
            toolbar true
            titleBarContent true
        }
        shortcuts = [
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.sprintPlan.del.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.sprintPlan.ctrln.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.sprintPlan.ctrla.text'],
            [code: 'is.ui.shortcut.ctrlshifta.code', text: 'is.ui.shortcut.sprintPlan.ctrlshifta.text'],
            [code: 'is.ui.shortcut.ctrlshiftc.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftc.text'],
            [code: 'is.ui.shortcut.ctrlshiftd.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftd.text'],
            [code: 'is.ui.shortcut.ctrlshiftr.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftr.text']
        ]
    }

    'timeline' {
        menuBar {
            title 'is.ui.timeline'
            defaultVisibility false
            defaultPosition 1
            productDynamicBar true
        }

        window {
            title 'is.ui.timeline'
            help 'is.ui.timeline.help'
            toolbar true
            titleBarContent true
        }
        shortcuts = [
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.timeline.ctrln.text']
        ]
    }

    'user' {
        window {
            title 'is.user'
            toolbar false
            init 'profile'
        }
    }

    'finder' {
        menuBar {
            title 'is.ui.finder'
            defaultVisibility false
            defaultPosition 4
            productDynamicBar true
        }
        window {
            title 'is.ui.finder'
            toolbar true
            init 'list'
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
            title 'is.ui.task.details'
            toolbar true
            init 'index'
        }
    }
}