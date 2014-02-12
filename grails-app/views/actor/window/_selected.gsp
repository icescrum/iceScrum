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
<underscore id="tpl-multiple-actors">
    <h3><a href="#">${message(code: "is.ui.selection")}</a></h3>
    <div id="right-actor-container" class="right-properties">
        <div class="stack twisted">
            <div class="postit actor postit-actor ui-selectee">
                <div class="postit-layout">
                    <p class="postit-id">** actor.uid **</p>
                    <div class="icon-container"></div>
                    <p class="postit-label break-word">** actor.name **</p>
                    <div class="postit-excerpt">** actor.description **</div>
                </div>
            </div>
        </div>
        <a href="${createLink(controller: 'actor', action: 'delete', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-success="$.icescrum.actor.delete"
           data-ajax-data='** JSON.stringify({id:ids}) **'
           data-is-shortcut
           data-is-shortcut-key="del">${message(code:'is.ui.sandbox.menu.delete')}</a>
        <entry:point id="tpl-multiple-actors-actions"/>
        <entry:point id="tpl-multiple-actors"/>
    </div>
</underscore>