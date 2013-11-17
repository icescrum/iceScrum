<%@ page import="org.icescrum.core.domain.PlanningPokerGame; org.icescrum.core.domain.Story; org.icescrum.core.utils.BundleUtils" %>
<div id="search-result">
    <is:backlogElementLayout
            id="window-${controllerName}"
            emptyRendering="true"
            dblclickable='[selector:".postit", callback:"\$.icescrum.displayQuicklook(obj);"]'
            style="display:${data ? 'block' : 'none'};"
            value="${data}"
            var="type">
            <g:if test="${type.key == 'stories'}">
                <div class="search-group"><g:message code="is.story"/> (${type.value?.size()?:0})</div>
                <g:each in="${type.value}" var="story">
                    <is:cache  cache="storyCache" key="postit-${story.id}-${story.lastUpdated}">
                        <g:render template="/story/postit" model="[story:story,user:user, sprint:sprint]"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'tasks'}">
                <div class="search-group"><g:message code="is.task"/> (${type.value?.size()?:0})</div>
                <g:each in="${type.value}" var="task">
                    <is:cache cache="taskCache" key="postit-norect-${task.id}-${task.lastUpdated}">
                        <g:render template="/task/postit" model="[task:task, user:user, rect:'false']"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'features'}">
                <div class="search-group"><g:message code="is.feature"/> (${type.value?.size()?:0})</div>
                <g:each in="${type.value}" var="feature">
                    <is:cache cache="featureCache" key="postit-${feature.id}-${feature.lastUpdated}">
                        <g:render template="/feature/postit" model="[feature:feature]"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'actors'}">
                <div class="search-group"><g:message code="is.actor"/> (${type.value?.size()?:0})</div>
                <g:each in="${type.value}" var="actor">
                    <is:cache cache="actorCache" key="postit-${actor.id}-${actor.lastUpdated}">
                        <g:render template="/actor/postit" model="[actor:actor]"/>
                    </is:cache>
                </g:each>
            </g:if>
    </is:backlogElementLayout>
    <g:render template="/finder/window/blank" model="[show: data ? false : true]"/>
</div>
<jq:jquery>
    $('#backlog-layout-window-${controllerName} .postit .dropmenu li a:not(".scrum-link")').parent().remove();
    $('#window-content-finder').on('resize', function(){
        var margin = $('#search-panel').outerWidth();
        if ( parseInt($('#search-panel').css('margin-right'), 10) < 0){
            margin = 0;
        }
        $('#search-result').css('width', Math.round($('#window-content-finder').width() - margin - 1));
    }).trigger('resize');
</jq:jquery>
<div id="search-panel">
    <form method="POST" action="#" id="finder-form">
        <ul>
            <li id="search-input" class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                <h3>${g.message(code:'is.ui.finder.submit')}</h3><is:input type="text" id="term" value="${params.term}" name="term"/>
            </li>
            <li class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                <h3>${g.message(code:'is.ui.finder.filters')}</h3>
                <ul id="search-on">
                    <li>
                        <h3 class="${params.withStories ? 'active' : ''}"><a href="#">${g.message(code:'is.ui.finder.filters.stories')} <input type="checkbox" class="hidden" ${params.withStories ? 'checked="checked"' : ''} name="withStories"/></a></h3>
                        <ul>
                            <li>${g.message(code:'is.story.creator')}<is:select width="150" maxHeight="200"
                                                                                styleSelect="dropdown"
                                                                                value="${params.story?.creator}"
                                                                                name="story.creator" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${creators}"/>
                            </li>
                            <li>${g.message(code:'is.story.type')}<is:select   width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.type}"
                                                                               name="story.type" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyTypes}"/>
                            </li>
                            <li>${g.message(code:'is.feature')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.feature}"
                                                                               name="story.feature" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="name" optionKey="id" from="${product.features}"/>
                            </li>
                            <li>${g.message(code:'is.actor')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.actor}"
                                                                               name="story.actor" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="name" optionKey="id" from="${product.actors}"/></li>
                            <li>${g.message(code:'is.story.affectVersion')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.affectedVersion}"
                                                                               name="story.affectedVersion" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               from="${product.getVersions(false, true)}"/>
                            </li>
                            <li>${g.message(code:'is.story.deliveredVersion')}<is:select width="150" maxHeight="200"
                                                                                         styleSelect="dropdown"
                                                                                         value="${params.story?.deliveredVersion}"
                                                                                         name="story.deliveredVersion" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                         from="${product.getVersions(true, false)}"/>
                            </li>
                            <li>${g.message(code:'is.story.state')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.state}"
                                                                               name="story.state" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyStates}"/>
                            </li>
                            <li>${g.message(code:'is.story.effort')}<is:select width="150" maxHeight="200"
                                                                              styleSelect="dropdown"
                                                                              value="${params.story?.effort}"
                                                                              name="story.effort" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                              optionValue="value" optionKey="key" from="${suiteSelect}"/>
                            </li>
                            <li>${g.message(code:'is.story.dependsOn')}<is:select width="150" maxHeight="200"
                                                                                  styleSelect="dropdown"
                                                                                  value="${params.story?.dependsOn}"
                                                                                  name="story.dependsOn" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                  optionValue="${{ el -> el.uid+' - '+el.name }}" optionKey="id" from="${product.stories}"/>
                            </li>
                            <li>${g.message(code:'is.release')}<is:select width="150" maxHeight="200"
                                                                           styleSelect="dropdown"
                                                                           value="${params.story?.parentRelease}"
                                                                           name="story.parentRelease" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                           optionValue="name" optionKey="id" from="${product.releases}"/>
                            </li>
                            <li>${g.message(code:'is.sprint')}<is:select width="150" maxHeight="200"
                                                                           styleSelect="dropdown"
                                                                           value="${params.story?.parentSprint}"
                                                                           name="story.parentSprint" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                           optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id"
                                                                           from="${product.releases*.sprints.flatten()}"/>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <h3 class="${params.withTasks ? 'active' : ''}"><a href="#">${g.message(code:'is.ui.finder.filters.tasks')} <input type="checkbox" class="hidden" ${params.withTasks ? 'checked="checked"' : ''} name="withTasks"/></a></h3>
                        <ul>
                            <li>${g.message(code:'is.task.creator')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.story?.parentSprint}"
                                                                               name="task.creator" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${tasksCreators}"/>
                            </li>
                            <li>${g.message(code:'is.task.type')}<is:select   width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.type}"
                                                                               name="task.type" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskTypes}"/>
                            </li>
                            <li>${g.message(code:'is.story')}<is:select  width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.parentStory}"
                                                                               name="task.parentStory" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="name" optionKey="id" from="${product.stories?.findAll{ it.state >= Story.STATE_PLANNED }}"/>
                            </li>
                            <li>${g.message(code:'is.release')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.parentRelease}"
                                                                               name="task.parentRelease" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="name" optionKey="id" from="${product.releases}"/></li>
                            <li>${g.message(code:'is.sprint')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.parentSprint}"
                                                                               name="task.parentSprint" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id"
                                                                               from="${product.releases*.sprints.flatten()}"/>
                            </li>
                            <li>${g.message(code:'is.task.state')}<is:select  width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.state}"
                                                                               name="task.state" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskStates}"/>
                            </li>
                            <li>${g.message(code:'is.task.responsible')}<is:select width="150" maxHeight="200"
                                                                               styleSelect="dropdown"
                                                                               value="${params.task?.responsible}"
                                                                               name="task.responsible" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                               optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${tasksResponsibles}"/>
                            </li>
                            </ul>
                    </li>
                    <li>
                        <h3 class="${params.withActors ? 'active' : ''}"><a href="#">${g.message(code:'is.ui.finder.filters.actors')} <input type="checkbox" class="hidden" ${params.withActors ? 'checked="checked"' : ''} name="withActors"/></a></h3>
                        <ul>
                            <li>${g.message(code:'is.actor.instances')}<is:select width="150" maxHeight="200"
                                                                                   styleSelect="dropdown"
                                                                                   value="${params.actor?.instance}"
                                                                                   name="actor.instance" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                   optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorInstances}"/>
                            </li>
                            <li>${g.message(code:'is.actor.use.frequency')}<is:select width="150" maxHeight="200"
                                                                                       styleSelect="dropdown"
                                                                                       value="${params.actor?.frequency}"
                                                                                       name="actor.frequency" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorFrequencies}"/>
                            </li>
                            <li>${g.message(code:'is.actor.it.level')}<is:select width="150" maxHeight="200"
                                                                                       styleSelect="dropdown"
                                                                                       value="${params.actor?.level}"
                                                                                       name="actor.level" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorLevels}"/>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <h3 class="${params.withFeatures ? 'active' : ''}"><a href="#">${g.message(code:'is.ui.finder.filters.features')} <input type="checkbox" class="hidden" ${params.withFeatures ? 'checked="checked"' : ''} name="withFeatures"/></a></h3>
                        <ul>
                            <li>Type<is:select   width="150" maxHeight="200"
                                                   styleSelect="dropdown"
                                                   value="${params.feature?.type}"
                                                   name="feature.type" noSelection="['':'Choose a type']"
                                                   optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.featureTypes}"/>
                            </li>
                        </ul>
                    </li>
                </ul>
            </li>
            <li class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                <h3>${g.message(code:'is.ui.finder.filters.common')}</h3>
                <ul class="search-options">
                    <li>${g.message(code:'is.ui.finder.filters.common.tag')}<is:input type="text" id="tag" name="tag" value="${params.tag?:''}"/></li>
                </ul>
            </li>
            <entry:point id="${controllerName}-${actionName}-side"/>
            <li id="search-submit">
                <a id="submitForm"  class="button-s clearfix"
                   data-shortcut="return"
                   data-shortcut-on="#${controllerName}-form, #${controllerName}-form"
                   onclick="document.location.hash = '#finder?'+$('#finder-form').serialize(); return false;">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.ui.finder.submit')}</span>
                    <span class="end"></span>
                </a>
                <entry:point id="${controllerName}-${actionName}-side-buttons"/>
            </li>
        </ul>
    </form>
</div>
<jq:jquery>
    $( "#tag" ).autocomplete({
        source: "${g.createLink(controller:'finder', action: 'tag', params:[product:params.product])}",
        minLength: 2
    });
    $("#search-on, #search-options").togglePanels();
</jq:jquery>
<is:shortcut key="return" callback="jQuery('#submitForm').click();" scope="${controllerName}" listenOn="'#search-panel, #search-panel input[type=text]'"/>