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
<div
     data-accordion="true"
     data-elemid="${story.id}"
     data-editable="true"
     data-editable-url="${createLink(controller: 'story', action: 'update', params: [product: params.product])}"
     data-editable-name="story">
    <h3><a href="#">${ message(code: "is.story") + ' - ' + story.uid}</a></h3>
    <div>
        <div class="field editable" data-editable-field="name" data-editable-type="text">${story.name}</div>
        <div class="field editable" data-editable-field="description" data-editable-type="textarea">${story.description}</div>
        <div class="field editable" data-editable-field="type" data-editable-type="selectui" data-editable-values="${storyTypes}">${story.type}</div>
        <div class="field editable" data-editable-field="feature.id" data-editable-type="selectui" data-placeholder="${message(code: 'is.ui.story.nofeature')}" data-allow-clear="true" data-editable-values="${features}">${story.feature}</div>
        <input type="hidden" name="story.tags" data-tag="true" data-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}" value="${story.tags}"/>
        <div class="field editable" data-editable-field="notes" data-editable-type="richarea">${story.notes}</div>
    </div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.test"/></a></h3>
    <div>

    </div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.comments"/></a></h3>
    <div>

    </div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.summary"/></a></h3>
    <div>

    </div>
</div>
</div>