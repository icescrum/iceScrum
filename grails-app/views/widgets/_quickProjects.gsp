<is:widget widgetDefinition="${widgetDefinition}">
    <div class="btn-group" ng-repeat="project in projects">
        <a href="{{:: getProjectUrl(project) }}" class="btn btn-default" role="button">{{ ::project.name }}</a>
        <a href="{{:: getProjectUrl(project, 'backlog') }}" class="btn btn-default" uib-tooltip="${message(code: 'is.ui.backlogs')}" role="button"><i class="fa fa-inbox"></i></a>
        <a href="{{:: getProjectUrl(project, 'taskBoard') }}" class="btn btn-default" uib-tooltip="${message(code: 'todo.is.ui.taskBoard')}" role="button"><i class="fa fa-tasks"></i></a>
    </div>
    <div ng-if="!projects.length && projectsLoaded">
        <button class="btn btn-primary"
                type="button"
                click-async="createSampleProject()">
            ${message(code: 'todo.is.ui.project.createSample')}
        </button>
    </div>
    <hr>
</is:widget>