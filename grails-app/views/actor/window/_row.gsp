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
<underscore id="tpl-actor-row">
    <tr data-elemid="** actor.id **"
        data-ui-popover
        data-ui-popover-placement="right"
        data-ui-popover-trigger="keep-hover"
        data-ui-popover-delay="500"
        data-ui-popover-html-content="#popover-actor-row-** actor.id ** > .content"
        data-ui-popover-html-title="#popover-actor-row-** actor.id ** > .title"
        class="actor-row">
        <td>** actor.uid **</td>
        <td>** actor.name ** </td>
        <td id="popover-actor-row-** actor.id **" class="hidden">
            <div class="title">
                ** actor.name **
            </div>
            <div class="content">
                ** actor.description **
            </div>
        </td>
    </tr>

</underscore>