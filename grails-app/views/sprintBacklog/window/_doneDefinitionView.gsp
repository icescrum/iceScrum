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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%
<%@ page import="org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils" %>
<g:form action="updateDoneDefinition" method="post" name="doneDefinitionForm" class="box-form box-form-200-legend">
  <is:fieldset title="is.ui.sprintBacklog.doneDefinition.properties.title">
    <is:fieldArea for="doneDefinition" label="is.sprint.doneDefinition" noborder="true" class="rich-large">
      <is:area
              rich="[ preview:true,
                      fillWidth:true,
                      margin:250,
                      height:250,
                      disabled:sec.noAccess(expression:'productOwner() or scrumMaster()',{true})]"
              id="doneDefinition"
              name="doneDefinition"
              value="${sprint?.doneDefinition}"/>
    </is:fieldArea>
  </is:fieldset>

  <is:buttonBar>
    <sec:access expression="productOwner() or scrumMaster()">
      <is:button
              targetLocation="${controllerName+'/'+actionName}/${sprint.id}"
              id="submitForm" type="submitToRemote"
              url="[controller:id, action:'updateDoneDefinition', params:[product:params.product,id:params.id]]"
              value="${message(code:'is.ui.sprintBacklog.doneDefinition.button.save')}"
              onSuccess="${is.notice(text:message(code:'is.sprint.doneDefinition.saved'))}"/>
      <is:button
            rendered="${sprint.orderNumber > 1 || sprint.parentRelease.orderNumber > 1}"
            type="link"
            remote="true"
            history="false"
            url="[controller:id, action:'copyFromPreviousDoneDefinition',id:params.id,params:[product:params.product]]"
            update="window-content-${id}">${message(code: 'is.ui.sprintBacklog.button.copyFromPreviousDoneDefinition')}
      </is:button>
    </sec:access>
    <is:button
            type="link"
            button="button-s button-s-black"
            remote="true"
            url="[controller:id, action:'index',id:params.id,params:[product:params.product]]"
            update="window-content-${id}">${message(code: 'is.button.close')}
    </is:button>
  </is:buttonBar>
</g:form>
<jq:jquery >
  jQuery("#window-content-${id}").addClass('window-content-toolbar');
  var area = jQuery('#doneDefinition-field');
  area.width(area.parent().width() - 250);
  <is:renderNotice />
  <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'doneDefinition',id:params.id,params:[product:params.product]]"
        group="${params.product}-${id}-doneDefinition-${params.id}"
        listenOn="#window-content-${id}"/>
</jq:jquery>
