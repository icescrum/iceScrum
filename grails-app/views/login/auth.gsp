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
        <title>${message(code: 'is.dialog.login')}</title>
        <meta name='layout' content='login'/>
    </head>
    <body class="not-logged-in login container-left-top-yellow-rect container-left-bottom-blue-rect">
        <div class="d-flex justify-content-center content row">
            <div class="rect_1"></div>
            <div class="rect_2"></div>
            <div class="rect_3"></div>
            <div class="text-center">
                <a href="/">
                    <img id="logo" alt="iceScrum" src="/wp-content/themes/new_icescrum/assets/logo.png">
                    <img id="logo-name" src="https://www.icescrum.com/wp-content/themes/new_icescrum/assets/icescrum.png" alt="iceScrum" class="img-responsive">
                </a>
                <h1>Great to see you again!</h1>
                <form action='${postUrl}' name="loginform" id="loginform" action="?" method="post" autocomplete='off'>
                    <p class="form-group text-left">
                        <label for="username">Email or Username<span class="required">*</span></label>
                        <input type="text" class="input-text form-control" name="j_username" id="username" value="">
                    </p>
                    <p class="form-group text-left">
                        <label for="password">Password<span class="required">*</span></label>
                        <input class="input-text form-control" type="password" name="j_password" id="password">
                    </p>
                    <div class="row">
                        <div class="col-6 back-link">
                            <a href="/my-account/lost-password/">Lost your password?</a>
                        </div>
                        <div class="col-6 text-right">
                            <input type="submit" class="icescrum-btn pull-right" name="login" value="Login">
                        </div>
                    </div>
                    <p id="remember_me_holder" style="display: none;">
                        <input type='checkbox' name='${rememberMeParameter}' id='remember_me' checked='checked'/>
                    </p>
                    <div class="text-center" style="margin-top: 70px;">
                        <div>
                            <span class="help-block grey">Don't have an account</span>
                            <a class="icescrum-btn invert" href="/my-account/?signup=yes">Get started</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>