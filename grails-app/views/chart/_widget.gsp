<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="chartCtrl" ng-init="openProjectChart(widget.settings.chart.id, widget.settings.project)">
        <nvd3 options="options" data="data"></nvd3>
    </div>
</is:widget>