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
--}%<is:objectAsXML object="${object}" node="sprint" indentLevel="${indentLevel}" root="${root}">
    <is:propertyAsXML
            name="['state','dailyWorkTime','velocity','capacity','resource','endDate','startDate','orderNumber','activationDate','closeDate','lastUpdated','dateCreated']"/>
    <is:propertyAsXML name="['retrospective','doneDefinition','description','goal']" cdata="true"/>
    <is:listAsXML
            name="tasks"
            template="/task/xml"
            indentLevel="${indentLevel + 1}"
            expr="${{it.parentStory == null}}"/>
    <is:listAsXML
            name="stories"
            template="/story/xml"
            deep="${deep}"
            child="story"
            indentLevel="${indentLevel + 1}"/>
    <is:listAsXML
            name="cliches"
            template="/project/cliche"
            child="cliche"
            deep="${deep}"
            indentLevel="${indentLevel  + 1}"/>
</is:objectAsXML>