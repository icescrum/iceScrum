%{--
- Copyright (c) 2015 Kagilum.
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

<script type="text/ng-template" id="edit.administration.project.html">
<form role='form'
      ng-controller="editProjectCtrl"
      show-validation
      novalidate
      ng-submit='update(project)'
      name="formHolder.editProjectForm">
    <h4>${message(code:"todo.is.ui.project.administration")}</h4>
    <div class="row">
        <div class="form-half">
            <label for="webservices" class="checkbox-inline">
                <input type="checkbox"
                       name="project.preferences.webservices"
                       id="webservices"
                       ng-model="project.preferences.webservices"/>
                ${message(code:'is.product.preferences.project.webservices')}
            </label>
        </div>
    </div>
    <table class="table table-striped table-responsive">
        <tr>
            <th>${message(code:'is.product.preferences.project.stakeHolderRestrictedViews')}</th>
            <th></th>
        </tr>
        <tr ng-repeat="view in views">
            <td ng-class="{'text-muted':!view.hidden}">{{ view.title }}</td>
            <td class="text-right"><input type="checkbox" name="view.hidden" ng-model="view.hidden"></td>
        </tr>
    </table>
    <div class="btn-toolbar">
        <button ng-if="authorizedProject('delete', project)"
                type="button"
                role="button"
                class="btn btn-danger"
                ng-click="delete(project)">
            ${message(code: 'is.projectmenu.submenu.project.delete')}
        </button>
        <button type="button"
                role="button"
                class="btn btn-danger"
                ng-click="archive(project)">
            ${message(code: 'is.dialog.project.archive.button')}
        </button>
    </div>
    <div class="btn-toolbar pull-right">
        <button type="button"
                role="button"
                class="btn btn-default"
                uib-tooltip="${ message(code:'is.button.cancel')}"
                ng-click="resetProjectForm()">
            ${message(code: 'is.button.cancel')}
        </button>
        <button type='submit'
                role="button"
                class='btn btn-primary'
                ng-disabled="!formHolder.editProjectForm.$dirty || formHolder.editProjectForm.$invalid">
            ${message(code: 'is.button.update')}
        </button>
    </div>
</form>
</script>