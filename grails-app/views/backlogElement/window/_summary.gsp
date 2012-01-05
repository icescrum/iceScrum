<%@ page import="grails.plugin.fluxiable.Activity; org.grails.comments.Comment" %>

<is:panelTab id="summary" selected="${!params.tab || 'summary' in params.tab ? 'true' : ''}">
    <g:if test="${summary?.size() > 0}">
        <ul class="list-news">
            <g:each in="${summary}" var="entry" status="i">
                <g:if test="${entry instanceof Comment}">
                    <g:render template="/components/comment"
                              plugin="icescrum-core"
                              model="[noEscape:true, backlogelement:story, comment:entry, commentId:'summary']"/>
                </g:if>
                <g:elseif test="${entry instanceof Activity && entry.code != 'comment'}">
                    <li ${(summary?.size() == (i + 1)) ? 'class="last"' : ''}>
                        <div class="news-item news-${entry.code}">
                            <p><is:scrumLink controller="user" action='profile'
                                             id="${entry.poster.username}">${entry.poster.firstName.encodeAsHTML()} ${entry.poster.lastName.encodeAsHTML()}</is:scrumLink>
                            <g:message code="is.fluxiable.${entry.code}"/>
                            <g:message code="is.${entry.code.startsWith('task') ? 'task' : 'story'}"/>
                                <strong>${entry.cachedLabel.encodeAsHTML()}</strong></p>

                            <p><g:formatDate date="${entry.dateCreated}" formatName="is.date.format.short.time"
                                             timeZone="${story.backlog.preferences.timezone}"/></p>
                        </div>
                    </li>
                </g:elseif>
            </g:each>
        </ul>
    </g:if>
    <g:else>
        <div class="panel-box-empty">
            ${message(code: 'is.ui.backlogelement.activity.all.no')}
        </div>
    </g:else>
</is:panelTab>