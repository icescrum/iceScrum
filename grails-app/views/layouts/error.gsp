%{--
- Copyright (c) 2016 Kagilum SAS.
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
    <g:layoutHead/>
</head>
<body class="error-template">
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div>
                    <svg class="logo" ng-class="getPushState()" viewBox="0 0 150 150">
                        <g:render template="/scrumOS/logo"/>
                    </svg>
                    <g:layoutBody/>
                </div>
            </div>
        </div>
    </div>
    <asset:javascript src="application.js"/>
</body>
</html>