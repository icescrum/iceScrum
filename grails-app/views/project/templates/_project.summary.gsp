<script type="text/ng-template" id="project.summary.html">
    <div class="row">
        <h4 class="col-md-6">{{ project.name + ' (' + project.pkey + ')' }}</h4>
        <h4 class="col-md-6 text-right"><i class="fa fa-users"></i> {{ project.team.name }}</h4>
    </div>
    <div class="row project-desc-chart">
        <div class="col-md-5" ng-bind-html="(project.description_html ? project.description_html : '<p>${message(code: 'todo.is.ui.project.nodescription')}</p>') | sanitize"></div>
        <div class="col-md-7" ng-controller="chartCtrl" ng-init="openChart('project', 'burnup', project)">
            <nvd3 options="options | merge: {chart:{height: 200}, title:{enable: false}}" data="data"></nvd3>
        </div>
    </div>
    <div class="well">
        <div class="row project-info">
            <div class="col-md-4" style="text-align: left;"><i class="fa fa-user"></i> {{ projectMembersCount }} ${ message(code: 'todo.is.ui.members') }</div>
            <div class="col-md-4" style="text-align: center;"><i class="fa fa-sticky-note"></i> {{ project.stories_count }} ${ message(code: 'todo.is.ui.stories') }</div>
            <div class="col-md-4" style="text-align: right;"><i class="fa fa-calendar"></i> {{ project.releases_count }} ${ message(code: 'todo.is.ui.releases') }</div>
        </div>
        <ng-include src="'release.timeline.html'" ng-controller="releaseTimelineCtrl"></ng-include>
        <div class="row project-rel-dates">
            <div class="col-md-6">{{ release.startDate | dayShort }}</div>
            <div class="col-md-6 text-right">{{ release.endDate | dayShort }}</div>
        </div>
    </div>
</script>