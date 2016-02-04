<script type="text/ng-template" id="tasks.panel.html">
    <div class="panel panel-light" ng-controller="userTaskCtrl">
        <div class="panel-heading" as-sortable-item-handle>
            <h3 class="panel-title"><i class="fa fa-tasks"></i> ${message(code: 'is.panel.mytask')}</h3>
        </div>
        <div class="panel-body" sticky-list sticky-watch="tasksByProject">
            <div class="list-group-container" ng-repeat="entry in tasksByProject track by $index">
                <div class="list-group-header">{{ ::entry.project.name }}</div>
                <div class="postits grid-group clearfix">
                    <div ng-repeat="task in entry.tasks" class="postit-container">
                        <a href="{{ ::serverUrl }}/p/{{ ::entry.project.pkey }}-T{{ ::task.id }}" style="text-decoration: none;">
                            <div ng-include="'task.light.html'"></div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</script>