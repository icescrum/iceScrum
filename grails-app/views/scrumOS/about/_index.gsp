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

<div id="dialog"
     data-ui-dialog
     data-ui-dialog-title="${message(code:'is.about')}"
     data-ui-dialog-close-button="true"
     data-ui-dialog-close-text="${message(code:'is.dialog.close')}"
     data-ui-dialog-width="600">
    <div data-ui-tabs>
        <ul>
            <entry:point id="about-tabs-title-first"/>
            <g:if test="${errors}">
                <li><a href="#errors-tab">${message(code:'is.dialog.about.errors')}</a></li>
            </g:if>
            <li><a href="#version-tab">${message(code:'is.dialog.about.version')}</a></li>
            <li><a href="#license-tab">${message(code:'is.dialog.about.license')}</a></li>
            <entry:point id="about-tabs-title-last"/>
        </ul>
        <entry:point id="about-tabs-content-first"/>
        <g:if test="${errors}">
            <div id="errors-tab" class="about-tab">
                <g:render template="/${controllerName}/about/errors" model="[errors:errors]"/>
            </div>
        </g:if>
        <div id="version-tab" class="about-tab">
            <g:render template="/${controllerName}/about/version" model="[version:about.version, server:server]"/>
        </div>
        <div id="license-tab" class="about-tab">
            <g:render template="/${controllerName}/about/license" model="[license:about.license.text().encodeAsNL2BR()]"/>
        </div>
        <entry:point id="about-tabs-content-last"/>
    </div>
</div>