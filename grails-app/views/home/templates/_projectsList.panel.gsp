<script type="text/ng-template" id="projectsList.panel.html">
    <div ng-controller="projectListCtrl" ng-init="type='public'">
        <accordion>
            <accordion-group heading="{{ project.name }}"
                             is-open="openedProjects[project.id]"
                             ng-repeat="project in projects">
                <div ng-include="'project.details.html'"></div>
            </accordion-group>
        </accordion>
    </div>
</script>