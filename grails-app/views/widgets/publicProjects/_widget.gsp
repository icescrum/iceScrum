<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="publicProjectListCtrl">
        <div ng-if="projects && !projects.length">
            <h4 class="text-center">${message(code: 'todo.is.ui.project.nopublicproject')}</h4>
        </div>
        <div ng-repeat="project in projects" class="row">
            <h4 class="col-md-12 clearfix">
                <div class="pull-left">{{:: project.name }} <small>owned by {{ project.owner | userFullName }}</small></div>
                <div class="pull-right"><small><time timeago datetime="{{ project.lastUpdated }}">{{ project.lastUpdated | dateTime }}</time> <i class="fa fa-clock-o"></i></small></div>
            </h4>
            <div class="col-md-9">
                <div class="description" style="margin-bottom: 10px;" ng-bind-html="project.description_html | stripTags: '<br><p>'"></div>
            </div>
            <div class="col-md-3">
                <img ng-repeat="user in ::project | allMembers"
                     ng-src="{{:: user | userAvatar }}"
                     height="26" width="26"
                     class="pull-right {{:: user | userColorRoles:project }}"
                     uib-tooltip="{{:: user | userFullName }}"/>
            </div>
            <div class="col-md-12 ">
                <ul class="list-inline text-muted">
                    <li><i class="fa fa-puzzle-piece" style="color:rgb(45, 140, 204)"></i> {{:: project.features_count }}</li>
                    <li><i class="fa fa-sticky-note" style="color: rgb(249, 241, 87);text-shadow:1px 1px 0px #CCC;"></i> {{:: project.stories_count }}</li>
                    <li><i class="fa fa-clock-o"></i> {{:: project.activities_count }}</li>
                    <li><i class="fa fa-calendar"></i> {{:: project.currentOrNextRelease.name }}</li>
                    <li><i class="fa fa-tasks"></i> {{:: project.currentOrNextRelease.currentOrNextSprint | sprintName }}</li>
                </ul>
                <hr ng-if="!$last" class="ng-scope">
            </div>
        </div>
    </div>
</is:widget>