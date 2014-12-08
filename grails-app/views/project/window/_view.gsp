%{--
- Copyright (c) 2014 Kagilum SAS
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
<g:set var="ownerOrSm" value="${request.scrumMaster || request.owner}"/>
<%@ page import="org.icescrum.core.domain.Activity" %>
<div class="row">
    <div class="col-sm-5 col-sm-push-7 col-md-5 col-md-push-7">

        <g:render template="window/toolbar" model="[params:params]"/>

        <entry:point id="${controllerName}-${actionName}-top-right" model="[sprint:sprint,release:release,product:product]"/>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.activity.title"/>
                    <small class="pull-right">
                        <g:link class="rss" data-toggle="tooltip" title="${message(code:'todo.is.ui.rss')}" mapping="${product.preferences.hidden ? 'privateURL' : ''}" action="feed" params="[product:product.pkey,lang:lang]">
                            <i class="fa fa-rss fa-lg"></i>
                        </g:link>
                    </small>
                </h3>
            </div>
            <div class="panel-body activities">
                <g:if test="${activities.size() > 0}">
                    <g:each in="${activities}" var="a" status="i">
                        <div class="activity clearfix">
                            <span class="text-muted ${a.code}"></span>
                            <div class="content">
                                <small class="text-muted pull-right">${a.dateCreated}<span class="fa fa-clock-o"></span></small>
                                <span class="clearfix">
                                    <is:scrumLink controller="user" action='profile' id="${a.poster.username}">${a.poster.firstName.encodeAsHTML()} ${a.poster.lastName.encodeAsHTML()}</is:scrumLink>
                                    <g:message code="is.fluxiable.${a.code}"/> <g:message code="is.${a.code == 'taskDelete' ? 'task' : a.code == 'acceptanceTestDelete' ? 'acceptanceTest' : 'story'}"/>
                                    <g:if test="${a.code != Activity.CODE_DELETE}">
                                        <is:scrumLink controller="story" id="${a.parentRef}" params="${a.code == 'comment' ? ['tab':'comments'] : []}">
                                            ${a.label.encodeAsHTML()}
                                        </is:scrumLink>
                                    </g:if>
                                    <g:else>
                                        ${a.label.encodeAsHTML()}
                                    </g:else>
                                </span>
                                <div class="sub-content">
                                    <img src="${is.avatar(user:a.poster)}" height="25px" class="pull-left"/>
                                    <span class="text-muted">${a.description}</span>
                                </div>
                            </div>
                        </div>
                    </g:each>
                </g:if>
                <g:else>
                    <div class="panel-box-empty">
                        <div style="text-align: center; padding:5px; font-size:14px;">
                            <a class="scrum-link" target="_blank" href="https://www.kagilum.com/documentation/getting-started-with-icescrum">${message(code:'is.ui.getting.started')}</a>
                        </div>
                    </div>
                </g:else>
            </div>
        </div>
        <entry:point id="${controllerName}-${actionName}-bottom-right" model="[sprint:sprint,release:release,product:product,activities:activities]"/>
    </div>
    <div class="col-md-7 col-md-pull-5 col-sm-7 col-sm-pull-5">
        <entry:point id="${controllerName}-${actionName}-top-left" model="[sprint:sprint,release:release,product:product]"/>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.chart.title"/>
                    <small class="pull-right">
                        <div dropdown class="btn-group" tooltip="${message(code:'todo.is.ui.charts')}">
                            <button class="btn btn-default btn-sm dropdown-toggle" type="button" dropdown-toggle>
                                <span class="glyphicon glyphicon-stats"></span>&nbsp;<span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu"
                                data-ui-dropdown-clickbsdropdown="$.icescrum.openChart"
                                data-ui-chart-container="#panel-chart-container"
                                data-ui-chart-cookie="${sprint && request.inProduct}"
                                data-ui-chart-default="${controllerName}/productBurnupChart/">
                                <li role="presentation" class="dropdown-header">${message(code: 'is.product')}</li>
                                <li><a data-ui-chart data-ui-chart-save="true" data-ui-chart-container="#panel-chart-container" href="${controllerName}/productBurnupChart/">${message(code: 'is.ui.project.chart.option.project')}</a></li>
                                <entry:point id="${controllerName}-${actionName}-charts-product" model="[sprint:sprint,release:release,product:product]"/>
                                <g:if test="${sprint && request.inProduct}">
                                    <li class="divider"></li>
                                    <li role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</li>
                                    <li><a data-ui-chart data-ui-chart-save="true" data-ui-chart-container="#panel-chart-container" href="sprintPlan/sprintBurndownRemainingChart">${message(code: 'is.ui.project.chart.option.remaining')}</a></li>
                                    <li><a data-ui-chart data-ui-chart-save="true" data-ui-chart-container="#panel-chart-container" href="sprintPlan/sprintBurnupTasksChart">${message(code: 'is.ui.project.chart.option.tasks')}</a></li>
                                    <li><a data-ui-chart data-ui-chart-save="true" data-ui-chart-container="#panel-chart-container" href="sprintPlan/sprintBurnupPointsChart">${message(code: 'is.ui.project.chart.option.points')}</a></li>
                                    <li><a data-ui-chart data-ui-chart-save="true" data-ui-chart-container="#panel-chart-container" href="sprintPlan/sprintBurnupStoriesChart">${message(code: 'is.ui.project.chart.option.stories')}</a></li>
                                    <entry:point id="${controllerName}-${actionName}-charts-sprint" model="[sprint:sprint,release:release,product:product]"/>
                                </g:if>
                            </ul>
                        </div>
                        <g:if test="${request.inProduct}">
                        </g:if>
                    </small>
                </h3>
            </div>
            <div class="panel-body" id="panel-chart-container">
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.description.title"/>
                    <g:if test="${request.productOwner}">
                        <small class="pull-right on-hover">
                            <a class="text-muted" tooltip="${message(code:'default.button.edit.label')}" href="${createLink(controller:'project', action:'edit',params:[product:product.id])}" data-ajax="true">
                                <i class="fa fa-edit fa-lg"></i>
                            </a>
                        </small>
                    </g:if>
                </h3>
            </div>
            <div class="panel-body">
                <g:if test="${product.description}">
                    <wikitext:renderHtml markup="Textile">${product.description}</wikitext:renderHtml>
                </g:if>
                <g:else>
                    <p class="text-muted"><g:message code="is.product.empty.description"/></p>
                </g:else>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.vision.title"/>
                    <g:if test="${request.productOwner && release?.id}">
                        <small class="pull-right on-hover">
                            <a class="text-muted" href="#releasePlan/vision/${release.id}" tooltip="${message(code:'default.button.edit.label')}">
                                <i class="fa fa-edit fa-lg"></i>
                            </a>
                        </small>
                    </g:if>
                </h3>
            </div>
            <div class="panel-body">
                <g:if test="${release?.vision}">
                    <wikitext:renderHtml markup="Textile">${is.truncated(value: release.vision, size: 1000, encodedHTML: false)}</wikitext:renderHtml>
                </g:if>
                <g:else>
                    <p class="text-muted"><g:message code="is.release.empty.vision"/></p>
                </g:else>
                <g:if test="${release?.vision?.length() > 1000}">
                    <p class="pull-right">
                        <a href="#releasePlan/vision/${release.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </a>
                    </p>
                </g:if>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.doneDefinition.title"/>
                    <g:if test="${(request.productOwner || request.scrumMaster) && sprint?.id}">
                        <small class="pull-right on-hover">
                            <a class="text-muted" href="#sprintPlan/doneDefinition/${sprint.id}" tooltip="${message(code:'default.button.edit.label')}">
                                <i class="fa fa-edit fa-lg"></i>
                            </a>
                        </small>
                    </g:if>
                </h3>
            </div>
            <div class="panel-body">
                <g:if test="${sprint?.doneDefinition}">
                    <wikitext:renderHtml markup="Textile">${is.truncated(value: sprint.doneDefinition, size: 1000, encodedHTML: false)}</wikitext:renderHtml>
                </g:if>
                <g:else>
                    <p class="text-muted"><g:message code="is.sprint.empty.doneDefinition"/></p>
                </g:else>
                <g:if test="${sprint?.doneDefinition?.length() > 1000}">
                    <p class="pull-right">
                        <a href="#sprintPlan/doneDefinition/${sprint.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </a>
                    </p>
                </g:if>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <g:message code="is.ui.project.retrospective.title"/>
                    <g:if test="${(request.productOwner || request.scrumMaster) && sprint?.id}">
                        <small class="pull-right on-hover">
                            <a class="text-muted" href="#sprintPlan/retrospective/${sprint.id}" tooltip="${message(code:'default.button.edit.label')}">
                                <i class="fa fa-edit fa-lg"></i>
                            </a>
                        </small>
                    </g:if>
                </h3>
            </div>
            <div class="panel-body">
                <g:if test="${sprint?.retrospective}">
                    <div class="rich-content"><wikitext:renderHtml
                            markup="Textile">${is.truncated(value: sprint.retrospective, size: 1000, encodedHTML: false)}</wikitext:renderHtml>
                    </div>
                </g:if>
                <g:else>
                    <p class="text-muted"><g:message code="is.sprint.empty.retrospective"/></p>
                </g:else>
                <g:if test="${sprint?.retrospective?.length() > 1000}">
                    <p class="pull-right">
                        <a href="#sprintPlan/retrospective/${sprint.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </a>
                    </p>
                </g:if>
            </div>
        </div>
        <entry:point id="${controllerName}-${actionName}-bottom-left" model="[sprint:sprint,release:release,product:product]"/>
    </div>

</div>

<is:onStream on=".panel-vision" events="[[object:'release',events:['vision']]]"/>
<is:onStream on=".panel-retrospective" events="[[object:'sprint',events:['retrospective']]]"/>
<is:onStream on=".panel-doneDefinition" events="[[object:'sprint',events:['doneDefinition']]]"/>