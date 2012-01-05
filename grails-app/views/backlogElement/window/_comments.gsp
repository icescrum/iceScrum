
<is:panelTab id="comments" selected="${params.tab && 'comments' in params.tab ? 'true' : ''}">
    <div class="addorlogin">
        <sec:ifNotLoggedIn>
            <g:link
                    controller="login"
                    onClick="this.href=this.href+'?ref='+decodeURI('${params.product?'p/'+story.backlog.pkey:params.team?'t/'+params.team:''}')+decodeURI(document.location.hash.replace('#','@'));">
                ${message(code: 'is.ui.backlogelement.comment.login')}
            </g:link>
        </sec:ifNotLoggedIn>
        <sec:ifLoggedIn>
            <is:link disabled="true"
                     onClick="jQuery.icescrum.openCommentTab('#comments');">${message(code: 'is.ui.backlogelement.comment.add')}</is:link>
        </sec:ifLoggedIn>
    </div>
    <isComment:render noEscape="true" bean="${story}" noComment="${message(code:'is.ui.backlogelement.activity.comments.no')}"/>
 </is:panelTab>