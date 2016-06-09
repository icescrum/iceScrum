%{--
- Copyright (c) Kagilum SAS.
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
    <meta name='layout' content='main'/>
    <g:if test="${params.product}">
        <feed:meta kind="rss" version="2.0" controller="project" action="feed" params="[product:pageScope.variables.context.object.pkey,lang:lang]"/>
        <title>${product?.name ?: ''}</title>
    </g:if>
</head>
<body>
</body>