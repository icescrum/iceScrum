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
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<head>
  <meta name='layout' content='main'/>
  <g:if test="${params.product}">
    <feed:meta kind="rss" version="2.0" controller="project" action="feed" params="[product:params.product,lang:lang]"/>
    <title>${product?.name ?: ''}</title>
  </g:if>
</head>
<body>

<jq:jquery>
  <g:if test="${params.product}">
    <icep:notifications
            name="projectGlobal"
            reload="[update:'#project-details',controller:'project',action:'projectDetails',params:[product:params.product]]"
            autoleave="false"
            group="${params.product}-product"/>
    <icep:notifications
            name="projectDelete"
            autoleave="false"
            callback="document.location='${createLink(uri:'/')}'"
            group="${params.product}-product-delete"/>
    <plugin:isAvailable name="icescrum-plugin-planning-poker">
      <icep:notifications
                  name="pluginPlanningPoker"
                  callback="jQuery.icescrum.planningpoker.notifyPlanningPoker(${params.product});"
                  autoleave="false"
                  group="${params.product}-plugin-planning-poker"/>
    </plugin:isAvailable>
  </g:if>
  <g:else>
    <g:if test="${params.team}">
      <icep:notifications
            name="projectGlobal"
            reload="[update:'#team-details',controller:'project',action:'teamDetails',params:[team:params.team]]"
            autoleave="false"
            group="${params.team}-product"/>
      <icep:notifications
            name="projectDelete"
            autoleave="false"
            callback="document.location='${createLink(uri:'/')}'"
            group="${params.team}-team-delete"/>
    </g:if>
  </g:else>
</jq:jquery>
</body>