services.factory('Portfolio', ['Resource', function($resource) {
    return $resource('/portfolio/:id/:action');
}]);

services.service('PortfolioService', ['Portfolio', 'Session', 'FormService', 'ProjectService', '$q', 'IceScrumEventType', 'CacheService', 'Project', function(Portfolio, Session, FormService, ProjectService, $q, IceScrumEventType, CacheService, Project) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(portfolio) {
        CacheService.addOrUpdate('portfolio', portfolio);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(portfolio) {
        if (Session.workspaceType == 'portfolio') {
            var workspace = Session.getWorkspace();
            if (workspace.id == portfolio.id && workspace.fkey != portfolio.fkey) {
                document.location = document.location.href.replace(workspace.fkey, portfolio.fkey);
            }
        }
        CacheService.addOrUpdate('portfolio', portfolio);
    };
    crudMethods[IceScrumEventType.DELETE] = function(portfolio) {
        CacheService.remove('portfolio', portfolio.id);
    };
    this.list = function(params) {
        if (!params) {
            params = {};
        }
        params.paginate = true;
        return Portfolio.get(params, function(data) {
            self.mergePortfolios(data.portfolios);
        }).$promise;
    };
    this.save = function(portfolio) {
        portfolio.class = 'portfolio';
        return Portfolio.save(portfolio, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(portfolio) {
        return Portfolio.update({id: portfolio.id}, {portfoliod: portfolio}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(portfolio) {
        return Portfolio.delete({id: portfolio.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.listProjects = function(portfolio) {
        if (_.isEmpty(portfolio.projects)) {
            return ProjectService.listByPortfolio(portfolio.id).then(function(projects) {
                portfolio.projects = projects;
                portfolio.projects_count = portfolio.projects.length;
                return projects;
            });
        } else {
            return $q.when(portfolio.projects);
        }
    };
    this.listProjectsWidget = function(portfolio) {
        // Don't use ProjectService as it will empty sub-associations like backlogs on each project in order to have a synced cache
        return Project.listByPortfolio({portfolioId: portfolio.id}).$promise;
    };
    this.getSynchronizedProjects = function(projects) {
        return FormService.httpGet('portfolio/synchronizedProjects', {params: {projects: _.map(projects, 'id')}}, true);
    };
    this.mergePortfolios = function(portfolios) {
        _.each(portfolios, crudMethods[IceScrumEventType.CREATE]);
    };
    this.authorizedPortfolio = function(action) {
        switch (action) {
            case 'edit':
            case 'update':
            case 'delete':
            case 'updateMembers':
                return Session.bo();
            default:
                return false;
        }
    };
}]);