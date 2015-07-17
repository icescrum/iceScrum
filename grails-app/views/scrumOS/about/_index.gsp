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
<is:dialog resizable="false"
           withTitlebar="false"
           noprefix="true"
           width="600"
           height="430"
           buttons="'${message(code: 'is.button.close')}': function() { jQuery(this).dialog('close'); }"
           draggable="false">
    <is:tabs elementId="about-tabs">
        <g:if test="${errors}">
            <is:tab elementId="errors-tab" class="about-tab" title="is.dialog.about.errors">
                <g:render template="/${controllerName}/about/errors" model="[errors: errors]"/>
            </is:tab>
        </g:if>
        <is:tab elementId="help-tab" class="about-tab" title="is.dialog.about.help">
            <g:render template="/${controllerName}/about/help" model="[version: about.version]"/>
        </is:tab>
        <entry:point id="about-tabs-first"/>
        <is:tab elementId="version-tab" class="about-tab" title="is.dialog.about.version">
            <g:render template="/${controllerName}/about/version" model="[version: about.version, server: server]"/>
        </is:tab>
        <is:tab elementId="legal-tab" class="about-tab box" title="is.dialog.about.legal">
            <g:render template="/${controllerName}/about/legal"
                      model="[license: about.license.text().encodeAsNL2BR()]"/>
        </is:tab>
        <entry:point id="about-tabs-last"/>
    </is:tabs>
</is:dialog>