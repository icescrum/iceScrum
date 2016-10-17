<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="publicProjectListCtrl">
        <uib-accordion>
            <div uib-accordion-group
                 is-open="openedProjects[currentProject.id]"
                 ng-repeat="currentProject in projects">
                <uib-accordion-heading>
                    {{ currentProject.name }}
                    <button type="button"
                            style="margin: -2px 4px 0 0"
                            class="pull-right btn btn-xs btn-default"
                            ng-click="$event.stopPropagation(); $event.preventDefault(); openProject(currentProject)"
                            uib-tooltip="${message(code:'todo.is.ui.project.open')}">
                        <i class="fa fa-expand"></i>
                    </button>
                </uib-accordion-heading>
                <div ng-if="currentProject.id == project.id"
                     ng-include="'project.details.html'">
                </div>
            </div>
        </uib-accordion>
    </div>
</is:widget>