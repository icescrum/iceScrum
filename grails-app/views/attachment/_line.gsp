%{--
- Copyright (c) 2012 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
-
--}%

<li class="is-multifiles-checkbox attachment-line" data-elemid="${attachment.id}">
    <div class="is-multifiles-filename file-icon ${attachment.ext?.toLowerCase()}-format" style="display: inline-block; margin-left: 5px;">
        <a ${attachment.url || attachment.previewable ? 'target="_blank"' : ''} href="${g.createLink(controller: controllerName, action: 'download', id: attachment.id, params:[product:params.product])}">
            <span class="filename" title="${attachment.filename} ${attachment.provider? ' - ('+ attachment.provider + ' / ' + attachment.poster.firstName +' '+ attachment.poster.lastName + ')' : '' } "><g:if test="${template}">${attachment.filename}</g:if><g:else>${is.truncated(value:attachment.filename, size: 23)}</g:else></span>
        </a>
    </div>
</li>