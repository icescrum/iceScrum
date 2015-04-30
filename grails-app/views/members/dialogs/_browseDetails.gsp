<%@ page import="org.icescrum.core.domain.security.Authority; grails.converters.JSON" %>
%{--
- Copyright (c) 2015 Kagilum.
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

<form id="form-team"
      name="form-team"
      method="post"
      class='box-form box-form-250 box-form-200-legend member-autocomplete'>
    <is:fieldInput for="team.name" label="is.team.name">
        <is:input id="team.name" name="team.name" value="${team.name}"/>
    </is:fieldInput>
    <is:fieldSelect for="team.owner" label="is.ui.team.owner">
        <is:select width="240"
                   from="${possibleOwners*.name}"
                   keys="${possibleOwners*.id}"
                   name="team.owner"
                   id="teamOwner"
                   onchange="if (jQuery(this).val() != ${team.owner.id}) { alert('${message(code: 'is.ui.team.owner.change.warning').encodeAsJavaScript()}'); }"
                   value="${team.owner.id}"/>
    </is:fieldSelect>
    <p class="field-input clearfix">
        <label>${ message(code: 'is.ui.team.projects')}</label>
        <span style="padding-left: 10px; display: inline-block; padding-top:5px">
            <g:each in="${team.products}" var="product" status="i">
                <a href="${grailsApplication.config.grails.serverURL}/p/${product.pkey}">${product.name}</a>${ i < team.products.size() -1 ? ', ' : '' }
            </g:each>
        </span>
    </p>
    <is:fieldInput for="find-team-members" label="is.dialog.wizard.section.team.find" class="members">
        <% def link = "<a><img height='40' width='40' src='\" + item.avatar + \"'/><span><b>\" + item.name + \"</b><br/>\" + item.activity + \"</span></a>"%>
        <is:autoCompleteSkin controller="user"
                             action="findUsers"
                             cache="true"
                             filter="jQuery('#member'+object.id).length == 0"
                             id="members"
                             name="find-team-members"
                             appendTo="#form-team"
                             onSelect="ui.item.editable = true;
                                       ui.item.view = 'members';
                                       ui.item.role = ${Authority.MEMBER};
                                       attachOnDomUpdate(jQuery('#team-member-list').jqoteapp('#user-tmpl', ui.item));"
                             renderItem="${link}"
                             minLength="2"/>
    </is:fieldInput>
    <div id="team-member-list" class="members-list"></div>
    <div class="field-buttons">
        <table cellpadding="0" cellspacing="0" border="0"><tbody><tr><td class="left-buttons" width="50%">&nbsp;</td>
            <td>
                <a id="update-team-button"
                   class="button-s clearfix"
                   data-ajax="true"
                   data-ajax-form="true"
                   data-ajax-method="POST"
                   data-ajax-notice="${message(code:'is.team.saved')}"
                   data-ajax-confirm="${message(code: 'is.ui.team.update.confirm')}"
                   data-ajax-success="var filter = jQuery('#team-browse-browse');
                                      filter.autocomplete('search', filter.val());
                                      filter.one('autocompleteupdated', function() {
                                          jQuery('.browse-item[data-elemid=${team.id}]').addClass('browse-item-active');
                                      });
                                      if (jQuery('#teamOwner').val() != ${team.owner.id}) {
                                          jQuery('#team-browse-details').html(jQuery('#empty-team-tmpl').html());
                                      }"
                   href="${createLink(controller: 'members', action: 'update', params: [id: team.id])}">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.update')}</span>
                    <span class="end"></span>
                </a>
            </td>
            <g:if test="${!team.products}">
                <td>
                    <a id="delete-team-button"
                       class="button-s clearfix"
                       data-ajax="true"
                       data-ajax-form="true"
                       data-ajax-method="POST"
                       data-ajax-notice="${message(code:'is.ui.team.deleted')}"
                       data-ajax-confirm="${message(code: 'default.button.delete.confirm.message')}"
                       data-ajax-success="var filter = jQuery('#team-browse-browse');
                                          filter.autocomplete('search', filter.val());
                                          jQuery('#team-browse-details').html(jQuery('#empty-team-tmpl').html());"
                       href="${createLink(controller: 'members', action: 'delete', params: [id: team.id])}">
                        <span class="start"></span>
                        <span class="content">${message(code:'default.button.delete.label')}</span>
                        <span class="end"></span>
                    </a>
                </td>
            </g:if>
            <td>
                <a id="cancel-team-button"
                   onClick="var filter = jQuery('#team-browse-browse');
                            filter.autocomplete('search', filter.val());
                            jQuery('#team-browse-details').html(jQuery('#empty-team-tmpl').html());"
                   class="button-s button-s-black">
                    <span class="start"></span>
                    <span class="content">${message(code:'is.button.cancel')}</span>
                    <span class="end"></span>
                </a>
            </td>
            <td width="50%">&nbsp;</td></tr></tbody>
        </table>
    </div>
    <jq:jquery>
        var members = ${memberEntries as JSON};
        $.each(members, function(index, member) {
            member.editable = true;
            member.view = 'members';
        });
        attachOnDomUpdate(jQuery('#team-member-list').jqotesub('#user-tmpl', members));
    </jq:jquery>
</form>