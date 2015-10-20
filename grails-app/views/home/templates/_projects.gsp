<script type="text/ng-template" id="projects.html">
    <div class="panel panel-light" ng-controller="projectListCtrl">
        <div class="panel-heading">
            <h3 ng-if="type == 'public'" class="panel-title"><i class="fa fa-folder-open"></i> ${message(code: 'is.panel.project.public')}</h3>
            <h3 ng-if="type == 'user'" class="panel-title"><i class="fa fa-folder-open-o"></i> ${message(code: 'is.panel.project.user')}</h3>
        </div>
        <div class="panel-body">
            <uib-accordion>
                <uib-accordion-group is-open="openedProjects[currentProject.id]"
                                     ng-repeat="currentProject in projects">
                    <uib-accordion-heading>
                        {{ currentProject.name }}
                        <button type="button"
                                class="pull-right btn btn-xs btn-default"
                                ng-click="$event.stopPropagation(); $event.preventDefault(); openProject(currentProject)"
                                uib-tooltip="${message(code:'todo.is.ui.project.open')}"
                                tooltip-append-to-body="true"
                                tooltip-placement="top">
                            <span class="fa fa-expand"></span>
                        </button>
                    </uib-accordion-heading>
                    <div ng-if="currentProject.id == project.id"
                         ng-include="'project.details.html'">
                    </div>
                </uib-accordion-group>
            </uib-accordion>
        </div>
    </div>
</script>