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
<ul>
  <li><a href="#tabs-description">
<g:message code="is.product.description"/></a></li>
</ul>
<div id="tabs-description">
  <div class="browse-informations clearfix">
    <img src="${resource(dir: is.currentThemeImage(), file: 'choose/default.png')}" class="ico">
    <h4>${product.name.encodeAsHTML()}</h4>
    <div class="description">
      <wikitext:renderHtml markup="Textile">${is.truncated(value:product.description,size:1000,encodedHTML:false)}</wikitext:renderHtml>
      <g:if test="${product.description?.length() > 200}">
          <div class="read-more">
           <is:link
              disabled="true"
              onClick="document.location=jQuery.icescrum.o.baseUrl+\'p/\'+jQuery(\'#product\').val()+\'#project\';jQuery(\'#dialog\').dialog(\'close\'); return false;">
              <g:message code="is.ui.project.link.more"/>
            </is:link>
          </div>
      </g:if>
    </div>
  </div>
  <table cellpadding="0" cellspacing="0" class="table-lines">
    <tr class="table-lines-head">
      <th class="first"><g:message code='is.dialog.wizard.project.option'/></th>
      <th class="last"><g:message code='is.dialog.wizard.project.value'/></th>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.planification.estimatedSprintsDuration'/></td>
      <td class="last">${product.preferences.estimatedSprintsDuration}</td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.autoDoneStory'/></td>
      <td class="last"><g:formatBoolean boolean="${product.preferences.autoDoneStory}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.assignOnCreateTask'/></td>
      <td class="last"><g:formatBoolean boolean="${product.preferences.assignOnBeginTask}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.assignOnBeginTask'/></td>
      <td class="last"><g:formatBoolean boolean="${product.preferences.assignOnBeginTask}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.displayRecurrentTasks'/></td>
      <td class="last"><g:formatBoolean boolean="${product.preferences.displayRecurrentTasks}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.displayUrgentTasks'/></td>
      <td class="last"><g:formatBoolean boolean="${product.preferences.displayUrgentTasks}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.product.preferences.sprint.limitUrgentTasks'/></td>
      <td class="last">${product.preferences.limitUrgentTasks}</td>
    </tr>
  </table>
</div>
<g:hiddenField name="product" value="${product.pkey}"/>