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
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
  <input type="hidden" name="productd.id" value="${params.product}">
  <input type="hidden" name="product" value="${params.product}">
  <input type="hidden" name="productd.version" value="${product.version}">
  <is:fieldset title="is.dialog.project.properties.title">
    <is:fieldInput for="productname" label="is.product.name">
      <is:input id="productname" name="productd.name" value="${product.name}"/>
    </is:fieldInput>
    <is:fieldInput for="productkey" label="is.dialog.project.properties.pkey">
      <is:input typed="[type:'alphanumeric',onlyletters:true,allcaps:true]" id="productkey" name="productd.pkey" value="${product.pkey}"/>
    </is:fieldInput>
    <is:fieldRadio rendered="${!privateOption}" for="productpreferenceshidden" label="is.product.preferences.project.hidden">
        <is:radio id="productpreferenceshidden" name="productd.preferences.hidden" value="${product.preferences.hidden}"/>
    </is:fieldRadio>
    <is:fieldSelect for="productpreferencestimezone" label="is.product.preferences.timezone">
        <is:localeTimeZone width="250" maxHeight="200" styleSelect="dropdown"
                           name="productd.preferences.timezone" id="productpreferencestimezone"
                           value="${product.preferences.timezone}"/>
    </is:fieldSelect>
    <is:fieldArea for="productdescription" label="is.product.description" noborder="true">
      <is:area
              rich="[preview:true,width:330]"
              id="productdescription"
              name="productd.description"
              value="${product.description}"/>
    </is:fieldArea>
  </is:fieldset>
</form>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-project" listenOn="'#form-project input'"/>