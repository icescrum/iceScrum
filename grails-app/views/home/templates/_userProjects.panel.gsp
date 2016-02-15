<script type="text/ng-template" id="userProjects.panel.html">
<div class="panel panel-light" ng-controller="projectListCtrl">
    <div class="panel-body">
            <div class="btn-group" ng-repeat="project in projects">
                <a href="" ng-click="openProject(project)" class="btn btn-default" role="button">{{ ::project.name }}</a>
                <a href="" ng-click="openProject(project)" class="btn btn-default"><i class="fa fa-sticky-note"></i></a>
                <a href="" ng-click="openProject(project)" class="btn btn-default"><i class="fa fa-tasks"></i></a>
            </div>
        <hr>
    </div>
</div>
</script>