%{--
- Copyright (c) 2016 Kagilum SAS
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
--}%
<head>
    <title>${message(code: 'todo.is.ui.404')}</title>
    <meta name='layout' content='error'/>
</head>
<body>
    <h1>Oops!</h1>
    <h2>${message(code: 'todo.is.ui.404')}</h2>
    <div class="error-details">
        ${message(code: 'todo.is.ui.404.details')}
    </div>
    <div class="error-actions">
        <a href="${homeUrl.encodeAsHTML()}" class="btn btn-primary btn-lg">
            <i class="fa fa-home"></i> ${message(code: 'todo.is.ui.40x.home')}</a>
        <a href="mailto:${emailSupport.encodeAsHTML()}" class="btn btn-secondary btn-lg">
            <i class="fa fa-envelope"></i> ${message(code: 'todo.is.ui.40x.support')}</a>
    </div>
</body>