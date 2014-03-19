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
<html lang="en">
<head>
    <title>iceScrum - <g:layoutTitle/></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" >
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, ms-touch-action: none" />
    <!-- iOS web app-->
    <meta name="apple-mobile-web-app-capable" content="yes"/>
    <link href="${r.resource(uri:'/images/iOS/icon-iphone.png')}" rel="apple-touch-icon"/>
    <link href="${r.resource(uri:'/images/iOS/icon-ipad.png')}" rel="apple-touch-icon" sizes="76x76"/>
    <link href="${r.resource(uri:'/images/iOS/icon-iphone-retina.png')}" rel="apple-touch-icon" sizes="120x120"/>
    <link href="${r.resource(uri:'/images/iOS/icon-ipad-retina.png')}" rel="apple-touch-icon" sizes="152x152"/>
    <r:external uri="/images/favicon.ico"/>

    <is:loadJsVar/>
    <r:require modules="jquery,bootstrap,jquery-plugins,jqplot,icescrum,objects${grailsApplication.config?.modulesResources ? ','+grailsApplication.config.modulesResources.join(',') : ''}"/>
    <sec:ifLoggedIn>
        <script src="${resource(dir: 'js/timeline/timeline_ajax', file: 'simile-ajax-api.js?bundle=true')}" type="text/javascript"></script>
        <script src="${resource(dir: 'js/timeline/timeline_js', file: 'timeline-api.js?bundle=true')}" type="text/javascript"></script>
        <script src="${resource(dir: 'js/timeline', file: 'icescrum-painter.js')}" type="text/javascript"></script>
    </sec:ifLoggedIn>
    <r:layoutResources/>
    <g:layoutHead/>
</head>
<body ${user?.preferences?.displayWhatsNew?'data-whatsnew="true"':''}>
<is:header/>
<div class="container-fluid">
    <div class="row sidebar-hidden">
        <g:if test="${product}">
            <div id="sidebar" class="hidden-xs col-sm-2 col-md-3 col-lg-2 well">
                <div class="sidebar-toggle">
                    <button class="btn btn-xs btn-danger">
                        <span class="glyphicon glyphicon-chevron-left"></span>
                        <span class="glyphicon glyphicon-chevron-right"></span>
                    </button>
                </div>
                <g:if test="${request.archivedProduct}">
                    <div class="alert alert-danger">
                        <strong>${message(code:'is.message.project.activate')}</strong>
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
                    <a href="#"><strong>${message(code:'is.ui.html5.notifications')}</strong></a>
                </div>
                <entry:point id="sidebar-alerts"/>
                <div class="sidebar-content"
                     data-ui-droppable
                     data-ui-droppable-drop="$.icescrum.onDropToWidgetBar"
                     data-ui-droppable-accept=".draggable-to-widgets"
                     data-ui-sortable
                     data-ui-sortable-handle=".panel-title > .drag"
                     data-ui-sortable-items=".widget-sortable">
                </div>
            </div>
        </g:if>
        <div id="main" class="col-xs-12 col-sm-${product ? '10' : '12'} col-md-${product ? '9' : '12'} col-lg-${product ? '10' : '12'}">
            <div id="main-content"
                 data-ui-droppable
                 data-ui-droppable-hover-class="pointer"
                 data-ui-droppable-drop="$.icescrum.onDropToWindow"
                 data-ui-droppable-accept=".draggable-to-main">
                <g:layoutBody/>
            </div>
        </div>
    </div>
    <span class="hidden"
          data-is-shortcut
          data-is-shortcut-key="H"
          data-is-shortcut-callback="$.icescrum.displayShortcuts"
          title="${message(code:'todo.is.ui.this.help')}"></span>
</div>
<r:layoutResources/>

<entry:point id="icescrum-footer"/>

<g:include controller="scrumOS" action="templates" params="[product:params.product]"/>
<is:onStream events="[[object:'product',events:['add','remove','update','redirect','archive', 'unarchive']]]"/>
<is:onStream events="[[object:'user',events:['addRoleProduct','removeRoleProduct','updateRoleProduct','updateProfile']]]"/>
</body>
</html>