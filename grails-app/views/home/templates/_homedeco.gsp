<script type="text/ng-template" id="home.not.connected.html">
<link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">


<div ng-controller="loginCtrl" class="container">
    <div html-sortable class="row" id="panelhome">
        <div class="col-md-4">
            <div class="panel panel-primary">
                <div class="panel-heading ">
                    <h3 class="panel-title">${message(code: 'is.connection')}</h3>
                </div>

                <div class="panel-body">

                    <form novalidate role="form" ng-submit="login(credentials)">
                        <div class="form-group">
                            <div class="col-md-9">
                                <label align="text-center"
                                       for="credentials.j_username">${message(code: 'is.user.username')}</label>
                                <input required="" ng-model="credentials.j_username" type="text"
                                       id="credentials.j_username"
                                       class="form-control ng-isolate-scope ng-dirty ng-valid-parse ng-valid ng-valid-required ng-touched"
                                       focus-me="true" value="">
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-sm-9">
                                <label for="credentials.j_password"
                                       align="text-center">${message(code: 'is.user.password')} </label>
                                <input required="" ng-model="credentials.j_password" type="password"
                                       id="credentials.j_password"
                                       class="form-control ng-untouched ng-dirty ng-valid-parse ng-valid ng-valid-required"
                                       value="">
                            </div>
                        </div>






                        </br>
                        <div class="checkbox">
                            <label>
                                <input type='checkbox'
                                       name='${rememberMeParameter}'
                                       id='remember_me'
                                       <g:if test='${hasCookie}'>checked='checked'</g:if>/> <g:message code="is.dialog.login.rememberme"/>
                            </label>
                        </div>

                        <div class="btn-toolbar pull-right">
                            <button class="btn btn-primary pull-right"
                                    tooltip="${message(code:'is.button.connect')} (RETURN)"
                                    tooltip-append-to-body="true"
                                    type="submit">
                                ${message(code:'is.button.connect')}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <div class="col-md-5">
            <div class="panel panel-primary ">
                <div class="panel-heading">
                    <h3 class="panel-title">${message(code: 'is.panel.rss')}</h3>
                </div>

                <div class="panel-body">.....</div>
            </div>
        </div>


        <div class="col-md-9">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="panel-title">Projets publics</h4></div>

                <div ng-controller="Accordion">
                    <accordion close-others="oneAtATime">
                        <accordion-group  >
                            <accordion-heading>
                               <i class="pull-right glyphicon" ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                            </accordion-heading>
                        </accordion-group>

                    <accordion-group >
                        <accordion-heading>
                           <i class="pull-right glyphicon" ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                        </accordion-heading>
                    </accordion-group>
                    <accordion-group >
                        <accordion-heading>
                          <i class="pull-right glyphicon" ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                        </accordion-heading>

                    </accordion-group>

                    <accordion-group>
                        <accordion-heading>
                          <i class="pull-right glyphicon" ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                        </accordion-heading>

                    </accordion-group>


                 </accordion>

                </div>


                        %{--<a href ng-click="showProject('public')">--}%

                            %{--{{projects}}--}%


                        %{--</a>--}%
                </div>





            </div>

        </div>
    </div>
</div>
</script>


