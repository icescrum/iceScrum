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
<is:modal title="${message(code:'is.dialog.exportProject.title')}">
    <form class="form-inline" role="form" ng-show="!progress" ng-submit="start()" novalidate>
        <div class="help-block">
            <g:message code="is.dialog.exportProject.description"/>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" ng-model="zip"> ${message(code:'todo.is.ui.export.zip')}
            </label>
        </div>
        <button type="submit" class="btn btn-primary" >${message(code:'todo.is.ui.export')}</button>
    </form>
    <is-progress start="progress" ng-show="progress"></is-progress>
</is:modal>