%{--
- Copyright (c) 2014 Kagilum.
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
<script type="text/icescrum-template" id="tpl-story-details">
<div class="panel panel-default">
    <div id="story-header"
         class="panel-heading"
         data-fixed-container="#right"
         data-fixed-offset-top="1"
         data-fixed-offset-width="-2">
        <h3 class="panel-title">
            <span data-binding-tpl="story-header-name"
                  data-binding-id="** story.id **"
                  data-binding-type="story"
                  data-binding-property="name">
            </span>
            <div class="pull-right">
                <span data-toggle="tooltip"
                      title="${message(code:'is.story.creator')} : ** $.icescrum.user.formatters.fullName(story.creator) **">
                    <img tpl-src="** $.icescrum.user.formatters.avatar(story.creator) **" alt="** $.icescrum.user.formatters.fullName(story.creator) **" height="21px"/>
                </span>
                <span class="label label-default"
                      data-toggle="tooltip"
                      title="${message(code:'is.backlogelement.id')}">** story.uid **</span>
                **# if($('.ui-selected').prev().data('elemid')) { **
                <a class="btn btn-xs btn-default"
                   role="button"
                   tabindex="0"
                   href="#** $.icescrum.o.currentOpenedWindow.data('id') **/** $('.ui-selected').prev().data('elemid') **"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                **# } **
                **# if($('.ui-selected').next().data('elemid')) {**
                <a class="btn btn-xs btn-default"
                   role="button"
                   tabindex="0"
                   href="#** $.icescrum.o.currentOpenedWindow.data('id') **/** $('.ui-selected').next().data('elemid') **"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                **# } **
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 title="${message(code:'todo.is.story.actions')}"
                 data-toggle="tooltip"
                 data-container="body"
                 data-binding-tpl="story-menu"
                 data-binding-id="** story.id **"
                 data-binding-type="story"
                 data-binding-property="state">
            </div>
            <div class="btn-group pull-right"
                 data-binding-tpl="story-buttons"
                 data-binding-id="** story.id **"
                 data-binding-type="story"
                 data-binding-watch="item">
            </div>
        </div>
        <div class="progress">
            **#
            var width =  100 / _.keys($.icescrum.story.states).length;
            _.each($.icescrum.story.states, function(name, key){
            var state = name.code.toLowerCase();
            if (story[state+'Date']){
            **
            <div class="progress-bar progress-bar-** state **"
                 data-toggle="tooltip"
                 data-placement="left"
                 data-container="body"
                 title="** name.value ** (** story[state+'Date'] **)" style="width: ** width **%">
                5 days
            </div>
            **#
            }
            }); **
        </div>
    </div>
    <div id="right-story-container" class="right-properties new panel-body">
        <div class="clearfix no-padding">
            <div class="col-md-6 form-group"
                 data-binding-tpl="story-input-name"
                 data-binding-type="story"
                 data-binding-id="** story.id **"
                 data-binding-property="name">
            </div>
            <div class="col-md-6 form-group"
                 data-binding-tpl="story-input-feature"
                 data-binding-type="story"
                 data-binding-id="** story.id **"
                 data-binding-property="feature">
            </div>
        </div>
        <div class="clearfix no-padding"
             data-binding-tpl="story-input-type"
             data-binding-type="story"
             data-binding-id="** story.id **"
             data-binding-property="type,affectVersion">
        </div>
        <div class="form-group"
             data-binding-tpl="story-input-dependsOn"
             data-binding-type="story"
             data-binding-id="** story.id **"
             data-binding-property="dependences,dependsOn">
        </div>
        <div class="form-group"
             data-binding-tpl="story-input-description"
             data-binding-type="story"
             data-binding-id="** story.id **"
             data-binding-property="description">
        </div>
        <div class="form-group"
             data-binding-tpl="story-input-tags"
             data-binding-type="story"
             data-binding-id="** story.id **"
             data-binding-property="tags">
        </div>
        <div class="form-group"
             data-binding-tpl="story-input-notes"
             data-binding-type="story"
             data-binding-id="** story.id **"
             data-binding-property="notes">
        </div>
        <ul class="nav nav-tabs nav-tabs-google" data-ui-tabs-auto-collapse>
            <li class="active"><a href="#activities" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity')}</a></li>
            <li><a href="#attachments" data-toggle="tab">${message(code: 'is.backlogelement.attachment')}</a></li>
            <li><a href="#comments" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity.comments')}</a></li>
            <li><a href="#tasks" data-toggle="tab">
                ${message(code: 'is.ui.backlogelement.activity.task')}
            </a></li>
            <li><a href="#tests" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity.test')}</a></li>
        </ul>
        <div class="tab-content">
            <div class="tab-pane active" id="activities">
                <table class="table table-striped">
                    <tbody data-binding-tpl="activities"
                           data-binding-type="story"
                           data-binding-object="object"
                           data-binding-id="** story.id **"
                           data-binding-property="activities">
                    </tbody>
                </table>
            </div>
            <div class="tab-pane" id="attachments">
                **# if(($.icescrum.user.creator(story) && story.state == $.icescrum.story.STATE_SUGGESTED) || $.icescrum.user.inProduct()) { **
                    ** partial('attachment-new', { attachmentable : story, id:'right-story-container' }) **
                **# } **
                <table class="table table-striped">
                    <tbody class="previews"
                           data-binding-tpl="attachmentable-attachments"
                           data-binding-id="** story.id **"
                           data-binding-type="story"
                           data-binding-object="attachmentable"
                           data-binding-property="attachments">
                    </tbody>
                </table>
            </div>
            <div class="tab-pane" id="comments">
                <table class="table table-striped">
                    <tbody data-binding-tpl="commentable-comments"
                           data-binding-id="** story.id **"
                           data-binding-type="story"
                           data-binding-object="commentable"
                           data-binding-property="comments">
                    </tbody>
                </table>
                **# if($.icescrum.user.inProduct() || $.icescrum.user.stakeHolder()) { **
                    ** partial('comment-new', { commentable : story }) **
                **# } **
            </div>
            <div class="tab-pane" id="tasks">
                **# if($.icescrum.user.inProduct()) { **
                    ** partial('task-new', { story : story }) **
                **# } **
                <table class="table table-striped">
                    <tbody data-binding-tpl="story-tasks"
                           data-binding-type="story"
                           data-binding-id="** story.id **"
                           data-binding-property="tasks">
                    </tbody>
                </table>
            </div>
            <div class="tab-pane" id="tests">
                **# if($.icescrum.user.inProduct()) { **
                    ** partial('test-new', { story : story }) **
                **# } **
                <table class="table table-striped">
                    <tbody data-binding-tpl="story-tests"
                           data-binding-type="story"
                           data-binding-id="** story.id **"
                           data-binding-property="acceptanceTests">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</script>
