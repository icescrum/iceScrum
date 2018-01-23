<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="publicProjectListCtrl">
        <div ng-if="projects && !projects.length">
            <h4 class="text-center">${message(code: 'todo.is.ui.project.nopublicproject')}</h4>
        </div>
        <div ng-repeat="project in projects" class="row projects-list">
            <hr ng-if="!$first" class="ng-scope">
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
                        <a href="p/{{:: project.pkey }}/#/taskBoard/{{:: project.currentOrNextRelease.id }}/{{:: project.currentOrNextRelease.currentOrNextSprint.id }}" class="link"><i
                                class="fa fa-tasks {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor }}"></i>&nbsp;<div
                                class="progress {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background-light' }}">
                            <span class="progress-value">{{:: project.currentOrNextRelease.currentOrNextSprint | sprintName }}</span>
                            <div class="progress-bar {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background' }}" role="progressbar"
                                 aria-valuenow="{{:: project.currentOrNextRelease.currentOrNextSprint | computePercentage:'velocity':'capacity' }}" aria-valuemin="0" aria-valuemax="100"
                                 style="width: {{:: project.currentOrNextRelease.currentOrNextSprint | computePercentage:'velocity':'capacity' }}%;"></div>
                        </div>&nbsp;<i class="fa fa-clock-o"></i>&nbsp;<time timeago datetime="{{:: project.currentOrNextRelease.currentOrNextSprint.endDate }}">{{ project.currentOrNextRelease.currentOrNextSprint.endDate | dateTime }}</time></a>
                    </li>
                </ul>
            </div>
            <div class="col-lg-2 col-xs-3">
                <div class="text-right">
                    <img ng-repeat="user in ::project | allMembers | limitTo:2"
                         ng-src="{{:: user | userAvatar }}"
                         height="20" width="20"
                         class="{{:: user | userColorRoles:project }}"
                         style="margin:3px;"
                         uib-tooltip="{{:: user | userFullName }}"/>
                    <span class="team-size" ng-if="::(project | allMembers).length > 2">+ {{::(project | allMembers).length - 2}}</span>
                </div>
                <div class="text-ellipsis clearfix text-right" title="{{:: project.team.name }}"><small><i class="fa fa-users"></i> {{::project.team.name }}</small></div>
            </div>
        </div>
    </div>
</is:widget>