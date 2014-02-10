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
<%@ page import="org.icescrum.core.domain.Actor" %>
<underscore id="tpl-postit-actor">
    <div data-elemid="** actor.id **" class="postit actor postit-actor ui-selectee">
        <div class="postit-layout">
            <p class="postit-id">
                <is:scrumLink controller="actor" id='** actor.id **'>** actor.id **</is:scrumLink>
            </p>
            <div class="icon-container">
                **# if (_.size(actor.attachments) > 0) { **
                    <span class="postit-attachment icon" title="** _.size(actor.attachments) **"></span>
                **# } **
            </div>
            <p class="postit-label break-word">** actor.name **</p>
            <div class="postit-excerpt">** actor.description **</div>
            <div class="state task-state">
                <div class="dropmenu-action">

                </div>
            </div>
        </div>
    </div>
</underscore>