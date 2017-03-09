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

<script type="text/ng-template" id="app.details.html">
<h3><i class="fa fa-{{ holder.app.icon }}"></i> {{ holder.app.name }}
    <div class="pull-right">
        <button ng-click="detailsApp()"
                class="btn btn-default"><i class="fa fa-times"></i></button>
    </div>
</h3>
<h4>${message(code: 'is.app.screenshots')}</h4>
<div class="row">
    <div class="col-md-8">
        <div class="col-md-6" ng-repeat="screenshot in holder.app.screenshots">
            <a href
               class="thumbnail"
               ng-click="selectScreenshot(screenshot)"
               ng-class="{'current':holder.screenshot == screenshot}">
                <img ng-src="{{ screenshot }}">
            </a>
        </div>
    </div>
    <div class="col-md-4">
        <div class="text-center actions">
            <p>
                <button type="submit"
                        class="btn btn-success"
                        ng-if="holder.app.enabled">${message(code: 'is.dialog.manageApps.enable')}</button>
                <button type="submit"
                        class="btn btn-danger"
                        ng-if="!holder.app.enabled">${message(code: 'is.dialog.manageApps.disable')}</button>
            </p>
            <p>
                <a href
                   ng-if="!holder.app.enabled"
                   class="btn btn-default">
                    ${message(code: 'is.dialog.manageApps.configure')}
                </a>
            </p>
            <p>
                <a href="{{ holder.app.documentation }}"
                   class="btn btn-default">
                    ${message(code: 'is.app.url.documentation')}
                </a>
            </p>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-8">
        <h4>${message(code: 'is.app.description')}</h4>
        <p class="description" ng-bind-html="holder.app.description"></p>
    </div>
    <div class="col-md-4">
        <h4>${message(code: 'is.dialog.manageApps.information')}</h4>
        <table class="table information">
            <tr>
                <td class="text-right">${message(code:'is.app.author')}</td>
                <td><a href="mailto:{{ holder.app.email }}">{{ holder.app.author }}</a></td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.version')}</td>
                <td>{{ holder.app.version }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.updated')}</td>
                <td>{{ holder.app.updated }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.widgets')}</td>
                <td>{{ holder.app.widgets ? '${message(code:'is.yes')}' : '${message(code:'is.no')}' }}</td>
            </tr>
            <tr>
                <td colspan="2" class="text-center"><a href="{{ holder.app.website }}">${message(code:'is.app.url.website')}</a></td>
            </tr>
        </table>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <span class="text-muted" ng-repeat="tag in holder.app.tags track by $index"><a href ng-click="search(tag)">{{ tag }}</a>{{$last ? '' : ', '}}</span>
    </div>
</div>
</script>