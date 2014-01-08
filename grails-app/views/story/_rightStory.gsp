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

<g:set var="storyTypesList" value="${org.icescrum.core.utils.BundleUtils.storyTypes.collect({k, v -> '\'' + k + '\': \'' + message(code: v) + '\''})}"/>
<g:set var="storyTypes" value="{${storyTypesList.join(',')}}"/>
<g:set var="featuresList" value="${org.icescrum.core.domain.Product.get(params.long('product')).features.collect({'\'' + it.id + '\': \'' + it.name + '\''})}"/>
<g:set var="features" value="{${featuresList.join(', ')}}"/>

<div id="right-story-properties"
     data-elemid="${story.id}">
    <div data-elemid="${story.id}"
         data-editable="true"
         data-editable-url="${createLink(controller: 'story', action: 'update', params: [product: params.product])}"
         data-editable-name="story">
        <div>
            <div class="field editable" name="name" data-editable-type="text">${story.name}</div>
            <div class="field editable" name="description" data-editable-type="textarea">${story.description}</div>
            <div class="field editable" name="type" data-editable-type="selectui" data-editable-values="${storyTypes}">${story.type}</div>
            <div class="field editable" name="feature.id" data-editable-type="selectui" data-placeholder="${message(code: 'is.ui.story.nofeature')}" data-allow-clear="true" data-editable-values="${features}">${story.feature}</div>
            <input type="hidden"
                   name="story.tags"
                   data-change="$.ajax({
                                    type: 'POST',
                                    url: $(this).closest('[data-editable=true]').data('editable-url'),
                                    data: {
                                        id: $(this).closest('[data-editable=true]').data('elemid'),
                                        'story.tags': event.val.join(','),
                                        manageTags: true
                                    }
                               });"
                   data-tag="true"
                   data-placeholder="${message(code:'is.backlogelement.tags')}"
                   data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"
                   value="${story.tags}"/>
            <div class="field editable" name="notes" data-editable-type="richarea">${story.notes}</div>
        </div>
    </div>
</div>