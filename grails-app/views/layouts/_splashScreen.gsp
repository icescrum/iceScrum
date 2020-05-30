<div id="application-loading" class="container h-100 d-flex justify-content-center">
    <div class="my-auto">
        <div id="main-loader" style="height: 101px; width:101px; margin-left:calc(50% - 101px/2);">
            <img alt="iceScrum" src="${assetPath(src: 'application/logo.png')}" height="100%" width="100%">
        </div>
        <div class="loading-text text-center" ng-if="application.loadingText" ng-cloak><span ng-if="application.loadingPercent != 100">{{ Math.round(application.loadingPercent) }}</span> {{ application.loadingText }}</div>
    </div>
</div>