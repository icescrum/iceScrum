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
<is:postitMenuItem first="true">
    <is:link id="${feature.id}"
             action="edit"
             update="window-content-${controllerName}"
             value="${message(code:'is.ui.feature.menu.update')}"
             remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem>
    <is:link id="${feature.id}"
             action="copyFeatureToBacklog"
             remote="true"
             history="false"
             onSuccess="jQuery.event.trigger('accept_story',data); jQuery.icescrum.renderNotice('${message(code: 'is.feature.copy')}');"
             value="${message(code:'is.ui.feature.menu.copy')}"/>
</is:postitMenuItem>
<is:postitMenuItem>
    <is:link
            id="${feature.id}"
            action="delete"
            remote="true"
            history="false"
            onSuccess="jQuery.event.trigger('remove_feature',data); jQuery.icescrum.renderNotice('${message(code:'is.feature.deleted')}');"
            value="${message(code:'is.ui.feature.menu.delete')}"/>
</is:postitMenuItem>
<entry:point id="${controllerName}-${actionName}-postitMenu" model="[feature:feature]"/>