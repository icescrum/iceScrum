%{--
- Copyright (c) 2014 Kagilum SAS
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
<is:modal title="${message(code:'is.about')}">
    <tabset type="tabsType" justified="true">
        <entry:point id="about-tabs-first"/>
        <g:if test="${errors}">
            <tab heading="${message(code:'is.dialog.about.errors')}">
                <g:render template="/${controllerName}/about/errors" model="[errors:errors]"/>
            </tab>
        </g:if>
        <tab heading="${message(code:'is.dialog.about.version')}">
            <g:render template="/${controllerName}/about/version" model="[version:about.version, server:server]"/>
        </tab>
        <tab heading="${message(code:'is.dialog.about.license')}">
            ${about.license.text().encodeAsNL2BR()}
        </tab>
        <entry:point id="about-tabs-last"/>
    </tabset>
</is:modal>