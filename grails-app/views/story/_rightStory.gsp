<%@ page import="grails.converters.JSON; org.icescrum.core.utils.BundleUtils; org.icescrum.core.domain.Product" %>
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

<g:set var="storyTypes" value="{${BundleUtils.storyTypes.collect({k, v -> '\'' + k + '\': \'' + message(code: v) + '\''}).join(',')}}"/>

<div id="right-story-properties"
     data-elemid="${story.id}">
    <div data-editable="true"
         data-editable-url="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
         data-editable-name="story">
            <div class="field editable"
                 name="name"
                 data-editable-type="text">${story.name}</div>
            <hr>
            <div class="field editable"
                 name="type"
                 data-editable-type="selectui"
                 data-editable-values="${storyTypes}">${story.type}</div>
            <div class="field editable"
                 name="affectVersion"
                 data-source="${g.createLink(controller:'project', action: 'versions', params:[product:params.product])}"
                 data-min-length="0"
                 data-search-on-init="true"
                 data-editable-type="autocompletable">${story.affectVersion}</div>
            <hr>
            <input
                 type="hidden"
                 class="field"
                 name="feature.id"
                 data-sl2ajax
                 data-sl2ajax-element="story"
                 data-sl2ajax-width="350"
                 data-sl2ajax-init-id="${story.feature.id}"
                 data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
                 data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: params.product])}"
                 data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
                 data-sl2ajax-allow-clear="true"
                 value="${story.feature.name}"/>
            <hr>
            <input
                 type="hidden"
                 class="field"
                 name="dependsOn.id"
                 data-sl2ajax
                 data-sl2ajax-element="story"
                 data-sl2ajax-width="350"
                 data-sl2ajax-init-id="${story.dependsOn.id}"
                 data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id: story.id, params: [product: params.product])}"
                 data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
                 data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
                 data-sl2ajax-allow-clear="true"
                 value="${story.dependsOn.name}"/>
            <hr>
            <div class="field editable"
                 name="description"
                 data-raw-value="${story.rawDescription}"
                 data-at="a"
                 data-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                 data-data="${g.createLink(controller:'actor', action: 'search', params:[product:params.product], absolute: true)}"
                 data-editable-type="atarea">${story.description}</div>
            <hr>
            <input  type="hidden"
                    name="story.tags"
                    style="width:100%"
                    data-sl2tag
                    data-sl2tag-tag-link="#finder?tag="
                    data-sl2tag-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
                    data-sl2tag-placeholder="${message(code:'is.backlogelement.tags')}"
                    data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"
                    value="${story.tags}"/>
            <hr>
            <textarea name="story.notes"
                      data-mkp
                      data-mkp-placeholder="_Aucune notes_"
                      data-mkp-height="170"
                      data-mkp-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}">${story.notes}</textarea>
            <hr>
            <div class="attachments dropzone-previews"
                 data-dz
                 data-dz-id="right-story-properties"
                 data-dz-add-remove-links="${createLink(action:'attachments', controller: 'story', id:story.id, params: [product: params.product])}"
                 data-dz-files='${story.attachments}'
                 data-dz-clickable="#right-story-properties button.clickable"
                 data-dz-url="${createLink(action:'attachments', controller: 'story', id:story.id, params: [product: params.product])}"
                 data-dz-previews-container="#right-story-properties .attachments .previews">
                <div class="providers">
                    <button class="clickable">file</button>
                </div>
                <div class="previews"></div>
            </div>
    </div>
</div>