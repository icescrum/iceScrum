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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<is:dialog valid="[action:'update',controller:'project',onSuccess:'jQuery.event.trigger(\'update_product\',[data]); jQuery.icescrum.renderNotice(\''+message(code:'is.product.updated')+'\');']"
          width="650"
          resizable="false"
          draggable="false">
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
  <input type="hidden" name="productd.id" value="${params.product}">
  <input type="hidden" name="product" value="${params.product}">
  <input type="hidden" name="productd.version" value="${product.version}">
  <is:fieldset nolegend="true" title="is.dialog.project.title">
    <is:accordion id="properties">
        <is:accordionSection title="is.dialog.project.properties.title">
            <is:fieldInput for="productname" label="is.product.name">
              <is:input id="productname" name="productd.name" value="${product.name}"/>
            </is:fieldInput>
            <is:fieldInput for="productkey" label="is.dialog.project.properties.pkey">
              <is:input typed="[type:'alphanumeric',onlyletters:true,allcaps:true]" id="productkey" name="productd.pkey" value="${product.pkey}"/>
            </is:fieldInput>
            <is:fieldSelect for="productpreferencestimezone" label="is.product.preferences.timezone">
                <is:localeTimeZone width="250"
                                   name="productd.preferences.timezone"
                                   id="productpreferencestimezone"
                                   value="${product.preferences.timezone}"/>
            </is:fieldSelect>
            <is:fieldArea class="productdescription-label" for="productdescription" label="is.product.description" noborder="${!product.preferences.archived && (request.owner || request.scrumMaster) || (product.preferences.archived && request.admin)}">
              <is:area
                      rich="[preview:true,width:295]"
                      id="productdescription"
                      name="productd.description"
                      value="${product.description}"/>
            </is:fieldArea>
            <entry:point id="${controllerName}-${actionName}-settings" model="[product:product]"/>
            <g:if test="${!product.preferences.archived && (request.owner || request.scrumMaster)}">
                <is:fieldInput for="archivedProject" label="is.dialog.project.archive" class="productcreator" noborder="true">
                    <button onClick="if (confirm('${message(code:'is.dialog.project.archive.confirm').encodeAsJavaScript()}')) {
                                          ${g.remoteFunction(action:'archive',
                                                             controller:'project',
                                                             params:[product:params.product],
                                                             onSuccess:'jQuery.event.trigger(\'archive_product\',data);')
                                           };}return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                        <g:message code="is.dialog.project.archive.button"/>
                    </button>
                </is:fieldInput>
            </g:if>
            <g:if test="${product.preferences.archived && request.admin}">
                <is:fieldInput for="archivedProject" label="is.dialog.project.unArchive" class="productcreator" noborder="true">
                    <button onClick="${g.remoteFunction(action:'unArchive',
                                                             controller:'project',
                                                             params:[product:params.product],
                                                             onSuccess:'jQuery.event.trigger(\'unarchive_product\',data);')
                                           } return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                        <g:message code="is.dialog.project.unArchive.button"/>
                    </button>
                </is:fieldInput>
            </g:if>
        </is:accordionSection>
        <is:accordionSection title="is.dialog.project.security.title">
            <is:fieldRadio rendered="${!privateOption}" for="productpreferenceshidden" label="is.product.preferences.project.hidden">
                <is:radio id="productpreferenceshidden" name="productd.preferences.hidden" value="${product.preferences.hidden}"/>
            </is:fieldRadio>
            <is:fieldFile for="productpreferencesStakeHolderRestrictedViews" label="is.product.preferences.project.stakeHolderRestrictedViews">
                <div class="restrictedViews">
                    <g:each var="view" in="${possibleViews}">
                        <is:checkbox label="${message(code:view.title)}" checked="${view.id in restrictedViews}"  value="${view.id}" name="productd.preferences.stakeHolderRestrictedViews"/>
                    </g:each>
                </div>
            </is:fieldFile>
            <is:fieldRadio for="productpreferenceswebservices" label="is.product.preferences.project.webservices" noborder="true">
                <is:radio id="productpreferenceswebservices" name="productd.preferences.webservices" value="${product.preferences.webservices}"/>
            </is:fieldRadio>
        </is:accordionSection>
        <entry:point id="${controllerName}-${actionName}" model="[product:product]"/>
    </is:accordion>
  </is:fieldset>
</form>
</is:dialog>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-project" listenOn="'#form-project input'"/>