<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
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
<body ng-controller="appCtrl" flow-prevent-drop="" ng-class="{ 'fullscreen':app.isFullScreen, 'ready': app.loading == 100, 'loading':app.loading < 100 }" class="loading">
<div id="app-progress">
    <div>
        <progressbar animate="true" value="app.loading" type="primary"></progressbar>
    </div>
</div>
<div class="main">
    <is:header/>
    <div class="container-fluid">
        <div class="row sidebar-hidden">
            <g:if test="${product}">
                <div id="sidebar">
                    <div class="sidebar-toggle">
                        <button class="btn btn-xs btn-danger">
                            <span class="fa fa-chevron-left"></span>
                            <span class="fa fa-chevron-right"></span>
                        </button>
                    </div>
                    <g:if test="${request.archivedProduct}">
                        <div class="alert alert-danger">
                            <strong>${message(code: 'is.message.project.activate')}</strong>
                        </div>
                    </g:if>
                    <g:if test="${!ApplicationSupport.isProVersion()}">
                        <div class="alert alert-info alert-dismissable" id="upgrade" style="display:none;">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                            <strong><g:message code="is.upgrade.icescrum.pro"/></strong>
                        </div>
                    </g:if>
                    <div class="alert alert-info alert-dismissable" id="notifications" style="display:none;">
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                        <a href="#"><strong>${message(code: 'is.ui.html5.notifications')}</strong></a>
                    </div>
                    <entry:point id="sidebar-alerts"/>
                    <div class="sidebar-content"
                         data-ui-droppable-drop="$.icescrum.onDropToWidgetBar"
                         data-ui-droppable-accept=".draggable-to-widgets"
                         data-ui-sortable-handle=".panel-title > .drag"
                         data-ui-sortable-items=".widget-sortable">
                    </div>
                </div>
            </g:if>
            <div id="main">
                <div id="main-content"
                     data-ui-droppable-hover-class="pointer"
                     data-ui-droppable-drop="$.icescrum.onDropToWindow"
                     data-ui-droppable-accept=".draggable-to-main"
                     ui-view>
                    <g:layoutBody/>
                </div>
            </div>
        </div>
    </div>
</div>
<entry:point id="icescrum-footer"/>
<asset:javascript src="application.js"/>
<g:include controller="scrumOS" action="templates" params="[product: params.product]"/>
</body>
</html>