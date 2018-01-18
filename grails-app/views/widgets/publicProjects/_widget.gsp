<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="publicProjectListCtrl">
        <div ng-if="projects && !projects.length">
            <h4 class="text-center">${message(code: 'todo.is.ui.project.nopublicproject')}</h4>
        </div>
        <div ng-repeat="project in projects" class="row projects-list">
            <h4 class="col-md-12 clearfix">
                <div class="pull-left"><a href="" class="link">{{:: project.name }}</a> <small>owned by {{:: project.owner | userFullName }}</small></div>
                <div class="pull-right">
                    <small><time timeago datetime="{{:: project.lastUpdated }}">{{ project.lastUpdated | dateTime }}</time> <i class="fa fa-clock-o"></i></small>
                </div>
            </h4>
            <div class="col-lg-10 col-xs-9">
                <div class="description" ng-bind-html="project.description_html | truncateAndSeeMore:project"></div>
            </div>
            <div class="col-lg-2 col-xs-3">
                <div class="backlogCharts chart pull-right" ng-controller="chartCtrl" ng-init="openChart('backlog', 'state', retrieveBacklog(project), backlogChartOptions)">
                    <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
                </div>
            </div>
            <div class="col-lg-10 col-xs-9">
                <ul class="list-inline text-muted pull-left">
                    <li class="activities">
                        <a href="p/{{:: project.pkey }}/#/project" class="link"><i class="fa fa-clock-o"></i> {{:: project.activities_count }}</a>
                    </li>
                    <li class="features">
                        <a href="p/{{:: project.pkey }}/#/feature" class="link"><i class="fa fa-puzzle-piece"></i> {{:: project.features_count }} <g:message code="is.ui.feature"/></a>
                    </li>
                    <li class="stories">
                        <a href="p/{{:: project.pkey }}/#/backlog" class="link"><i class="fa fa-sticky-note"></i> {{:: project.stories_count }} <g:message code="todo.is.ui.stories"/></a>
                    </li>
                    <li class="release" ng-if=":: project.currentOrNextRelease">
                        <a href="p/{{:: project.pkey }}/#/planning/{{:: project.currentOrNextRelease.id }}" class="link"><i class="fa fa-calendar {{:: project.currentOrNextRelease.state | releaseStateColor }}"></i> <span
                                class="text-ellipsis">{{:: project.currentOrNextRelease.name }}</span></a>
                    </li>
                    <li class="sprint" ng-if=":: project.currentOrNextRelease.currentOrNextSprint">
                        <a href="p/{{:: project.pkey }}/#/taskBoard/{{:: project.currentOrNextRelease.currentOrNextSprint.id }}" class="link"><i
                                class="fa fa-tasks {{:: project.currentOrNextRelease.currentOrNextSprint.state | releaseStateColor }}"></i> <span class="text-ellipsis">{{:: project.currentOrNextRelease.currentOrNextSprint | sprintName }}</span></a>
                    </li>
                    <li class="sprint" ng-if=":: project.currentOrNextRelease.currentOrNextSprint.state > 1">
                        <div class="progress {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background-light' }}">
                            <div class="progress-bar {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background' }}" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100"
                                 style="width: 60%;"></div>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="col-lg-2 col-xs-3">
                <img ng-repeat="user in ::project | allMembers"
                     ng-src="{{:: user | userAvatar }}"
                     height="26" width="26"
                     class="pull-right {{:: user | userColorRoles:project }}"
                     uib-tooltip="{{:: user | userFullName }}"/>
            </div>
            <hr ng-if="!$last" class="ng-scope">
        </div>
    </div>
</is:widget>