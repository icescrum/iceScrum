<%@ page import="org.icescrum.core.domain.PlanningPokerGame; org.icescrum.core.domain.Story; org.icescrum.core.utils.BundleUtils" %>
<g:if test="${!update}">
<div id="search-result">
</g:if>
    <is:backlogElementLayout
            id="window-${controllerName}"
            emptyRendering="true"
            dblclickable='[rendered:request.inProduct, selector:".postit", callback:"\$.icescrum.displayQuicklook(obj)"]'
            style="display:${data ? 'block' : 'none'};"
            value="${data}"
            var="type">
            <g:if test="${type.key == 'stories' && type.value}">
                <div class="search-group"><g:message code="is.story"/> (${type.value.size()})</div>
                <g:each in="${type.value}" var="story">
                    <is:cache  cache="storyCache" key="postit-${story.id}-${story.lastUpdated}">
                        <g:include view="/story/_postit.gsp" model="[story:story,user:user, sprint:sprint]" params="[product:params.product]"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'tasks' && type.value}">
                <div class="search-group"><g:message code="is.task"/> (${type.value.size()})</div>
                <g:each in="${type.value}" var="task">
                    <is:cache cache="taskCache" key="postit-${task.id}-${task.lastUpdated}">
                        <g:include view="/task/_postit.gsp" model="[task:task, user:user, rect:'false']" params="[product:params.product]"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'features' && type.value}">
                <div class="search-group"><g:message code="is.feature"/> (${type.value.size()})</div>
                <g:each in="${type.value}" var="feature">
                    <is:cache cache="featureCache" key="postit-${feature.id}-${feature.lastUpdated}">
                        <g:include view="/feature/_postit.gsp" model="[feature:feature]" params="[product:params.product]"/>
                    </is:cache>
                </g:each>
            </g:if>
            <g:if test="${type.key == 'actors' && type.value}">
                <div class="search-group"><g:message code="is.actor"/> (${type.value.size()})</div>
                <g:each in="${type.value}" var="actor">
                    <is:cache cache="actorCache" key="postit-${actor.id}-${actor.lastUpdated}">
                        <g:include view="/actor/_postit.gsp" model="[actor:actor]" params="[product:params.product]"/>
                    </is:cache>
                </g:each>
            </g:if>
    </is:backlogElementLayout>
    <g:include view="/finder/window/_blank.gsp" model="[data:data]"/>
    <jq:jquery>
        $('#backlog-layout-window-${controllerName} .postit .dropmenu li a:not(".scrum-link")').parent().remove();
        $('#window-content-finder').on('resize', function(){
            var margin = $('#search-panel').outerWidth();
            if ( parseInt($('#search-panel').css('margin-right'), 10) < 0){
                margin = 0;
            }
            $('#search-result').css('width', $('#window-content-finder').width() - margin);
        }).trigger('resize');
    </jq:jquery>
<g:if test="${!update}">
</div>
</g:if>
<g:if test="${!update}">
    <div id="search-panel">
        <form method="POST" action="#">
            <ul>
                <li id="search-input" class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                    <h3>Search:</h3><is:input type="text" id="term" name="term"/>
                </li>
                <li class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                    <h3>Filters on:</h3>
                    <ul id="search-on">
                        <li>
                            <h3><a href="#">Stories <input type="checkbox" class="hidden" name="withStories"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>Type: <is:select   width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.type" noSelection="['':'Choose a type']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyTypes}"/></li>
                                <li>Feature: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.feature" noSelection="['':message(code:'is.ui.backlog.choose.feature')]"
                                                       optionValue="name" optionKey="id" from="${product.features}"/></li>
                                <li>Actor: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.actor" noSelection="['':'Choose an actor']"
                                                       optionValue="name" optionKey="id" from="${product.actors}"/></li>
                                <li>State: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.state" noSelection="['':'Choose a state']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyStates}"/></li>
                                <li>Estimation: <is:select width="150" maxHeight="200"
                                                      styleSelect="dropdown"
                                                      name="story.effort" noSelection="['':'Choose an estimation']"
                                                      optionValue="value" optionKey="key" from="${suiteSelect}"/></li>
                                <li>Depends on: <is:select width="150" maxHeight="200"
                                                      styleSelect="dropdown"
                                                      name="story.dependsOn" noSelection="['':'Choose a dependence']"
                                                      optionValue="${{ el -> el.uid+' - '+el.name }}" optionKey="id" from="${product.stories}"/></li>
                                <li>Release: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.parentRelease" noSelection="['':'Choose a release']"
                                                       optionValue="name" optionKey="id" from="${product.releases}"/></li>
                                <li>Sprint: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.parentSprint" noSelection="['':'Choose a sprint']"
                                                       optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id" from="${product.releases*.sprints.flatten()}"/></li>
                                <li>Created by: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.creator" noSelection="['':'Choose a user']"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">Tasks <input type="checkbox" class="hidden" name="withTasks"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>Type: <is:select   width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.type" noSelection="['':'Choose a type']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskTypes}"/></li>
                                <li>Story: <is:select  width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentStory" noSelection="['':'Choose a story']"
                                                       optionValue="name" optionKey="id" from="${product.stories?.findAll{ it.state >= Story.STATE_PLANNED }}"/></li>
                                <li>Release: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentRelease" noSelection="['':'Choose a release']"
                                                       optionValue="name" optionKey="id" from="${product.releases}"/></li>
                                <li>Sprint: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentSprint" noSelection="['':'Choose a sprint']"
                                                       optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id" from="${product.releases*.sprints.flatten()}"/></li>
                                <li>State: <is:select  width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.state" noSelection="['':'Choose a type']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskStates}"/></li>
                                <li>Taken by: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.responsible" noSelection="['':'Choose a user']"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                                <li>Created by: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.creator" noSelection="['':'Choose a user']"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">Actors <input type="checkbox" class="hidden" name="withActors"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>Instance: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.instance" noSelection="['':'Choose an instance']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorInstances}"/></li>
                                <li>Frequency: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.frequency" noSelection="['':'Choose a frequency']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorFrequencies}"/></li>
                                <li>Level: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.level" noSelection="['':'Choose a level']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorLevels}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">Features <input type="checkbox" class="hidden" name="withFeatures"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>Type: <is:select   width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="feature.type" noSelection="['':'Choose a type']"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.featureTypes}"/></li>

                            </ul>
                        </li>
                    </ul>
                </li>
                <li class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                    <h3>Common filters:</h3>
                    <ul class="search-options">
                        <li>Tag: <is:input type="text" id="tag" name="tag"/></li>
                    </ul>
                </li>
                <li id="search-submit">
                    <is:button
                            id="submitForm"
                            type="submitToRemote"
                            url="[controller:'finder', action:'list', params:[product:params.product, update:true]]"
                            update="search-result"
                            button="button-s"
                            title="${message(code:'is.ui.finder.submit')}"
                            alt="${message(code:'is.ui.finder.submit')}">
                        <strong>${message(code: 'is.ui.finder.submit')}</strong>
                    </is:button>
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
    <is:shortcut key="return" callback="jQuery('#submitForm').click();" scope="${controllerName}" listenOn="'#search-panel, #search-panel input'"/>
</g:if>