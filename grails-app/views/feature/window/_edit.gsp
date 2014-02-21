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
<%@ page import="org.icescrum.core.domain.PlanningPokerGame; org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-edit-feature">
    <g:set var="updateUrl" value="${createLink(controller: 'feature', action: 'update', id:'** feature.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'feature', id:'** feature.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <h3><a href="#">** feature.id ** - ** feature.name **</a></h3>
    <div id="right-feature-container" class="right-properties no-fix-fill-accordion-bottom accordion-visible-on-hidden" data-elemid="** feature.id **">
        <div class="field fix-hidden-accordion-visible" style="width:90%">
            <label for="feature.name">${message(code:'is.feature.name')}</label>
            <input required
                   name="feature.name"
                   type="text"
                   class="important"
                   data-txt
                   data-txt-change="${updateUrl}"
                   value="** feature.name **">
        </div>
        <hr class="fix-hidden-accordion-visible">
        <div class="field fix-hidden-accordion-visible" style="height:100px">
            <label for="feature.description">${message(code:'is.backlogelement.description')}</label>
            <textarea name="feature.description"
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                      data-txt
                      data-txt-change="${updateUrl}">** feature.description **</textarea>
        </div>
        <hr>
        <div class="field" style="width:30%">
            <label for="feature.value">${message(code:'is.feature.value')}</label>
            <select name="feature.value"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** feature.value **">
                <is:options values="${PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)}" />
            </select>
        </div>
        <div class="field" style="width:30%">
            <label for="feature.type">${message(code:'is.feature.type')}</label>
            <select name="feature.type"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** feature.type **">
                <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
            </select>
        </div>
        <div class="field" style="width:30%">
            <label for="feature.type">${message(code:'is.feature.color')}</label>
            <select name="feature.color"
                    style="width:100%"
                    data-sl2
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** feature.color **">
                <is:options values="${is.internationalizeValues(map: BundleUtils.colorsSelect)}" />
            </select>
        </div>
        <hr>
        <div class="field">
            <label for="feature.tags">${message(code:'is.backlogelement.tags')}</label>
            <input  type="hidden"
                    name="feature.tags"
                    style="width:100%"
                    data-sl2tag
                    data-sl2tag-tag-link="#finder?tag="
                    data-sl2tag-change="${updateUrl}"
                    data-sl2tag-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                    data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                    value="** feature.tags **"/>
        </div>
        <hr>
        <div class="field">
            <label for="feature.notes">${message(code:'is.backlogelement.notes')}</label>
            <textarea name="feature.notes"
                      data-mkp
                      data-mkp-placeholder="_${message(code: 'is.ui.backlogelement.nonotes')}_"
                      data-mkp-height="170"
                      data-mkp-change="${updateUrl}">** feature.notes **</textarea>
        </div>
        <hr>
        <div class="attachments dropzone-previews"
             data-dz
             data-dz-id="right-feature-container"
             data-dz-add-remove-links="true"
             data-dz-files='** JSON.stringify(feature.attachments) **'
             data-dz-clickable="#right-feature-container .clickable"
             data-dz-url="${attachmentUrl}"
             data-dz-previews-container="#right-feature-container .attachments .previews">
            <div class="providers">
                <span class="icon is-icon-paperclip clickable" title="${message(code: 'is.ui.backlogelement.attachfiles')}">${message(code: 'is.ui.backlogelement.attachfiles')}</span>
                <button data-ui-button class="clickable">${message(code: 'is.ui.backlogelement.attachfiles')}</button>
            </div>
            <div class="previews"></div>
        </div>
    </div>
    <h3><a href="#">Stories</a></h3>
</underscore>