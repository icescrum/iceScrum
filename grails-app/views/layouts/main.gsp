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
<html lang="en" ng-app="isApplication" ng-strict-di>
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
    <asset:link rel="mask-icon" href="browser/safari-pinned-tab.svg" color="#FFCC04"/>
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>
    <meta name="theme-color" content="#ffffff">
    <asset:stylesheet href="application.css"/>
    <g:layoutHead/>
</head>
<body ng-controller="applicationCtrl"
      flow-prevent-drop=""
      fullscreen="application.isFullScreen"
      ng-class="{ 'mobile':application.mobile, 'mobile-xs':application.mobilexs, 'application-ready':application != null, 'loading': (application.loading || application.loadingText), 'splash-screen': (application.loadingPercent != 100 || application.loadingText)  }"
      class="splash-screen loading">
    <div id="application-loading">
        <svg class="logo" viewBox="0 0 150 150">
            <g:render template="/scrumOS/logo"/>
            <circle fill="none" cx="80px" cy="80px" r="63" style="stroke: #eee; stroke-width: 10px;"></circle>
            <path fill="none" transform="" circle-coords="80,80,63,0" circle="application.loadingPercent"
                  class="loading-circle"></path>
        </svg>
        <div class="loading-text text-center">{{ application.loadingText }}</div>
    </div>
    <is:header/>
    <div class="container-fluid main" ui-view>
        <g:layoutBody/>
    </div>
    <g:include controller="scrumOS" action="isSettings" params="[project: params.project]"/>
    <asset:javascript src="application.js"/>
    <g:render template="/scrumOS/templatesJS" model="[project: params.project]"/>
    <entry:point id="icescrum-footer"/>
</body>
</html>
