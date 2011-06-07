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
<is:wizard next="is.dialog.wizard.next" cancel="is.button.cancel" previous="is.dialog.wizard.previous"
           submit="is.dialog.wizard.submit" id="project-wizard" controller="project"
           before="\$('#choose-select-is-team-teams').empty();\$('#choose-select-is-team-members').empty();"
           onSuccess="\$('#dialog').dialog('close');" update="dialog" action="save">

    <is:fieldset title="is.dialog.wizard.section.project" description="is.dialog.wizard.section.project.description">
        <is:fieldInput for="productname" label="is.product.name">
            <is:input id="productname" name="product.name" value="${product.name}"/>
        </is:fieldInput>
        <is:fieldInput for="productpkey" label="is.dialog.wizard.project.pkey">
            <is:input id="productpkey" typed="[type:'alphanumeric',onlyletters:true,allcaps:true]" maxlength="10"
                      name="product.pkey" value="${product.pkey}"/>
        </is:fieldInput>
        <is:fieldArea for="productdescription" label="is.product.description" optional="true">
            <is:area rich="[preview:true,width:335]"
                     id="productdescription"
                     name="product.description"/>
        </is:fieldArea>
        <is:fieldDatePicker noborder="${privateOption?'true':''}" for="productstartDate"
                            label="is.dialog.wizard.project.startDate">
            <is:datePicker id="productstartDate" defaultDate="${product.startDate}"
                           onSelect="jQuery.icescrum.updateWizardDate(this);" name="product.startDate" mode="read-input"
                           changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>
        <is:fieldRadio rendered="${!privateOption}" for="product.preferences.hidden"
                       label="is.product.preferences.project.hidden" noborder="true">
            <is:radio id="product.preferences.hidden" name="product.preferences.hidden"
                      value="${product.preferences.hidden}"/>
        </is:fieldRadio>
    </is:fieldset>

    <is:fieldset title="is.dialog.wizard.section.team" description="is.dialog.wizard.section.team.description">

        <is:fieldRadio for="team.newTeam" label="is.product.team.new">
            <is:radio id="team.newTeam" name="team.newTeam" value="${true}"
                      onClick="if(this.value == 1){\$('#newTeamFieldSet').show();\$('#existingTeamFieldSet').hide();}else{\$('#newTeamFieldSet').hide();\$('#existingTeamFieldSet').show();}"/>
        </is:fieldRadio>
        <span id="newTeamFieldSet">
            <is:fieldInput for="team.name" label="is.team.name">
                <is:input id="team.name" name="team.name" value="${product.name} Team"/>
            </is:fieldInput>
            <is:fieldArea for="team.description" optional="true" label="is.team.description" noborder="true">
                <is:area rich="[preview:true,width:335]"
                         id="teamdescription"
                         name="team.description"/>
            </is:fieldArea>

            <is:autoCompleteChoose elementLabel="is.ui.autocompletechoose.users" controller="team" action="findMembers"
                                   minLength="0" name="is.team.members" resultId="userid"/>
        </span>
        <span id="existingTeamFieldSet" style="display:none">
            <is:autoCompleteChoose elementLabel="is.ui.autocompletechoose.teams" controller="team" action="findTeams"
                                   minLength="0" name="is.team.teams" resultId="teamid"/>
        </span>
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
            <is:input id="product.preferences.limitUrgentTasks" name="product.preferences.limitUrgentTasks"
                      typed="[type:'numeric',allow:'-']" value="${product.preferences.limitUrgentTasks}"/>
        </is:fieldRadio>
    </is:fieldset>

    <is:fieldset title="is.dialog.wizard.section.starting" description="is.dialog.wizard.section.starting.description">
        <is:fieldDatePicker for="productendDate" label="is.dialog.wizard.project.endDate">
            <is:datePicker id="productendDate" name="product.endDate" defaultDate="${product.endDate}"
                           minDate="${product.startDate}" onSelect="
      \$('#datepicker-firstSprint').datepicker('option', {maxDate:new Date(new Date(dateText).getTime() - 1*24*60*60*1000)});"
                           mode="read-input" changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>
        <is:fieldDatePicker for="firstSprint" label="is.dialog.wizard.firstSprint">
            <is:datePicker id="firstSprint" name="firstSprint" defaultDate="${product.startDate}"
                           minDate="${product.startDate}" maxDate="${product.endDate - 1}" mode="read-input"
                           changeMonth="true" changeYear="true"/>
        </is:fieldDatePicker>
        <is:fieldInput for="productpreferencesestimatedSprintsDuration"
                       label="is.product.preferences.planification.estimatedSprintsDuration" noborder="true">
            <is:input id="productpreferencesestimatedSprintsDuration"
                      name="product.preferences.estimatedSprintsDuration" typed="[type:'numeric']"
                      value="${product.preferences.estimatedSprintsDuration}"/>
        </is:fieldInput>
    </is:fieldset>

</is:wizard>