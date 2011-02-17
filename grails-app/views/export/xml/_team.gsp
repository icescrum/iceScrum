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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%<is:objectAsXML object ="${object}" node="team" indentLevel="${indentLevel}" root="${root}">
  <is:propertyAsXML name="['velocity','dateCreated']"/>
  <is:propertyAsXML name="['name','description']" cdata="true"/>
    <is:propertyAsXML
            object ="preferences"
            name="['allowNewMembers','allowRoleChange']"/>
  <is:listAsXML name="members" template="/export/xml/user" child="user" deep="${deep}" indentLevel="${indentLevel  + 1}"/>
  <is:listAsXML name="scrumMasters" template="/export/xml/user" deep="false" child="scrumMaster" indentLevel="${indentLevel  + 1}"/>
</is:objectAsXML>