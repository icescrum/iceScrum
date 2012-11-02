<%@ page import="org.icescrum.core.utils.BundleUtils; org.icescrum.core.domain.Story; org.icescrum.core.domain.Task" %>
<div class="releaseNotes" style="padding: 10px;">
    <div style="float:right; padding: 10px; padding-top: 10px">
        <button value="test">Copy as TEXT</button>
        <button value="test">Copy as HTML</button>
    </div>
    <h1>${release.name}</h1>
    <g:if test="${tasks}">
        <h2>${message(code: BundleUtils.taskTypes[Task.TYPE_URGENT])}</h2>
        <ul>
            <g:each in="${tasks}" var="task">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURLTASK", params: [product: release.parentProduct.pkey], id: task.uid)}">${message(code:'is.ui.sprintNotes.story', args:[release.parentProduct.pkey])}${task.uid}</a> - ${task.name}</li>
            </g:each>
        </ul>
    </g:if>
    <g:if test="${defectStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_DEFECT])}</h2>
        <ul>
            <g:each in="${defectStories}" var="story">
                <li>
                    <a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.sprintNotes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}
                </li>
            </g:each>
        </ul>
    </g:if>
    <g:if test="${technicalStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_TECHNICAL_STORY])}</h2>
        <ul>
            <g:each in="${technicalStories}" var="story">
                <li>
                    <a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.sprintNotes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}
                </li>
            </g:each>
        </ul>
    </g:if>
    <g:if test="${userStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_USER_STORY])}</h2>
        <ul>
            <g:each in="${userStories}" var="story">
                <li>
                    <a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.sprintNotes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}
                </li>
            </g:each>
        </ul>
    </g:if>
</div>