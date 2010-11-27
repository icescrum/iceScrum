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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
  <input type="hidden" name="teamd.id" value="${params.team}">
  <input type="hidden" name="team" value="${params.team}">
  <input type="hidden" name="teamd.version" value="${team.version}">
  <is:fieldset title="is.dialog.project.properties.title">
    <is:fieldInput for="teamname" label="is.team.name">
      <is:input id="teamname" name="teamd.name" value="${team.name}"/>
    </is:fieldInput>
    <is:fieldArea for="teamdescription" label="is.team.description" noborder="true">
      <is:area
              rich="[preview:true,width:330]"
              id="teamdescription"
              name="teamd.description"
              value="${team.description}"/>
    </is:fieldArea>
  </is:fieldset>
  <is:fieldset nolegend="true" title="is.dialog.team.preferences.title">
    <is:accordion id="preferences" autoHeight="false">

      <is:accordionSection title="is.dialog.team.preferences.title">
        <is:fieldRadio for="teampreferencesallowNewMembers" label="is.team.preferences.allowNewMembers">
          <is:radio id="teampreferencesallowNewMembers" name="teamd.preferences.allowNewMembers" value="${team.preferences.allowNewMembers}"/>
        </is:fieldRadio>
        <is:fieldRadio for="teampreferencesallowRoleChange" label="is.team.preferences.allowRoleChange" noborder="true">
          <is:radio id="teampreferencesallowRoleChange" name="teamd.preferences.allowRoleChange" value="${team.preferences.allowRoleChange}"/>
        </is:fieldRadio>
      </is:accordionSection>
    </is:accordion>
  </is:fieldset>
  <sec:access expression="owner()">
    <is:fieldset title="is.dialog.project.others.title" nolegend="true">
      <button onClick="
        if (confirm('${message(code:'is.dialog.team.others.delete.button').encodeAsJavaScript()}')) {
          ${g.remoteFunction(action:'delete',
                             controller:'team',
                             params:[team:params.team],
                             onSuccess:'document.location=data.url;')
           };
        }
        return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
        <g:message code="is.dialog.team.others.delete.button"/>
      </button>
    </is:fieldset>
  </sec:access>
</form>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-project" listenOn="'#form-project input'"/>