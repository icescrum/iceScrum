%{--
- Copyright (c) 2015 Kagilum.
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
<is:dialog id="dialog-team-browse"
           width="940"
           buttons="'${message(code: 'is.button.close')}': function() { \$(this).dialog('close'); }"
           height="585">
    <is:browser detailsLabel="is.ui.team.details"
                browserLabel="is.ui.team.owner.of"
                controller="members"
                titleLabel="is.ui.team.menu"
                actionColumn="browseList"
                name="team-browse" >
    </is:browser>
    <template id="empty-team-tmpl">
        <form id="form-team-create" class="box-form box-form-250 box-form-200-legend" name="form-team-create" method="post">
            <is:fieldInput for="teamName" label="is.ui.team.create.name">
                <is:input id="teamName" name="team.name"/>
                <a id="create-team-button"
                   style="margin-top:5px"
                   class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-ajax-notice="${message(code:'is.team.saved')}"
                   data-ajax-success="var filter = jQuery('#team-browse-browse');
                                      filter.autocomplete('search', filter.val());
                                      jQuery('#teamName').val('');"
                   href="${createLink(controller: 'members', action: 'save')}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.add')}</span>
                    <span class="end"></span>
                </a>
            </is:fieldInput>
        </form>
        <div class='box-blank clearfix' style='display:block;'>
            <p>${message(code: 'is.ui.team.explanation')}</p>
        </div>
    </template>
    <jq:jquery>jQuery('#team-browse-details').html(jQuery('#empty-team-tmpl').html());</jq:jquery>
</is:dialog>