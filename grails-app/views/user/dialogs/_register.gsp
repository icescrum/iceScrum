<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
%{--
- Copyright (c) 2015 Kagilum SAS.
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
<is:modal name="formHolder.registerForm"
          form="register()"
          validate="true"
          submitButton="${message(code: 'is.button.register')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.dialog.register')}">
    <p>
        <g:message code="is.dialog.register.description"/>
    </p>
    <div ng-include="'user.form.html'"></div>
</is:modal>