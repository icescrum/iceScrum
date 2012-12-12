%{--
- Copyright (c) 2012 Kagilum SAS.
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
-
--}%

<g:set var="attachment" value="[
   id: '?**=this.id**?',
   ext: '?**=this.ext**?',
   url: '?**=this.url**?',
   filename: '?**=this.filename**?',
   provide: '?**=this.provider**?',
   poster: '?**=this.poster**?'
]"/>

<template id="toolbar-line-attachment-tmpl">
    <g:render template="/attachment/line" model="[attachment: attachment, template: true]"/>
</template>