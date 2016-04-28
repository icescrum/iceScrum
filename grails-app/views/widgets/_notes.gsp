<is:widget widgetDefinition="${widgetDefinition}">
    <div class="form-group">
        <textarea id="note-size" is-markitup
                  class="form-control"
                  name="notes"
                  ng-model="widget.settings.text"
                  is-model-html="widget.settings.text_html"
                  ng-show="showNotesTextarea"
                  ng-blur="showNotesTextarea = false; update(widget)"
                  placeholder="${message(code: 'is.panel.notes.placeholder')}"></textarea>
        <div class="markitup-preview"
             ng-disabled="true"
             ng-show="!showNotesTextarea"
             ng-click="showNotesTextarea = true"
             ng-class="{'placeholder': !widget.settings.text_html}"
             tabindex="0"
             ng-bind-html="(widget.settings.text_html ? widget.settings.text_html : '<p>${message(code: 'is.panel.notes.placeholder')}</p>') | sanitize"></div>
    </div>
</is:widget>