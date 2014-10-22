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
<is:modal size="sm"
          title="${message(code:'is.dialog.login')}"
          submitButton="${message(code:'is.button.connect')}"
          closeButton="${message(code:'is.button.cancel')}"
          autoFillFix="true"
          form="login(credentials)">
    <div class="form-group">
        <label for="credentials.j_username">${message(code:'is.user.username')}</label>
        <g:if test="${enableRegistration}"><div class="input-group"></g:if>
        <input required
               ng-model="credentials.j_username"
               type="text"
               id="credentials.j_username"
               class="form-control"
               focus-me="true"
               value="${params.username?:''}">
        <g:if test="${enableRegistration}">
            <span class="input-group-btn">
                <a tabindex="-1"
                        class="btn btn-default"
                        type="button"
                        href="#user/register"
                        tooltip-placement="top"
                        tooltip="${message(code:'todo.is.new')}">
                    <i class="fa fa-user"></i>
                </a>
            </span>
        </g:if>
        <g:if test="${enableRegistration}"></div></g:if>
    </div>
    <div class="form-group">
        <label for="credentials.j_password">${message(code:'is.user.password')}</label>
        <g:if test="${activeLostPassword}"><div class="input-group"></g:if>
        <input required
               ng-model="credentials.j_password"
               type="password"
               id="credentials.j_password"
               class="form-control"
               value="">
        <g:if test="${activeLostPassword}">
            <span class="input-group-btn">
                <a tabindex="-1"
                        class="btn btn-default"
                        type="button"
                        tooltip-placement="top"
                        href="#user/retrieve"
                        tooltip="${message(code:'todo.is.retrieve')}">
                    <i class="fa fa-flash"></i>
                </a>
            </span>
        </g:if>
        <g:if test="${activeLostPassword}"></div></g:if>
    </div>
    <div class="checkbox">
        <label>
            <input
                    type='checkbox'
                    name='${rememberMeParameter}'
                    id='remember_me'
                    <g:if test='${hasCookie}'>checked='checked'</g:if>/> <g:message code="is.dialog.login.rememberme"/>
        </label>
    </div>
</is:modal>