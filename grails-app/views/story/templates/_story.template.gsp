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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<script type="text/ng-template" id="story.template.new.html">
<is:modal form="submit(template)"
          submitButton="${message(code:'default.button.create.label')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'todo.is.ui.story.template.new')}">
    <p class="help-block">
        ${message(code: 'todo.is.ui.story.template.help')}
    </p>
    <div class="form-group">
        <label for="template.name">${message(code:'todo.is.ui.story.template.name')}</label>
        <input autofocus
               class="form-control"
               ng-model="template.name"
               placeholder="${message(code:'todo.is.ui.story.template.name.placeholder')}"/>
    </div>
</is:modal>
</script>

<script type="text/ng-template" id="story.template.edit.html">
<is:modal title="${message(code:'todo.is.ui.story.template.manage')}">
    <table class="table table-striped">
        <tr ng-repeat="templateEntry in templateEntries">
            <td>
                {{ templateEntry.text }}
            </td>
            <td>
                <button class="btn btn-xs btn-danger pull-right"
                        type="button"
                        uib-tooltip="${message(code:'default.button.delete.label')}"
                        ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: deleteTemplate, args: [templateEntry] })"><i class="fa fa-times"></i></button>
            </td>
        </tr>
    </table>
</is:modal>
</script>
