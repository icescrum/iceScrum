<form ng-switch-when="true"
      ng-controller="ChartWidgetCtrl"
      ng-submit="update(widget)"
      class="form-horizontal">
    <div class="form-group">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.charts.title')}">{{ $select.selected.id }}</ui-select-match>
                <ui-select-choices repeat="chart in charts">{{chart.id}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.project">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.projects.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.projects.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="project in projects">{{project.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.release">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.releases.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.releases.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="release in releases">{{release.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.sprint">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.sprints.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.sprints.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="release in releases">{{sprint.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
</form>