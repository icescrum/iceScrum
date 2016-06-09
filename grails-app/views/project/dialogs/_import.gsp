%{--
- Copyright (c) 2015 Kagilum SAS
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
%{--
- Copyright (c) 2014 Kagilum.
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
<is:modal title="${message(code:'is.dialog.importProject.choose.title')}" class="import">
    <div flow-drop
         flow-init="flowConfig"
         flow-file-added="!! {xml:1,zip:1}[$file.getExtension()]"
         flow-drop-enabled="!$flow.files.length"
         flow-file-success="checkValidation($message)"
         flow-files-submitted="$flow.upload(); progressStatus();">
        <div ng-hide="$flow.files.length" class="help-block">
            <g:message code="is.dialog.importProject.choose.description"/>
        </div>
        <div ng-hide="$flow.files.length">
            <button class="btn btn-primary" flow-btn><i class="fa fa-upload"></i> <g:message code="is.dialog.importProject.choose.file"/></button>
        </div>
        <div ng-show="$flow.files[0].isUploading() && !progress">
            <uib-progressbar value="$flow.files[0].sizeUploaded()" max="$flow.files[0].size" type="primary">
                <b>{{ $flow.files[0].timeRemaining() }}sec ({{ $flow.files[0].currentSpeed }} bytes/sec)</b>
            </uib-progressbar>
        </div>
        <is-progress start="progress" ng-show="progress"></is-progress>
        <form name="importProjectForm"
              role="form"
              show-validation
              ng-show="changes"
              ng-submit="applyChanges()" novalidate>
            <div class="help-block">
                <g:message code="todo.is.ui.import.changes"/>
            </div>
            <div class="changes row">
                <div class="erase">
                    <label>
                        <input type="checkbox"
                               name="erase"
                               ng-model="changes.erase"> ${message(code:'todo.is.ui.import.erase')}
                    </label>
                </div>
            </div>
            <div class="changes row" ng-show="_changes.showProjectName && !changes.erase">
                <div class="changes-col-1">
                    <label for="project.name_">${message(code:'todo.is.ui.import.project.name')}</label>
                    <input required
                           type="text"
                           id="project.name_"
                           name="project.name_"
                           class="form-control"
                           disabled="disabled"
                           ng-model="_changes.product.name">
                </div>
                <div class="changes-arrow">
                    <i class="fa fa-arrow-right"></i>
                </div>
                <div class="changes-col-2">
                    <label for="project.name">${message(code:'todo.is.ui.import.changes.project.name')}</label>
                    <input required
                           not-match="_changes.product.name"
                           type="text"
                           id="project.name"
                           name="project.name"
                           class="form-control"
                           ng-model="changes.product.name">
                </div>
            </div>
            <div class="changes row" ng-show="_changes.showProjectPkey && !changes.erase">
                <div class="changes-col-1">
                    <label for="project.pkey_">${message(code:'todo.is.ui.import.project.pkey')}</label>
                    <input required
                           type="text"
                           id="project.pkey_"
                           name="project.pkey_"
                           class="form-control text-capitalize"
                           disabled="disabled"
                           ng-model="_changes.product.pkey">
                </div>
                <div class="changes-arrow">
                    <i class="fa fa-arrow-right"></i>
                </div>
                <div class="changes-col-2">
                    <label for="project.pkey">${message(code:'todo.is.ui.import.changes.project.pkey')}</label>
                    <input required
                           not-match="_changes.product.pkey"
                           type="text"
                           capitalize
                           id="project.pkey"
                           name="project.pkey"
                           class="form-control text-capitalize"
                           ng-pattern="/^[A-Z0-9]*$/"
                           ng-model="changes.product.pkey">
                </div>
            </div>
            <div class="changes row" ng-if="_changes.showTeam">
                <div class="changes-col-1">
                    <label for="team.name_">${message(code:'todo.is.ui.import.changes.team.name')}</label>
                    <input required
                           type="text"
                           id="team.name_"
                           name="team.name_"
                           class="form-control"
                           disabled="disabled"
                           ng-model="_changes.team.name">
                </div>
                <div class="changes-arrow">
                    <i class="fa fa-arrow-right"></i>
                </div>
                <div class="changes-col-2">
                    <label for="team.name_">${message(code:'todo.is.ui.import.changes.team.name')}</label>
                    <input required
                           not-match="_changes.team.name"
                           type="text"
                           id="team.name"
                           name="team.name"
                           class="form-control"
                           ng-model="changes.team.name">
                </div>
            </div>
            <div class="changes row" ng-if="_changes.showUsers" ng-repeat="(key, value) in changes.users">
                <div class="changes-col-1">
                    <label for="_username{{ key }}">${message(code:'todo.is.ui.import.username')}</label>
                    <input required
                           type="text"
                           id="_username{{ key }}"
                           name="_username{{ key }}"
                           class="form-control"
                           disabled="disabled"
                           ng-model="_changes.users[key]">
                </div>
                <div class="changes-arrow">
                    <i class="fa fa-arrow-right"></i>
                </div>
                <div class="changes-col-2">
                    <label for="username{{ key }}">${message(code:'todo.is.ui.import.changes.username')}</label>
                    <input required
                           not-match="_changes.users[key]"
                           type="text"
                           id="username{{ key }}"
                           name="username{{ key }}"
                           class="form-control"
                           ng-model="changes.users[key]">
                </div>
            </div>
            <div class="text-right">
                <input type="submit" ng-disabled="importProjectForm.$invalid" class="btn btn-primary" value="${message(code:'todo.is.ui.import.changes.submit')}">
            </div>
        </form>
        <div ng-show="product.name">
        </div>
    </div>
</is:modal>