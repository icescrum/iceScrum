/*
 * Copyright (c) 2020 Kagilum SAS.
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web

import groovy.json.JsonOutput
import org.codehaus.groovy.grails.web.mapping.ResponseCodeUrlMapping
import org.codehaus.groovy.grails.web.mapping.UrlMapping
import org.codehaus.groovy.grails.web.mapping.reporting.UrlMappingsRenderer

class OpenAPIUrlMappingsRenderer implements UrlMappingsRenderer {

    PrintStream out = System.out

    @Override
    void render(List<UrlMapping> urlMappings) {
        out.println(JsonOutput.prettyPrint(JsonOutput.toJson(getOpenApi(urlMappings))))
    }

    Map getOpenApi(List<UrlMapping> urlMappings) {
        def api = [
                openapi: '3.0.2',
                info   : [
                        title      : 'iceScrum REST API',
                        description: 'Access iceScrum programmatically',
                        version    : '1',
                        contact    : [
                                email: 'support@kagilum.com'
                        ]
                ],
                tags   : [],
                paths  : [:]
        ]
        def restUrlMappings = urlMappings.findAll { it.urlData.tokens[0] == 'ws' }
        def mappingsByController = restUrlMappings.findAll { it.controllerName }.groupBy { it.controllerName }
        restUrlMappings.findAll { !it.controllerName }.each { mapping ->
            def controllerConstraint = mapping.constraints.find { it.propertyName == 'controller' }
            def controllerNames = controllerConstraint.inList
            controllerNames.each { controllerName ->
                if (!mappingsByController.containsKey(controllerName)) {
                    mappingsByController[controllerName] = []
                }
                mappingsByController[controllerName] << mapping
            }
        }
        mappingsByController.keySet().sort().each { controllerName ->
            api.tags << [name: controllerName]
            mappingsByController[controllerName].each { mapping ->
                def urlPattern = establishUrlPattern(mapping, controllerName)
                def methods = !mapping.actionName || mapping.actionName instanceof String ? ['get'] : ((Map) mapping.actionName).keySet().collect { it.toLowerCase() }
                api.paths[urlPattern] = methods.collectEntries { method ->
                    def methodDescription = [
                            tags     : [controllerName],
                            responses: [
                                    '200': [
                                            description: 'successful operation'
                                    ]
                            ]
                    ]
                    if (mapping.constraints) {
                        methodDescription.parameters = mapping.constraints.findAll { it.propertyName != 'controller' }.collect { constraint ->
                            def parameter = [
                                    name    : constraint.propertyName,
                                    in      : 'path',
                                    required: !constraint.nullable,
                                    schema  : [:]
                            ]
                            if (constraint.matches == '\\d*') {
                                parameter.schema.type = 'integer'
                                parameter.schema.format = 'int64'
                            } else {
                                parameter.schema.type = 'string'
                                if (constraint.inList) {
                                    parameter.schema.enum = constraint.inList
                                }
                            }
                            return parameter
                        }
                    }
                    return [(method): methodDescription]
                }
            }
        }
        return api
    }

    private String establishUrlPattern(UrlMapping mapping, String controllerName) {
        if (mapping instanceof ResponseCodeUrlMapping) {
            throw new IllegalArgumentException('Error generating OpenAPI: dont know what to do with double ResponseCodeUrlMapping')
        }
        final constraints = mapping.constraints
        final tokens = mapping.urlData.tokens
        StringBuilder urlPattern = new StringBuilder(UrlMapping.SLASH)
        int constraintIndex = 0
        tokens.eachWithIndex { String token, int i ->
            boolean hasTokens = token.contains(UrlMapping.CAPTURED_WILDCARD) || token.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)
            if (hasTokens) {
                String finalToken = token
                while (hasTokens) {
                    if (finalToken.contains(UrlMapping.CAPTURED_WILDCARD)) {
                        def constraint = constraints[constraintIndex++]
                        if (constraint.propertyName == 'controller') {
                            finalToken = controllerName
                        } else {
                            finalToken = finalToken.replaceFirst(/\(\*\)/, '\\{' + constraint.propertyName + '}')
                        }
                    } else if (finalToken.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)) {
                        throw new IllegalArgumentException('Error generating OpenAPI: dont know what to do with double wildCard')
                    }
                    hasTokens = finalToken.contains(UrlMapping.CAPTURED_WILDCARD) || finalToken.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)
                }
                urlPattern << finalToken
            } else {
                urlPattern << token
            }
            if (i < (tokens.length - 1)) {
                urlPattern << UrlMapping.SLASH
            }
        }
        if (mapping.urlData.hasOptionalExtension()) {
            throw new IllegalArgumentException('Error generating OpenAPI: dont know what to do with optional extension')
        }
        return urlPattern.toString().replaceAll('\\?', '')
    }
}
