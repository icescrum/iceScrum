%{--
- Copyright (c) 2019 Kagilum SAS
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
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>iceScrum - ${message(code: 'is.login')}</title>
        <meta name='layout' content='simple'/>
    </head>
    <body>
        <div class="not-logged-in container-left-top-yellow-rect container-left-bottom-blue-rect" style="height: 100vh; overflow-y: auto; overflow-x: hidden">
            <div class="d-flex justify-content-center content">
                <div class="rect_1"></div>
                <div class="rect_2"></div>
                <div class="rect_3"></div>
                <div class="register" ng-controller="registerCtrl" ng-init="token = '${token ?: ''}';redirectTo='${params.redirectTo ?: ''}'">
                    <div class="text-center">
                        <a href="https://www.icescrum.com" target="_blank">
                            <img id="logo" alt="iceScrum" src="${assetPath(src: 'application/logo.png')}">
                            <img id="logo-name" src="${assetPath(src: 'application/icescrum.png')}" alt="iceScrum" class="img-fluid">
                        </a>
                    </div>
                    <form role='form'
                          name="formHolder.registerForm"
                          show-validation
                          ng-submit='register()'
                          class="form-special"
                          method="post"
                          autocomplete='off'
                          novalidate>
                        <g:if test="${user?.errors}">
                            <div class="alert alert-danger mb-4 mt-4" role="alert">
                                <g:renderErrors bean="${user}"/>
                            </div>
                        </g:if>
                        <div class="row">
                            <div class="form-group col-12">
                                <label for="username">${message(code: 'is.user.username')}<span class="required">*</span></label>
                                <input required
                                       type="text"
                                       class="form-control"
                                       name="user.username"
                                       autocomplete="off"
                                       ng-model="user.username"
                                       ng-remote-validate="/user/available/username"
                                       ng-remote-validate-code="user.username.unique"
                                       value="${user ? user.username : ''}"
                                       autofocus/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-6">
                                <label for="firstName">${message(code: 'is.user.firstname')}<span class="required">*</span></label>
                                <input required
                                       type="text"
                                       class="form-control"
                                       autocomplete="off"
                                       value="${user ? user.firstName : ''}"
                                       name="user.firstName"
                                       ng-model="user.firstName"/>
                            </div>
                            <div class="form-group col-6">
                                <label for="lastName">${message(code: 'is.user.lastname')}<span class="required">*</span></label>
                                <input required
                                       type="text"
                                       class="form-control"
                                       autocomplete="off"
                                       value="${user ? user.lastName : ''}"
                                       name="user.lastName"
                                       ng-model="user.lastName"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-12">
                                <label for="email">${message(code: 'is.user.email')}<span class="required">*</span></label>
                                <input required
                                       type="email"
                                       name="user.email"
                                       class="form-control"
                                       autocomplete="off"
                                       value="${user ? user.email : ''}"
                                       ng-model="user.email"
                                       ng-remote-validate-code="user.email.unique"
                                       ng-remote-validate="/user/available/email"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-6">
                                <label for="password" class="d-flex align-items-center justify-content-between">
                                    <div>${message(code: 'is.user.password')}<span class="required">*</span></div>
                                    <div class="small" onclick="togglePassword(this)">
                                        <i class="fa fa-eye"></i>
                                        <i class="fa fa-eye-slash" style="display:none;"></i>
                                    </div>
                                </label>
                                <input required
                                       name="user.password"
                                       type="password"
                                       class="form-control"
                                       ng-model="user.password"
                                       ng-password-strength>
                            </div>
                            <div class="form-group col-6">
                                <label for="confirmPassword" class="d-flex align-items-center justify-content-between">
                                    <div>${message(code: 'is.login.register.confirmPassword')}<span class="required">*</span></div>
                                    <div class="small" onclick="togglePassword(this)">
                                        <i class="fa fa-eye"></i>
                                        <i class="fa fa-eye-slash" style="display:none;"></i>
                                    </div>
                                </label>
                                <input required
                                       name="confirmPassword"
                                       type="password"
                                       class="form-control"
                                       is-match="user.password"
                                       ng-model="user.confirmPassword">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 form-group">
                                <label for="preferences.activity">${message(code: 'is.user.preferences.activity')}</label>
                                <input name="preferences.activity"
                                       type="text"
                                       value="${user ? user.preferences.activity : ''}"
                                       class="form-control"
                                       ng-model="user.preferences.activity">
                            </div>
                        </div>
                        <div class="d-flex justify-content-end align-items-center">
                            <button type='submit'
                                    ng-disabled='application.submitting || formHolder.registerForm.$invalid'
                                    class="btn btn-primary">
                                ${message(code: 'is.login.register')}
                            </button>
                        </div>
                    </form>
                    <div class="text-center login-footer">
                        <div class="login-cta-text">${message(code: 'is.login.register.login.cta')}</div>
                        <a href="${createLink(action: 'auth', controller: 'login')}/" class="btn btn-secondary">${message(code: 'is.login')}</a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>