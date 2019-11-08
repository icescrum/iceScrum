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
                <div class="retrieve">
                    <div class="text-center">
                        <a href="https://www.icescrum.com" target="_blank">
                            <img id="logo" alt="iceScrum" src="${assetPath(src: 'application/logo.png')}">
                            <img id="logo-name" src="${assetPath(src: 'application/icescrum.png')}" alt="iceScrum" class="img-fluid">
                        </a>
                    </div>
                    <form action="${g.createLink(action: 'retrieve', controller: 'user')}/"
                          class="form-special"
                          show-validation
                          method="post" autocomplete='off'>
                        <g:if test="${error}">
                            <div class="alert bg-danger form-text mb-4 text-center" role="alert">
                                ${error}
                            </div>
                        </g:if>
                        <g:else>
                            <div class="mb-4 text-center">
                                ${g.message(code: 'is.login.retrieve.description')}
                            </div>
                        </g:else>
                        <div class="form-group">
                            <label for="username">${message(code: 'is.login.username.or.email')}</label>
                            <input required
                                   autofocus
                                   type="text"
                                   name="username"
                                   id="username"
                                   class="form-control">
                        </div>
                        <div class="d-flex justify-content-end align-items-center">
                            <input type="submit"
                                   class="btn btn-primary"
                                   value="${message(code: 'is.login.retrieve.button')}">
                        </div>
                    </form>
                    <div class="text-center login-footer">
                        <a href="${createLink(action: "auth", controller: "login")}/" class="btn btn-secondary">${message(code: 'is.login')}</a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>