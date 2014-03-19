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
<is:modal name="register"
          size="sm"
          title="${message(code:'is.dialog.login')}"
          form="[action:postUrl,method:'POST',success:'$.icescrum.user.authSuccess',submit:message(code:'is.button.connect')]">
    <h4><g:message code="is.welcome"/></h4>
    <div class="form-group">
        <label for="j_username">${message(code:'is.user.username')}</label>
        <g:if test="${enableRegistration}"><div class="input-group"></g:if>
        <input required
               name="j_username"
               type="text"
               id="j_username"
               class="form-control"
               autofocus
               value="${params.username?:''}">
        <g:if test="${enableRegistration}">
            <span class="input-group-btn">
                <button href="${createLink(action:'register', controller:'user')}"
                        data-ajax="true"
                        tabindex="-1"
                        class="btn btn-default"
                        type="button"
                        data-toggle="tooltip" data-placement="top" title="${message(code:'todo.is.new')}">
                    <i class="glyphicon glyphicon-user"></i>
                </button>
            </span>
        </g:if>
        <g:if test="${enableRegistration}"></div></g:if>
    </div>
    <div class="form-group">
        <label for="j_password">${message(code:'is.user.password')}</label>
        <g:if test="${activeLostPassword}"><div class="input-group"></g:if>
        <input required
               name="j_password"
               type="password"
               id="j_password"
               class="form-control"
               value="">
        <g:if test="${activeLostPassword}">
            <span class="input-group-btn">
                <button href="${createLink(action:'retrieve', controller:'user')}"
                        data-ajax="true"
                        tabindex="-1"
                        class="btn btn-default"
                        type="button"
                        data-toggle="tooltip" data-placement="top" title="${message(code:'todo.is.forgot')}">
                    <i class="glyphicon glyphicon-flash"></i>
                </button>
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