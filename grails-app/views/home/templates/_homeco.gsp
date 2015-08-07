<script type="text/ng-template" id="home.connected.html">
<link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">

<div class="container" >
    <div html-sortable class="row"  id="panelhome">

        <div class="col-md-5">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code:'is.panel.rss')}</div>

                <div class="panel-body">..</div>
            </div>
        </div>
        <div class="col-md-5">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code:'is.panel.notes')} </div>
               <div> <textarea rows="4" cols="50"></textarea></div>
                <div class="panel-body">..</div>
            </div>
        </div>
        <div class="col-md-7">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code:'is.panel.myprojects')} </div>

                <div class="panel-body">..</div>
            </div>
        </div>
        <div class="col-md-7">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code:'is.panel.mood')}</div>
                <div class="panel-body">..</div>
            </div>
        </div>
            <div class="col-md-5" >
                <div class="panel panel-primary">
                    <div class="panel-heading">${message(code:'is.panel.mytask')}</div>
                    <div ng-controller="Accordion">
                        <accordion close-others="oneAtATime">
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
                </div>
            </div>
        </div>
    </div>
</div>
</div>
</script>