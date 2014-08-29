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
<script type="text/ng-template" id="comment.editor.html">
<form ng-submit="save(editableComment, selected)"
      name="formHolder.commentForm"
      show-validation
      novalidate>
    <div class="form-group">
        <textarea required
                  ng-maxlength="5000"
                  msd-elastic
                  ng-model="editableComment.body"
                  class="form-control"
                  placeholder="${message(code:'todo.is.ui.comment')}"></textarea>
    </div>
    <div class="btn-toolbar pull-right">
        <button
                class="btn btn-primary pull-right"
                ng-class="{ disabled: !formHolder.commentForm.$dirty || formHolder.commentForm.$invalid  }"
                tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.save')}
        </button>
    </div>
</form>
</script>