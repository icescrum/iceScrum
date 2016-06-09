<%@ page import="org.icescrum.core.support.ApplicationSupport;" %>
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
<g:set var="releaseNotesURL" value="${message(code:'is.ui.whatsnew.releaseNotesURL', args:[ApplicationSupport.getNormalisedVersion()])}"/>
<is:dialog
        resizable="false"
        withTitlebar="false"
        width="650"
        id="dialog-whatsnew"
        buttons="'${message(code:'is.button.close')}': function() { ${remoteFunction(controller:'scrumOS',action:'whatsNew',params:[hide:true])}; jQuery(this).dialog('close'); }"
        draggable="false">
        <div class='box-form box-form-250 box-form-200-legend'>
            <is:fieldset title="is.ui.whatsnew.title" id="member-autocomplete">
                <is:fieldInformation noborder="true">${message(code:'is.ui.whatsnew.description', args:[g.meta(name:"app.version")])}</is:fieldInformation>
                <div class="features-list">
                    <ul>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"></a>
                            <a href="${releaseNotesURL}" target="_blank">Story description template and autocomplete on actors</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"></a>
                            <a href="${releaseNotesURL}" target="_blank">Better UI and search field on large drop-down lists</a>
                        </li>
                    </ul>
                    <span class="more">
                        <g:message code="is.ui.whatsnew.more"/> <a href="${releaseNotesURL}" target="_blank">${message(code:"is.ui.whatsnew.releaseNotes", args:[g.meta(name:"app.version")])}</a>
                    </span>
                    <g:set var="now" value="${new Date()}"/>
                    <g:set var="validFrom" value="${new Date('22/12/2014')}"/>
                    <g:set var="validTo" value="${new Date('01/07/2015')}"/>
                    <g:if test="${validFrom.before(now) && validTo.after(now)}">
                        <span class="more wishes">
                            <g:message code="is.ui.holidaySeasonWishes"/>
                        </span>
                    </g:if>
                </div>
            </is:fieldset>
        </div>
</is:dialog>