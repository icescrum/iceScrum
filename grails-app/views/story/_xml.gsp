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
--}%<is:objectAsXML object="${object}" node="story" indentLevel="${indentLevel}" root="${root}">
    <is:propertyAsXML
            name="['state','suggestedDate','acceptedDate','estimatedDate','plannedDate','inProgressDate','doneDate','effort','value','rank','creationDate','type','executionFrequency']"/>
    <is:propertyAsXML name="['name','textAs','textICan','textTo','notes','description']" cdata="true"/>
    <is:propertyAsXML object="creator"/>
    <is:propertyAsXML object="feature"/>
    <is:propertyAsXML object="actor"/>
    <is:listAsXML
            name="tasks"
            template="/task/xml"
            child="task"
            deep="${deep}"
            indentLevel="${indentLevel + 1}"/>
</is:objectAsXML>