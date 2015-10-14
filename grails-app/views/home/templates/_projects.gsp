<script type="text/ng-template" id="projects.html">
    <div class="panel panel-primary" ng-controller="projectListCtrl">
        <div class="panel-heading">
            <h3 class="panel-title">${message(code: 'is.panel.project.public')}</h3>
        </div>
        <uib-accordion>
            <uib-accordion-group is-open="openedProjects[project.id]"
                                 ng-repeat="project in projects">
                <uib-accordion-heading>
                    {{ project.name }}
                    <button type="button"
                            class="btn btn-default"
                            ng-click="$event.stopPropagation(); openProject(project)"
                            uib-tooltip="${message(code:'todo.is.ui.project.open')}"
                            tooltip-append-to-body="true"
                            tooltip-placement="top">
                        <span class="fa fa-expand"></span>
                    </button>
                </uib-accordion-heading>
                <div ng-include="'project.details.html'"></div>
            </uib-accordion-group>
        </uib-accordion>
    </div>
</script>