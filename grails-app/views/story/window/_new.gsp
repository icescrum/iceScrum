<underscore id="tpl-new-story">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">${message(code: "is.ui.sandbox.toolbar.new")} ${message(code: "is.story")}</h3>
            <div class="help-block">${message(code:'is.ui.sandbox.help')}</div>
        </div>
        <div id="right-story-container" class="right-properties new panel-body">
            <div id="right-story-template">
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
            <div class="clearfix no-padding">
                <div class="form-group col-md-6">
                    <label for="story.name">${message(code:'is.story.name')}</label>
                    <input required="required"
                           name="story.name"
                           type="text"
                           class="form-control"
                           value="**# if(template){ **** story.name ** **# } **"
                           onkeyup="$.icescrum.story.findDuplicate(this.value)"
                           onblur="$.icescrum.story.findDuplicate(null)"
                           placeholder="${message(code: 'is.ui.story.noname')}"
                           data-txt
                           data-txt-only-return="true"
                           data-txt-on-save="$.icescrum.story.afterSave"
                           data-txt-change="${createLink(controller: 'story', action: 'save', params: [product: '** jQuery.icescrum.product.pkey **', template:'** template **'])}">
                    <p class="duplicate bg-warning"></p>
                </div>
                <div class="form-group col-md-6">
                    <label for="template">Use a template</label>
                    <input  type="hidden"
                            name="template"
                            class="form-control"
                            data-sl2ajax
                            data-sl2ajax-url="${createLink(controller: 'story', action: 'templateEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                            data-sl2ajax-placeholder="Choose a template"
                            data-sl2ajax-change="$.icescrum.story.createForm"
                            data-sl2ajax-allow-clear="true"
                            value="**# if(template){ **** template ** **# } **"/>
                </div>
            </div>
        </div>
    </div>
</underscore>