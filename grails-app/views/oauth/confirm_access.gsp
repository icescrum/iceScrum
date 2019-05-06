<%@ page import="org.icescrum.core.support.ApplicationSupport; org.springframework.security.oauth2.common.exceptions.UnapprovedClientAuthenticationException" %>
<head>
    <meta name='layout' content='simple-without-ng'/>
    <title>${message(code: 'is.ui.oauth.confirm')}</title>
</head>
<body>
    <g:if test="${lastException && !(lastException instanceof UnapprovedClientAuthenticationException)}">
        <div class="error">
            <h2>Woops!</h2>
            <p>${message(code: 'is.ui.oauth.access.not.granted')} (${lastException?.message})</p>
        </div>
    </g:if>
    <g:else>
        <g:set var="client" value="${applicationContext.getBean('clientDetailsService')?.loadClientByClientId(params.client_id)}"/>
        <g:set var="user" value="${applicationContext.getBean('springSecurityService')?.principal}"/>
        <div id="oauth-confirm" class="d-flex align-items-center justify-content-center">
            <div class="card">
                <div class="card-body">
                    <a href="/">
                        <img alt="iceScrum" src="${assetPath(src: 'application/logo.png')}" class="rounded-circle" height="34px" width="34px">
                        <img id="logo-name" src="${assetPath(src: 'application/icescrum.png')}" alt="iceScrum">
                    </a>
                    <g:if test='${flash.message}'>
                        <div class='login_message'>${flash.message}</div>
                    </g:if>
                    <div class="d-flex justify-content-center mt-3 mb-3">
                        <div class="m-2">
                            <img src="${client.additionalInformation.clientIcon ?: ''}" height="60px" width="60px"/>
                        </div>
                        <div class="m-2">
                            <img alt="iceScrum" src="${assetPath(src: 'application/logo.png')}" height="60px" width="60px">
                        </div>
                    </div>
                    <h2 class="text-center">${message(code: 'is.ui.oauth.authorize', args: [client.additionalInformation.clientName])}</h2>
                    <div class="d-flex pt-3 pbs-3 justify-content-start">
                        <img src="${ApplicationSupport.serverURL() + '/user/avatar/' + user.id}" class="user-avatar mr-2"/>
                        <div>
                            ${message(code: 'is.ui.oauth.by', args: [client.additionalInformation.clientName, client.additionalInformation.clientOwnerUrl, client.additionalInformation.clientOwner])}<br/>
                            ${message(code: 'is.ui.oauth.want.access', args: [user.username])}
                        </div>
                    </div>
                    <ul class="list-group list-group-flush mt-4 mb-4">
                        <li class="list-group-item">Cras justo odio</li>
                        <li class="list-group-item">Dapibus ac facilisis in</li>
                        <li class="list-group-item">Morbi leo risus</li>
                        <li class="list-group-item">Porta ac consectetur ac</li>
                        <li class="list-group-item">Vestibulum at eros</li>
                    </ul>
                    <div class="pb-4 pt-2"><small>${message(code: 'is.ui.oauth.legal')}</small></div>
                    <div class="d-flex justify-content-end">
                        <div class="mr-2">
                            <form method='POST' id='denialForm'>
                                <input name='user_oauth_approval' type='hidden' value='false'/>
                                <input type="submit" class="btn btn-secondary" name="deny" value="${message(code: 'is.ui.oauth.deny')}">
                            </form>
                        </div>
                        <div class="ml-2">
                            <form method='POST' id='confirmationForm'>
                                <input name='user_oauth_approval' type='hidden' value='true'/>
                                <input type="submit" class="btn btn-primary" name="authorize" value="${message(code: 'is.ui.oauth.allow')}">
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </g:else>
</body>
