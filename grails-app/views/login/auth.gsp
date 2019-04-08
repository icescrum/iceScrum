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
        <meta name='layout' content='login'/>
    </head>
    <body class="container-left-top-yellow-rect container-left-bottom-blue-rect">
        <div class="d-flex justify-content-center row">
            <div>
                <h1 class="text-center">Great to see you again!</h1>
                <form action='${postUrl}' name="loginform" id="loginform" action="?" method="post" autocomplete='off'>
                    <p class="form-group">
                        <label for="username">${message(code: 'is.login.username.or.email')}<span class="required">*</span></label>
                        <input type="text" class="input-text form-control" name="j_username" id="username" value="">
                    </p>
                    <p class="form-group">
                        <label for="password">${message(code: 'is.user.password')}<span class="required">*</span></label>
                        <input class="input-text form-control" type="password" name="j_password" id="password">
                    </p>
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <a href="/login/retrieve/">${message(code: 'is.login.retrieve')}</a>
                        </div>
                        <div>
                            <input type="submit" class="btn btn-primary" name="login" value="Login">
                        </div>
                    </div>
                    <p id="remember_me_holder" style="display: none;">
                        <input type='checkbox' name='${rememberMeParameter}' id='remember_me' checked='checked'/>
                    </p>
                    <div class="text-center">
                            <span class="form-text grey">Don't have an account</span>
                            <a class="btn btn-secondary" href="/login/register">${message(code: 'is.login.register')}</a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>