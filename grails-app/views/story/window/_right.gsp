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
<div id="right-properties" data-accordion="true" data-height-style="fill">
    <h3><a href="#">${message(code: "is.story")}</a></h3>
    <div id="right-story-container"
         data-push
         data-push-listen='{ "object":"story","events":["select", "unselect", "update", "remove"] }'
         data-push-template="sandboxRight"></div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.test"/></a></h3>
    <div></div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.comments"/></a></h3>
    <div></div>
    <h3><a href="#"><g:message code="is.ui.backlogelement.activity.summary"/></a></h3>
    <div></div>
</div>