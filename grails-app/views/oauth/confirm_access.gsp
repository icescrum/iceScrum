<%@ page import="org.springframework.security.oauth2.common.exceptions.UnapprovedClientAuthenticationException" %>
<head>
    <meta name='layout' content='simple-without-ng'/>
    <title>Confirm Access</title>
    <style type='text/css' media='screen'>
    #login {
        margin: 15px 0px; padding: 0px;
        text-align: center;
    }

    #login .inner {
        width: 260px;
        margin: 0px auto;
        text-align: left;
        padding: 10px;
        border-top: 1px dashed #499ede;
        border-bottom: 1px dashed #499ede;
        background-color: #EEF;
    }

    #login .inner .fheader {
        padding: 4px;margin: 3px 0px 3px 0;color: #2e3741;font-size: 14px;font-weight: bold;
    }

    #login .inner .cssform p {
        clear: left;
        margin: 0;
        padding: 5px 0 8px 0;
        padding-left: 105px;
        border-top: 1px dashed gray;
        margin-bottom: 10px;
        height: 1%;
    }

    #login .inner .cssform input[type='text'] {
        width: 120px;
    }

    #login .inner .cssform label {
        font-weight: bold;
        float: left;
        margin-left: -105px;
        width: 100px;
    }

    #login .inner .login_message {color: red;}

    #login .inner .text_ {width: 120px;}

    #login .inner .chk {height: 12px;}
    </style>
</head>

<body>
    <div id='login'>
        <div class='inner'>
            <g:if test="${lastException && !(lastException instanceof UnapprovedClientAuthenticationException)}">
                <div class="error">
                    <h2>Woops!</h2>

                    <p>Access could not be granted. (${lastException?.message})</p>
                </div>
            </g:if>
            <g:else>
                <g:if test='${flash.message}'>
                    <div class='login_message'>${flash.message}</div>
                </g:if>
                <div class='fheader'>Please Confirm</div>
                <div>You hereby authorize <b>${applicationContext.getBean('clientDetailsService')?.loadClientByClientId(params.client_id)?.clientId ?: 'n/a'}</b> to access your protected resources.</div>
                <form method='POST' id='confirmationForm' class='cssform'>
                    <p>
                        <input name='user_oauth_approval' type='hidden' value='true'/>
                        <label><input name="authorize" value="Authorize" type="submit"/></label>
                    </p>
                </form>
                <form method='POST' id='denialForm' class='cssform'>
                    <p>
                        <input name='user_oauth_approval' type='hidden' value='false'/>
                        <label><input name="deny" value="Deny" type="submit"/></label>
                    </p>
                </form>
            </g:else>
        </div>
    </div>
</body>
