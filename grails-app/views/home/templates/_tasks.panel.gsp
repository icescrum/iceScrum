<script type="text/ng-template" id="tasks.panel.html">
<div class="panel panel-primary" ng-controller="userTaskCtrl">
        <div class="panel-heading">
            ${message(code: 'is.panel.mytask')}
        </div>
        <accordion ng-repeat="(project, tasks) in tasksByProject">
            {{project}}
            <accordion-group heading="{{task.uid }} - {{task.name }}" ng-repeat="task in tasks">
                <table>
                    <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.creationDate}}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.estimation }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Etat')} : {{task.state | i18n:'TaskStates' }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Description')} : {{ task.description }}</td></tr>
                    <tr><td>${message(code: 'is.panel.task.Story')} : {{ task.parentStory.name }}</td></tr>
                </table>
            </accordion-group>
        </accordion>
    </div>
</script>