%{--
- Copyright (c) 2014 Kagilum SAS.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<!DOCTYPE html>
<html lang="en" ng-app="isApp" ng-strict-di>
<head>
    <title>iceScrum - <g:layoutTitle/></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
    <!-- iOS web app-->
    <meta name="apple-mobile-web-app-capable" content="yes"/>
    <asset:link rel="apple-touch-icon" href="iOS/icon-iphone.png"/>
    <asset:link rel="apple-touch-icon" href="iOS/icon-ipad.png" sizes="76x76"/>
    <asset:link rel="apple-touch-icon" href="iOS/icon-iphone-retina.png" sizes="120x120"/>
    <asset:link rel="apple-touch-icon" href="iOS/icon-ipad-retina.png" sizes="152x152"/>
    <!-- end iOS web app-->
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>
    <asset:stylesheet href="application.css"/>
    <script type="text/javascript"
            src="${grailsApplication.config.grails.serverURL}/assets/pdfjs/pdf.compat.js"></script>
    <script type="text/javascript" src="${grailsApplication.config.grails.serverURL}/assets/pdfjs/pdf.js"></script>
    <g:layoutHead/>
</head>
<body ng-controller="appCtrl"
      flow-prevent-drop=""
      fullscreen="app.isFullScreen"
      ng-class="{ 'mobile':app.mobile, 'app-ready':app != null, 'loading': (app.loading || app.loadingText), 'splash-screen': (app.loadingPercent != 100 || app.loadingText)  }"
      class="splash-screen loading">
    <g:render template="/scrumOS/checkServerURL"/>
    <div id="app-loading">
        <svg class="logo" viewBox="0 0 150 150">
            <g:render template="/scrumOS/logo"/>
            <circle fill="none" cx="80px" cy="80px" r="63" style="stroke: #eee; stroke-width: 10px;"></circle>
            <path fill="none" transform="" circle-coords="80,80,63,0" circle="app.loadingPercent"
                  class="loading-circle"></path>
        </svg>
        <div class="loading-text text-center">{{ app.loadingText }}</div>
    </div>
    <is:header/>
    <div class="container-fluid main" ui-view>
        <g:layoutBody/>
    </div>
    <g:include controller="scrumOS" action="isSettings" params="[product: params.product]"/>
    <asset:javascript src="application.js"/>
    <g:include controller="scrumOS" action="templates" params="[product: params.product]"/>
    <entry:point id="icescrum-footer"/>
</body>
</html>