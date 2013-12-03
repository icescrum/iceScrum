<%@ page import="org.icescrum.core.utils.BundleUtils" %>
%{--
- Copyright (c) 2011 Kagilum SAS.
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

<template id="user-tmpl">
    <![CDATA[
    ?**
        var name = this.name.length <= 20 ? this.name : this.name.substring(0,17)+'...';
        var activity = this.activity ? this.activity : '&nbsp;';
        var id = new Date().getTime();
        var role = this.role ? this.role : 0;
    **?
    <span class="member ui-corner-all" id='member?**=this.id**?'>
        <span class="button-s">
            <span style="display: block;" class="button-action button-delete" onclick="jQuery(this).closest('.member').remove();">del</span>
        </span>
        <img src="?**=this.avatar**?" height="48" class="avatar" width="48"/>
        <span class="fullname">?**=name**?</span>
        <span class="activity">?**=activity**?</span>
        <input type="hidden" name="members.?**=this.id**?" value="?**=this.id**?"/>
         <is:select width="110"
                    id="?**=id**?"
                    from="${BundleUtils.roles.values().collect {v -> message(code: v)}}"
                    keys="${BundleUtils.roles.keySet().asList()}"
                    name="role.?**=this.id**?"
                    value="?**=role**?"/>
    </span>
    ]]>
</template>