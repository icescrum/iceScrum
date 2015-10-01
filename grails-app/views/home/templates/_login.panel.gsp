<script type="text/ng-template" id="login.panel.html">
    <div class="panel panel-primary">
        <div class="panel-heading ">
            <h3 class="panel-title">${message(code: 'is.connection')}</h3>
        </div>
        <div class="panel-body">
            <form novalidate role="form" ng-submit="login(credentials)" ng-controller="loginCtrl">
                <div class="form-group">
                    <div class="col-md-9">
                        <label align="text-center"
                               for="credentials.j_username">${message(code: 'is.user.username')}</label>

                        <div class="input-group">
                            <input required="" ng-model="credentials.j_username" type="text"
                                   id="credentials.j_username"
                                   class="form-control ng-isolate-scope ng-dirty ng-valid-parse ng-valid ng-valid-required ng-touched"
                                   focus-me="true" value="">
                            <span class="input-group-btn"><a tabindex="-1" class="btn btn-default" type="button"
                                                             href ng-click="showRegisterModal()"
                                                             tooltip-placement="top"
                                                             tooltip="${message(code: 'todo.is.new')}">
                                <i class="fa fa-user"></i></a>
                            </span>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-9">
                            <label for="credentials.j_password"
                                   align="text-center">${message(code: 'is.user.password')}</label>

                            <div class="input-group">
                                <input required="" ng-model="credentials.j_password" type="password"
                                       id="credentials.j_password"
                                       class="form-control ng-untouched ng-dirty ng-valid-parse ng-valid ng-valid-required"
                                       value="">
                                <span class="input-group-btn">
                                    <a tabindex="-1"
                                       class="btn btn-default"
                                       type="button"
                                       tooltip-placement="top"
                                       href
                                       ng-click="showRetrieveModal()"
                                       tooltip="${message(code: 'todo.is.retrieve')}">
                                        <i class="fa fa-flash"></i>
                                    </a>
                                </span>
                            </div>
                        </div>
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
                        <button class="btn btn-primary pull-right"
                                tooltip="${message(code: 'is.button.connect')} (RETURN)"
                                tooltip-append-to-body="true"
                                type="submit">
                            ${message(code: 'is.button.connect')}
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</script>