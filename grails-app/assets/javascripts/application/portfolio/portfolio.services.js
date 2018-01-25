this.getSynchronizedProjects = function(projects) {
    return FormService.httpGet('portfolio/synchronizedProjects', {params: {projects: _.map(projects, 'id')}}, true);
};
this.mergePortfolios = function(portfolios) {
    _.each(portfolios, crudMethods[IceScrumEventType.CREATE]);
};