<%@ page import="grails.plugin.springsecurity.SpringSecurityUtils" %>
<is:widget widgetDefinition="${widgetDefinition}">
    <form novalidate role="form" ng-submit="login(credentials)" ng-controller="loginCtrl">
        <div class="form-group">
            <label for="credentials.j_username">${message(code: 'is.dialog.login.username.or.email')}</label>
            <input required
                   ng-model="credentials.j_username"
                   type="text"
                   id="credentials.j_username"
                   class="form-control"
                   autofocus
                   value="">
        </div>
        <div class="form-group">
            <label for="credentials.j_password">${message(code: 'is.user.password')}</label>
            <input required
                   ng-model="credentials.j_password"
                   type="password"
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
        <div class="btn-toolbar pull-right" style="margin-top: -5px;">
            <button class="btn btn-default"
                    type="button"
                    ng-click="showRetrieveModal()">
                <i class="fa fa-question"></i> ${message(code: 'is.dialog.retrieve')}
            </button>
            <button class="btn btn-default"
                    type="button"
                    ng-click="showRegisterModal()">
                <i class="fa fa-user-plus"></i> ${message(code: 'is.button.register')}
            </button>
            <button class="btn btn-primary pull-right"
                    ng-disabled="application.submitting"
                    type="submit">
                ${message(code: 'is.button.connect')}
            </button>
        </div>
    </form>
</is:widget>