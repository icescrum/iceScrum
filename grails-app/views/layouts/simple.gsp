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
- Damien vitrac (damien@oocube.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>iceScrum - <g:layoutTitle/></title>
    <r:external uri="/${is.currentThemeImage()}favicon.ico"/>
    <!--[if IE 8]><meta http-equiv="X-UA-Compatible" content="IE=8"/><![endif]-->
    <is:loadJsVar/>
    <r:require modules="jquery,jquery-ui,jquery-ui-plugins,jquery-plugins,jqplot,icescrum"/>
    <r:layoutResources/>
    <g:layoutHead/>
</head>

<body class="simple">
<g:layoutBody/>
<is:spinner
        on400="var error = jQuery.parseJSON(xhr.responseText); jQuery.icescrum.renderNotice( error.notice.text, 'error', error.notice.title); "
        on403="jQuery.icescrum.renderNotice('${message(code:'is.error.denied')}', 'error');"
        on500="jQuery.icescrum.dialogError(xhr)"/>
<r:layoutResources/>
<entry:point id="icescrum-footer"/>
</body>
</html>