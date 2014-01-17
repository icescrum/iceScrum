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

<g:set var="storyTypes" value="[:]"/>
<% BundleUtils.storyTypes.collect { k, v -> storyTypes[k] = message(code: v) } %>

<div id="right-story-properties" data-elemid="${story.id}">
    <input required
           name="story.name"
           type="text"
           class="important"
           onkeyup="jQuery.icescrum.story.findDuplicate(this.value)"
           onblur="jQuery.icescrum.story.findDuplicate(null)"
           data-txt
           data-txt-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
           value="${story.name}">
    <span class="duplicate"></span>
    <hr>
    <div class="inline">
        <select name="story.type"
                style="width:33%;"
                class="important"
                onchange="jQuery.icescrum.story.typeChanged(this)"
                data-sl2
                data-sl2-icon-class="ico-story-"
                data-sl2-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
                data-sl2-value="${story.type}">
            <is:options values="${storyTypes}" />
        </select>
    </div>
    <hr>
    <input type="hidden"
           name="story.affectVersion"
           style="width:90%"
           data-sl2ajax
           data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
           data-sl2ajax-placeholder="${message(code:'is.story.affectVersion')}"
           data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:params.product])}"
           data-sl2ajax-allow-clear="true"
           data-sl2ajax-create-choice-on-empty="true"
           value="${story.affectVersion}"/>
    <hr>
    <input
         type="hidden"
         name="story.feature.id"
         style="width:90%;"
         data-sl2ajax
         data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
         data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: params.product])}"
         data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
         data-sl2ajax-allow-clear="true"
         value="${story.feature.name}"/>
    <hr>
    <input
         type="hidden"
         name="story.dependsOn.id"
         style="width:90%;"
         data-sl2ajax
         data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id: story.id, params: [product: params.product])}"
         data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
         data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
         data-sl2ajax-allow-clear="true"
         value="${story.dependsOn.name}"/>
    <hr>
    <textarea name="story.description"
         class="selectallonce"
         data-at
         data-at-at="a"
         data-at-matcher="$.icescrum.story.storyTemplate"
         data-at-change="${createLink(controller: 'story', action: 'update', params: [product: params.product, id:story.id])}"
         data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
         data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:params.product], absolute: true)}">${story.description}</textarea>
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