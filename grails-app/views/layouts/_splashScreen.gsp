<div id="application-loading" class="container h-100 d-flex justify-content-center">
    <div class="my-auto">
        <div id="main-loader" style="height: 101px; width:101px;">
            <img alt="iceScrum" src="${assetPath(src: 'application/logo.png')}" height="100%" width="100%">
        </div>
        <div class="loading-text text-center" ng-if="application.loadingPercent != 100 && application.loadingText" ng-cloak>{{ Math.round(application.loadingPercent) }} {{ application.loadingText }}</div>
    </div>
</div>