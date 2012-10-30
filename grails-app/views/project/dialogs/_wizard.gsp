<%@ page import="org.icescrum.core.domain.security.Authority; org.icescrum.core.utils.BundleUtils" %>
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
        resizable="false"
        noprefix="true"
        withTitlebar="false"
        width="800"
        draggable="false">
<is:wizard next="is.dialog.wizard.next" cancel="is.button.cancel" previous="is.dialog.wizard.previous"
           submit="is.dialog.wizard.submit" id="project-wizard" controller="project"
           before="\$('#choose-select-is-team-teams').empty();\$('#choose-select-is-team-members').empty();"
           onSuccess="jQuery('#dialog').dialog('close'); jQuery.icescrum.renderNotice('${message(code:'is.product.saved.redirect')}'); jQuery.event.trigger('redirect_product',data);" update="dialog" action="save">

    <is:fieldset title="is.dialog.wizard.section.project" description="is.dialog.wizard.section.project.description">
        <is:fieldInput for="productname" label="is.product.name">
            <is:input id="productname" name="product.name" value="${product.name}"/>
        </is:fieldInput>
        <is:fieldInput for="productpkey" label="is.dialog.wizard.project.pkey">
            <is:input id="productpkey" typed="[type:'alphanumeric',onlyletters:true,allcaps:true]" maxlength="10"
                      name="product.pkey" value="${product.pkey}"/>
        </is:fieldInput>
        <is:fieldRadio rendered="${!privateOption}" for="product.preferences.hidden" label="is.product.preferences.project.hidden">
            <is:radio id="product.preferences.hidden" name="product.preferences.hidden" value="${product.preferences.hidden}"/>
        </is:fieldRadio>
        <is:fieldSelect for="product.preferences.timezone" label="is.product.preferences.timezone">
          <is:localeTimeZone width="250" maxHeight="200" styleSelect="dropdown" name="product.preferences.timezone" value="UTC"/>
        </is:fieldSelect>
        <is:fieldArea for="productdescription" label="is.product.description" noborder="true" optional="true">
            <is:area rich="[preview:true,width:335,height:200]" id="productdescription" name="product.description"/>
        </is:fieldArea>
    </is:fieldset>

    <is:fieldset title="is.dialog.wizard.section.team" description="is.dialog.wizard.section.team.description" id="member-autocomplete">
        <is:fieldInput for="team.members" label="is.dialog.wizard.section.team.find" class="members">
            <% def link = "<a><img height='40' width='40' src='\" + item.avatar + \"'/><span><b>\" + item.name + \"</b><br/>\" + item.activity + \"</span></a>"%>
            <is:autoCompleteSkin
                        controller="user"
                        action="findUsers"
                        cache="true"
                        filter="jQuery('#member'+object.id).length == 0 ? true : false"
                        id="members"
                        name="team.members"
                        appendTo="#member-autocomplete"
                        onSelect="jQuery('.members-list').jqoteapp('#user-tmpl', ui.item)"
                        renderItem="${link}"
                        minLength="2"/>
        </is:fieldInput>
        <div class="members-list">
            <span class="member ui-corner-all" id='member${user.id}'>
                <span class="button-s">
                    <span style="display: block;" class="button-action button-delete" onclick="jQuery(this).closest('.member').remove();">del</span>
                </span>
                <img src="${is.avatar([user:user,link:true])}" height="48" class="avatar" width="48"/>
                <span class="fullname">${is.truncated(value:user.firstName+" "+user.lastName,size:17)}</span>
                <span class="activity">${user.preferences.activity?:'&nbsp;'}</span>
                <input type="hidden" name="members.${user.id}" value="${user.id}"/>
                 <is:select container="#member${user.id}"
                            width="110"
                            maxHeight="200"
                            id="${new Date().time}"
                            styleSelect="dropdown"
                            from="${BundleUtils.roles.values().collect {v -> message(code: v)}}"
                            keys="${BundleUtils.roles.keySet().asList()}"
                            name="role.${user.id}"
                            value="${Authority.PO_AND_SM}"/>
            </span>
        </div>
    </is:fieldset>

    <is:fieldset title="is.dialog.wizard.section.options" description="is.dialog.wizard.section.options.description">
        <is:fieldSelect for="product.planningPokerGameType"
                        label="is.product.preferences.planification.estimationSuite">
            <is:select from="${estimationSuitSelect.values().asList()}" keys="${estimationSuitSelect.keySet().asList()}"
                       width="240" maxHeight="100" styleSelect="dropdown" name="product.planningPokerGameType"
                       id="product.planningPokerGameType" value="${product.planningPokerGameType}"/>
        </is:fieldSelect>
        <is:fieldRadio for="product.preferences.noEstimation" label="is.product.preferences.planification.noEstimation">
            <is:radio id="product.preferences.noEstimation" name="product.preferences.noEstimation"
                      value="${product.preferences.noEstimation}"/>
        </is:fieldRadio>
        <is:fieldRadio for="productpreferenceshideweekend" label="is.product.preferences.project.hideWeekend">
            <is:radio id="product.preferences.hideWeekend" name="product.preferences.hideWeekend"
                      value="${product.preferences.hideWeekend}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.autoDoneStory" label="is.product.preferences.sprint.autoDoneStory">
            <is:radio id="product.preferences.autoDoneStory" name="product.preferences.autoDoneStory"
                      value="${product.preferences.noEstimation}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.autoCreateTaskOnEmptyStory"
                       label="is.product.preferences.sprint.autoCreateTaskOnEmptyStory">
            <is:radio id="product.preferences.autoCreateTaskOnEmptyStory"
                      name="product.preferences.autoCreateTaskOnEmptyStory"
                      value="${product.preferences.autoCreateTaskOnEmptyStory}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.assignOnCreateTask"
                       label="is.product.preferences.sprint.assignOnCreateTask">
            <is:radio id="product.preferences.assignOnCreateTask" name="product.preferences.assignOnCreateTask"
                      value="${product.preferences.assignOnCreateTask}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.assignOnBeginTask"
                       label="is.product.preferences.sprint.assignOnBeginTask">
            <is:radio id="product.preferences.assignOnBeginTask" name="product.preferences.assignOnBeginTask"
                      value="${product.preferences.assignOnBeginTask}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.displayRecurrentTasks"
                       label="is.product.preferences.sprint.displayRecurrentTasks">
            <is:radio id="product.preferences.displayRecurrentTasks" name="product.preferences.displayRecurrentTasks"
                      value="${product.preferences.displayRecurrentTasks}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.displayUrgentTasks"
                       label="is.product.preferences.sprint.displayUrgentTasks">
            <is:radio id="product.preferences.displayUrgentTasks" name="product.preferences.displayUrgentTasks"
                      value="${product.preferences.displayUrgentTasks}"/>
        </is:fieldRadio>
        <is:fieldRadio for="product.preferences.limitUrgentTasks" label="is.product.preferences.sprint.limitUrgentTasks"
                       noborder="true">
            <is:input id="product.preferences.limitUrgentTasks" class="small" name="product.preferences.limitUrgentTasks"
                      typed="[type:'numeric',allow:'-']" value="${product.preferences.limitUrgentTasks}"/>
        </is:fieldRadio>
    </is:fieldset>

    <is:fieldset title="is.dialog.wizard.section.starting" description="is.dialog.wizard.section.starting.description">

        <is:fieldDatePicker noborder="${privateOption?'true':''}" for="productstartDate"
                            label="is.dialog.wizard.project.startDate">
            <is:datePicker id="productstartDate" defaultDate="${product.startDate}"
                           onSelect="jQuery.icescrum.updateWizardDate(this);" name="product.startDate" mode="read-input"
                           changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>

        <is:fieldDatePicker for="firstSprint" label="is.dialog.wizard.firstSprint">
            <is:datePicker id="firstSprint" name="firstSprint" defaultDate="${product.startDate}"
                           minDate="${product.startDate}" maxDate="${product.endDate - 1}" mode="read-input"
                           changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>

         <is:fieldInput for="productpreferencesestimatedSprintsDuration"
                       label="is.product.preferences.planification.estimatedSprintsDuration">
            <is:input id="productpreferencesestimatedSprintsDuration" class="small"
                      name="product.preferences.estimatedSprintsDuration" typed="[type:'numeric']"
                      value="${product.preferences.estimatedSprintsDuration}"/>
        </is:fieldInput>

        <is:fieldDatePicker for="productendDate" label="is.dialog.wizard.project.endDate">
            <is:datePicker id="productendDate" name="product.endDate" defaultDate="${product.endDate}"
                           minDate="${product.startDate}" mode="read-input" changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>

        <is:fieldArea for="vision" label="is.release.vision" noborder="true" optional="true">
            <is:area rich="[preview:true,width:335,height:200]"
                     id="vision"
                     name="vision"/>
        </is:fieldArea>

    </is:fieldset>

</is:wizard>
</is:dialog>