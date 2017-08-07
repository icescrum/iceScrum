<is:widget widgetDefinition="${widgetDefinition}">
    <div sticky-list>
        <div class="list-group-container" ng-repeat="entry in tasksByProject track by $index">
            <div class="list-group-header sticky-header">{{ ::entry.project.name }}</div>
            <div class="postits clearfix" postits-screen-size>
                <div ng-repeat="task in entry.tasks" class="postit-container">
                    <a href="{{ task.uid | permalink:'task':entry.project.pkey }}" style="text-decoration: none;">
                        <div ng-include="'task.light.html'"></div>
                    </a>
                </div>
            </div>
        </div>
    </div>
</is:widget>