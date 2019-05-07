<div id="application-loading" class="container h-100 d-flex justify-content-center">
    <div class="my-auto">
        <div id="main-loader">
            <img alt="iceScrum" src="${assetPath(src: 'application/logo.png')}" height="100px" width="100px">
        </div>
        <div class="loading-text text-center" ng-if="application.loadingPercent != 100 && application.loadingText" ng-cloak>{{ Math.round(application.loadingPercent) }} {{ application.loadingText }}</div>
    </div>
</div>