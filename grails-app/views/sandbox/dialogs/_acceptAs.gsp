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
        height="125"
        width="430"
        valid="[
          action:'accept',
          controller:'story',
          params:'jQuery.icescrum.postit.ids($(\'.postit.ui-selected,.table-row-focus\'))',
          onSuccess:'var type = jQuery(\'input[name=type]:checked\', \'#dialog form\').val(); $.event.trigger(\'accept_story\',data)',
          button:'is.dialog.acceptAs.button'
      ]">
    <form class="box-form box-form-160 box-form-160-legend">
        <input type="hidden" value="${params.product}" name="product"/>
        <is:fieldset title="is.dialog.acceptAs.title">
            <is:fieldRadio for="type" label="is.dialog.acceptAs.acceptAs.title" noborder="true">
                <g:if test="${sprint}">
                    <is:radio
                            from="[(message(code: 'is.story')): 'story', (message(code: 'is.feature')): 'feature', (message(code: 'is.task.type.urgent')): 'task']"
                            id="type" value="story" name="type"/>
                </g:if>
                <g:else>
                    <is:radio from="[(message(code: 'is.story')): 'story', (message(code: 'is.feature')): 'feature']"
                              id="type" value="story" name="type"/>
                </g:else>
            </is:fieldRadio>
        </is:fieldset>
    </form>
</is:dialog>