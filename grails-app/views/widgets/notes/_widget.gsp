<is:widget widgetDefinition="${widgetDefinition}">
    <div class="form-group" ng-if="authorizedWidget('update', widget)">
        <textarea at
                  id="note-size" is-markitup
                  class="form-control"
                  name="notes"
                  ng-model="widget.settings.text"
                  is-model-html="widget.settings.text_html"
                  ng-show="showNotesTextarea"
                  ng-blur="showNotesTextarea = false; update(widget)"
                  placeholder="${message(code: 'is.ui.widget.notes.placeholder')}"></textarea>
        <div class="markitup-preview"
             ng-show="!showNotesTextarea"
             ng-click="showNotesTextarea = true"
             ng-class="{'placeholder': !widget.settings.text_html}"
             tabindex="0"
             ng-bind-html="widget.settings.text_html ? widget.settings.text_html : '<p>${message(code: 'is.ui.widget.notes.placeholder')}</p>'"></div>
    </div>
    <div class="form-control-static" ng-if="!authorizedWidget('update', widget)" ng-bind-html="widget.settings.text_html">
</is:widget>