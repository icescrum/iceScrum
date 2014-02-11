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
<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-edit-actor">
    <g:set var="updateUrl" value="${createLink(controller: 'actor', action: 'update', id:'** actor.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'actor', id:'** actor.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <h3><a href="#">** actor.id ** - ** actor.name **</a></h3>
    <div id="right-actor-container" class="right-properties no-fix-fill-accordion-bottom accordion-visible-on-hidden" data-elemid="** actor.id **">
        <div class="field fix-hidden-accordion-visible" style="width:90%">
            <label for="actor.name">${message(code:'is.actor.name')}</label>
            <input required
                   name="actor.name"
                   type="text"
                   class="important"
                   data-txt
                   data-txt-change="${updateUrl}"
                   value="** actor.name **">
        </div>
        <hr class="fix-hidden-accordion-visible">
        <div class="field" style="width:30%">
            <label for="actor.instances">${message(code:'is.actor.instances')}</label>
            <select name="actor.instances"
                    class="important"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** actor.instances **">
                <is:options values="${BundleUtils.actorInstances}" />
            </select>
        </div>
        <div class="field" style="width:30%">
            <label for="actor.expertnessLevel">${message(code:'is.actor.it.level')}</label>
            <select name="actor.expertnessLevel"
                    class="important"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** actor.expertnessLevel **">
                <is:options values="${is.internationalizeValues(map: BundleUtils.actorLevels)}" />
            </select>
        </div>
        <div class="field" style="width:30%">
            <label for="actor.useFrequency">${message(code:'is.actor.use.frequency')}</label>
            <select name="actor.useFrequency"
                    class="important"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** actor.useFrequency **">
                <is:options values="${is.internationalizeValues(map: BundleUtils.actorFrequencies)}" />
            </select>
        </div>
        <hr>
        <div class="field fix-hidden-accordion-visible" style="height:100px">
            <label for="actor.description">${message(code:'is.backlogelement.description')}</label>
            <textarea name="actor.description"
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                      data-txt
                      data-txt-change="${updateUrl}">** actor.description **</textarea>
        </div>
        <hr>
        <div class="field">
            <label for="actor.tags">${message(code:'is.backlogelement.tags')}</label>
            <input  type="hidden"
                    name="actor.tags"
                    style="width:100%"
                    data-sl2tag
                    data-sl2tag-tag-link="#finder?tag="
                    data-sl2tag-change="${updateUrl}"
                    data-sl2tag-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                    data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                    value="** actor.tags **"/>
        </div>
        <hr>
        <div class="field">
            <label for="actor.notes">${message(code:'is.backlogelement.notes')}</label>
            <textarea name="actor.notes"
                      data-mkp
                      data-mkp-placeholder="_${message(code: 'is.ui.backlogelement.nonotes')}_"
                      data-mkp-height="170"
                      data-mkp-change="${updateUrl}">** actor.notes **</textarea>
        </div>
        <hr>
        <div class="attachments dropzone-previews"
             data-dz
             data-dz-id="right-actor-container"
             data-dz-add-remove-links="true"
             data-dz-files='** JSON.stringify(actor.attachments) **'
             data-dz-clickable="#right-actor-container .clickable"
             data-dz-url="${attachmentUrl}"
             data-dz-previews-container="#right-actor-container .attachments .previews">
            <div class="providers">
                <span class="icon is-icon-paperclip clickable" title="${message(code: 'is.ui.backlogelement.attachfiles')}">${message(code: 'is.ui.backlogelement.attachfiles')}</span>
                <button data-ui-button class="clickable">${message(code: 'is.ui.backlogelement.attachfiles')}</button>
            </div>
            <div class="previews"></div>
        </div>
    </div>
    <h3><a href="#">Stories</a></h3>
    <div></div>
</underscore>