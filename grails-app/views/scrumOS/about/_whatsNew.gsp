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
                <a href="https://www.icescrum.com/your-new-icescrum/" target="_blank"><img style="width:639px;" src="https://www.icescrum.com/wp-content/uploads/2017/01/v7-planning-1024x532.png"/></a>
                <p style="margin:15px;">With the new version of iceScrum our objective is to develop a performing tool, always responding to our user’s needs. Thus, we are really glad to officially announce you the migration to the new version of iceScrum: <strong>the v7</strong>.
                </p>
                <p style="margin:15px;"><strong>On Monday, 19 June</strong>, all the projects hosted on the iceScrum Cloud platform will be only accessible via the new version.</p>
                <p style="margin:15px;">In order to get used to it, we invite you to test the new features of iceScrum on <a style="color:#357ebd" href="https://demo.icescrum.com" target="_blank">demo.icescrum.com</a>. This address is accessible from today and until the 16th of June with your normal iceScrum.com credentials.</p>
                <p style="margin:15px;"><strong>Then, we will migrate ALL the projects next week-end, 17 and 18 June.</strong></p>
                <p>If you have any question feel free to answer this email, and discover what's new in iceScrum, you can go to this page:
                    <a href="https://www.icescrum.com/documentation/migration-cloud/">Cloud migration</a>
                </p>
                <p style="margin-top: 15px;font-weight: bold;">Don't worry, be Agile !</p></div>
        </is:fieldset>
    </div>
</is:dialog>