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
<table>
    <thead>
    <tr>
        <th width="50%">${message(code:'is.dialog.about.errors.name')}</th>
        <th width="50%">${message(code:'is.dialog.about.errors.message')}</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${errors}" var="error">
        <tr>
            <td>${g.message(code:error.title)}
                <g:if test="${error.version}">
                    ${' (R'+error.version?.replaceFirst('\\.','#')+')'}
                </g:if>
            </td>
            <td>${error.message?.startsWith('is.') ? g.message(code:error.message, args:error.args?:null) : error.message}
                <g:if test="${error.version}">
                    <br/>
                    <a href="${error.url}">${g.message(code:'is.warning.version.download')}</a>
                </g:if>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>