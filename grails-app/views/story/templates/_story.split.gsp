<script type="text/ng-template" id="story.split.html">
<is:modal form="submit(stories)"
          submitButton="${message(code: 'is.ui.backlog.menu.split')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.dialog.split.title')}">
    <p class="help-block">${message(code: 'is.dialog.split.description')}</p>
    <div class="form-group col-sm-12">
        <slider ng-model="splitCount"
                min="2"
                step="1"
                max="10"
                value="splitCount"
                on-stop-slide="onChangeSplitNumber()"></slider>
    </div>
    <table class="table table-striped">
        <tr ng-repeat="story in stories track by $index">
            <td>
                <div class="clearfix">
                    <div class="form-group col-sm-8">
                        <label>${message(code:'is.story.name')}</label>
                        <input required
                               ng-maxlength="100"
                               type="text"
                               ng-model="stories[$index].name"
                               class="form-control">
                    </div>
                    <div class="form-group col-sm-2">
                        <label>${message(code:'is.story.effort')}</label>
                        <input ng-model="stories[$index].effort"
                               type="number"
                               min="0"
                               class="form-control text-right">
                    </div>
                    <div class="form-group col-sm-2">
                        <label>${message(code:'is.story.value')}</label>
                        <input ng-model="stories[$index].value"
                               type="number"
                               min="0"
                               class="form-control text-right">
                    </div>
                    <div class="form-group col-sm-12">
                        <label>${message(code:'is.backlogelement.description')}</label>
                        <textarea required
                                  at="atOptions"
                                  ng-maxlength="3000"
                                  type="text"
                                  ng-model="stories[$index].description"
                                  class="form-control"></textarea>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</is:modal>
</script>