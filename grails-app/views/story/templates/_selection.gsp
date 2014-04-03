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
<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.utils.BundleUtils" %>
<script type="text/icescrum-template" id="tpl-story-multiple">
<g:set var="storyTypes" value="[:]"/>
<% BundleUtils.storyTypes.collect { k, v -> storyTypes[k] = message(code: v) } %>
<h3><a href="#">${message(code: "is.ui.selection")}</a></h3>
<div id="right-story-container" class="right-properties">
    <div class="stack twisted">
        <div class="postit story postit-story ui-selectee">
            <div class="postit-layout **# if(story.feature){ ** postit-** story.feature.color ** **# } **">
                <p class="postit-id">** story.uid **</p>
                <div class="icon-container"></div>
                <p class="postit-label break-word">** story.name **</p>
                <div class="postit-excerpt">** story.description **</div>
                <span class="postit-ico ico-story-** story.type **"></span>
                <div class="state task-state">
                    <span class="text-state">** $.icescrum.story.formatters.state(story) **</span>
                </div>
            </div>
        </div>
    </div>
    **# if ($.icescrum.user.productOwner) { **
    <div class="actions">
        <a href="${createLink(controller: 'story', action: 'copy', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-sync='story'
           data-ajax-data='** JSON.stringify({id:ids}) **'
           data-is-shortcut
           data-is-shortcut-key="c">${message(code:'is.ui.sandbox.menu.clone')}</a>
        **# if (story.state <= $.icescrum.story.STATE_ESTIMATED) { **
        <a href="${createLink(controller: 'story', action: 'delete', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-success="$.icescrum.story.delete"
           data-ajax-data='** JSON.stringify({id:ids}) **'
           data-is-shortcut
           data-is-shortcut-key="del">${message(code:'is.ui.sandbox.menu.delete')}</a>
        **# } **
        **# if (story.state == $.icescrum.story.STATE_SUGGESTED) { **
        <a href="${createLink(controller: 'story', action: 'update', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-sync='story'
           data-ajax-data='** JSON.stringify({id:ids, "story.state": ${Story.STATE_ACCEPTED}}, true) **'>${message(code:'is.ui.sandbox.menu.acceptAsStory')}</a>
        <a href="${createLink(controller: 'story', action: 'acceptAsFeature', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-success="$.icescrum.story.delete"
           data-ajax-data='** JSON.stringify({id:ids}) **'>${message(code:'is.ui.sandbox.menu.acceptAsFeature')}</a>
        **# if ($.icescrum.sprint.current) { **
        <a href="${createLink(controller: 'story', action: 'acceptAsTask', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-ui-button
           data-ajax
           data-ajax-method="POST"
           data-ajax-success="$.icescrum.story.delete"
           data-ajax-data='** JSON.stringify({id:ids}) **'>${message(code:'is.ui.sandbox.menu.acceptAsUrgentTask')}</a>
        **# } **
        **# } **
        <entry:point id="tpl-multiple-stories-actions"/>
    </div>
    <hr>
    <input type="hidden"
           name="story.feature.id"
           style="width:100%;"
           data-sl2ajax
           data-sl2ajax-change="${createLink(controller: 'story', action: 'update', params: [product: '** jQuery.icescrum.product.pkey **'])}?** $.param({id:ids}, true) **"
           data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
           data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
           data-sl2ajax-allow-clear="true"/>
    <hr/>
    <select name="story.type"
            style="width:100%;"
            class="important"
            data-sl2
            data-sl2-icon-class="ico-story-"
            data-sl2-change="${createLink(controller: 'story', action: 'update', params: [product: '** jQuery.icescrum.product.pkey **'])}?** $.param({id:ids}, true) **">
        <is:options values="${storyTypes}" />
    </select>
    **# } **
    <entry:point id="tpl-multiple-stories"/>
</div>
</script>