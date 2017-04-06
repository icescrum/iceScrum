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
<is:modal title="${message(code: 'is.ui.about')}">
    <uib-tabset type="pills" justified="true">
        <uib-tab heading="${message(code: 'is.dialog.about.warnings')}">
            <g:render template="/${controllerName}/about/warnings"/>
        </uib-tab>
        <entry:point id="about-first-tab"/>
        <uib-tab heading="${message(code: 'is.dialog.about.help')}">
            <g:render template="/${controllerName}/about/help" model="[version: about.version]"/>
        </uib-tab>
        <uib-tab heading="${message(code: 'is.dialog.about.version')}">
            <g:render template="/${controllerName}/about/version" model="[version: about.version, versionNumber: versionNumber, server: server, configLocation: configLocation]"/>
        </uib-tab>
        <uib-tab heading="${message(code: 'is.dialog.about.legal')}">
            ${about.license.text().encodeAsNL2BR()}
        </uib-tab>
        <entry:point id="about-last-tab"/>
    </uib-tabset>
</is:modal>