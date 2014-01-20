%{--
- Copyright (c) 2010 iceScrum Technologies.
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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>iceScrum - <g:layoutTitle/></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" >
    <r:external uri="/${is.currentThemeImage()}favicon.ico"/>
    <is:loadJsVar/>
    <r:require modules="jquery,jquery-ui,jquery-ui-plugins,jquery-plugins,jqplot,icescrum,objects${grailsApplication.config?.modulesResources ? ','+grailsApplication.config.modulesResources.join(',') : ''}"/>
    <sec:ifLoggedIn>
        <script src="${resource(dir: 'js/timeline/timeline_ajax', file: 'simile-ajax-api.js?bundle=true')}" type="text/javascript"></script>
        <script src="${resource(dir: 'js/timeline/timeline_js', file: 'timeline-api.js?bundle=true')}" type="text/javascript"></script>
        <script src="${resource(dir: 'js/timeline', file: 'icescrum-painter.js')}" type="text/javascript"></script>
    </sec:ifLoggedIn>
    <r:layoutResources/>
    <g:layoutHead/>
</head>

<body class="icescrum" ${user?.preferences?.displayWhatsNew?'data-whatsnew="true"':''}>
<is:header/>
<div id="local"
     data-ui-droppable
     data-ui-droppable-drop="$.icescrum.onDropToWidgetBar"
     data-ui-droppable-hover-class="local-active"
     data-ui-droppable-accept=".draggable-to-widgets"
     data-ui-sortable
     data-ui-sortable-handle=".widget-toolbar"
     data-ui-sortable-items=".box-widget-sortable"
     data-ui-resizable-panel
     data-ui-resizable-panel-right="false"
     data-ui-resizable-panel-grid="265"
     data-ui-resizable-panel-max-width="265">
    <div class="widget-bar">
      <div id="widget-list">
        <div class="message" id="upgrade" style="display:none;">
            <span class="close"><g:message code="is.ui.hide"/></span>
            <g:message code="is.upgrade.icescrum.pro"/>
        </div>
        <g:if test="${request.archivedProduct}">
            <div class="message" style="display:block;">
                <g:message code="is.message.project.activate"/>
            </div>
        </g:if>
      </div>
    </div>
    <div id="notifications" style="display:none;"><a id="accept_notifications">${message(code:'is.ui.html5.notifications')}</a> (<a id="hide_notifications">${message(code:'is.ui.hide')}</a>)</div>
</div>
<div id="main">
    <div id="main-content"
         data-ui-droppable
         data-ui-droppable-drop="$.icescrum.onDropToWindow"
         data-ui-droppable-hover-class="main-active"
         data-ui-droppable-accept=".draggable-to-main">
        <g:layoutBody/>
    </div>
</div>
<r:layoutResources/>
<entry:point id="icescrum-footer"/>
<g:include controller="scrumOS" action="templates" params="[product:params.product]"/>
<is:onStream events="[[object:'product',events:['add','remove','update','redirect','archive', 'unarchive']]]"/>
<is:onStream events="[[object:'user',events:['addRoleProduct','removeRoleProduct','updateRoleProduct','updateProfile']]]"/>
</body>
</html>