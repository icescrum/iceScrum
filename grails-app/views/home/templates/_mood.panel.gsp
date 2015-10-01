<script type="text/ng-template" id="mood.panel.html">
    <div class="panel panel-primary">
        <div class="panel-heading">${message(code: 'is.panel.mood')}</div>

        <div class="panel-body" ng-controller="moodCtrl">
            <div ng-switch="alreadySavedToday">
                <div ng-switch-default>
                    <button ng-click="save('GOOD')" tooltip="Great" class="fa fa-smile-o fa-5x"></button>
                    <button ng-click="save('MEH')" tooltip="So-so" class="fa fa-meh-o fa-5x"></button>
                    <button ng-click="save('BAD')" tooltip="Bad" class="fa fa-frown-o fa-5x"></button>
                </div>

                <div ng-switch-when="true">
                    <table ng-repeat="mood in moods">
                        <tr><td>${message(code: 'is.panel.mood.feeling')}: {{mood.feeling | i18n:'MoodFeelings'}}</td>
                        </tr>
                    </table>

                    <div ng-controller="moodChartCtrl">
                        <div class="panel-body" id="panel-chart-container">
                            <nvd3 options="options" data="data"></nvd3>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</script>