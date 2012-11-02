%{--
- Copyright (c) 2010 iceScrum Technologies.
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
<li class="navigation-item button-ico button-add">
    <a class="tool-button button-n"
       href="#feature/add"
       title="${message(code:'is.ui.feature.toolbar.alt.new')}"
       alt="${message(code:'is.ui.feature.toolbar.alt.new')}">
        <span class="start"></span>
        <span class="content">
            <span class="ico"></span>
            ${message(code: 'is.ui.feature.toolbar.new')}
        </span>
        <span class="end"></span>
    </a>
</li>
<entry:point id="${controllerName}-${actionName}-widget-toolbar"/>