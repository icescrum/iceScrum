<script type="text/ng-template" id="tasks.panel.html">
<div class="panel panel-primary" ng-controller="userTaskCtrl">
        <div class="panel-heading">
            ${message(code: 'is.panel.mytask')}
        </div>
        <uib-accordion ng-repeat="entry in tasksByProject">
            {{ entry.project.name }}
            <button type="button"
                    class="btn btn-default"
                    ng-click="$event.stopPropagation(); openProject(entry.project)"
                    uib-tooltip="${message(code:'todo.is.ui.project.open')}"
                    tooltip-append-to-body="true"
                    tooltip-placement="top">
                <span class="fa fa-expand"></span>
            </button>
            <uib-accordion-group heading="{{task.uid }} - {{task.name }}" ng-repeat="task in entry.tasks">
                <table>
                    <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.creationDate}}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.estimation }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Etat')} : {{task.state | i18n:'TaskStates' }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Description')} : {{ task.description }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Story')} : {{ task.parentStory.name }}</td></tr>
                </table>
            </uib-accordion-group>
        </uib-accordion>
    </div>
</script>