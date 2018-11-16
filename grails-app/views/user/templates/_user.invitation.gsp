%{--
- Copyright (c) 2018 Kagilum SAS.
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
<script type="text/ng-template" id="user.invitation.html">
<is:modal title="${message(code: 'is.ui.user.invitation.title')}"
          footer="${false}"
          size="md">
    <div ng-if="invitationEntries">
        <p ng-bind-html="message('is.ui.user.invitation.congrats', [invitedEmailAddress])">
        </p>
        <ul>
            <li ng-repeat="invitationEntry in invitationEntries">
                {{ invitationEntry.type }} - {{ invitationEntry.objectName }}
            </li>
        </ul>
        <div ng-if="authenticated()">
            <p>
                ${message(code: 'is.ui.user.invitation.loggedin')} (<em>{{ currentEmailAddress }}</em>)
            </p>
            <div class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        ng-disabled="application.submitting"
                        ng-click="acceptInvitations()"
                        hotkey="{'return': hotkeyClick }"
                        type="button">
                    ${message(code: 'is.ui.user.invitation.accept')}
                </button>
                <button class="btn btn-default pull-right"
                        ng-disabled="application.submitting"
                        ng-click="$close()"
                        type="button">
                    ${message(code: 'is.ui.user.invitation.ignore')}
                </button>
            </div>
        </div>
        <div ng-if="!authenticated()">
            <p>
                ${message(code: 'is.ui.user.invitation.notloggedin')}
            </p>
            <div class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        ng-disabled="application.submitting"
                        ng-click="register()"
                        hotkey="{'return': hotkeyClick }"
                        type="button">
                    ${message(code: 'is.ui.user.invitation.create')}
                </button>
                <button class="btn btn-default pull-right"
                        ng-disabled="application.submitting"
                        ng-click="logIn()"
                        type="button">
                    ${message(code: 'is.ui.user.invitation.login')}
                </button>
            </div>
        </div>
    </div>
</is:modal>
</script>