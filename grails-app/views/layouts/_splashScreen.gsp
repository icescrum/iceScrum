<div id="application-loading" class="container h-100 d-flex justify-content-center">
    <div class="my-auto">
        <div id="main-loader"></div>
        <div class="loading-text text-center" ng-if="application.loadingPercent != 100 && application.loadingText" ng-cloak>{{ application.loadingPercent }} {{ application.loadingText }}</div>
    </div>
</div>