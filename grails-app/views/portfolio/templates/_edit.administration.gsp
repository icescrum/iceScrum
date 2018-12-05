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

<script type="text/ng-template" id="edit.administration.portfolio.html">
<form role='form'
      ng-controller="editPortfolioCtrl"
      show-validation
      novalidate
      ng-submit='update(portfolio)'
      name="formHolder.editPortfolioForm">
    <entry:point id="portfolio-edit-administration"/>
    <h4>${message(code: "is.ui.danger.zone")}</h4>
    <div class="btn-toolbar">
        <button ng-if="authorizedPortfolio('delete', portfolio)"
                type="button"
                role="button"
                class="btn btn-danger"
                ng-click="delete(portfolio)">
            ${message(code: 'is.ui.portfolio.delete')}
        </button>
    </div>
    <div class="btn-toolbar pull-right">
        <button type="button"
                role="button"
                class="btn btn-secondary"
                ng-click="$close()">
            ${message(code: 'is.button.cancel')}
        </button>
        <button type='submit'
                role="button"
                class='btn btn-primary'
                ng-disabled="!formHolder.editPortfolioForm.$dirty || formHolder.editPortfolioForm.$invalid">
            ${message(code: 'is.button.update')}
        </button>
    </div>
</form>
</script>