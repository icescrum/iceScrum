<%@ page import="org.icescrum.core.domain.security.Authority; grails.plugin.springsecurity.SpringSecurityUtils; org.icescrum.core.support.ApplicationSupport" %>
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

<script type="text/ng-template" id="edit.general.project.html">
<form role='form'
      ng-controller="editProjectCtrl"
      show-validation
      novalidate
      ng-submit='update(project)'
      name="formHolder.editProjectForm">
    <ng-include src="'form.general.project.html'"></ng-include>
    <div class="btn-toolbar pull-right">
        <button type="button"
                role="button"
                class="btn btn-default"
                ng-click="$close()">
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