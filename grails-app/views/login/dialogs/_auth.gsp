<div data-ui-dialog
     data-ui-dialog-ajax-form="true"
     data-ui-dialog-ajax-form-success="$.icescrum.user.authSuccess"
     data-ui-dialog-ajax-form-submit-text="${message(code:'is.button.connect')}"
     data-ui-dialog-ajax-form-cancel-text="${message(code:'is.button.cancel')}"
     data-ui-dialog-title="${message(code:"is.dialog.login")}">
    <div class="information">
        <g:message code="is.welcome"/>
    </div>
    <form method="POST" action="${postUrl}">
        <div class="field" style="width:58%">
            <label for="j_username">${message(code:'is.user.username')}</label>
            <input required
                   name="j_username"
                   type="text"
                   id="j_username"
                   autofocus
                   value="${params.username?:''}">
        </div><!-- no space --><div class="right-auth-links">
            <g:if test="${enableRegistration}">
                <a href="${createLink(action:'register', controller:'user')}"
                   data-ajax="true"
                   class="scrum-link">${message(code:'is.button.register')}</a>
            </g:if>
        </div>
        <hr/>
        <div class="field" style="width:58%">
            <label for="j_password">${message(code:'is.user.password')}</label>
            <input required
                   name="j_password"
                   type="password"
                   id="j_password"
                   value="">
        </div><!-- no space --><div class="right-auth-links">
            <g:if test="${activeLostPassword}">
                <a href="${createLink(action:'retrieve', controller:'user')}"
                   data-ajax="true"
                   class="scrum-link">${message(code:'is.dialog.login.lostPassword')}</a>
            </g:if>
        </div>
        <hr/>
        <div class="field">
            <input
                   type='checkbox'
                   name='${rememberMeParameter}'
                   id='remember_me'
                   <g:if test='${hasCookie}'>checked='checked'</g:if>/>
            <label for='remember_me'><g:message code="is.dialog.login.rememberme"/></label>
        </div>
        <input type="submit" style="display:none;"/>
    </form>
</div>