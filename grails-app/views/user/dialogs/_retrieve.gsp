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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<head>
  <meta name='layout' content='simple'/>
  <title><g:message code="is.dialog.retrieve"/></title>
</head>
<body>
<g:setProvider library="jquery"/>
<is:simpleDesktop>
  <div id="login_form" class="box">

    <is:boxTile>
      <g:message code="is.dialog.retrieve" />
    </is:boxTile>

    <g:formRemote
            url="[action:'retrieve',controller:'user']"
            id="retrieveForm"
            name="retrieveForm"
            method="post"
            class="box-form box-form-small-legend box-content box-form-160"
            onSuccess="jQuery.icescrum.renderNotice(data.text); jQuery.doTimeout(1000,function(){window.location.href='${createLink(controller:'login',action:'auth')}';})">

      <is:fieldInformation nobordertop="true">
        <g:message code="is.dialog.retrieve.description"/>
      </is:fieldInformation>

      <is:fieldInput for="text" label="is.dialog.retrieve.input" noborder="true">
        <is:input name="text" id="text" autofocus=""/>
      </is:fieldInput>

      <is:buttonBar id="retrieve-button-bar">
          <is:button type="link"
                     action="auth"
                     controller="login"
                     remote="false"
                     value="${message(code:'is.button.cancel')}"/>
          <is:button id="retrieveSubmit"
                  history="false"
                  type="submitToRemote"
                  controller="user"
                  action="retrieve"
                  onSuccess="jQuery.icescrum.renderNotice(data.text); jQuery.doTimeout(1000,function(){window.location.href='${createLink(controller:'login',action:'auth')}';})"
                  value="${message(code:'is.dialog.retrieve.button.reset')}"/>
      </is:buttonBar>

    </g:formRemote>
  </div>
</is:simpleDesktop>
<is:shortcut key="return" callback="\$('#retrieveSubmit').click();"/>
</body>