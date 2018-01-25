<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="publicProjectListCtrl">
        <div ng-if="projects && !projects.length">
            <h4 class="text-center">${message(code: 'todo.is.ui.project.nopublicproject')}</h4>
        </div>
        <div ng-repeat="project in projects" class="row projects-list">
            <div ng-include src="'projects.list.html'"></div>
        </div>
    </div>
</is:widget>