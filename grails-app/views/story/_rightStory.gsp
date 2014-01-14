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
            <div class="field editable"
                 name="description"
                 data-raw-value="${story.rawDescription}"
                 data-editable-type="textarea">${story.description}</div>
            <div class="field editable"
                 name="type"
                 data-editable-type="selectui"
                 data-editable-values="${storyTypes}">${story.type}</div>
            <div class="field editable"
                 name="feature.id"
                 data-width="350"
                 data-select-id="${story.feature.id}"
                 data-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: params.product])}"
                 data-editable-type="inputselect"
                 data-placeholder="${message(code: 'is.ui.story.nofeature')}"
                 data-allow-clear="true">${story.feature.name}</div>
            <div class="field editable"
                 name="dependsOn.id"
                 data-width="350"
                 data-select-id="${story.dependsOn.id}"
                 data-url="${createLink(controller: 'story', action: 'dependenceEntries', id: story.id, params: [product: params.product])}"
                 data-editable-type="inputselect"
                 data-placeholder="${message(code: 'is.ui.story.nodependence')}"
                 data-allow-clear="true">${story.dependsOn.name}</div>
            <input
                type="hidden"
                name="story.tags"
                data-change="
                $.ajax({
                    type: 'POST',
                    url: $(this).closest('[data-editable=true]').data('editable-url'),
                    data: {
                        id: $('#right-story-properties').data('elemid'),
                        'story.tags': event.val.join(','),
                        manageTags: true
                    }
                });"
                data-tag="true"
                data-placeholder="${message(code:'is.backlogelement.tags')}"
                data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"
                value="${story.tags}"/>
            <div
                class="field editable"
                name="notes"
                data-raw-value="${story.rawNotes}"
                data-editable-type="richarea">${story.notes}</div>

            <div data-dropzone="true"
                 data-dropzone-id="right-story-properties"
                 data-add-remove-links="${createLink(action:'attachments', controller: 'story', id:story.id, params: [product: params.product])}"
                 data-files='${story.attachments}'
                 data-clickable="#right-story-properties button.clickable"
                 data-url="${createLink(action:'attachments', controller: 'story', id:story.id, params: [product: params.product])}"
                 data-previews-container="#right-story-properties .attachments .previews"
                 class="attachments dropzone-previews">
                <div class="providers">
                    <button class="clickable">file</button>
                </div>
                <div class="previews"></div>
            </div>
    </div>
</div>