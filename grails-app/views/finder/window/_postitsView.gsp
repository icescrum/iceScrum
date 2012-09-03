<is:backlogElementLayout
        id="window-${controllerName}"
        emptyRendering="true"
        dblclickable='[rendered:request.inProduct, selector:".postit", callback:is.quickLook(params:"findTypeAndId(obj)")]'
        style="display:${data ? 'block' : 'none'};"
        value="${data}"
        var="type">
        <g:if test="${type.key == 'stories'}">
            <div class="search-group"><g:message code="is.story"/></div>
            <g:each in="${type.value}" var="story">
                <is:cache  cache="storyCache" key="postit-${story.id}-${story.lastUpdated}">
                    <g:include view="/story/_postit.gsp" model="[story:story,user:user, sprint:sprint]" params="[product:params.product]"/>
                </is:cache>
            </g:each>
        </g:if>
        <g:if test="${type.key == 'tasks'}">
            <div class="search-group"><g:message code="is.task"/></div>
            <g:each in="${type.value}" var="task">
                <is:cache cache="taskCache" key="postit-${task.id}-${task.lastUpdated}">
                    <g:include view="/task/_postit.gsp" model="[task:task, user:user, rect:'false']" params="[product:params.product]"/>
                </is:cache>
            </g:each>
        </g:if>
        <g:if test="${type.key == 'features'}">
            <div class="search-group"><g:message code="is.feature"/></div>
            <g:each in="${type.value}" var="feature">
                <is:cache cache="featureCache" key="postit-${feature.id}-${feature.lastUpdated}">
                    <g:include view="/feature/_postit.gsp" model="[feature:feature]" params="[product:params.product]"/>
                </is:cache>
            </g:each>
        </g:if>
        <g:if test="${type.key == 'actors'}">
            <div class="search-group"><g:message code="is.actor"/></div>
            <g:each in="${type.value}" var="actor">
                <is:cache cache="actorCache" key="postit-${actor.id}-${actor.lastUpdated}">
                    <g:include view="/actor/_postit.gsp" model="[actor:actor]" params="[product:params.product]"/>
                </is:cache>
            </g:each>
        </g:if>
</is:backlogElementLayout>
<g:include view="/finder/window/_blank.gsp" model="[data:data]"/>
<div id="search-panel">
    <form method="POST" action="#">
        <is:fieldset title="is.ui.finder.search.tag.title">
            <is:fieldInput label="is.ui.finder.search.tag" for="tag" noborder="true">
                <is:input name="term" id="term" value="${params.term}" focus="true"/>
            </is:fieldInput>
        </is:fieldset>
        <div id="search-submit">
            <is:button
                    id="submitForm"
                    type="submitToRemote"
                    url="[controller:'finder', action:'list', params:[product:params.product]]"
                    update="window-content-finder"
                    button="button-s"
                    title="${message(code:'is.ui.finder.submit')}"
                    alt="${message(code:'is.ui.finder.submit')}">
                <strong>${message(code: 'is.ui.finder.submit')}</strong>
            </is:button>
        </div>
    </form>
</div>
<script type="text/javascript">
    function findTypeAndId(obj){
        var type = '';
        if (obj.hasClass('postit-task')){
            type = 'task.id';
        }else if (obj.hasClass('postit-story')){
            type = 'story.id';
        }else if (obj.hasClass('postit-feature')){
            type = 'feature.id';
        }else if (obj.hasClass('postit-actor')){
            type = 'actor.id';
        }
        return type+'='+obj.data('elemid');
    }
</script>
<jq:jquery>
    jQuery('#backlog-layout-window-${controllerName} .postit .dropmenu li a:not(".scrum-link")').parent().remove();
</jq:jquery>
<is:shortcut key="return" callback="jQuery('#submitForm').click();" scope="${controllerName}" listenOn="'#search-panel, #search-panel input'"/>