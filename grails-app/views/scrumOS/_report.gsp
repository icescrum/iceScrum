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
<div data-ui-dialog
     data-ui-dialog-height="125"
     data-ui-dialog-close-button="true"
     data-ui-dialog-close-text="${message(code:'is.dialog.close')}"
     data-ui-dialog-title="${message(code:'is.dialog.report.generation')}">
     <div class="information">
        <g:message code="is.dialog.report.description"/>
     </div>
     <div data-ui-progressbar
          data-ui-progressbar-label="${message(code:'is.report.processing')}"
          data-ui-progressbar-stop-progress-on=".ui-dialog:hidden"
          data-ui-progressbar-get-progress="${createLink(action:actionName,controller:controllerName,params:[product:params.product,status:true], id:params.id?:null)}"
          data-ui-progressbar-download="${createLink(action:actionName,controller:controllerName,params:[product:params.product,get:true,format:params.format], id:params.id?:null)}">
     </div>
</div>