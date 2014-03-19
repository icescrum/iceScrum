<%@ page import="org.icescrum.core.utils.BundleUtils" %>
<underscore id="tpl-edit-story">
    **# var sizeAttachments = _.size(story.attachments) **
    **# var sizeComments = _.size(story.comments) **
    **# var sizeTasks = _.size(story.tasks) **
    **# var sizeTests = _.size(story.tests) **
    <g:set var="updateUrl" value="${createLink(controller: 'story', action: 'update', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <g:set var="attachmentUrl" value="${createLink(action:'attachments', controller: 'story', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"/>
    <div class="panel panel-default">
        <div class="panel-heading" data-fixed data-fixed-container="#right" data-fixed-offset-top="1" data-fixed-offset-width="-2">
            <h3 class="panel-title">
                <a href="${g.createLink(controller:'story', action:'follow', id:'**.story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                   data-status
                   data-status-toggle="fa-star"
                   data-status-title="followers"><i class="fa fa-star-o"></i></a> ** story.name ** <small>**# if (story.origin) { ** ${message(code:'is.story.origin')}: ** story.origin ** **# } **</small>
                <div class="pull-right">
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
                <button title="${message(code:'todo.is.story.actions')}"
                        data-toggle="tooltip"
                        data-container="body"
                        class="btn btn-default"><span class="fa fa-cog"></span></button>
                <div class="btn-group pull-right">
                    <a href="${g.createLink(controller:'story', action:'like', id:'**.story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                       class="btn btn-default"
                       data-status
                       data-status-title="likers"
                       data-status-suffix="up"
                       data-status-toggle="fa-thumbs">
                        <i class="fa fa-thumbs-o-up"></i>
                        <span class="badge"></span>
                    </a>
                    <button name="activities" class="btn btn-default"
                            title="${message(code:'todo.is.story.lastActivity')}"
                            data-toggle="tooltip"
                            data-container="body"
                            data-scrollto
                            data-scrollto-id="activities"
                            data-scrollto-tabs="true"
                            data-scrollto-container="#right">
                        <span class="fa fa-clock-o"></span>
                    </button>
                    <button class="btn btn-default"
                            title="** sizeAttachments ** ${message(code:'todo.is.backlogelement.attachments')}"
                            data-toggle="tooltip"
                            data-container="body"
                            data-scrollto
                            data-scrollto-id="attachments"
                            data-scrollto-tabs="true"
                            data-scrollto-container="#right">
                        <span class="fa fa-paperclip"></span>
                        <span class="badge" **# if(sizeAttachments == 0) { ** style="display:none" **# } ** >** sizeAttachments **</span>
                    </button>
                    <button name="comments" class="btn btn-default"
                            title="** sizeComments ** ${message(code:'todo.is.story.comments')}"
                            data-toggle="tooltip"
                            data-container="body"
                            data-scrollto
                            data-scrollto-id="comments"
                            data-scrollto-tabs="true"
                            data-scrollto-container="#right">
                        <span class="fa fa-comment**# if(sizeComments == 0){ **-o**# } **"></span>
                        <span class="badge" **# if(sizeComments == 0) { ** style="display:none" **# } ** >** sizeComments **</span>
                    </button>
                    <button name="tasks" class="btn btn-default"
                            title="** sizeTasks ** ${message(code:'todo.is.story.tasks')}"
                            data-toggle="tooltip"
                            data-container="body"
                            data-scrollto
                            data-scrollTo-id="tasks"
                            data-scrollto-tabs="true"
                            data-scrollto-container="#right">
                        <span class="fa fa-tasks"></span>
                        <span class="badge" **# if(sizeTasks == 0) { ** style="display:none" **# } ** >** sizeTasks **</span>
                    </button>
                    <button name="tests" class="btn btn-default"
                            title="** sizeTests ** ${message(code:'todo.is.acceptanceTests')}"
                            data-toggle="tooltip"
                            data-container="body"
                            data-placement="left"
                            data-scrollto
                            data-scrollto-id="tests"
                            data-scrollto-tabs="true"
                            data-scrollto-container="#right">
                        <span class="fa fa-check-square**# if(sizeTests == 0){ **-o**# } **"></span>
                        <span class="badge" **# if(sizeTests == 0) { ** style="display:none" **# } ** >** sizeTests **</span>
                    </button>
                </div>
            </div>
        </div>
        <div id="right-story-container" class="right-properties new panel-body" data-elemid="** story.id **">
            <div class="clearfix no-padding">
                <div class="col-md-6 form-group">
                    <label for="story.name">${message(code:'is.story.name')}</label>
                    <div class="input-group">
                        <input required
                               name="story.name"
                               type="text"
                               class="form-control"
                               data-txt
                               data-txt-change="${updateUrl}"
                               value="** story.name **">
                        <span class="input-group-btn">
                            <button type="button"
                                    data-title="${message(code:'is.permalink')}"
                                    data-toggle="popover"
                                    data-content="** $.icescrum.o.grailsServer **/** $.icescrum.product.pkey **-** story.uid **"
                                    data-container="body"
                                    data-placement="left"
                                    class="btn btn-default">
                                <i class="fa fa-link"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-md-6 form-group">
                    <label for="story.feature.id">${message(code:'is.feature')}</label>
                    **# if (story.feature) { **
                    <div class="input-group">
                        **# } **
                        <input  type="hidden"
                                name="story.feature.id"
                                style="width:100%;"
                                data-sl2ajax
                                class="form-control"
                                data-sl2ajax-format-result="$.icescrum.feature.formatSelect"
                                data-sl2ajax-format-selection="$.icescrum.feature.formatSelect"
                                data-sl2ajax-created="$.icescrum.feature.formatSelect"
                                data-sl2ajax-change="${updateUrl}"
                                data-sl2ajax-url="${createLink(controller: 'feature', action: 'featureEntries', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                                data-sl2ajax-placeholder="${message(code: 'is.ui.story.nofeature')}"
                                data-sl2ajax-allow-clear="true"
                                data-color="**# if (story.feature) { **** story.feature.color ****# } **"
                                value="**# if (story.feature) { **** story.feature.name ****# } **"/>
                        **# if (story.feature) { **
                        <span class="input-group-btn">
                            <a href="#feature/** story.feature.id **"
                               title="** story.feature.name **"
                               class="btn btn-default">
                                <i class="fa fa-external-link"></i>
                            </a>
                        </span>
                    </div>
                    **# } **
                </div>
            </div>
            <div class="clearfix no-padding">
                <div class="form-group col-md-**# if(story.type == $.icescrum.story.TYPE_DEFECT) { **6**# } else { **12**# } **">
                    <label for="story.type">${message(code:'is.story.type')}</label>
                    <select name="story.type"
                            class="form-control"
                            style="width:100%"
                            data-sl2
                            data-sl2-format-result="$.icescrum.story.formatSelect"
                            data-sl2-format-selection="$.icescrum.story.formatSelect"
                            data-sl2-change="${updateUrl}"
                            data-sl2-value="** story.type **">
                        <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}" />
                    </select>
                </div>
                **# if(story.type == $.icescrum.story.TYPE_DEFECT) { **
                <div class="col-md-6 form-group">
                    <label for="story.affectVersion">${message(code:'is.story.affectVersion')}</label>
                    <input type="hidden"
                           name="story.affectVersion"
                           style="width:100%"
                           class="form-control"
                           data-sl2ajax
                           data-sl2ajax-change="${updateUrl}"
                           data-sl2ajax-placeholder="${message(code:'is.ui.story.noaffectversion')}"
                           data-sl2ajax-url="${g.createLink(controller:'project', action: 'versions', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                           data-sl2ajax-allow-clear="true"
                           data-sl2ajax-create-choice-on-empty="true"
                           value="** story.affectVersion **"/>
                </div>
                **# } **
            </div>
            <div class="form-group">
                <label for="story.dependsOn.id">${message(code:'is.story.dependsOn')}</label>
                **# if (story.dependsOn) { **
                <div class="input-group">
                    **# } **
                <input
                        type="hidden"
                        name="story.dependsOn.id"
                        style="width:100%;"
                        data-sl2ajax
                        class="form-control"
                        data-sl2ajax-change="${updateUrl}"
                        data-sl2ajax-url="${createLink(controller: 'story', action: 'dependenceEntries', id:'** story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
                        data-sl2ajax-placeholder="${message(code: 'is.ui.story.nodependence')}"
                        data-sl2ajax-allow-clear="true"
                        value="**# if (story.dependsOn) { **** story.dependsOn.name ** (** story.dependsOn.uid **) **# } **"/>
                **# if (story.dependsOn) { **
                    <span class="input-group-btn">
                        <a href="#story/** story.dependsOn.id **"
                           title="** story.dependsOn.name **"
                           class="btn btn-default">
                            <i class="fa fa-external-link"></i>
                        </a>
                    </span>
                </div>
                **# } **
            </div>
            **# if (_.size(story.dependences) > 0) {
                _.each(story.dependences, function(item) { **
                    <a class="scrum-link" title="** item.name **">** item.name **</a>
                **# }) **
            **# } **
            <div class="form-group">
                <label for="story.description">${message(code:'is.backlogelement.description')}</label>
                <textarea name="story.description"
                          data-at
                          class="form-control"
                          data-at-at="a"
                          data-at-matcher="$.icescrum.story.formatters.description"
                          data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                          data-at-placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                          data-at-change="${updateUrl}"
                          data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                          data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}">** story.description **</textarea>
            </div>
            <div class="form-group">
                <input  type="hidden"
                        name="story.tags"
                        style="width:100%"
                        data-sl2tag
                        class="form-control"
                        data-sl2tag-tag-link="#finder?tag="
                        data-sl2tag-change="${updateUrl}"
                        data-sl2tag-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                        data-sl2tag-url="${g.createLink(controller:'finder', action: 'tag', params:[product:'** jQuery.icescrum.product.pkey **'])}"
                        value="** story.tags **"/>
            </div>
            <div class="form-group">
                <label for="story.notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea name="story.notes"
                          data-mkp
                          class="form-control"
                          data-mkp-placeholder="_${message(code: 'is.ui.backlogelement.nonotes')}_"
                          data-mkp-height="140"
                          data-mkp-change="${updateUrl}">** story.notes **</textarea>
            </div>
            <ul class="nav nav-tabs nav-tabs-google" data-ui-tabs-auto-collapse>
                <li class="active"><a href="#activities" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity')}</a></li>
                <li><a href="#attachments" data-toggle="tab">${message(code: 'is.backlogelement.attachment')}</a></li>
                <li><a href="#comments" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity.comments')}</a></li>
                <li><a href="#tasks" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity.task')}</a></li>
                <li><a href="#tests" data-toggle="tab">${message(code: 'is.ui.backlogelement.activity.test')}</a></li>
            </ul>
            <div class="tab-content">
                <div class="tab-pane active" id="activities">
                </div>
                <div class="tab-pane" id="comments">
                </div>
                <div class="tab-pane" id="attachments">
                    <div data-dz
                         data-dz-id="right-story-container"
                         data-dz-add-remove-links="true"
                         data-dz-files='** JSON.stringify(story.attachments) **'
                         data-dz-clickable="#right-story-container .clickable"
                         data-dz-url="${attachmentUrl}"
                         data-dz-previews-container="#right-story-container .previews"
                         class="btn-group pull-right btn-group-sm providers">
                        <button class="btn btn-default clickable"
                                data-toggle="tooltip"
                                data-ui-tooltip-container="body"
                                title="${message(code:'todo.is.ui.attach.files')}">
                            <span class="glyphicon glyphicon-plus"></span>
                        </button>
                    </div>
                    <div class="clearfix previews list-group">
                    </div>
                </div>
                <div class="tab-pane" id="tasks">
                </div>
                <div class="tab-pane" id="tests">
                </div>
            </div>
        </div>
    </div>
</underscore>