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
    <title>${message(code: 'is.login')}</title>
    <meta name='layout' content='simple-without-ng'/>
</head>

<body>
<div class="not-logged-in container-left-top-yellow-rect container-left-bottom-blue-rect" style="height: 100vh">
    <div class="d-flex justify-content-center content">
        <div class="rect_1"></div>

        <div class="rect_2"></div>

        <div class="rect_3"></div>

        <div class="register">
            <div class="text-center">
                <a href="https://www.icescrum.com" target="_blank">
                    <img id="logo" alt="iceScrum" src="${assetPath(src: 'application/logo.png')}">
                    <img id="logo-name" src="${assetPath(src: 'application/icescrum.png')}" alt="iceScrum" class="img-fluid">
                </a>
            </div>

            <form action='${createLink(action: 'save', controller: 'user')}/' class="form-special" method="post" autocomplete='off'>
                <g:if test="${user?.errors}">
                    <div class="alert alert-danger mb-4 mt-4" role="alert">
                        <g:renderErrors bean="${user}"/>
                    </div>
                </g:if>
                <div class="row">
                    <div class="form-group col-12">
                        <label for="username">${message(code: 'is.user.username')}</label>
                        <input required
                               type="text"
                               class="form-control"
                               name="user.username"
                               autocomplete="off"
                               ng-remote-validate="/user/available/username"
                               ng-remote-validate-code="user.username.unique"
                               value="${user ? user.username : ''}"
                               autofocus/>
                    </div>
                </div>

                <div class="row">
                    <div class="form-group col-6">
                        <label for="firstName">${message(code: 'is.user.firstname')}</label>
                        <input required
                               type="text"
                               class="form-control"
                               autocomplete="off"
                               value="${user ? user.firstName : ''}"
                               name="user.firstName"/>
                    </div>

                    <div class="form-group col-6">
                        <label for="lastName">${message(code: 'is.user.lastname')}</label>
                        <input required
                               type="text"
                               class="form-control"
                               autocomplete="off"
                               value="${user ? user.lastName : ''}"
                               name="user.lastName"/>
                    </div>
                </div>

                <div class="row">
                    <div class="form-group col-12">
                        <label for="email">${message(code: 'is.user.email')}</label>
                        <input required
                               type="email"
                               name="user.email"
                               class="form-control"
                               autocomplete="off"
                               value="${user ? user.email : ''}"
                               ng-remote-validate-code="user.email.unique"
                               ng-remote-validate="/user/available/email"/>
                    </div>
                </div>

                <div class="row">
                    <div class="form-group col-6">
                        <label for="password" class="d-flex align-items-center justify-content-between">
                            <div>${message(code: 'is.user.password')}</div>

                            <div class="small" onclick="togglePassword(this)">
                                <i class="fa fa-eye"></i>
                                <i class="fa fa-eye-slash" style="display:none;"></i>
                            </div>
                        </label>
                        <input required
                               name="user.password"
                               type="password"
                               class="form-control"
                               minlength="4">
                    </div>

                    <div class="form-group col-6">
                        <label for="confirmPassword" class="d-flex align-items-center justify-content-between">
                            <div>${message(code: 'is.login.register.confirmPassword')}</div>

                            <div class="small" onclick="togglePassword(this)">
                                <i class="fa fa-eye"></i>
                                <i class="fa fa-eye-slash" style="display:none;"></i>
                            </div>
                        </label>
                        <input required
                               name="user.confirmPassword"
                               type="password"
                               class="form-control"
                               minlength="4">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="preferences.activity">${message(code: 'is.user.preferences.activity')}</label>
                        <input name="preferences.activity"
                               type="text"
                               value="${user ? user.preferences.activity : ''}"
                               class="form-control">
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <input type="submit" class="btn btn-primary" value="${message(code: 'is.login.register')}">
                    </div>
                </div>
            </form>

            <div class="text-center login-footer">
                <div class="login-cta-text">Already have an account</div>
                <a href="${createLink(action: "auth", controller: "login")}/" class="btn btn-secondary">${message(code: 'is.login')}</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>