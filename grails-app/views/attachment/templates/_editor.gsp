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
<script type="text/icescrum-template" id="tpl-attachment-new">
    **# var type = attachmentable.class.toLowerCase(); **
    <g:set var="attachmentUrl" value="${createLink(controller: 'attachment', params: [product: '** jQuery.icescrum.product.pkey **', type:'** type **', attachmentable:'** attachmentable.id **'])}"/>
    <table class="table">
        <tr>
            <td>
                <div class="btn-group pull-right btn-group-sm providers"
                     data-dz
                     data-dz-id="** id **"
                     data-dz-add-remove-links="true"
                     data-dz-clickable="#** id ** .clickable"
                     data-dz-url="${attachmentUrl}"
                     data-dz-previews-container="#** id ** .previews">
                    <button class="btn btn-primary clickable"
                            tooltip-append-to-body="true"
                            tooltip="${message(code:'todo.is.ui.attach.files')}">
                        <span class="glyphicon glyphicon-plus"></span>
                    </button>
                </div>
            </td>
        </tr>
    </table>
</script>