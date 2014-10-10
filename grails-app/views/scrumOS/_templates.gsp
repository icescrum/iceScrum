%{--
- Copyright (c) 2014 Kagilum SAS.
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
<script type="text/ng-template" id="confirm.modal.html">
    <is:modal form="submit()"
              submitButton="${message(code:'todo.is.ui.confirm')}"
              closeButton="${message(code:'is.button.cancel')}"
              title="${message(code:'todo.is.ui.confirm.title')}">
        {{ message }}
    </is:modal>
</script>

<script type="text/ng-template" id="select.or.create.team.html">
<a>
    <span ng-show="!match.model.id">${message(code:'todo.is.ui.create.team')} </span><span>{{ match.model.name }}</span>
</a>
</script>

<script type="text/ng-template" id="select.member.html">
<a>
    <span ng-show="!match.model.id">${message(code:'todo.is.ui.user.will.be.invited')} </span><span>{{ match.model.firstName }} {{ match.model.lastName }}</span>
</a>
</script>