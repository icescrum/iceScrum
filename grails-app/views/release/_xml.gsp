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
--}%<is:objectAsXML object ="${object}" node="release" indentLevel="${indentLevel}" root="${root}">
  <is:propertyAsXML name="['state','releaseVelocity','endDate','startDate','orderNumber','lastUpdated','dateCreated']"/>
  <is:propertyAsXML name="['name','vision','description','goal']" cdata="true"/>
  <is:listAsXML
          name="sprints"
          template="/sprint/xml"
          child="sprint"
          deep="${deep}"
          indentLevel="${indentLevel + 1}"/>
  <is:listAsXML
        name="cliches"
        template="/project/cliche"
        deep="${deep}"
        indentLevel="${indentLevel  + 1}"
        child="cliche"/>
  <is:listAsXML
       name="features"
       child="feature"
       deep="${deep}"
       indentLevel="${indentLevel + 1}"/>
  <is:listAsXML
       name="attachments"
       template="/attachment/xml"
       child="attachment"
       deep="${deep}"
       indentLevel="${indentLevel + 1}"/>
</is:objectAsXML>