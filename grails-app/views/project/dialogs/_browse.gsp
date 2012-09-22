%{--
- Copyright (c) 2010 iceScrum Technologies.
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
<is:dialog
        resizable="false"
          draggable="false"
          noprefix="true"
          width="940"
          height="540"
          valid="[action:'index',
              controller:'scrumOS',
              before:'document.location=jQuery.icescrum.o.baseUrl+\'p/\'+jQuery(\'#product\').val()+\'#project\';jQuery(\'#dialog\').dialog(\'close\'); return false;',
              button:'is.dialog.browseProject.button']">
<form id="form-project-browse" name="form-project-browse" method="post">
<is:browser detailsLabel="is.dialog.browseProject.details"
        browserLabel="is.dialog.browseProject.projects"
        controller="project"
        titleLabel="is.dialog.browseProject.title"
        actionColumn="browseList"
        name="project-browse" >
</is:browser>
</form>
</is:dialog>