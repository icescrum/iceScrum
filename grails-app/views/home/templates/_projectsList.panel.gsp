<script type="text/ng-template" id="projectsList.panel.html">
    <div ng-init="type='public'">
        <div class="panel panel-primary" ng-controller="projectListCtrl">
            <div class="panel-heading">
                <h4 class="panel-title">${message(code: 'is.panel.project.public')}</h4>
            </div>
            <accordion>
                <accordion-group heading="{{ project.name }}"
                                 is-open="openedProjects[project.id]"
                                 ng-repeat="project in projects">
                    <div ng-include="'project.details.html'"></div>
                </accordion-group>
            </accordion>
        </div>
    </div>
</script>
