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