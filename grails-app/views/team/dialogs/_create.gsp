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
<form id="teamForm" name="teamForm" method="post" class='box-form box-form-250 box-form-200-legend'>
<is:fieldset title="is.dialog.createTeam.general.title">
    <is:fieldInput for="teamname" label="is.team.name">
      <is:input id="teamname" name="team.name"/>
    </is:fieldInput>
    <is:fieldArea for="teamdescription" label="is.team.description" noborder="true">
      <is:area
              rich="[preview:true,width:335]"
              id="teamdescription"
              name="team.description"/>
    </is:fieldArea>
  </is:fieldset>

  <is:fieldset title="is.dialog.createTeam.search.title">
    <is:autoCompleteChoose  elementLabel="is.ui.autocompletechoose.users" controller="team" action="findMembers" minLength="0" name="is.team.members" resultId="searchid"/>
  </is:fieldset>

</form>