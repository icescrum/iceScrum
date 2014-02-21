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
<underscore id="tpl-postit-feature">
    <div data-elemid="** feature.id **" class="postit feature postit-feature ui-selectee">
        <div class="postit-layout postit-** feature.color **">
            <p class="postit-id">
                <is:scrumLink controller="feature" id='** feature.id **'>** feature.id **</is:scrumLink>
            </p>
            <div class="icon-container">
                **# if (_.size(feature.attachments) > 0) { **
                    <span class="postit-attachment icon" title="** _.size(feature.attachments) **"></span>
                **# } **
            </div>
            <p class="postit-label break-word">** feature.name **</p>
            <div class="postit-excerpt">** feature.description **</div>
            <span class="postit-ico ico-feature-** feature.type **" title="** $.icescrum.feature.formatters.type(feature) **"></span>
            <div class="state task-state">
                <span class="mini-value">** feature.value **</span>
                <span class="text-state">** $.icescrum.feature.formatters.state(feature) **</span>
            </div>
        </div>
    </div>
</underscore>