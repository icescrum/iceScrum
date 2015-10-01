<div class="backlogs">
    <div ng-repeat="backlog in backlogs"
         class="backlog ${index == 0 ? 'selected' : ''}"
         tooltip="{{ backlog.name }}"
         tooltip-append-to-body="true"
         tooltip-placement="top">
        <div class="backlog-name text-center">
            <h3>{{ backlog.count }}</h3>
            <b>{{ backlog.name }}</b>
        </div>
        <div ng-repeat="color in backlog.colors track by $index" style="background-color:{{ color }}"></div>
    </div>
</div>