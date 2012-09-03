%{--
- Copyright (c) 2012 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<g:set var="sprint" value="${task.backlog}"/>
<g:set var="product" value="${sprint.parentRelease.parentProduct}"/>

<div class="dashboard" id="details-${task.id}" data-elemid="${task.id}">
    <div class="colset-2-80 clearfix">
        <div class="col1">

            <is:panel id="panel-infos">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.information')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.backlogelement.id')}">
                        ${task.uid}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.backlogelement.name')}">
                        ${task.name.encodeAsHTML()}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.story')}" rendered="${task.parentStory != null}" id="${'detail-story-'+task.parentStory?.id}">
                        <is:scrumLink controller="story" id="${task.parentStory.id}">
                            ${task.parentStory.name.encodeAsHTML()}
                        </is:scrumLink>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.type')}" rendered="${task.parentStory == null}">
                        ${message(code: taskTypeCode)}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.color')}">
                        <is:postitIcon color="${task.color}"/>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.estimation')}" rendered="${task.estimation != null}">
                        ${task.estimation}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.sprint')}" rendered="${sprint != null}">
                        <is:scrumLink controller="releasePlan" id="${sprint.parentRelease.id}">
                            ${message(code: 'is.release')} ${sprint.parentRelease.orderNumber}
                        </is:scrumLink>
                        <is:scrumLink controller="sprintPlan" id="${sprint.id}">
                            ${message(code: 'is.sprint')} ${sprint.orderNumber}
                        </is:scrumLink>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.backlogelement.description')}">
                        ${task.description?.encodeAsHTML()?.encodeAsNL2BR()}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.backlogelement.notes')}">
                        <g:if test="${task.notes}">
                            <div class="rich-content"><wikitext:renderHtml markup="Textile">${task.notes}</wikitext:renderHtml></div>
                        </g:if>
                    </is:panelLine>
                    <g:if test="${task.totalAttachments}">
                        <is:panelLine legend="${message(code:'is.ui.backlogelement.attachment',args:[task.totalAttachments > 1 ?'s':''])}">
                            <is:attachedFiles bean="${task}" width="120" deletable="${false}"
                                              params="[product:params.product]" action="download"
                                              controller="task"
                                              size="20"/>
                        </is:panelLine>
                    </g:if>
                </is:panelContext>
            </is:panel>

            <is:panel id="panel-activity">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.activity')}</is:panelTitle>
                <is:panelTabButton id="panel-box-1">
                    <a rel="#summary" href="../" class="${!params.tab || 'summary' in params.tab ? 'selected' : ''}">
                        ${message(code: 'is.ui.backlogelement.activity.summary')}
                    </a>
                    <entry:point id="${controllerName}-${actionName}-tab-button"/>
                </is:panelTabButton>
                <div id="panel-tab-contents-1" class="panel-tab-contents">
                    <g:include  action="summaryPanel" controller="task" params="[product:params.product, id:task.id]"/>
                    <entry:point id="${controllerName}-${actionName}-tab-entry" model="[task:task]"/>
                </div>
                <jq:jquery>
                    $("#panel-box-1 a").live('hover',function(){
                        $(this).each(function() {
                          var item = $(this);
                          var rel = $(item.attr('rel'));
                          item.click(function(){
                            $("#panel-tab-contents-1 .tab-selected").hide();
                            $("#panel-tab-contents-1 .tab-selected").removeClass("tab-selected");
                            $("#panel-box-1 .selected").removeClass("selected");
                            item.addClass("selected");
                            rel.addClass("tab-selected");
                            rel.show();
                            return false;
                          });
                        });
                    });
                </jq:jquery>
            </is:panel>

        </div>

        <div class="col2">

            <is:panel id="panel-people">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.people')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.task.creator')}">
                        <is:scrumLink controller="user" action="profile" id="${task.creator.username}">
                            ${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}
                        </is:scrumLink>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.responsible')}" rendered="${task.responsible != null}">
                        <is:scrumLink controller="user" action="profile" id="${task.responsible.username}">
                            ${task.responsible.firstName.encodeAsHTML()} ${task.responsible.lastName.encodeAsHTML()}
                        </is:scrumLink>
                    </is:panelLine>
                </is:panelContext>
            </is:panel>

            <is:panel id="panel-dates">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.dates')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.task.date.created')}">
                        <g:formatDate date="${task.dateCreated}"
                                      formatName="is.date.format.short.time"
                                      timeZone="${product.preferences.timezone}"/>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.date.inprogress')}" rendered="${task.inProgressDate != null}">
                        <g:formatDate date="${task.inProgressDate}"
                                      formatName="is.date.format.short.time"
                                      timeZone="${product.preferences.timezone}"/>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.task.date.done')}" rendered="${task.doneDate != null}">
                        <g:formatDate date="${task.doneDate}"
                                      formatName="is.date.format.short.time"
                                      timeZone="${product.preferences.timezone}"/>
                    </is:panelLine>
                </is:panelContext>
            </is:panel>

            <is:panel id="panel-progress">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.progress')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.task.state')}">
                        ${message(code: taskStateCode)}
                    </is:panelLine>
                </is:panelContext>
            </is:panel>

            <entry:point id="${controllerName}-${actionName}-right" model="[task:task]"/>

        </div>
    </div>
</div>