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
    <title>${message(code: 'todo.is.ui.401')}</title>
    <meta name='layout' content='error'/>
</head>
<body>
    <entry:point id="icescrum-401-header" model="[homeUrl: homeUrl, originalUrl: originalUrl]"/>
    <h1>Oops!</h1>
    <h2>${message(code: 'todo.is.ui.401')}</h2>
    <div class="mt-4 mb-4">
        ${message(code: 'todo.is.ui.401.details')}
    </div>
    <entry:point id="icescrum-401-footer" model="[homeUrl: homeUrl, originalUrl: originalUrl]"/>
    <script type="text/javascript">
        setTimeout(function() { login(); }, 3000);
    </script>
</body>