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
            <div class="d-flex justify-content-center content row">
                <div class="rect_1"></div>
                <div class="rect_2"></div>
                <div class="rect_3"></div>
                <div class="login">
                    <div class="text-center">
                        <a href="https://www.icescrum.com" target="_blank">
                            <img id="logo" alt="iceScrum" src="${assetPath(src: 'application/logo.png')}">
                            <img id="logo-name" src="${assetPath(src: 'application/icescrum.png')}" alt="iceScrum" class="img-fluid">
                        </a>
                    </div>
                    <h1 class="text-center">Great to see you again!</h1>
                    <form action='${postUrl}' name="loginform" id="loginform" class="form-special" method="post" autocomplete='off'>
                        <p class="form-group">
                            <label for="username">${message(code: 'is.login.username.or.email')}<span class="required">*</span></label>
                            <input type="text" class="input-large input-text form-control" name="j_username" id="username" value="">
                        </p>
                        <p class="form-group">
                            <label for="password">${message(code: 'is.user.password')}<span class="required">*</span></label>
                            <input class="input-large input-text form-control" type="password" name="j_password" id="password">
                        </p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="back-link">
                                <a href="/login/retrieve/">${message(code: 'is.login.retrieve')}</a>
                            </div>
                            <div>
                                <input type="submit" class="btn btn-primary" name="login" value="Login">
                            </div>
                        </div>
                        <p id="remember_me_holder" style="display: none;">
                            <input type='checkbox' name='${rememberMeParameter}' id='remember_me' checked='checked'/>
                        </p>
                        <div class="text-center login-footer">
                            <div class="login-cta-text">Don't have an account</div>
                            <a class="btn btn-secondary" href="/login/register">${message(code: 'is.login.register')}</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>