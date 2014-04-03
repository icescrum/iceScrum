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
<script type="text/icescrum-template" id="tpl-attachmentable-attachments">
**# var type = attachmentable.class.toLowerCase() **
**# _.each(attachmentable.attachments, function(attachment){ **
    <tr class="dz-preview">
        <td colspan="** iff(!$.icescrum.user.creator(attachmentable) && !$.icescrum.user.inProduct(),'colspan=\'2\'') **">
            <a href="${createLink(controller:'attachment', id:'** attachment.id **', params:[product:'** jQuery.icescrum.product.pkey **', attachmentable:'** attachmentable.id **', type:'** type **'])}">
                <span class="dz-filename" title="** attachment.name ** - ** filesize(attachment.length) **">** attachment.name **.** attachment.ext **</span> - <span class="dz-size">** filesize(attachment.length) **</span>
            </a>
        </td>
        **# if($.icescrum.user.creator(attachmentable) || $.icescrum.user.inProduct()) { **
            <td>
                <a class="dz-remove delete on-hover pull-right"
                   href="${createLink(controller:'attachment', id:'** attachment.id **', params:[product:'** jQuery.icescrum.product.pkey **', attachmentable:'** attachmentable.id **', type:'** type **'])}"
                   data-ajax="true"
                   data-attachmentable-type="** type **"
                   data-attachmentable-id="** attachmentable.id **"
                   data-attachment-id="** attachment.id **"
                   data-ajax-success="$.icescrum.attachment.delete"
                   data-ajax-method="DELETE">
                    <span class="fa fa-times text-danger"></span>
                </a>
            </td>
        **# } **
    </tr>
**# }); **
</script>