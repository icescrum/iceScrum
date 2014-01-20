<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-sandbox">
    <span id="stories-sandbox-size">{{ _.size( _.where(list,{ state: $.icescrum.story.STATE_SUGGESTED }) ) }} stories</span>
</underscore>

<underscore id="tpl-postit-row-story">
    <li data-elemid="{{ story.id }}" class="postit-row postit-row-story">
        <em>({{ story.effort }} {{# if(story.effort > 1) { }}pts{{# } else { }}pt{{# } }})</em>
        <span title="{{ story.name }}" class="postit-icon {{# if(story.feature){ }} postit-icon-{{ story.feature.color }} {{# } else { }} postit-yellow {{# } }}"></span>
        {{ story.uid }} - {{ story.name }}
    </li>
</underscore>

<underscore id="tpl-new-story">
    <h3><a href="#">${message(code: "is.story")}</a></h3>
    <div id="right-story-container" class="right-properties">
        <input required="required"
               name="story.name"
               type="text"
               class="important"
               onkeyup="$.icescrum.story.findDuplicate(this.value)"
               onblur="$.icescrum.story.findDuplicate(null)"
               placeholder="${message(code: 'is.ui.story.noname')}"
               data-txt
               data-txt-on-save="$.icescrum.story.afterSave"
               data-txt-change="${createLink(controller: 'story', action: 'save', params: [product: params.product])}">
        <span class="duplicate"></span>
    </div>
</underscore>

<underscore id="tpl-multiple-stories">
    <h3><a href="#">${message(code: "is.story")}</a></h3>
    <div id="right-story-container" class="right-properties">
        <div class="stack twisted">
            <div data-elemid="{{ story.id }}" id="postit-story-{{ story.id }}" class="postit story postit-story ui-selectee">
                <div class="postit-layout {{# if(story.feature){ }} postit-{{ story.feature.color }} {{# } }}">
                    <p class="postit-id">
                        <a class="scrum-link" href="/icescrum/p/TESTPROJ#story/{{ story.id }}">{{ story.id }}</a>
                    </p>
                    <div class="icon-container"></div>
                    <p class="postit-label break-word">{{ story.name }}</p>
                    <div class="postit-excerpt">{{ story.description }}</div>
                    <span class="postit-ico ico-story-{{ story.type }}"></span>
                    <div class="state task-state">
                        <span class="text-state">{{ $.icescrum.story.formatters.state(story.state) }}</span>
                        <div class="dropmenu-action">
                            <div id="menu-postit-story-{{ story.id }}"
                                 data-nowindows="false"
                                 data-offset="0"
                                 data-top="13"
                                 class="dropmenu"
                                 data-dropmenu="true">
                                <span class="dropmenu-arrow">!</span>
                                <div class="dropmenu-content ui-corner-all">
                                    <ul class="small">
                                        <li>
                                            <a data-ajax="true" data-ajax-notice="Story sent back to sandbox"
                                               data-ajax-trigger="returnToSandbox_story"
                                               href="/icescrum/p/1/story/returnToSandbox/{{ story.id }}">return to sandbox</a>
                                        </li>
                                        <li>
                                            <a data-ajax="true"
                                               data-ajax-notice="The story has been successfully copied to the sandbox"
                                               data-ajax-trigger="add_story" href="/icescrum/p/1/story/copy/{{ story.id }}">Copy</a>
                                        </li>
                                        <li>
                                            <a data-ajax="true" href="/icescrum/p/1/story/openDialogDelete/{{ story.id }}">Delete</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</underscore>

<underscore id="tpl-edit-story">
    <g:set var="storyTypes" value="[:]"/>
    <% BundleUtils.storyTypes.collect { k, v -> storyTypes[k] = message(code: v) } %>
    <g:set var="updateUrl" value="${createLink(controller: 'story', action: 'update', id:'{{ story.id }}', params: [product: params.product])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'story', id:'{{ story.id }}', params: [product: params.product])}"/>
    <h3><a href="#">{{ story.id }} - {{ story.name }}</a></h3>
    <div id="right-story-container" class="right-properties" data-elemid="{{ story.id }}">
        <input required
               name="story.name"
               type="text"
               class="important"
               data-txt
               data-txt-change="${updateUrl}"
               value="{{ story.name }}">
        <hr>
        <div class="inline">
            <select name="story.type"
                    style="width:33%;"
                    class="important"
                    data-sl2
                    data-sl2-icon-class="ico-story-"
                    data-sl2-change="${updateUrl}"
                    data-sl2-value="{{ story.type }}">
                <is:options values="${storyTypes}" />
            </select>
        </div>
        <hr>
        {{# if(story.type == $.icescrum.story.TYPE_DEFECT) { }}
        <input type="hidden"
               name="story.affectVersion"
               style="width:90%"
               data-sl2ajax
               data-sl2ajax-change="${updateUrl}"
               data-sl2ajax-placeholder="${message(code:'is.ui.story.noaffectversion')}"
               data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:params.product])}"
               data-sl2ajax-allow-clear="true"
               data-sl2ajax-create-choice-on-empty="true"
               value="{{ story.affectVersion }}"/>
        <hr>
        {{# } }}
        <input
                type="hidden"
                name="story.feature.id"
                style="width:90%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: params.product])}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
                data-sl2ajax-allow-clear="true"
                value="{{# if (story.feature) { }}{{ story.feature.name }}{{# } }}"/>
        <hr>
        <g:set var="dependsOnUrl" value="${createLink(controller: 'story', action: 'dependenceEntries', id:'{{ story.id }}', params: [product: params.product])}"/>
        <input
                type="hidden"
                name="story.dependsOn.id"
                style="width:90%;"
                data-sl2ajax
                data-sl2ajax-change="${updateUrl}"
                data-sl2ajax-url="${dependsOnUrl}"
                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
                data-sl2ajax-allow-clear="true"
                value="{{# if (story.dependsOn) { }}{{ story.dependsOn.name }} ({{ story.dependsOn.id }}) {{# } }}"/>
        <hr>
        <textarea name="story.description"
                  data-at
                  data-at-at="a"
                  data-at-matcher="$.icescrum.story.formatters.description"
                  data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                  data-at-placeholder="${message(code: 'is.ui.story.nodescription')}"
                  data-at-change="${updateUrl}"
                  data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                  data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:params.product], absolute: true)}">{{ story.description }}</textarea>
        <hr>
        <input  type="hidden"
                name="story.tags"
                style="width:100%"
                data-sl2tag
                data-sl2tag-tag-link="#finder?tag="
                data-sl2tag-change="${updateUrl}"
                data-sl2tag-placeholder="${message(code:'is.ui.story.notags')}"
                data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}"
                value="{{ story.tags }}"/>
        <hr>
        <textarea name="story.notes"
                  data-mkp
                  data-mkp-placeholder="_${message(code: 'is.ui.story.nonotes')}_"
                  data-mkp-height="170"
                  data-mkp-change="${updateUrl}">{{ story.notes }}</textarea>
        <hr>
        <div class="attachments dropzone-previews"
             data-dz
             data-dz-id="right-story-container"
             data-dz-add-remove-links="true"
             data-dz-files='{{ JSON.stringify(story.attachments) }}'
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

<underscore id="tpl-postit-story">
    <div data-elemid="{{ story.id }}" id="postit-story-{{ story.id }}" class="postit story postit-story ui-selectee">
        <div class="postit-layout {{# if(story.feature){ }} postit-{{ story.feature.color }} {{# } }}">
            <p class="postit-id">
                <a class="scrum-link" href="/icescrum/p/TESTPROJ#story/{{ story.id }}">{{ story.id }}</a>
            </p>
            <div class="icon-container"></div>
            <p class="postit-label break-word">{{ story.name }}</p>
            <div class="postit-excerpt">{{ $.icescrum.story.formatters.description(story.description) }}</div>
            <span class="postit-ico ico-story-{{ story.type }}"></span>
            <div class="state task-state">
                <span class="text-state">{{ $.icescrum.story.formatters.state(story.state) }}</span>
                <div class="dropmenu-action">
                    <div id="menu-postit-story-{{ story.id }}"
                         data-nowindows="false"
                         data-offset="0"
                         data-top="13"
                         class="dropmenu"
                         data-dropmenu="true">
                        <span class="dropmenu-arrow">!</span>
                        <div class="dropmenu-content ui-corner-all">
                            <ul class="small">
                                <li>
                                    <a data-ajax="true" data-ajax-notice="Story sent back to sandbox"
                                       data-ajax-trigger="returnToSandbox_story"
                                       href="/icescrum/p/1/story/returnToSandbox/{{ story.id }}">return to sandbox</a>
                                </li>
                                <li>
                                    <a data-ajax="true"
                                       data-ajax-notice="The story has been successfully copied to the sandbox"
                                       data-ajax-trigger="add_story" href="/icescrum/p/1/story/copy/{{ story.id }}">Copy</a>
                                </li>
                                <li>
                                    <a data-ajax="true" href="/icescrum/p/1/story/openDialogDelete/{{ story.id }}">Delete</a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</underscore>