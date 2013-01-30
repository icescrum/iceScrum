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
--}%<is:objectAsXML object="${object}" node="task" indentLevel="${indentLevel}" root="${root}">
    <is:propertyAsXML name="['estimation','initial','type','state','rank','creationDate','inProgressDate','doneDate','blocked','color']"/>
    <is:propertyAsXML object="creator"/>
    <is:propertyAsXML object="responsible"/>
    <is:propertyAsXML name="['name','description','notes','tags']" cdata="true"/>
    <is:listAsXML
            name="attachments"
            template="/addons/attachmentXml"
            child="attachment"
            deep="${deep}"
            indentLevel="${indentLevel + 1}"/>
</is:objectAsXML>