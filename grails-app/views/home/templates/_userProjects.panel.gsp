<script type="text/ng-template" id="userProjects.panel.html">
<div class="panel panel-light" ng-controller="projectListCtrl">
    <div class="panel-body">
            <div class="btn-group" ng-repeat="project in projects">
                <a href="{{:: getProjectUrl(project) }}" class="btn btn-default" role="button">{{ ::project.name }}</a>
                <a href="{{:: getProjectUrl(project, 'backlog') }}" class="btn btn-default" role="button"><i class="fa fa-inbox"></i></a>
                <a href="{{:: getProjectUrl(project, 'taskBoard') }}" class="btn btn-default" role="button"><i class="fa fa-tasks"></i></a>
            </div>
        <hr>
    </div>
</div>
</script>