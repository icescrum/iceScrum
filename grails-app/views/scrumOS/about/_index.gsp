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
<is:tabs elementId="about-tabs">
  <is:tab elementId="company-tab" class="about-tab" title="is.dialog.about.services">
    <g:include view="${id}/about/_services.gsp" model="[services:about.services]"/>
  </is:tab>
  <is:tab elementId="team-tab" class="about-tab" title="is.dialog.about.team">
    <g:include view="${id}/about/_team.gsp" model="[team:about.team]"/>
  </is:tab>
  <is:tab elementId="contributors-tab" class="about-tab" title="is.dialog.about.contributors">
    <g:include view="${id}/about/_contributor.gsp" model="[contributors:about.contributors]"/>
  </is:tab>
  <is:tab elementId="version-tab" class="about-tab" title="is.dialog.about.version">
    <g:include view="${id}/about/_version.gsp" model="[version:about.version]"/>
  </is:tab>
  <is:tab elementId="license-tab" class="about-tab box" title="is.dialog.about.license">
    <g:include view="${id}/about/_license.gsp" model="[license:about.license.text().encodeAsNL2BR()]"/>
  </is:tab>
</is:tabs>