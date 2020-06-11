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

import grails.util.Holders
import groovy.json.JsonOutput
import org.codehaus.groovy.grails.validation.ConstrainedProperty
import org.codehaus.groovy.grails.web.mapping.ResponseCodeUrlMapping
import org.codehaus.groovy.grails.web.mapping.UrlMapping
import org.codehaus.groovy.grails.web.mapping.reporting.UrlMappingsRenderer

class OpenAPIUrlMappingsRenderer implements UrlMappingsRenderer {

    @Override
    void render(List<UrlMapping> urlMappings) {
        println(JsonOutput.prettyPrint(JsonOutput.toJson(getOpenApi(urlMappings))))
    }

    Map getOpenApi(List<UrlMapping> urlMappings) {
        def restUrlMappings = urlMappings.findAll {
            it.urlData.tokens[0] == 'ws' && !it.parameterValues.oapi?.hide
        }
        def tags = []
        def paths = new TreeMap<String, Map>()
        restUrlMappings.groupBy { it.controllerName }.each { controllerAttribute, mappings ->
            mappings.each { mapping ->
                def controllerNames = controllerAttribute ? [controllerAttribute] : mapping.constraints.find { it.propertyName == 'controller' }.inList
                def actions = mapping.constraints.find { it.propertyName == 'action' }?.inList ?: ['']
                def workspaceTypes = mapping.constraints.find { it.propertyName == 'workspaceType' }?.inList ?: ['']
                def combinations = [controllerNames, actions, workspaceTypes].combinations()
                combinations.each { combination ->
                    def controllerName = combination[0]
                    def actionName = combination[1]
                    Map fixedParameters = [controller: controllerName, action: actionName, workspaceType: combination[2]]
                    String urlPattern = establishUrlPattern(mapping, fixedParameters)
                    def constraints = mapping.constraints.findAll { !fixedParameters.containsKey(it.propertyName) }
                    String tag = controllerName
                    tags << tag
                    if (mapping.actionName instanceof String) {
                        throwError(mapping, 'An HTTP method must be specified')
                    }
                    def methodNames
                    if (mapping.actionName) {
                        def actionMap = (Map) mapping.actionName
                        methodNames = actionMap.keySet().collect { it.toLowerCase() }
                        if (actionMap.containsKey('POST') && actionMap.containsKey('PUT') && actionMap['POST'] == actionMap['PUT']) {
                            methodNames.remove('post')
                        }
                    } else {
                        methodNames = ['get']
                    }
                    paths[urlPattern] = methodNames.collectEntries { methodName ->
                        if (!actionName) {
                            actionName = mapping.actionName instanceof  String ? mapping.actionName : mapping.actionName[methodName.toUpperCase()]
                        }
                        if (!isControllerActionExist(controllerName, actionName)) {
                            throwError(mapping, "Action not found in ${controllerName.capitalize()}Controller: $actionName")
                        }
                        return [(methodName): getMethodDescription(tag, constraints, fixedParameters)]
                    }
                }
            }
        }
        return [
                openapi: '3.0.2',
                info   : [
                        title      : 'iceScrum REST API',
                        description: 'Access iceScrum programmatically',
                        version    : '1',
                        contact    : [
                                email: 'support@kagilum.com'
                        ]
                ],
                tags   : tags.unique().sort().collect { [name: it] },
                paths  : paths
        ]
    }

    private Map getMethodDescription(String tag, List<ConstrainedProperty> constraints, Map fixedParameters) {
        def methodDescription = [
                tags     : [tag],
                responses: [
                        '200': [
                                description: 'successful operation'
                        ]
                ]
        ]
        if (constraints) {
            methodDescription.parameters = constraints.collect { constraint ->
                def parameter = [
                        name    : getParameterName(constraint.propertyName, fixedParameters),
                        in      : 'path',
                        required: true,
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
        return methodDescription
    }

    private String establishUrlPattern(UrlMapping mapping, Map fixedParameters) {
        if (mapping instanceof ResponseCodeUrlMapping) {
            throwError(mapping, "Don't know what to do with double ResponseCodeUrlMapping")
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
                        if (fixedParameters[constraint.propertyName]) {
                            finalToken = fixedParameters[constraint.propertyName]
                        } else {
                            finalToken = finalToken.replaceFirst(/\(\*\)/, '\\{' + getParameterName(constraint.propertyName, fixedParameters) + '}')
                        }
                    } else if (finalToken.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)) {
                        throwError(mapping, "Don't know what to do with double wildCard")
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
            throwError(mapping, "Don't know what to do with optional extension")
        }
        return urlPattern.toString().replaceAll('\\?', '')
    }

    private String getParameterName(String propertyName, Map fixedParameters) {
        if (propertyName == 'workspace' && fixedParameters.workspaceType) {
            return fixedParameters.workspaceType
        } else {
            return propertyName
        }
    }

    private throwError(UrlMapping mapping, String message) {
        println('Error generating OpenAPI - ' + mapping.urlData.tokens.join('/') + ' - ' + message)
//        throw new IllegalArgumentException('Error generating OpenAPI - ' + mapping.urlData.tokens.join('/') + ' - ' + message)
    }

    private isControllerActionExist(String controllerName, String actionName) {
        def controllerMetaClass = Holders.grailsApplication.getArtefactByLogicalPropertyName('Controller', controllerName).metaClass
        return controllerMetaClass.metaMethodIndex.getMethods(controllerMetaClass.theClass, actionName) != null
    }
}
