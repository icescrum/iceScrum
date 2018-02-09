/*
 * Copyright (c) 2015 Kagilum SAS
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 */


import grails.plugin.databasemigration.MigrationUtils
import liquibase.resource.ClassLoaderResourceAccessor
import liquibase.resource.CompositeResourceAccessor
import liquibase.resource.FileSystemResourceAccessor
import liquibase.resource.ResourceAccessor
import org.icescrum.core.security.MethodScrumExpressionHandler
import org.icescrum.core.security.WebScrumExpressionHandler
import org.icescrum.core.utils.TimeoutHttpSessionListener
import org.icescrum.i18n.IceScrumMessageSource

beans = {

    xmlns task: "http://www.springframework.org/schema/task"
    task.'annotation-driven'()

    webExpressionHandler(WebScrumExpressionHandler) {
        roleHierarchy = ref('roleHierarchy')
    }

    expressionHandler(MethodScrumExpressionHandler) {
        parameterNameDiscoverer = ref('parameterNameDiscoverer')
        permissionEvaluator = ref('permissionEvaluator')
        roleHierarchy = ref('roleHierarchy')
        trustResolver = ref('authenticationTrustResolver')
    }

    messageSource(IceScrumMessageSource) {
        basenames = "WEB-INF/grails-app/i18n/messages"
    }

    timeoutHttpSessionListener(TimeoutHttpSessionListener) {
        config = grailsApplication.config
    }

    /* Manage plugins migrations */
    if (!application.warDeployed) {

        String changelogLocationPath = new File('grails-app/migrations').path
        def openers = [new FileSystemResourceAccessor(changelogLocationPath), new ClassLoaderResourceAccessor()]
        System.getProperty("icescrum.plugins.dir")?.split(";")?.each {
            if(new File(it + "/grails-app/migrations").exists()){
                openers << new FileSystemResourceAccessor(it + "/grails-app/migrations")
            }
        }
        migrationResourceAccessor(CompositeResourceAccessor, openers)
    }
}