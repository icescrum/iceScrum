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

<script type="text/ng-template" id="edit.general.prodfoo.html">
<form role='form'
      show-validation
      novalidate
      ng-controller="actorCtrl"
      name="formHolder.actorForm">
    <h4>${message(code:"is.ui.actor.actors")}</h4>
    <p class="help-block">${message(code:'is.ui.actor.help')}</p>
    <div ng-if="authorizedActor('create') || authorizedActor('update')">
        <label for="actor.name">${message(code:'is.actor.name')}</label>
        <div class="input-group">
            <input autofocus
                   name="actor.name"
                   ng-required="actor.id"
                   type="text"
                   id="actor.name"
                   class="form-control"
                   placeholder="{{ actor.id ? '' : message('is.ui.actor.noname') }}"
                   ng-model="actor.name"/>
            <span class="input-group-btn">
                <button class="btn btn-default"
                        ng-if="!actor.id"
                        type="submit"
                        ng-click="save(actor)">
                    ${message(code:'default.button.create.label')}
                </button>
                <button class="btn btn-primary"
                        ng-if="actor.id"
                        ng-disabled="!formHolder.actorForm.$dirty || formHolder.actorForm.$invalid"
                        type="submit"
                        ng-click="update(actor)">
                    ${message(code:'default.button.update.label')}
                </button>
                <button class="btn btn-default"
                        ng-if="actor.id"
                        ng-disabled="!formHolder.actorForm.$dirty"
                        type="submit"
                        ng-click="resetActorForm()">
                    ${message(code:'is.button.cancel')}
                </button>
            </span>
        </div>
    </div>
    <table ng-if="actors.length" class="table table-striped table-responsive">
        <thead>
            <tr>
                <th></th>
                <th>${message(code: 'todo.is.ui.stories')}</th>
                <th ng-if="authorizedActor('update') || authorizedActor('delete', actor)"></th>
            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="actor in actors | orderBy: 'name'">
                <td>
                    {{ actor.name }}
                </td>
                <td>
                    <a ng-click="$close()" href="{{ actorSearchUrl(actor) }}">{{ actor.stories_count }}</a>
                </td>
                <td class="btn-toolbar"
                    ng-if="authorizedActor('update') || authorizedActor('delete', actor)">
                    <a class="btn btn-primary btn-xs pull-right"
                       ng-if="authorizedActor('update')"
                       ng-click="edit(actor)">
                        <i class="fa fa-pencil"></i>
                    </a>
                    <a class="btn btn-danger btn-xs pull-right"
                       ng-if="authorizedActor('delete', actor)"
                       ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [actor] })">
                        <i class="fa fa-close"></i>
                    </a>
                </td>
            </tr>
        </tbody>
    </table>
    <div ng-if="actor.length == 0">
        ${message(code: 'todo.is.ui.actor.placeholder')}
    </div>
</form>
</script>