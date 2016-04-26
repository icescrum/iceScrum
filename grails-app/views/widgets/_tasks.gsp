<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="userTaskCtrl" sticky-list>
        <div class="list-group-container" ng-repeat="entry in tasksByProject track by $index">
            <div class="list-group-header sticky-header">{{ ::entry.project.name }}</div>
            <div class="postits grid-group clearfix">
                <div ng-repeat="task in entry.tasks" class="postit-container">
                    <a href="{{ ::serverUrl }}/{{ ::entry.project.pkey }}-T{{ ::task.id }}" style="text-decoration: none;">
                        <div ng-include="'task.light.html'"></div>
                    </a>
                </div>
                <div ng-repeat="task in entry.tasks" class="postit-container">
                    <a href="{{ ::serverUrl }}/{{ ::entry.project.pkey }}-T{{ ::task.id }}" style="text-decoration: none;">
                        <div ng-include="'task.light.html'"></div>
                    </a>
                </div>
                <div ng-repeat="task in entry.tasks" class="postit-container">
                    <a href="{{ ::serverUrl }}/{{ ::entry.project.pkey }}-T{{ ::task.id }}" style="text-decoration: none;">
                        <div ng-include="'task.light.html'"></div>
                    </a>
                </div>
            </div>
        </div>
    </div>
</is:widget>