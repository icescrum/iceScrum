<script type="text/ng-template" id="login.panel.html">
<div class="panel panel-light">
    <div class="panel-heading ">
        <h3 class="panel-title"><i class="fa fa-user"></i> ${message(code: 'is.dialog.login')}</h3>
    </div>
    <div class="panel-body">
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
                <label>
                    <input type='checkbox'
                           name='${rememberMeParameter}'
                           id='remember_me'
                           <g:if test='${hasCookie}'>checked='checked'</g:if>/> <g:message
                        code="is.dialog.login.rememberme"/>
                </label>
            </div>
            <div class="btn-toolbar pull-right">
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
                        type="submit">
                    ${message(code: 'is.button.connect')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>