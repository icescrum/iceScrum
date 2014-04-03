%{--
- Copyright (c) 2014 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<div data-binding-type="feature"
     data-binding-watch="array"
     data-binding-selector="#features-size"
     data-binding-tpl="tpl-features">

    <select name="export"
            onchange="$.icescrum.downloadExport(this)"
            style="width:100px;"
            data-sl2-placeholder="Export in"
            data-sl2-icon-class="file-icon format-"
            data-sl2>
                <option></option>
                <g:each in="${exportFormats}" var="format">
                    <option url="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}"
                            value="${format.code.toLowerCase()}">${format.name}</option>
                </g:each>
    </select>
    <entry:point id="${controllerName}-${actionName}"/>
</div>
<script type="text/icescrum-template" id="tpl-features" style="display:none">
    <span id="features-size">** _.size(list) ** ${message(code:'is.ui.feature.features')}</span>
</script>