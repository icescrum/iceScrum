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
<g:set var="releaseNotesURL" value="${message(code: 'is.ui.whatsnew.releaseNotesURL', args: [ApplicationSupport.getNormalisedVersion()])}"/>
<is:dialog
        resizable="false"
        withTitlebar="false"
        width="700"
        height="550"
        id="dialog-whatsnew"
        buttons="'${message(code: 'is.button.close')}': function() { ${remoteFunction(controller: 'scrumOS', action: 'whatsNew', params: [hide: true])}; jQuery(this).dialog('close'); }"
        draggable="false">
    <div class='box-form box-form-250 box-form-200-legend'>
        <is:fieldset title="Get on board for a new Agile experience with iceScrum v7!" id="member-autocomplete">
            <div style="background: white; text-align: center;font-size: 12px;">
                <a href="https://www.icescrum.com/your-new-icescrum/" target="_blank"><img style="width:639px;" src="https://www.icescrum.com/wp-content/uploads/2017/06/planning-small.png"/></a>
                <p style="margin:15px;">A new iceScrum is here! More intuitive, more powerful, we reinvented iceScrum to provide the best agile experience!</p>
                <p>
                    From this current installation, you can export your projects with a new menu in order to import them on a server with the v7 installed.
                    Follow the <a style="color:#357ebd" href="https://www.icescrum.com/documentation/migration-standalone/">Standalone migration</a> guide to learn more about how to proceed.
                </p>
                <p style="margin-top: 15px;font-weight: bold;">Don't worry, be Agile !</p></div>
        </is:fieldset>
    </div>
</is:dialog>