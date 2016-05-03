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
<%@ page import="org.icescrum.core.utils.BundleUtils; grails.converters.JSON;" %>
<script type="text/javascript">
    var isSettings = {
        user: ${user as JSON},
        roles: ${roles as JSON},
        project: ${product ? product as JSON : 'null'},
        pushContext: ${product?.id ?: "''"},
        messages: ${i18nMessages as JSON},
        bundles: ${is.i18nBundle() as JSON},
        applicationMenus: ${applicationMenus as JSON},
        types: {
            task:${BundleUtils.taskTypes.keySet() as JSON},
            story:${BundleUtils.storyTypes.keySet() as JSON},
            feature:${BundleUtils.featureTypes.keySet() as JSON},
            planningPoker:${BundleUtils.planningPokerGameSuites.keySet() as JSON}
        },
        states: {
            task: ${BundleUtils.taskStates.keySet() as JSON},
            acceptanceTest: ${BundleUtils.acceptanceTestStates.keySet() as JSON}
        },
        plugins: [],
        controllerEntryPoints: {},
        serverUrl: "${grailsApplication.config.grails.serverURL}"
    };
</script>