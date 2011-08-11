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
- Damien vitrac (damien@oocube.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<head>
  <meta name='layout' content='simple'/>
  <title><g:message code="is.dialog.login"/></title>
</head>
<body>
<g:setProvider library="jquery"/>

<is:simpleDesktop>
  <div id="login_form" class="box">

    <is:boxTile><g:message code="is.dialog.login" /></is:boxTile>

    <g:formRemote url="${[uri:postUrl]}" id="loginForm" name="loginForm" method="post" class="box-form box-form-small-legend box-content box-form-160" onSuccess="document.location='${params.ref?params.ref.replace('@','#'):''}'">

      <is:fieldInformation nobordertop="true" div="true">
        <div class="welcome">
          <g:message code="is.welcome"/>
        </div>
        <div class="retrieve-link">
          <g:if test="activeLostPassword">
            <g:link controller="user" action="retrieve">
              <g:message code="is.dialog.login.lostPassword"/>
            </g:link>
          </g:if>
        </div>
      </is:fieldInformation>

      <is:fieldInput for="username" label="is.user.username">
        <is:input name="j_username" id="username" value="${params.username?:''}" focus="true"/>
      </is:fieldInput>

      <is:fieldInput for="password" label="is.user.password">
        <is:password name="j_password" id="password" />
      </is:fieldInput>

      <p class="field-check-line clearfix">
        <input type='checkbox' name='${rememberMeParameter}' id='remember_me' <g:if test='${hasCookie}'>checked='checked'</g:if>/>
        <label for='remember_me'><g:message code="is.dialog.login.rememberme"/></label>
      </p>
      
      <is:buttonBar id="login-button-bar">
        <is:button id="loginSubmit" history="false" type="submitToRemote" url="${[uri:postUrl]}" onSuccess="document.location='${params.ref?params.ref.replace('@','#'):''}'" value="${message(code: 'is.button.connect')}"/>
        <is:button rendered="${enableRegistration}" type="link" action="register" controller="user" remote="false" value="${message(code: 'is.button.register')}"/>
      </is:buttonBar>

    </g:formRemote>
  </div>
</is:simpleDesktop>
<is:shortcut key="return" callback="jQuery('#loginSubmit').click();"/>
</body>
