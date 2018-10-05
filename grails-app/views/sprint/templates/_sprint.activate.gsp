%{--
- Copyright (c) 2018 Kagilum.
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

<script type="text/ng-template" id="story.activate.html">
<is:modal form="activate(sprint)"
          submitButton="${message(code: 'is.ui.releasePlan.menu.sprint.activate')}"
          submitButtonColor="danger"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.ui.releasePlan.menu.sprint.activate')}">
    <p>
        ${message(code: 'is.ui.releasePlan.menu.sprint.activate.confirm')}
    </p>
    <table class="table">
        <tbody>
            <tr><td><strong>${message(code: 'is.sprint.startDate')}</strong></td><td class="ng-binding">{{ sprint.startDate | dayShort }}</td></tr>
            <tr><td><strong>${message(code: 'is.sprint.plannedVelocity')}</strong></td><td class="ng-binding">{{ sprint.capacity }}</td></tr>
        </tbody>
    </table>
</is:modal>
</script>
