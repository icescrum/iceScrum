%{--
- Copyright (c) 2010 iceScrum Technologies.
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
- Stephane Maldini (stephane.maldini@icescrum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="grails.plugin.fluxiable.Activity" %>
<div class="dashboard">
    <div class="colset-2 clearfix">
        <div class="col1">
            <entry:point id="${controllerName}-${actionName}-top-left" model="[sprint:sprint,release:release,product:product]"/>
            <is:panel id="panel-chart">
                <is:panelTitle>
                    <g:if test="${request.inProduct}">
                        <is:link class="right" id="chart-sprintBurndownRemainingChart" disabled="true"
                                 onClick="jQuery.icescrum.displayChart('#panel-chart-container','sprintPlan/sprintBurndownRemainingChart',true);">${message(code: 'is.ui.project.chart.option.remaining')}</is:link>
                        <span class="right">|</span>
                        <is:link class="right" id="chart-sprintBurnupTasksChart" disabled="true"
                                 onClick="jQuery.icescrum.displayChart('#panel-chart-container','sprintPlan/sprintBurnupTasksChart',true);">${message(code: 'is.ui.project.chart.option.tasks')}</is:link>
                        <span class="right">|</span>
                        <is:link class="right" id="chart-sprintBurnupPointsChart" disabled="true"
                                 onClick="jQuery.icescrum.displayChart('#panel-chart-container','sprintPlan/sprintBurnupPointsChart',true);">${message(code: 'is.ui.project.chart.option.points')}</is:link>
                        <span class="right">|</span>
                        <is:link rendered="${sprint}" id="chart-sprintBurnupStoriesChart" class="right" disabled="true"
                                 onClick="jQuery.icescrum.displayChart('#panel-chart-container','sprintPlan/sprintBurnupStoriesChart',true);">${message(code: 'is.ui.project.chart.option.stories')}</is:link>
                        <span class="right">|</span>
                    </g:if>
                    <is:link class="right" disabled="true" id="chart-productBurnupChart"
                             onClick="jQuery.icescrum.displayChart('#panel-chart-container','${controllerName}/productBurnupChart/',true);">${message(code: 'is.ui.project.chart.option.project')}</is:link>
                    <g:message code="is.ui.project.chart.title"/>
                </is:panelTitle>
                <div id="panel-chart-container" class="panel-box-content">
                </div>
            </is:panel>
            <is:panel id="panel-description">
                <is:panelTitle>
                    <g:if test="${request.scrumMaster}">
                        <span class="right">
                            <a href="${createLink(controller:'project', action:'edit',params:[product:product.id])}" data-ajax="true">
                                <g:message code="default.button.edit.label"/>
                            </a>
                        </span>
                    </g:if>
                    <g:message code="is.ui.project.description.title"/>
                </is:panelTitle>
                <div class="panel-box-content">
                    <g:if test="${product.description}">
                        <div class="rich-content"><is:renderHtml>${product.description}</is:renderHtml></div>
                    </g:if>
                    <g:else>
                        <g:message code="is.product.empty.description"/>
                    </g:else>
                </div>
            </is:panel>
            <is:panel class="panel-vision" id="panel-vision-${release?.id}">
                <is:panelTitle>
                    <g:if test="${request.productOwner && release?.id}">
                        <span class="right">
                            <a href="#releasePlan/vision/${release.id}">
                                <g:message code="default.button.edit.label"/>
                            </a>
                        </span>
                    </g:if>
                    <g:message code="is.ui.project.vision.title"/>
                </is:panelTitle>
                <div class="panel-box-content">
                    <g:if test="${release?.vision}">
                        <div class="rich-content"><is:renderHtml>${is.truncated(value: release.vision, size: 1000, encodedHTML: false)}</is:renderHtml></div>
                    </g:if>
                    <g:else>
                        <g:message code="is.release.empty.vision"/>
                    </g:else>
                </div>
                <g:if test="${release?.vision?.length() > 1000}">
                    <div class="read-more">
                        <is:scrumLink
                                controller="releasePlan"
                                action="vision"
                                id="${release.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </is:scrumLink>
                    </div>
                </g:if>
            </is:panel>
            <is:panel class="panel-doneDefinition" id="panel-doneDefinition-${sprint?.id}">
                <is:panelTitle>
                    <g:if test="${(request.productOwner || request.scrumMaster) && sprint?.id}">
                        <span class="right">
                            <a href="#sprintPlan/doneDefinition/${sprint.id}">
                                <g:message code="default.button.edit.label"/>
                            </a>
                        </span>
                    </g:if>
                    <g:message code="is.ui.project.doneDefinition.title"/>
                </is:panelTitle>
                <div class="panel-box-content">
                    <g:if test="${sprint?.doneDefinition}">
                        <div class="rich-content"><is:renderHtml>${is.truncated(value: sprint.doneDefinition, size: 1000, encodedHTML: false)}</is:renderHtml></div>
                    </g:if>
                    <g:else>
                        <g:message code="is.sprint.empty.doneDefinition"/>
                    </g:else>
                </div>
                <g:if test="${sprint?.doneDefinition?.length() > 1000}">
                    <div class="read-more">
                        <is:scrumLink
                                controller="sprintPlan"
                                action="doneDefinition"
                                id="${sprint.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </is:scrumLink>
                    </div>
                </g:if>
            </is:panel>
            <is:panel class="panel-retrospective" id="panel-retrospective-${sprint?.id}">
                <is:panelTitle>
                    <g:if test="${(request.productOwner || request.scrumMaster) && sprint?.id}">
                        <span class="right">
                            <a href="#sprintPlan/retrospective/${sprint.id}">
                                <g:message code="default.button.edit.label"/>
                            </a>
                        </span>
                    </g:if>
                    <g:message code="is.ui.project.retrospective.title"/>
                </is:panelTitle>
                <div class="panel-box-content">
                    <g:if test="${sprint?.retrospective}">
                        <div class="rich-content"><is:renderHtml>${is.truncated(value: sprint.retrospective, size: 1000, encodedHTML: false)}</is:renderHtml>
                        </div>
                    </g:if>
                    <g:else>
                        <g:message code="is.sprint.empty.retrospective"/>
                    </g:else>
                </div>
                <g:if test="${sprint?.retrospective?.length() > 1000}">
                    <div class="read-more">
                        <is:scrumLink
                                controller="sprintPlan"
                                action="retrospective"
                                id="${sprint.id}">
                            <g:message code="is.ui.project.link.more"/>
                        </is:scrumLink>
                    </div>
                </g:if>
            </is:panel>
            <entry:point id="${controllerName}-${actionName}-bottom-left" model="[sprint:sprint,release:release,product:product]"/>
        </div>

        <div class="col2">
            <entry:point id="${controllerName}-${actionName}-top-right" model="[sprint:sprint,release:release,product:product]"/>
            <is:cache cache="projectCache" role="false" key="${product.id}-${product.lastUpdated}-${activities.size() ? activities?.first()?.dateCreated :''}">
                <is:panel id="panel-activity">
                    <is:panelTitle>
                        <g:link class="button-rss" action="feed" params="[product:product.pkey,lang:lang]">
                            <span class='ico'></span>
                        </g:link>
                        <g:message code="is.ui.project.activity.title"/>
                    </is:panelTitle>
                    <g:if test="${activities.size() > 0}">
                        <ul class="list-news">
                            <g:each in="${activities}" var="a" status="i">
                                <li ${(activities.size() == (i + 1)) ? 'class="last"' : ''}>
                                    <div class="news-item news-${a.code}">
                                        <p>
                                            <is:scrumLink controller="user" action='profile'
                                                          id="${a.poster.username}">${a.poster.firstName.encodeAsHTML()} ${a.poster.lastName.encodeAsHTML()}</is:scrumLink>
                                            <g:message code="is.fluxiable.${a.code}"/> <g:message code="is.${a.code == 'taskDelete' ? 'task' : a.code == 'acceptanceTestDelete' ? 'acceptanceTest' : 'story'}"/>
                                            <g:if test="${a.code != Activity.CODE_DELETE}">
                                                <is:scrumLink controller="story" id="${a.cachedId}"
                                                              params="${a.code == 'comment' ? ['tab':'comments'] : []}">${a.cachedLabel.encodeAsHTML()}</is:scrumLink>
                                            </g:if>
                                            <g:else>
                                                <strong>${a.cachedLabel.encodeAsHTML()}</strong>
                                            </g:else>
                                        </p>

                                        <p><g:formatDate date="${a.dateCreated}" formatName="is.date.format.short.time"
                                                         timeZone="${product.preferences.timezone}"/></p>
                                    </div>
                                </li>
                            </g:each>
                        </ul>
                    </g:if>
                    <g:else>
                        <div class="panel-box-empty">
                            <div style="text-align: center; padding:5px; font-size:14px;">
                                ${message(code:'is.ui.getting.started')}
                                <br/><a class="scrum-link" href onClick="jQuery.icescrum.guidedTour('fullProject', true)">${message(code:'is.ui.getting.started.tour')}</a>
                                <br/><a class="scrum-link" target="_blank" href="https://www.icescrum.com/documentation/getting-started-with-icescrum?utm_source=dashboard&utm_medium=link&utm_campaign=icescrum">${message(code:'is.ui.getting.started.link')}</a>
                            </div>
                        </div>
                    </g:else>
                </is:panel>
            </is:cache>
            <entry:point id="${controllerName}-${actionName}-bottom-right"
                         model="[sprint:sprint,release:release,product:product,activities:activities]"/>
        </div>
    </div>
</div>

<jq:jquery>
    $('.list-news .news-item').hover(function(){
      $(this).addClass('news-item-hover');
    }, function(){
      $(this).removeClass('news-item-hover');
    });
    <g:if test="${sprint && sec.access(expression:'inProduct()',{true})}">
        jQuery.icescrum.displayChartFromCookie('#panel-chart-container','${controllerName}/productBurnupChart/');
    </g:if>
    <g:else>
        jQuery.icescrum.displayChart('#panel-chart-container','${controllerName}/productBurnupChart/');
    </g:else>
</jq:jquery>

<is:onStream on=".panel-vision" events="[[object:'release',events:['vision']]]"/>
<is:onStream on=".panel-retrospective" events="[[object:'sprint',events:['retrospective']]]"/>
<is:onStream on=".panel-doneDefinition" events="[[object:'sprint',events:['doneDefinition']]]"/>