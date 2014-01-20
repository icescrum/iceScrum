<underscore id="tpl-postit-story">
    <div data-elemid="** story.id **" id="postit-story-** story.id **" class="postit story postit-story ui-selectee">
        <div class="postit-layout **# if(story.feature){ ** postit-** story.feature.color ** **# } **">
            <p class="postit-id">
                <is:scrumLink controller="story" id='** story.id **'>** story.id **</is:scrumLink>
                <g:if test="${dependsOn}">
                    <span class="dependsOn" data-elemid="${dependsOn.id}">(<is:scrumLink controller="story" id="${dependsOn.id}">${dependsOn.uid}</is:scrumLink>)</span>
                </g:if>
            </p>
            <div class="icon-container">
                **# if (_.size(story.comments) > 0) { **
                    <span class="postit-comment icon" title="** _.size(story.comments) **"></span>
                **# } **
                **# if (_.size(story.attachments) > 0) { **
                    <span class="postit-attachment icon" title="** _.size(story.attachments) **"></span>
                **# } **
                **# if (_.size(story.acceptanceTests) > 0) { **
                    <span class="icon story-icon-acceptance-test icon-acceptance-test"></span>
                **# } **
            </div>
            <p class="postit-label break-word">** story.name **</p>
            <div class="postit-excerpt">** $.icescrum.story.formatters.description(story.description) **</div>
            <span class="postit-ico ico-story-** story.type **"></span>
            <div class="state task-state">
                <span class="text-state">** $.icescrum.story.formatters.state(story.state) **</span>
                <div class="dropmenu-action">
                    <div id="menu-postit-story-** story.id **"
                         data-nowindows="false"
                         data-offset="0"
                         data-top="13"
                         class="dropmenu"
                         data-dropmenu="true">
                        <span class="dropmenu-arrow">!</span>
                        <div class="dropmenu-content ui-corner-all">
                            <ul class="small">
                                **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_SUGGESTED) { **
                                <li>
                                    <a href="${createLink(action:'accept',controller:'story', id:'** story.id **', params:[type:'story',product:params.product])}"
                                       data-ajax-trigger="accept_story"
                                       data-ajax-notice="${message(code: 'is.story.acceptedAsStory').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.sandbox.menu.acceptAsStory'/>
                                    </a>
                                </li>
                                <li>
                                    <a href="${createLink(action:'accept',controller:'story', id:'** story.id **', params:[type:'feature',product:params.product])}"
                                       data-ajax-trigger="accept_story"
                                       data-ajax-notice="${message(code: 'is.story.acceptedAsFeature').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.sandbox.menu.acceptAsFeature'/>
                                    </a>
                                </li>
                                **# if ($.icescrum.sprint.current) { **
                                <li class="menu-accept-task">
                                    <a href="${createLink(action:'accept',controller:'story', id:'** story.id **', params:[type:'task',product:params.product])}"
                                       data-ajax-trigger="accept_story"
                                       data-ajax-notice="${message(code: 'is.story.acceptedAsUrgentTask').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.sandbox.menu.acceptAsUrgentTask'/>
                                    </a>
                                </li>
                                **# } **
                                **# } **
                                **# if ($.icescrum.user.productOwner && _.contains([$.icescrum.story.STATE_ACCEPTED, $.icescrum.story.STATE_ESTIMATED], story.state)) { **
                                    <li>
                                        <a href="${createLink(action:'returnToSandbox', id:'** story.id **', controller:'story',params:[product:params.product])}"
                                           data-ajax-trigger="returnToSandbox_story"
                                           data-ajax-notice="${message(code: 'is.story.returnedToSandbox').encodeAsJavaScript()}"
                                           data-ajax="true">
                                            <g:message code='is.ui.backlog.menu.returnToSandbox'/>
                                        </a>
                                    </li>
                                **# } **
                                **# if ($.icescrum.user.inProduct && _.contains([$.icescrum.story.STATE_PLANNED, $.icescrum.story.STATE_INPROGRESS], story.state)) { **
                                <li>
                                    <a href="#sprintPlan/add/** story.parentSprint.id **/?story.id=** story.id **">
                                        <g:message code='is.ui.sprintPlan.kanban.recurrentTasks.add'/>
                                    </a>
                                </li>
                                **# } **
                                **# if ($.icescrum.user.inProduct && story.state >= $.icescrum.story.STATE_SUGGESTED) { **
                                <li>
                                    <a href="${createLink(action:'copy',controller:'story', id:'** story.id **', params:[product:params.product])}"
                                       data-ajax-trigger="add_story"
                                       data-ajax-notice="${message(code: 'is.story.cloned').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.releasePlan.menu.story.clone'/>
                                    </a>
                                </li>
                                **# } **
                                **# if ($.icescrum.user.poOrSm && story.state >= $.icescrum.story.STATE_PLANNED && story.state != $.icescrum.story.STATE_DONE) { **
                                <li>
                                    <a href="${createLink(action:'unPlan',controller:'story', id:'** story.id **', params:[product:params.product])}"
                                       data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
                                       data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.story.warning.dissociate').encodeAsJavaScript()}"
                                       data-ajax-notice="${message(code: 'is.sprint.stories.dissociated').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.releasePlan.menu.story.dissociate'/>
                                    </a>
                                </li>
                                **# } **
                                **# if ($.icescrum.user.poOrSm && story.state >= $.icescrum.story.STATE_PLANNED && story.state != $.icescrum.story.STATE_INPROGRESS) { **
                                <li class="menu-shift-${sprint?.parentRelease?.id}-${(sprint?.orderNumber instanceof Integer ?sprint?.orderNumber + 1:sprint?.orderNumber)} ${nextSprintExist?'':'hidden'}">
                                    <a href="${createLink(action:'unPlan',controller:'story', id:'** story.id **',params:[product:params.product,shiftToNext:true])}"
                                       data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
                                       data-ajax-notice="${message(code: 'is.story.shiftedToNext').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.sprintPlan.menu.postit.shiftToNext'/>
                                    </a>
                                </li>
                                **# } **
                                **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_INPROGRESS) { **
                                <li>
                                    <a href="${createLink(action:'done',controller:'story', id:'** story.id **', params:[product:params.product])}"
                                       data-ajax-trigger="done_story"
                                       data-ajax-notice="${message(code: 'is.story.declaredAsDone').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.releasePlan.menu.story.done'/>
                                    </a>
                                </li>
                                **# } **
                                **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_DONE && story.parentSprint.state == $.icescrum.sprint.STATE_INPROGRESS) { **
                                <li>
                                    <a href="${createLink(action:'unDone',controller:'story', id:'** story.id **', params:[product:params.product])}"
                                       data-ajax-trigger="unDone_story"
                                       data-ajax-notice="${message(code: 'is.story.declaredAsUnDone').encodeAsJavaScript()}"
                                       data-ajax="true">
                                        <g:message code='is.ui.releasePlan.menu.story.undone'/>
                                    </a>
                                </li>
                                **# } **
                                <entry:point id="${controllerName}-postitMenu"/>
                                **# if (($.icescrum.user.productOwner && story.state <= $.icescrum.story.STATE_ESTIMATED) || ($.icescrum.user.productOwner && story.state <= $.icescrum.story.STATE_SUGGESTED)) { **
                                <li>
                                    <a href="${createLink(action:'openDialogDelete',controller:'story', id:'** story.id **',params:[product:params.product])}"
                                       data-ajax="true">
                                        <g:message code='is.ui.sandbox.menu.delete'/>
                                    </a>
                                </li>
                                **# } **
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</underscore>