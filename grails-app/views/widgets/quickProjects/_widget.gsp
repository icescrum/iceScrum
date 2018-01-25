<is:widget widgetDefinition="${widgetDefinition}">
    <div class="btn-group buttons-margin-bottom" ng-repeat="project in projects">
        <a href="{{:: getProjectUrl(project) }}" class="btn btn-default" role="button">{{ ::project.name }}</a>
        <a href="{{:: getProjectUrl(project, 'backlog') }}" class="btn btn-default" uib-tooltip="${message(code: 'is.ui.backlogs')}" role="button"><i class="fa fa-inbox"></i></a>
        <a href="{{:: getProjectUrl(project, 'taskBoard') }}" class="btn btn-default" uib-tooltip="${message(code: 'todo.is.ui.taskBoard')}" role="button"><i class="fa fa-tasks"></i></a>
    </div>
    <div ng-if="!projects.length && projectsLoaded" class="buttons-margin-bottom">
        <a class="btn btn-primary"
           ui-sref="newProject">
            ${message(code: 'todo.is.ui.project.createNew')}
        </a>
        <button class="btn btn-default"
                type="button"
                click-async="createSampleProject()">
            ${message(code: 'is.ui.project.sample.create')}
        </button>
    </div>
    <hr>
</is:widget>