<script type="text/ng-template" id="publicProjects.panel.html">
<div class="panel panel-light" ng-controller="projectListCtrl">
    <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-folder-open"></i> ${message(code: 'is.panel.project.public')}</h3>
    </div>
    <div class="panel-body">
        <uib-accordion>
            <uib-accordion-group is-open="openedProjects[currentProject.id]"
                                 ng-repeat="currentProject in projects">
                <uib-accordion-heading>
                    {{ currentProject.name }}
                    <button type="button"
                            style="margin: -2px 4px 0 0"
                            class="pull-right btn btn-xs btn-default"
                            ng-click="$event.stopPropagation(); $event.preventDefault(); openProject(currentProject)"
                            uib-tooltip="${message(code:'todo.is.ui.project.open')}">
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