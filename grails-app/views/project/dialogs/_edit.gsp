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
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
  <input type="hidden" name="productd.id" value="${params.product}">
  <input type="hidden" name="product" value="${params.product}">
  <input type="hidden" name="productd.version" value="${product.version}">
  <is:fieldset title="is.dialog.project.properties.title">
    <is:fieldInput for="productname" label="is.product.name">
      <is:input id="productname" name="productd.name" value="${product.name}"/>
    </is:fieldInput>
    <is:fieldInput for="productkey" label="is.product.pkey">
      <is:input id="productkey" name="productd.pkey" value="${product.pkey}"/>
    </is:fieldInput>
    <is:fieldArea for="productdescription" label="is.product.description" noborder="true">
      <is:area
              rich="[preview:true,width:330]"
              id="productdescription"
              name="productd.description"
              value="${product.description}"/>
    </is:fieldArea>
  </is:fieldset>

  <is:fieldset nolegend="true" title="is.dialog.project.permissions.title">
    <is:accordion id="preferences" autoHeight="false">
      <is:accordionSection title="is.dialog.project.permissions.title">
        <is:fieldRadio rendered="${!privateOption}" for="productpreferenceshidden" label="is.product.preferences.project.hidden">
          <is:radio id="productpreferenceshidden" name="productd.preferences.hidden" value="${product.preferences.hidden}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferencesnewTeams" label="is.product.preferences.project.newTeams">
          <is:radio id="productpreferencesnewTeams" name="productd.preferences.newTeams" value="${product.preferences.newTeams}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferenceslockPo" noborder="true" label="is.product.preferences.project.lockPo">
          <is:radio id="productpreferenceslockPo" name="productd.preferences.lockPo" value="${product.preferences.lockPo}"/>
        </is:fieldRadio>
      </is:accordionSection>
    </is:accordion>
  </is:fieldset>
</form>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-project" listenOn="'#form-project input'"/>