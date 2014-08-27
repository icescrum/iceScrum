%{--
- Copyright (c) 2014 Kagilum SAS.
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
<script type="text/icescrum-template" id="tpl-shortcuts-list">
    <is:modal title="${message(code:'todo.is.shortcuts')}" size="lg" name="shortcuts">
        <div class="row">
        **# _.each(shortcuts, function(shortcut, index){ **
            <div class="help-keys">
                <kdb class="help-key">
                    <span>** shortcut.key **</span>
                </kdb> <span>** shortcut.title **</span>
            </div>
            **# if ((index + 1) % 4 == 0){ ** </div>
                **# if(index < shortcuts.length){ ** <div class="row"> **# } **
            **# } **
        **# }); **
        **# if (shortcuts.length % 4 != 0){ ** </div> **# } **
    </is:modal>
</script>
<script type="text/icescrum-template" id="tpl-modal-alert">
    <div class="modal fade" data-ui-dialog>
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">** title **</h4>
                </div>
                <div class="modal-body">
                    <p>** body **</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">${message(code:'todo.is.ui.close')}</button>
                </div>
            </div>
        </div>
    </div>
</script>
<script type="text/icescrum-template" id="tpl-report-error">
<is:modal name="sendError"
          size="md"
          title="${message(code: 'is.dialog.sendError.title')}"
          form="[action:createLink(controller:'scrumOS', action:'reportError'),method:'POST',submit:message(code:'todo.is.dialog.sendError.send')]">
                <p>${message(code: 'is.dialog.sendError.description')}</p>
                <div class="form-group"
                    <label for="report.stack">${message(code:'is.dialog.sendError.stackError')}</label>
                    <textarea name="report.stack" readonly style="max-height:300px; width:100%; overflow:auto">** text **</textarea>
                </div>
                <div class="form-group"
                    <label for="report.comment">${message(code:'is.dialog.sendError.comments')}</label>
                    <textarea focus-me="true" name="report.comment" required style="width:100%;"></textarea>
                </div>
</is:modal>
</script>