<is:widget widgetDefinition="${widgetDefinition}">
    <div sticky-list>
        <div ng-repeat="entry in tasksByProject track by $index">
            <div class="list-group-header sticky-header">{{ ::entry.project.name }}</div>
            <div class="postits clearfix" postits-screen-size>
                <div ng-repeat="task in entry.tasks" class="postit-container">
                    <div ng-include="'task.light.html'" ng-init="link = taskUrl(task, entry.project);"></div>
                </div>
            </div>
        </div>
    </div>
</is:widget>