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
--}%
<script type="text/ng-template" id="comment.editor.html">
    <table class="table comment-editor">
        <tbody>
        <tr class="comment-editor">
            <td class="avatar">
                <img ng-src="{{comment.poster | userAvatar}}" width="25px">
            </td>
            <td>
                <form ng-controller="commentCtrl" ng-submit="save(comment, selected)">
                    <textarea required
                              ng-model="comment.body"
                              class="form-control"
                              placeholder="${message(code:'todo.is.ui.comment')}"></textarea>
                    <div>
                        <small class="text-muted">${message(code:'todo.is.ui.comment.cancel')}</small>
                        <button type="submit" ng-show="!comment.id" class="btn btn-primary btn-sm pull-right">${message(code:'todo.is.ui.comment.post')}</button>
                        <button type="submit" ng-show="comment.id" class="btn btn-primary btn-sm pull-right">${message(code:'todo.is.ui.comment.update')}</button>
                    </div>
                </form>
            </td>
        </tr>
        </tbody>
    </table>
</script>