controllers.controller('backlogChartWidgetCtrl', ['$scope', 'BacklogService', 'ProjectService', '$controller', '$element', function($scope, BacklogService, ProjectService, $controller, $element) {
    $controller('chartWidgetCtrl', {$scope: $scope, $element: $element});
    var widget = $scope.widget; // $scope.widget is inherited

    $scope.widgetReady = function(widget) {
        return !!(widget.settings && widget.settings.backlog && widget.settings.chartType);
    };

    $scope.getTitle = function(){
        return $scope.holder.title;
    };

    $scope.getUrl = function(){
        return $scope.widgetReady(widget) ? 'p/' + widget.settings.backlog.project.pkey + '/#/backlog/' + widget.settings.backlog.code : '';
    };

    $scope.refreshProjects = function(term) {
        if(widget.settings && widget.settings.backlog && widget.settings.backlog.project && !$scope.holder.projectResolved){
            ProjectService.get(widget.settings.backlog.project.id).then(function(project){
                $scope.holder.projectResolved = true;
                $scope.holder.project = project;
            });
        }
        ProjectService.listByUser({term: term, paginate: true}).then(function(projectsAndCount) {
            $scope.projects = projectsAndCount.projects;
            if (!term && widget.settings && widget.settings.backlog && !_.find($scope.projects, {id: widget.settings.backlog.project.id})) {
                $scope.projects.unshift(widget.settings.backlog.project);
            }
        });
    };

    $scope.refreshBacklogs = function() {
        if (widget.settings && widget.settings.backlog && !$scope.holder.backlogResolved) {
            BacklogService.get(widget.settings.backlog.id, widget.settings.backlog.project).then(function (backlog) {
                $scope.holder.backlogResolved = true;
                $scope.holder.backlog = backlog;
            });
        }
        BacklogService.list($scope.holder.project).then(function (backlogs) {
            $scope.holder.backlogs = backlogs;
        });
    };

    $scope.settingsChanged = function() {
        widget.type = 'backlog';
        widget.typeId = $scope.holder.backlog.id;
        widget.settings = {
            backlog:{
                id:$scope.holder.backlog.id,
                code:$scope.holder.backlog.code,
                project:{
                    id:$scope.holder.project.id,
                    pkey:$scope.holder.project.pkey
                }
            },
            chartType:$scope.holder.chartType
        };
    };

    $scope.display = function(widget){
        if($scope.widgetReady(widget)){
            var chartWidgetOptions = _.merge($scope.getChartWidgetOptions(widget), {
                chart:{
                    height:function($element){
                        return $element ? $element.find('.panel-body')[0].getBoundingClientRect().height : 0;
                    },
                    margin:{top:0,right:0, bottom:0, left:0}
                },
                title:{
                    enable:false
                },
                caption:{
                    enable:false
                }
            });
            $scope.openChart('backlog', widget.settings.chartType, widget.settings.backlog, chartWidgetOptions).then(function(data){
                $scope.holder.title = data.options.title.text;
                $scope.holder.caption =  data.options.caption.text;
            });
        }
    };

    // Init
    $scope.holder = {
        title:"",
        chartType: widget.settings ? widget.settings.chartType : 'type'
    };
}]);
