<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
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
<is:dialog valid="[action:'update',controller:'user',id:user.id,onSuccess:'jQuery.event.trigger(\'updateProfile_user\',[data])']"
            title="is.dialog.profile"
            width="600"
            noprefix="true"
            resizable="false"
            draggable="false">
<form id="form-profile" method="post" class='box-form box-form-250 box-form-200-legend'
      onsubmit="jQuery('.ui-dialog-buttonpane button:eq(1)').click();
      return false;">
    <input type="hidden" id="product" name="product" value="${params.product}"/>
    <input type="hidden" id="user.version" name="user.version" value="${user.version}"/>
    <is:fieldset nolegend="true" title="is.dialog.profile">
        <is:accordion id="profile" autoHeight="false">
            <is:accordionSection title="is.dialog.profile.general.title">

                <is:fieldInput for="userfirstName" label="is.user.firstname">
                    <is:input id="userfirstName" name="user.firstName" value="${user.firstName}"/>
                </is:fieldInput>
                <is:fieldInput for="userlastName" label="is.user.lastname">
                    <is:input id="userlastName" name="user.lastName" value="${user.lastName}"/>
                </is:fieldInput>
                <is:fieldInput for="userusername" label="is.user.username">
                    <is:input id="userusername" disabled="disabled" name="username" value="${user.username}"/>
                </is:fieldInput>

                <g:if test="${!user.accountExternal}">
                    <is:fieldInput for="userpassword" label="is.user.password" class="user-password">
                        <is:password id="userpassword" name="user.password"/>
                    </is:fieldInput>
                    <is:fieldInput for="confirmPassword" label="is.dialog.profile.confirmPassword" class="user-password-confirm">
                        <is:password id="confirmPassword" name="confirmPassword"/>
                    </is:fieldInput>
                </g:if>
                    <is:fieldInput for="useremail" label="is.user.email">
                        <is:input id="useremail" name="user.email" disabled="${user.accountExternal?'disabled':false}" value="${user.email}"/>
                    </is:fieldInput>

                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar.enable)}">
                    <is:fieldInput for="avatar" label="is.dialog.profile.gravatar" class="profile-avatar">
                        <a href="http://gravatar.com/emails"><is:avatar user="${user}"/></a>
                    </is:fieldInput>
                </g:if>
                <g:else>
                    <is:fieldFile class="file-avatar" for="avatar" label="" noborder="true">
                        <is:avatar elementId="preview-avatar" user="${user}" nocache="true"/>
                        <is:multiFilesUpload
                                name="avatar"
                                accept="['jpg','png','gif']"
                                urlUpload="${createLink(action:'upload',controller:'scrumOS')}"
                                multi="1"
                                onUploadComplete="jQuery('#avatar-selected').val('');jQuery('#preview-avatar').attr('src','${createLink(action:'previewAvatar',controller:'user')}?fileID='+fileID);"
                                progress="[
                      url:createLink(action:'uploadStatus',controller:'scrumOS'),
                      label:message(code:'is.upload.wait'),
                    ]"/>
                    </is:fieldFile>
                    <is:fieldInput class="file-avatar">
                        <is:avatarSelector/>
                    </is:fieldInput>
                </g:else>

                <is:fieldInput for="activity" label="is.user.preferences.activity" optional="true">
                    <is:input name='user.preferences.activity' id='activity' value="${user.preferences.activity}"/>
                </is:fieldInput>
                <is:fieldSelect for="user.preferences.language" label="is.user.preferences.language" noborder="true">
                    <is:localeSelecter width="170" styleSelect="dropdown" name="user.preferences.language"
                                       id="user.preferences.language" value="${user.preferences.language}"/>
                </is:fieldSelect>
            </is:accordionSection>
            <g:if test="${projects}">
                <is:accordionSection title="is.dialog.profile.emailsSettings">
                    <is:fieldFile for="userpreferencesemailsSettingsautoFollow" label="is.dialog.profile.emailsSettings.autoFollow">
                        <div class="emails-settings">
                            <g:each var="project" in="${projects}">
                                <is:checkbox label="${project.name}" checked="${project.pkey in user.preferences.emailsSettings.autoFollow}"  value="${project.pkey}" name="user.preferences.emailsSettings.autoFollow"/>
                            </g:each>
                        </div>
                    </is:fieldFile>
                    <is:fieldFile for="userpreferencesemailsSettingsonStory" label="is.dialog.profile.emailsSettings.onStory">
                        <div class="emails-settings">
                            <g:each var="project" in="${projects}">
                                <is:checkbox label="${project.name}" checked="${project.pkey in user.preferences.emailsSettings.onStory}"  value="${project.pkey}" name="user.preferences.emailsSettings.onStory"/>
                            </g:each>
                        </div>
                    </is:fieldFile>
                    <is:fieldFile for="userpreferencesemailsSettingsonUrgentTask" label="is.dialog.profile.emailsSettings.onUrgentTask">
                        <div class="emails-settings">
                            <g:each var="project" in="${projects}">
                                <is:checkbox label="${project.name}" checked="${project.pkey in user.preferences.emailsSettings.onUrgentTask}"  value="${project.pkey}" name="user.preferences.emailsSettings.onUrgentTask"/>
                            </g:each>
                        </div>
                    </is:fieldFile>
                </is:accordionSection>
            </g:if>
            <entry:point id="${controllerName}-${actionName}" model="[user:user]"/>
        </is:accordion>
    </is:fieldset>
</form>
<is:shortcut key="return" callback="jQuery('.ui-dialog-buttonpane button:eq(1)').click();" scope="form-profile"
             listenOn="'#form-profile input'"/>
</is:dialog>