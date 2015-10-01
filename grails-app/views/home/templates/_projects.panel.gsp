<script type="text/ng-template" id="projects.panel.html">
    <div class="panel panel-primary" ng-controller="projectListCtrl" ng-init="type='user'">
        <div class="panel-heading">
            ${message(code: 'is.panel.myprojects')}
        </div>
        <accordion>
            <accordion-group heading="{{ project.name }}"
                             is-open="openedProjects[project.id]"
                             ng-repeat="project in projects">
                <div ng-include="'project.details.html'"></div>
            </accordion-group>
        </accordion>
    </div>
</script>