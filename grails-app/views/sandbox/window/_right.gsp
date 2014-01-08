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

<div id="right-current-view">
    <h3><g:message code="is.ui.sandbox"/></h3>
    <span id="stories-sandbox-size">${storyCount}</span> stories
</div>
<div id="right-story-container">
</div>


<jq:jquery>

var selectStory = function (event, ui) {
    var id = $(ui.selected).data('elemid');
    $.ajax({
        url: '${createLink(controller:'sandbox',action:'index',params:[product: params.product])}' + '/' + id,
        success: function (data) {
            $.event.trigger('select_story', data);
        }
    });
};

var unselectStory = function (event, ui) {
    // The timeout prevents ugly flickering
    $.doTimeout(200, function () {
        if ($('.story.ui-selected').length == 0) {
            $.event.trigger('unselect_story');
        }
    });
};

$('#window-content-sandbox').off('selectableselected selectableunselected')
    .on('selectableselected', selectStory)
    .on('selectableunselected', unselectStory);
</jq:jquery>

<is:onStream
        on="#right-story-container"
        events="[[object:'story',events:['select','unselect', 'update', 'remove']]]"
        template="sandboxRight"/>