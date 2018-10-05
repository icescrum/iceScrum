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

<script type="text/ng-template" id="sprint.autoPlan.html">
<is:modal form="submit(modelHolder.plannedVelocity)"
          submitButton="${message(code: 'is.dialog.promptAutoPlan.button')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.dialog.promptAutoPlan.title')}">
    <p class="help-block">
        ${message(code: 'is.dialog.promptAutoPlan.description')}
    </p>
    <div class="form-group">
        <label for="plannedVelocity">${message(code: 'is.sprint.plannedVelocity')}</label>
        <input autofocus
               name="plannedVelocity"
               type="number"
               min="0"
               class="form-control"
               ng-model="modelHolder.plannedVelocity"/>
    </div>
</is:modal>
</script>
