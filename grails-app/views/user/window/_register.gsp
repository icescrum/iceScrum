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
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<head>
  <meta name='layout' content='simple'/>
  <title><g:message code="is.dialog.register"/></title>
</head>
<body>
<g:setProvider library="jquery"/>

<is:simpleDesktop>
  
  <div id='register-form' class="box">

    <is:boxTile><g:message code="is.dialog.register"/></is:boxTile>
    
    <form id="registerForm" name="registerForm" method="post" class='box-form box-form-small-legend box-content box-form-180' onsubmit="$('input[name=registerButton]').click();return false;">

        <is:fieldInformation nobordertop="true">
          <g:message code="is.welcome"/>
        </is:fieldInformation>

        <is:fieldInput for="firstName" label="is.user.firstname">
          <is:input id="firstName" name="firstName" value="${user.firstName}" focus="true" />
        </is:fieldInput>

        <is:fieldInput for="lastName" label="is.user.lastname">
          <is:input name='lastName' id='lastName' value="${user.lastName}" />
        </is:fieldInput>

        <is:fieldInput for="username" label="is.user.username">
          <is:input name="username" id="username" value="${user.username}" />
        </is:fieldInput>

        <is:fieldInput for="password" label="is.user.password">
          <is:password name='password' id='password' value="${user.password}" />
        </is:fieldInput>

        <is:fieldInput for="confirmPassword" label="is.dialog.register.confirmPassword">
          <is:password name='confirmPassword' id='confirmPassword' value="" />
        </is:fieldInput>

        <is:fieldInput for="email" label="is.user.email">
          <is:input name='email' id='email' value="${user.email}" />
        </is:fieldInput>

        <is:fieldInput for="activity" label="is.user.preferences.activity" optional="true">
          <is:input name='preferences.activity' id='activity' />
        </is:fieldInput>

        <is:fieldSelect for="language" label="is.user.preferences.language" noborder="true">
          <is:localeSelecter container="#registerForm" width="170" styleSelect="dropdown" name="preferences.language"/>
        </is:fieldSelect>
        
        <is:fieldInformation>
          <g:message code="is.dialog.register.description"/>
        </is:fieldInformation>

        <is:buttonBar id="login-button-bar">
          <is:button name="registerButton" type="submitToRemote" action='save' value="${message(code:'is.button.register')}" onSuccess="window.location.href='${createLink(controller:'login',action:'auth')}/?lang='+data.lang+'&username='+data.username;"/>
          <is:button type="link" button="button-s button-s-black" url="[controller:'login', action:'auth']" value="${message(code: 'is.button.cancel')}"/>
        </is:buttonBar>
    </form>
  </div>
  <is:shortcut key="return" listenOn="'input'" callback="jQuery('input[name=registerButton]').click();"/>
</is:simpleDesktop>
</body>
