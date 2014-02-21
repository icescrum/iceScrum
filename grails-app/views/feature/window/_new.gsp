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
<underscore id="tpl-new-feature">
    <h3><a href="#">${message(code: "is.ui.feature.toolbar.new")} ${message(code: "is.feature")}</a></h3>
    <div id="right-feature-container" class="right-properties new">
        <div class="field"  style="width:100%">
            <label for="feature.name">${message(code:'is.feature.name')}</label>
            <input required="required"
                   name="feature.name"
                   type="text"
                   class="important"
                   value=""
                   placeholder="${message(code: 'is.ui.feature.noname')}"
                   data-txt
                   data-txt-only-return="true"
                   data-txt-on-save="$.icescrum.feature.afterSave"
                   data-txt-change="${createLink(controller: 'feature', action: 'save', params: [product: '** jQuery.icescrum.product.pkey **'])}">
        </div>
    </div>
</underscore>