<%@ page import="grails.plugin.springsecurity.SpringSecurityUtils;org.icescrum.core.support.ApplicationSupport" %>
<is:widget widgetDefinition="${widgetDefinition}">
    <form novalidate role="form" ng-submit="login(credentials)" ng-controller="loginCtrl">
        <div class="form-group">
            <label for="credentials.j_username">
                <small class="pull-right text-muted" ng-click="showRegisterModal()">${message(code: 'is.button.register')}</small>
                <div>${message(code: 'is.dialog.login.username.or.email')}</div>
            </label>
            <input required
                   ng-model="credentials.j_username"
                   type="text"
                   name="is_username"
                   id="credentials.j_username"
                   class="form-control"
                   autofocus
                   value="">
        </div>
        <div class="form-group">
            <label for="credentials.j_password">
                <small class="pull-right text-muted" ng-click="showRetrieveModal()">${message(code: 'is.dialog.retrieve')}</small>
                <div>${message(code: 'is.user.password')}</div>
            </label>
            <input required
                   ng-model="credentials.j_password"
                   type="password"
                   name="is_password"
                   id="credentials.j_password"
                   class="form-control"
                   value="">
        </div>
        <div class="checkbox">
            <label for="credentials.remember_me" class="checkbox-inline">
                <input type="checkbox"
                       ng-model="credentials.${SpringSecurityUtils.securityConfig.rememberMe.parameter}"
                       name="${SpringSecurityUtils.securityConfig.rememberMe.parameter}"
                       id="credentials.remember_me"/>
                ${message(code: 'is.dialog.login.rememberme')}
            </label>
        </div>
        <div class="footer-btn-toolbar btn-toolbar">
            <button class="btn btn-primary pull-right"
                    ng-disabled="application.submitting"
                    type="submit">
                ${message(code: 'is.button.connect')}
            </button>
        </div>
    </form>
</is:widget>