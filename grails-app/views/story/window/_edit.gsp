<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-edit-story">
    <g:set var="storyTypes" value="[:]"/>
    <%  //todo refactor like languages taglib return object
        BundleUtils.storyTypes.collect { k, v -> storyTypes[k] = message(code: v) } %>
    <g:set var="updateUrl" value="${createLink(controller: 'story', action: 'update', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'story', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <h3><a href="#">** story.id ** - ** story.name **</a></h3>
    <div id="right-story-container" class="right-properties no-fix-fill-accordion-bottom accordion-visible-on-hidden" data-elemid="** story.id **">
        <div class="field fix-hidden-accordion-visible" style="width:90%">
            <label for="story.name">${message(code:'is.story.name')}</label>
            <input required
                   name="story.name"
                   type="text"
                   class="important"
                   data-txt
                   data-txt-change="${updateUrl}"
                   value="** story.name **">
        </div>
        <a href="** $.icescrum.o.baseUrl **** $.icescrum.product.pkey **-** story.uid **">
            <span class="icon is-icon-permalink" title="${message(code:'is.permalink')}">${message(code:'is.permalink')}</span>
        </a>
        <hr class="fix-hidden-accordion-visible">
        <div class="field" style="width:33%">
            <label for="story.type">${message(code:'is.story.type')}</label>
            <select name="story.type"
                    class="important"
                    style="width:100%"
                    data-sl2
                    data-sl2-icon-class="ico-story-"
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="** story.type **">
                <is:options values="${storyTypes}" />
            </select>
        </div>
        <hr>
        **# if(story.type == $.icescrum.story.TYPE_DEFECT) { **
        <div class="field" style="width:90%">
            <label for="story.affectVersion">${message(code:'is.story.affectVersion')}</label>
            <input type="hidden"
                   name="story.affectVersion"
                   style="width:100%"
                   data-sl2ajax
                   data-sl2ajax-change="${updateUrl}"
                   data-sl2ajax-placeholder="${message(code:'is.ui.story.noaffectversion')}"
                   data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                   data-sl2ajax-allow-clear="true"
                   data-sl2ajax-create-choice-on-empty="true"
                   value="** story.affectVersion **"/>
        </div>
        <hr>
        **# } **
        <div class="field" style="width:90%">
            <label for="story.feature.id">${message(code:'is.feature')}</label>
            <input
                type="hidden"
                name="story.feature.id"
                style="width:100%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
                data-sl2ajax-allow-clear="true"
                value="**# if (story.feature) { **** story.feature.name ****# } **"/>
        </div>
        **# if (story.feature) { **
        <a href=""><span class="icon is-icon-link" title="** story.feature.name **">** story.feature.name **</span></a>
        **# } **
        <hr>
        <div class="field" style="width:90%">
            <label for="story.dependsOn.id">${message(code:'is.story.dependsOn')}</label>
            <input
                type="hidden"
                name="story.dependsOn.id"
                style="width:100%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
                data-sl2ajax-allow-clear="true"
                value="**# if (story.dependsOn) { **** story.dependsOn.name ** (** story.dependsOn.uid **) **# } **"/>
        </div>
        **# if (story.dependsOn) { **
            <a href=""><span class="icon is-icon-link" title="** story.dependsOn.name **">** story.dependsOn.name **</span></a>
        **# } **
        <hr>
        **# if (_.size(story.dependences) > 0) {
            _.each(story.dependences, function(item) { **
                <a class="scrum-link" title="** item.name **">** item.name **</a>
        **# }) **
        <hr>
        **# } **
        <div class="field fix-hidden-accordion-visible" style="height:100px">
            <label for="story.description">${message(code:'is.backlogelement.description')}</label>
            <textarea name="story.description"
                      data-at
                      data-at-at="a"
                      data-at-matcher="$.icescrum.story.formatters.description"
                      data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                      data-at-placeholder="${message(code: 'is.ui.story.nodescription')}"
                      data-at-change="${updateUrl}"
                      data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                      data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}">** story.description **</textarea>
        </div>
        <hr>
        <div class="field">
            <label for="story.tags">${message(code:'is.backlogelement.tags')}</label>
            <input  type="hidden"
                    name="story.tags"
                    style="width:100%"
                    data-sl2tag
                    data-sl2tag-tag-link="#finder?tag="
                    data-sl2tag-change="${updateUrl}"
                    data-sl2tag-placeholder="${message(code:'is.ui.story.notags')}"
                    data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                    value="** story.tags **"/>
        </div>
        <hr>
        <div class="field">
            <label for="story.notes">${message(code:'is.backlogelement.notes')}</label>
            <textarea name="story.notes"
                      data-mkp
                      data-mkp-placeholder="_${message(code: 'is.ui.story.nonotes')}_"
                      data-mkp-height="170"
                      data-mkp-change="${updateUrl}">** story.notes **</textarea>
        </div>
        <hr>
        <div class="attachments dropzone-previews"
             data-dz
             data-dz-id="right-story-container"
             data-dz-add-remove-links="true"
             data-dz-files='** JSON.stringify(story.attachments) **'
             data-dz-clickable="#right-story-container .clickable"
             data-dz-url="${attachmentUrl}"
             data-dz-previews-container="#right-story-container .attachments .previews">
            <div class="providers">
                <span class="icon is-icon-paperclip clickable" title="Attach file(s)">Attach file(s)</span>
                <button data-ui-button class="clickable">Attach file(s)</button>
            </div>
            <div class="previews"></div>
        </div>
    </div>
    <h3><a href="#">summary</a></h3>
    <div></div>
    <h3><a href="#">comments</a></h3>
    <div></div>
    <h3><a href="#">Acceptance tests</a></h3>
    <div></div>
    <h3><a href="#">tasks</a></h3>
    <div></div>
</underscore>