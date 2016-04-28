services.factory('Widget', ['Resource', function($resource) {
    return $resource('/ui/widget/:widgetDefinitionId/:id');
}]);

services.service("WidgetService", ['CacheService', '$q', 'Session', 'Widget', function(CacheService, $q, Session, Widget) {
    Session.widgets = CacheService.getCache('widget');
    this.list = function() {
        var widgets = CacheService.getCache('widget');
        return _.isEmpty(widgets) ? Widget.query().$promise.then(function(widgets) {
            _.each(widgets, function(widget){
                CacheService.addOrUpdate('widget', widget);
            });
            return CacheService.getCache('widget');
        }) : $q.when(widgets);
    };

    this.update = function(widget) {
        widget.class = 'widget';
        return widget.$update({widgetDefinitionId: widget.widgetDefinitionId, id:widget.id}, function(widget){
            CacheService.addOrUpdate('widget', widget);
        }).$promise;
    };

    this['delete'] = function(widget){
        return widget.$delete({widgetDefinitionId: widget.widgetDefinitionId, id:widget.id}, function(){
            CacheService.remove('widget', widget.id);
        }).$promise;
    };
}]);
