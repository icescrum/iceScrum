<%@ page import="org.icescrum.core.utils.BundleUtils; org.icescrum.core.domain.Story; org.icescrum.core.domain.Task" %>
<g:if test="${!request.readOnly}">
    <div style="float:right; padding: 10px; padding-top: 10px" class="panel-line">
        <button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" onclick="NotesToText('#releaseNotes','.copyNotes');">${message(code:'is.ui.notes.copy.as.text')}</button>
        <button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" onclick="NotesToHtml('#releaseNotes','.copyNotes');">${message(code:'is.ui.notes.copy.as.html')}</button>
    </div>
</g:if>
<div id="releaseNotes">
    <h1>${release.name} (${g.formatDate(date:release.startDate,formatName:'is.date.format.short', timeZone:release.parentProduct.preferences.timezone)} - ${g.formatDate(date:release.endDate,formatName:'is.date.format.short', timeZone:release.parentProduct.preferences.timezone)})</h1>
    <g:if test="${tasks}">
        <h2>${message(code: BundleUtils.taskTypes[Task.TYPE_URGENT])}</h2>
        <ul><g:each in="${tasks}" var="task">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURLTASK", params: [product: release.parentProduct.pkey], id: task.uid)}">${message(code:'is.ui.notes.story', args:[release.parentProduct.pkey])}${task.uid}</a> - ${task.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${defectStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_DEFECT])}</h2>
        <ul><g:each in="${defectStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${technicalStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_TECHNICAL_STORY])}</h2>
        <ul><g:each in="${technicalStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${userStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_USER_STORY])}</h2>
        <ul><g:each in="${userStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: release.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[release.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
</div>
<g:if test="${!request.readOnly}">
    <h1 class="copyNotes" style="display: none;">${message(code:'is.ui.releasePlan.notes.copyTo')}</h1>
    <textarea class="copyNotes selectall" rows="20"></textarea>
    <is:buttonBar>
        <is:button
                href="#${controllerName+'/'+release.id}"
                elementId="close"
                type="link"
                button="button-s button-s-black"
                value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>