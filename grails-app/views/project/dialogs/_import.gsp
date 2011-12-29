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
--}%
<g:setProvider library="jquery"/>

   <g:if test="${!product}">
     <g:formRemote url="[action:'importProject']" update="dialog" name="${id}-import-form" class="box-form box-form-180 box-form-180-legend">
        <is:fieldset title="is.dialog.importProject.choose.title">
          <is:fieldInformation noborder="true">
            <g:message code="is.dialog.importProject.choose.description"/>
          </is:fieldInformation>
          <is:fieldFile noborder="true" label="is.dialog.importProject.choose.file">
            <is:multiFilesUpload elementId="inportProductXml"
                          name="file"
                          accept="['xml']"
                          urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                          multi="1"
                          params="[product:params.product]"
                          onUploadComplete="\$('#${id}-import-form-submit').click();\$('#${id}-import-form').hide();\$('#import-validate').show();"
                          progress="[
                            url:createLink(action:'uploadStatus',controller:'scrumOS'),
                            label:message(code:'is.upload.wait'),
                          ]"/>
          </is:fieldFile>
          <input type="submit" style="display:none;" id="${id}-import-form-submit" value="submit"/>
        </is:fieldset>
     </g:formRemote>
     <div id="import-validate" class="box-form" style="display:none;">
        <is:fieldset title="is.dialog.importProject.validate.title">
            <is:fieldInformation noborder="true">
              <g:message code="is.dialog.importProject.validate.description"/>
            </is:fieldInformation>
            <is:progressBar
              elementId="progress"
              label="${message(code:'is.validate.start')}"
              startOn="#${id}-import-form"
              startOnWhen="submit"
              url="${createLink(action:'importProject',params:[status:true])}"
              />
        </is:fieldset>
     </div>
    </g:if>

    <g:else>
      <form class="box-form box-form-180 box-form-200-legend" id="import-form">
        <is:fieldset title="is.dialog.importProject.confirm.title" nolegend="true">
          <is:fieldInformation noborder="true">
            <g:message code="is.dialog.importProject.confirm.description"/>
            <g:if test="${product.erasableByUser}">
              <br/>
              <g:message code="is.dialog.importProject.confirm.erasable.description"/>
            </g:if>
            <g:if test="${importMustChangeValues}">
              <br/>
              <g:message code="is.dialog.importProject.confirm.changeValues.description"/>
            </g:if>
          </is:fieldInformation>

          <is:accordion id="preferences" autoHeight="false" active="0">

            <g:if test="${importMustChangeValues || product.erasableByUser}">
              <is:accordionSection title="is.dialog.importProject.confirm.changeValues.title">
                <g:if test="${product.erasableByUser}">
                  <is:fieldRadio for="producterasableByUser" label="is.product.erasableByUser" noborder="${(!teamsErrors).toString()}">
                    <is:radio id="producterasableByUser" name="productd.erasableByUser" value="1" onClick="\$('#productname-field').parent().toggle();\$('#productpkey-field').parent().toggle();"/>
                  </is:fieldRadio>
                 </g:if>
                <g:if test="${product.hasErrors()}">
                   <is:fieldInput label="is.product.name" for="productname" noborder="${(!teamsErrors).toString()}" style="display:${product.erasableByUser?'none':'block'}">
                    <is:input id="productname"  name="productd.name" value="${product.name}"/>
                  </is:fieldInput>
                  <is:fieldInput label="is.product.pkey" for="productpkey" noborder="${(!teamsErrors).toString()}" style="display:${product.erasableByUser?'none':'block'}">
                    <is:input id="productpkey"  name="productd.pkey" value="${product.pkey}"/>
                  </is:fieldInput>
                </g:if>
                <g:each in="${teamsErrors}" var="team" status="current">
                  <is:fieldInput label="is.dialog.importProject.team.name" for="teamname${team.uid}" noborder="${(!usersErrors).toString()}">
                    <is:input id="teamname${team.uid}"  name="team.name.${team.uid}" value="${team.name}"/>
                  </is:fieldInput>
                </g:each>
                <g:each in="${usersErrors}" var="user" status="current">
                  <is:fieldInput label="is.dialog.importProject.user.name" for="username${user.uid}" noborder="${(current >= usersErrors.size() - 1).toString()}">
                    <is:input id="username${user.uid}"  name="user.username.${user.uid}" value="${user.username}"/>
                  </is:fieldInput>
                </g:each>
              </is:accordionSection>
            </g:if>

            <is:accordionSection title="is.dialog.importProject.confirm.details.title">
                <g:if test="${!product.hasErrors() && !product.erasableByUser}">
                  <is:fieldInput label="is.product.name" for="name">
                    <is:input id="name"  name="name" value="${product.name}" disabled="disabled"/>
                  </is:fieldInput>
                  <is:fieldInput label="is.product.pkey" for="pkey">
                    <is:input id="pkey"  name="pkey" value="${product.pkey}" disabled="disabled"/>
                  </is:fieldInput>
                </g:if>
                <is:fieldArea label="is.product.description" for="description">
                  <is:area rich="[disabled:true]" id="description" name="description" value="${product.description}"/>
                </is:fieldArea>
                <is:fieldInput label="is.product.startDate" for="startDate">
                  <is:input id="startDate"  name="startDate" disabled="disabled" value="${g.formatDate(date:product.startDate, formatName:'is.date.format.short')}"/>
                </is:fieldInput>
                <is:fieldInput label="is.dialog.importProject.confirm.details.stories" for="stories">
                  <is:input id="stories"  name="stories" disabled="disabled" value="${product.stories?.size()?:0}"/>
                </is:fieldInput>
                <is:fieldInput label="is.dialog.importProject.confirm.details.releases" for="releases">
                  <is:input id="releases"  name="releases" disabled="disabled" value="${product.releases?.size()?:0}"/>
                </is:fieldInput>
                <is:fieldInput label="is.dialog.importProject.confirm.details.teams" for="teams">
                  <is:input id="teams"  name="teams" disabled="disabled" value="${product.teams.size()}"/>
                </is:fieldInput>
                <is:fieldInput label="is.dialog.importProject.confirm.details.members" noborder="true" for="members">
                  <is:input id="members"  name="members" disabled="disabled" value="${product.getAllUsers().size()}"/>
                </is:fieldInput>
            </is:accordionSection>

          </is:accordion>
        </is:fieldset>
      </form>
      <jq:jquery>
        jQuery('.ui-dialog-buttonpane button:eq(1)').show();
      </jq:jquery>
    </g:else>