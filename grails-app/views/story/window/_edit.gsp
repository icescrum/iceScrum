<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-edit-story">
    <g:set var="storyTypes" value="[:]"/>
    <% BundleUtils.storyTypes.collect { k, v -> storyTypes[k] = message(code: v) } %>
    <g:set var="updateUrl" value="${createLink(controller: 'story', action: 'update', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'story', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <h3><a href="#">** story.id ** - ** story.name **</a></h3>
    <div id="right-story-container" class="right-properties" data-elemid="** story.id **">
        <input required
               name="story.name"
               type="text"
               class="important"
               data-txt
               data-txt-change="${updateUrl}"
               value="** story.name **">
        <hr>
        <div class="inline">
            <select name="story.type"
                    style="width:33%;"
                    class="important"
                    data-sl2
                    data-sl2-icon-class="ico-story-"
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** story.type **">
                <is:options values="${storyTypes}" />
            </select>
        </div>
        <hr>
        **# if(story.type == $.icescrum.story.TYPE_DEFECT) { **
        <input type="hidden"
               name="story.affectVersion"
               style="width:90%"
               data-sl2ajax
               data-sl2ajax-change="${updateUrl}"
               data-sl2ajax-placeholder="${message(code:'is.ui.story.noaffectversion')}"
               data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:'** jQuery.icescrum.product.pkey **'])}"
               data-sl2ajax-allow-clear="true"
               data-sl2ajax-create-choice-on-empty="true"
               value="** story.affectVersion **"/>
        <hr>
        **# } **
        <input
                type="hidden"
                name="story.feature.id"
                style="width:90%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
                data-sl2ajax-allow-clear="true"
                value="**# if (story.feature) { **** story.feature.name ****# } **"/>
        <hr>
        <input
                type="hidden"
                name="story.dependsOn.id"
                style="width:90%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
                data-sl2ajax-allow-clear="true"
                value="**# if (story.dependsOn) { **** story.dependsOn.name ** (** story.dependsOn.uid **) **# } **"/>
        <hr>
        <textarea name="story.description"
                  data-at
                  data-at-at="a"
                  data-at-matcher="$.icescrum.story.formatters.description"
                  data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                  data-at-placeholder="${message(code: 'is.ui.story.nodescription')}"
                  data-at-change="${updateUrl}"
                  data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                  data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}">** story.description **</textarea>
        <hr>
        <input  type="hidden"
                name="story.tags"
                style="width:100%"
                data-sl2tag
                data-sl2tag-tag-link="#finder?tag="
                data-sl2tag-change="${updateUrl}"
                data-sl2tag-placeholder="${message(code:'is.ui.story.notags')}"
                data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                value="** story.tags **"/>
        <hr>
        <textarea name="story.notes"
                  data-mkp
                  data-mkp-placeholder="_${message(code: 'is.ui.story.nonotes')}_"
                  data-mkp-height="170"
                  data-mkp-change="${updateUrl}">** story.notes **</textarea>
        <hr>
        <div class="attachments dropzone-previews"
             data-dz
             data-dz-id="right-story-container"
             data-dz-add-remove-links="true"
             data-dz-files='** JSON.stringify(story.attachments) **'
             data-dz-clickable="#right-story-container button.clickable"
             data-dz-url="${attachmentUrl}"
             data-dz-previews-container="#right-story-container .attachments .previews">
            <div class="providers">
                <button class="clickable">file</button>
            </div>
            <div class="previews"></div>
        </div>
    </div>
</underscore>