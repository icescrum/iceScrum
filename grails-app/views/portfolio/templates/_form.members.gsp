%{--
- Copyright (c) 2017 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="form.members.portfolio.html">
<p class="help-block">${message(code: 'is.ui.user.add' + (grailsApplication.config.icescrum.invitation.enable ? '' : '.invite'))}</p>
<div class="row">
    <div class="col-sm-4">
        <label for="businessOwners.search">${message(code: 'todo.is.ui.select.portfolio.businessOwner')}</label>
        <p class="input-group">
            <input autocomplete="off"
                   type="text"
                   name="businessOwners.search"
                   id="businessOwners.search"
                   class="form-control"
                   placeholder="${message(code: 'is.ui.user.search.placeholder' + (grailsApplication.config.icescrum.user.search.enable ? '' : '.email'))}"
                   ng-model="bo"
                   uib-typeahead="bo as bo.name for bo in searchUsers($viewValue, true)"
                   typeahead-append-to-body="true"
                   typeahead-loading="searchingBo"
                   typeahead-min-length="2"
                   typeahead-wait-ms="250"
                   typeahead-on-select="addUser($item, 'bo')"
                   typeahead-template-url="select.member.html">
            <span class="input-group-addon">
                <i class="fa" ng-class="{ 'fa-search': !searchingBo, 'fa-refresh':searchingBo }"></i>
            </span>
        </p>
    </div>
    <div class="col-sm-8">
        <label ng-if="portfolio.businessOwners.length">${message(code: 'is.ui.portfolio.businessOwners')}</label>
        <div ng-class="{'list-users': portfolio.businessOwners.length > 0}">
            <ng-include ng-init="role = 'bo';" ng-repeat="user in portfolio.businessOwners" src="'user.item.portfolio.html'"></ng-include>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-sm-4">
        <label for="stakeHolders.search">${message(code: 'todo.is.ui.select.portfolio.stakeholder')}</label>
        <p class="input-group">
            <input autocomplete="off"
                   type="text"
                   name="stakeHolder.search"
                   id="stakeHolder.search"
                   class="form-control"
                   placeholder="${message(code: 'is.ui.user.search.placeholder' + (grailsApplication.config.icescrum.user.search.enable ? '' : '.email'))}"
                   ng-model="sh"
                   uib-typeahead="sh as sh.name for sh in searchUsers($viewValue)"
                   typeahead-append-to-body="true"
                   typeahead-loading="searchingSh"
                   typeahead-min-length="2"
                   typeahead-wait-ms="250"
                   typeahead-on-select="addUser($item, 'sh')"
                   typeahead-template-url="select.member.html">
            <span class="input-group-addon">
                <i class="fa" ng-class="{ 'fa-search': !searchingSh, 'fa-refresh':searchingSh }"></i>
            </span>
        </p>
    </div>
    <div class="col-sm-8">
        <label ng-if="portfolio.stakeHolders.length">${message(code: 'is.ui.portfolio.stakeholders')}</label>
        <div ng-class="{'list-users': portfolio.stakeHolders.length > 0}">
            <ng-include ng-init="role = 'sh';" ng-repeat="user in portfolio.stakeHolders" src="'user.item.portfolio.html'"></ng-include>
        </div>
    </div>
</div>
</script>
