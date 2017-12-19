/*
 * Copyright (c) 2017 Kagilum SAS.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

services.factory('Portfolio', ['Resource', function($resource) {
    return $resource('/portfolio/:id/:action');
}]);

services.service('PortfolioService', ['Portfolio', 'Session', 'FormService', 'ProjectService', '$q', function(Portfolio, Session, FormService, ProjectService, $q) {
    this.save = function(portfolio) {
        portfolio.class = 'portfolio';
        return Portfolio.save(portfolio).$promise;
    };
    this.update = function(portfolio) {
        return Portfolio.update({id: portfolio.id}, {portfoliod: portfolio}).$promise;
    };
    this['delete'] = function(portfolio) {
        return Portfolio.delete({id: portfolio.id}).$promise;
    };
    this.listProjects = function(portfolio) {
        if (_.isEmpty(portfolio.projects)) {
            return ProjectService.listByPortfolio(portfolio.id).then(function(projects) {
                portfolio.projects = projects;
                portfolio.projects_count = portfolio.projects.length;
            });
        } else {
            return $q.when(portfolio.projects);
        }
    };
    this.authorizedPortfolio = function(action) {
        switch (action) {
            case 'edit':
            case 'update':
            case 'delete':
                return Session.bo();
            default:
                return false;
        }
    };
}]);