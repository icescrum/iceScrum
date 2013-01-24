<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Task; org.icescrum.core.utils.BundleUtils" %>
<g:if test="${!request.readOnly}">
    <div style="float:right; padding: 10px; padding-top: 10px" class="panel-line">
        <button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" onclick="NotesToText('#sprintNotes','.copyNotes');">${message(code:'is.ui.notes.copy.as.text')}</button>
        <button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" onclick="NotesToHtml('#sprintNotes','.copyNotes');">${message(code:'is.ui.notes.copy.as.html')}</button>
    </div>
</g:if>
<div id="sprintNotes">
    <h1>${sprint.deliveredVersion ? sprint.deliveredVersion + ' - ' : ''}${sprint.parentRelease.name} - ${message(code:'is.sprint')} ${sprint.orderNumber} (${g.formatDate(date:sprint.startDate,formatName:'is.date.format.short', timeZone:sprint.parentProduct.preferences.timezone)} - ${g.formatDate(date:sprint.endDate,formatName:'is.date.format.short', timeZone:sprint.parentProduct.preferences.timezone)})</h1>
    <g:if test="${tasks}">
        <h2>${message(code: BundleUtils.taskTypes[Task.TYPE_URGENT])}</h2>
        <ul><g:each in="${tasks}" var="task">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURLTASK", params: [product: sprint.parentProduct.pkey], id: task.uid)}">${message(code:'is.ui.notes.story', args:[sprint.parentProduct.pkey])}${task.uid}</a> - ${task.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${defectStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_DEFECT])}</h2>
        <ul><g:each in="${defectStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: sprint.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[sprint.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${technicalStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_TECHNICAL_STORY])}</h2>
        <ul><g:each in="${technicalStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: sprint.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[sprint.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
    <g:if test="${userStories}">
        <h2>${message(code: BundleUtils.storyTypes[Story.TYPE_USER_STORY])}</h2>
        <ul><g:each in="${userStories}" var="story">
                <li><a class="scrum-link" href="${createLink(absolute: true, mapping: "shortURL", params: [product: sprint.parentProduct.pkey], id: story.uid)}">${message(code:'is.ui.notes.story', args:[sprint.parentProduct.pkey])}${story.uid}</a> - ${story.name}</li>
            </g:each></ul>
    </g:if>
</div>
<g:if test="${!request.readOnly}">
    <h1 class="copyNotes" style="display: none;">${message(code:'is.ui.sprintPlan.notes.copyTo')}</h1>
    <textarea class="copyNotes selectall" rows="20"></textarea>
    <is:buttonBar>
        <is:button
                href="#${controllerName+'/'+sprint.id}"
                elementId="close"
                type="link"
                button="button-s button-s-black"
                value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>