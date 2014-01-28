<underscore id="tpl-new-story">
    <h3><a href="#">${message(code: "is.ui.sandbox.toolbar.new")} ${message(code: "is.story")}</a></h3>
    <div id="right-story-container" class="right-properties new">
        <div id="right-story-template">
            <div class="help">${message(code:'is.ui.sandbox.help')}</div>
            **# if (template) { **
                <div class="postit story postit-story">
                    <div class="postit-layout **# if(story.feature){ ** postit-** story.feature.color ** **# } **">
                        <p class="postit-id">
                            <b title="Yes the devil!">666</b>
                            **# if (story.dependsOn) { **
                            <span class="dependsOn" data-elemid="** story.dependsOn.id **">(<is:scrumLink controller="story" id="** story.dependsOn.id **">** story.dependsOn.uid **</is:scrumLink>)</span>
                            **# } **
                        </p>
                        <p class="postit-label break-word">** story.name **</p>
                        <div class="postit-excerpt">** $.icescrum.story.formatters.description(story) **</div>
                        <span class="postit-ico ico-story-** story.type **" title="** $.icescrum.story.formatters.type(story) **"></span>
                        <div class="state task-state">
                            <span class="text-state">** $.icescrum.story.formatters.state(story) **</span>
                        </div>
                    </div>
                </div>
            **# } **
        </div>
        <input required="required"
               name="story.name"
               type="text"
               class="important"
               value="**# if(template){ **** story.name ** **# } **"
               onkeyup="$.icescrum.story.findDuplicate(this.value)"
               onblur="$.icescrum.story.findDuplicate(null)"
               placeholder="${message(code: 'is.ui.story.noname')}"
               data-txt
               data-txt-only-return="true"
               data-txt-on-save="$.icescrum.story.afterSave"
               data-txt-change="${createLink(controller: 'story', action: 'save', params: [product: '** jQuery.icescrum.product.pkey **', template:'** template **'])}">
        <input  type="hidden"
                name="template"
                data-sl2ajax
                data-sl2ajax-url="${createLink(controller: 'story', action: 'templateEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                data-sl2ajax-placeholder="Story template"
                data-sl2ajax-change="$.icescrum.story.createForm"
                data-sl2ajax-allow-clear="true"
                value="**# if(template){ **** template ** **# } **"/>
         <span class="duplicate"></span>
    </div>
</underscore>