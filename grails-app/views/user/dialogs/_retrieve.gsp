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
<div data-ui-dialog
     data-ui-dialog-ajax-form="true"
     data-ui-dialog-ajax-form-success="$.icescrum.user.retrieveSuccess"
     data-ui-dialog-ajax-form-submit-text="${message(code:'is.dialog.retrieve.button.reset')}"
     data-ui-dialog-ajax-form-cancel-text="${message(code:'is.button.cancel')}"
     data-ui-dialog-title="${message(code:"is.dialog.retrieve")}">
    <div class="information">
        <g:message code="is.dialog.retrieve.description"/>
    </div>
    <form method="POST" action="${createLink(action:'retrieve')}">
        <div class="field" style="width:100%">
            <label for="text">${message(code:'is.dialog.retrieve.input')}</label>
            <input required
                   name="text"
                   type="text"
                   id="text"
                   autofocus
                   value="">
        </div>
        <input type="submit" class="hidden-submit"/>
    </form>
</div>