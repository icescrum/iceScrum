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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.domain.AcceptanceTest" %>

<g:set var="acceptanceTest" value="[id:'?**=this.id**?',
                             creator:[id:'?**=this.poster.id**?'],
                             name:'?**=this.name**?',
                             state: '?**=this.state**?',
                             description:'?**=this.description**?',
                             uid:'?**=this.uid**?',
                             body:'?**=this.body**?']"/>

<template id="acceptancetest-storydetail-tmpl">
      <g:render template="/acceptanceTest/acceptanceTest"
          model="[acceptanceTest:acceptanceTest, template:true]"/>
</template>