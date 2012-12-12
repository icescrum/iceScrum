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

--}%
<is:dialog valid="[controller:destController, action:'attachments', id:bean.id, onSuccess:'jQuery.event.trigger(\'replaceAll_attachments\', data);']"
           dialogClass="overflow-visible"
           width="500"
           maxHeight="500"
           buttons="'${message(code: 'is.button.close')}': function() { \$(this).dialog('close'); }">
    <form id="form-${destController}-attachments" name="form-projectform-${destController}-attachments" method="post" class='box-form box-form-250 box-form-200-legend'>
        <input type="hidden" name="product" value="${params.product}">
        <is:fieldset title="is.dialog.documents.manage.${destController}">
            <is:fieldFile for='${destController}.attachments' label="is.backlogelement.attachment" noborder="true">
            <is:multiFilesUpload elementId="${destController}attachments"
                                 class="attachments"
                                 name="attachments"
                                 bean="${bean}"
                                 urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                                 params="[product:params.product]"
                                 progress="[
                                         url:createLink(action:'uploadStatus',controller:'scrumOS'),
                                         label:message(code:'is.upload.wait')
                                 ]"/>
            </is:fieldFile>
        </is:fieldset>
    </form>
</is:dialog>