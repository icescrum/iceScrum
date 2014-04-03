%{--
- Copyright (c) 2014 Kagilum.
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
--}%
<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<g:set var="updateUrl" value="${createLink(controller: 'story', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
<script type="text/icescrum-template" id="tpl-story-input-notes">
<label for="story.notes">${message(code:'is.backlogelement.notes')}</label>
<textarea name="story.notes"
          class="form-control"
          data-mkp="true"
          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"
          data-mkp-change="${updateUrl}">** story.notes **</textarea>
<div class="markitup-preview" style="display:none;">** story.notes_html  **</div>
</script>
<script type="text/icescrum-template" id="tpl-story-input-tags">
<input type="hidden"
       name="story.tags"
       style="width:100%"
       class="form-control"
       value="** story.tags **"
       data-sl2tag
       data-sl2tag-tag-link="#finder?tag="
       data-sl2tag-change="${updateUrl}"
       data-sl2tag-placeholder="${message(code:'is.ui.backlogelement.notags')}"
       data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"/>
</script>
<script type="text/icescrum-template" id="tpl-story-input-description">
<label for="story.description">${message(code:'is.backlogelement.description')}</label>
<textarea name="story.description"
          class="form-control"
          data-at
          data-at-at="a"
          data-at-matcher="$.icescrum.story.formatters.description"
          data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
          data-at-placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
          data-at-change="${updateUrl}"
          data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
          data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}">** story.description **</textarea>
</script>
<script type="text/icescrum-template" id="tpl-story-input-dependsOn">
<label for="story.dependsOn.id">${message(code:'is.story.dependsOn')}</label>
**# if (story.dependsOn) { **
<div class="input-group">
    **# } **
    <input  type="hidden"
            name="story.dependsOn.id"
            style="width:100%;"
            class="form-control"
            data-sl2ajax
            data-sl2ajax-change="${updateUrl}"
            data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
            data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
            data-sl2ajax-allow-clear="true"
            value="**# if (story.dependsOn) { **** story.dependsOn.name ** (** story.dependsOn.uid **) **# } **"/>
    **# if (story.dependsOn) { **
    <span class="input-group-btn">
        <a href="#story/** story.dependsOn.id **"
           title="** story.dependsOn.name **"
           class="btn btn-default">
            <i class="fa fa-external-link"></i>
        </a>
    </span>
</div>
**# } **
<div class="clearfix" style="margin-top: 15px;">
    **# if (_.size(story.dependences) > 0) { **
    <strong>${message(code:'is.story.dependences')} :</strong>
    **# _.each(story.dependences, function(item) { **
    <a class="scrum-link" title="** item.name **">** item.name **</a>
    **# }) **
    **# } **
</div>
</script>
<script type="text/icescrum-template" id="tpl-story-input-type">
<div class="form-group ** iff(story.type == $.icescrum.story.TYPE_DEFECT, 'col-md-6') **">
    <label for="story.type">${message(code:'is.story.type')}</label>
    <select name="story.type"
            class="form-control"
            style="width:100%"
            data-sl2
            data-sl2-format-result="$.icescrum.story.formatSelect"
            data-sl2-format-selection="$.icescrum.story.formatSelect"
            data-sl2-change="${updateUrl}"
            data-sl2-value="** story.type **">
        <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}" />
    </select>
</div>
<div class="col-md-6 form-group ** iff(story.type != $.icescrum.story.TYPE_DEFECT, 'hidden') **">
    <label for="story.affectVersion">${message(code:'is.story.affectVersion')}</label>
    <input type="hidden"
           name="story.affectVersion"
           style="width:100%"
           class="form-control"
           value="** story.affectVersion **"
           data-sl2ajax
           data-sl2ajax-change="${updateUrl}"
           data-sl2ajax-placeholder="${message(code:'is.ui.story.noaffectversion')}"
           data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-sl2ajax-allow-clear="true"
           data-sl2ajax-create-choice-on-empty="true"/>
</div>
</script>
<script type="text/icescrum-template" id="tpl-story-input-feature">
<label for="story.feature.id">${message(code:'is.feature')}</label>
**# if (story.feature) { **
<div class="input-group">
    **# } **
    <input  type="hidden"
            name="story.feature.id"
            style="width:100%;"
            class="form-control"
            value="**# if (story.feature) { **** story.feature.name ****# } **"
            data-sl2ajax
            data-sl2ajax-format-result="$.icescrum.feature.formatSelect"
            data-sl2ajax-format-selection="$.icescrum.feature.formatSelect"
            data-sl2ajax-created="$.icescrum.feature.formatSelect"
            data-sl2ajax-change="${updateUrl}"
            data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
            data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
            data-sl2ajax-allow-clear="true"
            data-color="**# if (story.feature) { **** story.feature.color ****# } **"/>
    **# if (story.feature) { **
    <span class="input-group-btn">
        <a href="#feature/** story.feature.id **"
           title="** story.feature.name **"
           class="btn btn-default">
            <i class="fa fa-external-link"></i>
        </a>
    </span>
</div>
**# } **
</script>
<script type="text/icescrum-template" id="tpl-story-input-name">
<label for="story.name">${message(code:'is.story.name')}</label>
<div class="input-group">
    <input required
           name="story.name"
           type="text"
           class="form-control"
           data-txt
           data-txt-change="${updateUrl}"
           data-txt-binding-id="** story.id **"
           value="** story.name **">
    <span class="input-group-btn">
        <button type="button"
                tabindex="-1"
                data-title="${message(code:'is.permalink')}"
                data-toggle="popover"
                data-content="** $.icescrum.o.grailsServer **/** $.icescrum.product.pkey **-** story.uid **"
                data-container="body"
                data-placement="left"
                class="btn btn-default">
            <i class="fa fa-link"></i>
        </button>
    </span>
</div>
</script>