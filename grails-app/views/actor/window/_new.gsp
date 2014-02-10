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
<underscore id="tpl-new-actor">
    <h3><a href="#">${message(code: "is.ui.actor.toolbar.new")} ${message(code: "is.actor")}</a></h3>
    <div id="right-actor-container" class="right-properties new">
        <div id="right-actor-template">
            <div class="help">${message(code:'is.ui.actor.help')}</div>
            **# if (template) { **
                <div class="postit actor postit-actor">
                    <div class="postit-layout">
                        <p class="postit-id">
                            <b title="Yes the devil!">666</b>
                        </p>
                        <p class="postit-label break-word">** actor.name **</p>
                        <div class="postit-excerpt">** actor.description **</div>
                    </div>
                </div>
            **# } **
        </div>
        <div class="field"  style="width:100%">
            <label for="actor.name">${message(code:'is.actor.name')}</label>
            <input required="required"
                   name="actor.name"
                   type="text"
                   class="important"
                   value=""
                   placeholder="${message(code: 'is.ui.actor.noname')}"
                   data-txt
                   data-txt-only-return="true"
                   data-txt-on-save="$.icescrum.actor.afterSave"
                   data-txt-change="${createLink(controller: 'actor', action: 'save', params: [product: '** jQuery.icescrum.product.pkey **', template:'** template **'])}">
        </div>
    </div>
</underscore>