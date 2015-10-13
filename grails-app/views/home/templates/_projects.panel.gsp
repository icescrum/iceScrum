<script type="text/ng-template" id="projects.panel.html">
    <div class="panel panel-primary" ng-controller="projectListCtrl" ng-init="type='user'">
        <div class="panel-heading">
            ${message(code: 'is.panel.myprojects')}
        </div>
        <accordion>
            <accordion-group is-open="openedProjects[project.id]"
                             ng-repeat="project in projects">
                <accordion-heading>
                    {{ project.name }}
                    <button type="button"
                            class="btn btn-default"
                            ng-click="$event.stopPropagation(); openProject(project)"
                            tooltip="${message(code:'todo.is.ui.project.open')}"
                            tooltip-append-to-body="true"
                            tooltip-placement="top">
                        <span class="fa fa-expand"></span>
                    </button>
                </accordion-heading>
                <div ng-include="'project.details.html'"></div>
            </accordion-group>
        </accordion>
    </div>
</script>