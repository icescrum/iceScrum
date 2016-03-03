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
    <is:loadJsVar/>
    <asset:stylesheet href="application.css"/>
    <script type="text/javascript" src="${grailsApplication.config.grails.serverURL}/assets/pdfjs/pdf.compat.js"></script>
    <script type="text/javascript" src="${grailsApplication.config.grails.serverURL}/assets/pdfjs/pdf.js"></script>
    <g:layoutHead/>
</head>
<body ng-controller="appCtrl" flow-prevent-drop="" ng-class="{ 'fullscreen':app.isFullScreen, 'loading': app.loading, 'splash-screen': app.loadingPercent != 100 }" class="flex splash-screen loading">
<div id="app-loading">
    <svg class="logo loading" width="100%" height="100%" x="0px" y="0px" viewBox="0 0 150 150" style="enable-background:new 0 0 150 150;" xml:space="preserve">
        <path class="logois logois1" d="M77.345,118.476c0,0-44.015-24.76-47.161-26.527c-3.146-1.771-0.028-3.523-0.028-3.523  l49.521-27.854c0,0,46.335,26.058,49.486,27.833c3.154,1.771,0.008,3.545,0.008,3.545S83.921,117.4,81.978,118.492  C79.676,119.787,77.345,118.476,77.345,118.476z"/>
        <path class="logois logois2" d="M77.349,107.287c0,0-44.019-24.758-47.165-26.527s0-3.539,0-3.539L79.68,49.38  c0,0,46.332,26.062,49.482,27.834c3.154,1.775,0.008,3.547,0.008,3.547s-45.193,25.422-47.16,26.525  C79.676,108.599,77.349,107.287,77.349,107.287z"/>
        <path class="logois logois3" d="M77.345,95.244c0,0-44.015-24.76-47.161-26.529s0-3.541,0-3.541  s44.814-25.207,47.153-26.522c2.339-1.313,4.602-0.041,4.602-0.041l36.191,20.396c0,0,4.141,1.336,8.162-0.852  c0.33-0.178,0.924-0.553,0.922,0.732c-0.014,12.328-15.943,19.957-15.943,19.957S84.345,93.939,82.009,95.248  C79.676,96.556,77.345,95.244,77.345,95.244z"/>
        <circle fill="none" cx="80px" cy="80px" r="63" style="stroke: #eee; stroke-width: 10px;"></circle>
        <path fill="none" transform="" circle-coords="80,80,63,0" circle="app.loadingPercent" class="loading-circle"></path>
    </svg>
</div>
<is:header/>
<div class="container-fluid main" ui-view>
    <g:layoutBody/>
</div>
<entry:point id="icescrum-footer"/>
<asset:javascript src="application.js"/>
<g:include controller="scrumOS" action="templates" params="[product: params.product]"/>
<g:render template="/layouts/analyticsAndFeedback"/>
</body>
</html>