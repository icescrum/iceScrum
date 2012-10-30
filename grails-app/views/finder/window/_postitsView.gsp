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
                    <h3>${g.message(code:'is.ui.finder.submit')}:</h3><is:input type="text" id="term" name="term"/>
                </li>
                <li class="search-box ui-widget-content ui-corner-top ui-corner-bottom">
                    <h3>${g.message(code:'is.ui.finder.filters')}:</h3>
                    <ul id="search-on">
                        <li>
                            <h3><a href="#">${g.message(code:'is.ui.finder.filters.stories')} <input type="checkbox" class="hidden" name="withStories"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>${g.message(code:'is.story.type')}: <is:select   width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.type" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyTypes}"/></li>
                                <li>${g.message(code:'is.feature')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.feature" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="name" optionKey="id" from="${product.features}"/></li>
                                <li>${g.message(code:'is.actor')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.actor" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="name" optionKey="id" from="${product.actors}"/></li>
                                <li>${g.message(code:'is.story.affectVersion')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.affectedVersion" noSelection="['':g.message(code:'is.ui.choose.or.empty')]" from="${product.getVersions(false, true)}"/></li>
                                <li>${g.message(code:'is.story.state')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.state" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.storyStates}"/></li>
                                <li>${g.message(code:'is.story.effort')}: <is:select width="150" maxHeight="200"
                                                      styleSelect="dropdown"
                                                      name="story.effort" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                      optionValue="value" optionKey="key" from="${suiteSelect}"/></li>
                                <li>${g.message(code:'is.story.dependsOn')}: <is:select width="150" maxHeight="200"
                                                      styleSelect="dropdown"
                                                      name="story.dependsOn" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                      optionValue="${{ el -> el.uid+' - '+el.name }}" optionKey="id" from="${product.stories}"/></li>
                                <li>${g.message(code:'is.release')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.parentRelease" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="name" optionKey="id" from="${product.releases}"/></li>
                                <li>${g.message(code:'is.sprint')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.parentSprint" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id" from="${product.releases*.sprints.flatten()}"/></li>
                                <li>${g.message(code:'is.story.deliveredVersion')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.deliveredVersion" noSelection="['':g.message(code:'is.ui.choose.or.empty')]" from="${product.getVersions(true, false)}"/></li>
                                <li>${g.message(code:'is.story.creator')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="story.creator" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">${g.message(code:'is.ui.finder.filters.tasks')} <input type="checkbox" class="hidden" name="withTasks"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>${g.message(code:'is.task.type')}: <is:select   width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.type" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskTypes}"/></li>
                                <li>${g.message(code:'is.story')}: <is:select  width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentStory" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="name" optionKey="id" from="${product.stories?.findAll{ it.state >= Story.STATE_PLANNED }}"/></li>
                                <li>${g.message(code:'is.release')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentRelease" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="name" optionKey="id" from="${product.releases}"/></li>
                                <li>${g.message(code:'is.sprint')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.parentSprint" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{el -> 'R'+el.parentRelease.orderNumber +' S'+ el.orderNumber}}" optionKey="id" from="${product.releases*.sprints.flatten()}"/></li>
                                <li>${g.message(code:'is.task.state')}: <is:select  width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.state" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.taskStates}"/></li>
                                <li>${g.message(code:'is.task.responsible')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.responsible" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                                <li>${g.message(code:'is.task.creator')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="task.creator" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{el -> el.firstName+' '+el.lastName}}" optionKey="id" from="${product.allUsers}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">${g.message(code:'is.ui.finder.filters.actors')} <input type="checkbox" class="hidden" name="withActors"/> <input type="checkbox" disabled="disabled"/></a></h3>
                            <ul>
                                <li>${g.message(code:'is.actor.instances')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.instance" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorInstances}"/></li>
                                <li>${g.message(code:'is.actor.use.frequency')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.frequency" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorFrequencies}"/></li>
                                <li>${g.message(code:'is.actor.it.level')}: <is:select width="150" maxHeight="200"
                                                       styleSelect="dropdown"
                                                       name="actor.level" noSelection="['':g.message(code:'is.ui.choose.or.empty')]"
                                                       optionValue="${{ el -> message(code:el.value) }}" optionKey="key" from="${BundleUtils.actorLevels}"/></li>
                            </ul>
                        </li>
                        <li>
                            <h3><a href="#">${g.message(code:'is.ui.finder.filters.features')} <input type="checkbox" class="hidden" name="withFeatures"/> <input type="checkbox" disabled="disabled"/></a></h3>
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
                    <h3>${g.message(code:'is.ui.finder.filters.common')}</h3>
                    <ul class="search-options">
                        <li>${g.message(code:'is.ui.finder.filters.common.tag')}: <is:input type="text" id="tag" name="tag" value="${params.tag?:''}"/></li>
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
    <is:shortcut key="return" callback="jQuery('#submitForm').click();" scope="${controllerName}" listenOn="'#search-panel, #search-panel input[type=text]'"/>
</g:if>