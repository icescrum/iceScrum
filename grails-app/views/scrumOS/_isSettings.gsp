%{--
- Copyright (c) 2016 Kagilum SAS.
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
<%@ page import="org.icescrum.core.support.ApplicationSupport; grails.converters.JSON;" %>
<script type="text/javascript">
    var isSettings = {
        user: ${user as JSON},
        menus: ${menus as JSON},
        roles: ${roles as JSON},
        defaultView: "${defaultView}",
        project: ${project ? project as JSON : 'null'},
        projectTeam: ${project ? project.firstTeam as JSON : 'null'},
        context: '${context}',
        pushContext: ${project?.id ?: "''"},
        messages: ${i18nMessages as JSON},
        bundles: ${is.i18nBundle() as JSON},
        projectMenus: ${projectMenus as JSON},
        types: {
            task:${resourceBundles.taskTypes.keySet() as JSON},
            story:${resourceBundles.storyTypes.keySet() as JSON},
            feature:${resourceBundles.featureTypes.keySet() as JSON},
            planningPoker:${resourceBundles.planningPokerGameSuites.keySet() as JSON}
        },
        states: {
            task: ${resourceBundles.taskStates.keySet() as JSON},
            story: ${resourceBundles.storyStates.keySet() as JSON},
            acceptanceTest: ${resourceBundles.acceptanceTestStates.keySet() as JSON}
        },
        plugins: [],
        controllerHooks: {},
        version: "${g.meta(name: 'app.version')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        warning: ${ApplicationSupport.getLastWarning() as JSON}
        <entry:point id="scrumOS-isSettings" model="[user:user, roles:roles, project:project]"/>
    };
</script>
