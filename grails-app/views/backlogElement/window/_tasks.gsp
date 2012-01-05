
<is:panelTab id="tasks" selected="${params.tab && 'tasks' in params.tab ? 'true' : ''}">
    <g:if test="${story.tasks}">
        <is:tableView>
            <is:table id="task-table">
                <is:tableHeader name="${message(code:'is.task.name')}"/>
                <is:tableHeader name="${message(code:'is.task.estimation')}"/>
                <is:tableHeader name="${message(code:'is.task.creator')}"/>
                <is:tableHeader name="${message(code:'is.task.responsible')}"/>
                <is:tableHeader name="${message(code:'is.task.state')}"/>

                <is:tableRows in="${story.tasks}" rowClass="${{task -> task.blocked?'ico-task-1':''}}"
                              var="task">
                    <is:tableColumn>${task.name.encodeAsHTML()}</is:tableColumn>
                    <is:tableColumn>${task.estimation >= 0 ? task.estimation : '?'}</is:tableColumn>
                    <is:tableColumn>${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}</is:tableColumn>
                    <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
                    <is:tableColumn>${is.bundle(bundle: 'taskStates', value: task.state)}</is:tableColumn>
                </is:tableRows>
            </is:table>
        </is:tableView>
    </g:if>
    <g:else><div
            class="panel-box-empty">${message(code: 'is.ui.backlogelement.activity.task.no')}</div></g:else>
</is:panelTab>