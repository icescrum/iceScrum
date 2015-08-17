<script type="text/ng-template" id="project.details.html">
    <h4 class="pull-right"><i class="fa fa-users"/> {{ project.team.name }}</h4>
    <h4>{{ project.name }} ({{ project.pkey }})</h4>
    <div class="row">
        <div class="col-md-6" ng-bind-html="(project.description_html ? project.description_html : '<p>${message(code: 'todo.is.ui.project.nodescription')}</p>') | sanitize"></div>
        <div class="col-md-6">PLACEHOLDER CHART</div>
    </div>
    <div class="row">
        <div class="col-md-4"><i class="fa fa-user"/> {{ projectMembersCount }} ${ message(code: 'todo.is.ui.members') }</div>
        <div class="col-md-4"><i class="fa fa-sticky-note"/> {{ project.stories_count }} ${ message(code: 'todo.is.ui.stories') }</div>
        <div class="col-md-4"><i class="fa fa-calendar"/> {{ project.releases_count }} ${ message(code: 'todo.is.ui.releases') }</div>
    </div>
    <h5>${ message(code:'todo.is.ui.release')} {{ release.name }}</h5>
    <progress class="form-control-static form-bar" max="release.duration">
        <bar ng-repeat="sprint in release.sprints"
             class="{{ $last ? 'last-bar' : '' }}"
             tooltip-append-to-body="true"
             tooltip-template="'sprint.tooltip.html'"
             tooltip-placement="bottom"
             type="{{ { 1: 'default', 2: 'progress', 3: 'done' }[sprint.state] }}"
             value="sprint.duration">
            #{{ sprint.orderNumber }}
        </bar>
        <div class="progress-empty" ng-if="release.sprints != undefined && release.sprints.length == 0">${message(code: 'todo.is.ui.nosprint')}</div>
    </progress>
</script>