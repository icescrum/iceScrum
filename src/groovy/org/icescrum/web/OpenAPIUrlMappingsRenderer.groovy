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

    static final String GET = 'get'
    static final String PUT = 'put'
    static final String POST = 'post'
    static final String DELETE = 'delete'

    @Override
    void render(List<UrlMapping> urlMappings) {
        println(JsonOutput.prettyPrint(JsonOutput.toJson(getOpenApi(urlMappings))))
    }

    Map getOpenApi(List<UrlMapping> urlMappings) {
        def restUrlMappings = urlMappings.findAll {
            def customParameters = it.parameterValues.oapi
            it.urlData.tokens[0] == 'ws' && !customParameters?.hide
        }
        def tags = []
        def paths = new TreeMap<String, Map>()
        restUrlMappings.groupBy { it.controllerName }.each { controllerAttribute, mappings ->
            mappings.each { mapping ->
                def customParameters = mapping.parameterValues.oapi
                def controllerNames = controllerAttribute ? [controllerAttribute] : mapping.constraints.find { it.propertyName == 'controller' }.inList
                def actions = mapping.constraints.find { it.propertyName == 'action' }?.inList ?: ['']
                def workspaceTypes = mapping.constraints.find { it.propertyName == 'workspaceType' }?.inList ?: ['']
                def combinations = [controllerNames, actions, workspaceTypes].combinations()
                combinations.each { combination ->
                    def controllerName = combination[0]
                    def actionNameFromParameter = combination[1]
                    Map globalFixedParameters = [controller: controllerName, action: actionNameFromParameter, workspaceType: combination[2]]
                    def optionalParametersCombinations = getOptionalParameterCombinations(mapping.constraints.findAll { it.nullable })
                    optionalParametersCombinations.each { optionalParametersCombination ->
                        def fixedParameters = globalFixedParameters + optionalParametersCombination
                        String urlPattern = getUrlPattern(mapping, fixedParameters)
                        def constraints = mapping.constraints.findAll { !fixedParameters.containsKey(it.propertyName) }
                        String tag = customParameters?.tag ?: controllerName
                        tags << tag
                        def methodNames
                        if (mapping.actionName) {
                            if (mapping.actionName instanceof String) {
                                throwError(mapping, 'An HTTP method must be specified')
                            }
                            def actionMap = (Map) mapping.actionName
                            methodNames = actionMap.keySet().collect { it.toLowerCase() }
                            if (actionMap.containsKey('POST') && actionMap.containsKey('PUT') && actionMap['POST'] == actionMap['PUT']) {
                                methodNames.remove(POST)
                            }
                        } else {
                            methodNames = [customParameters?.method ? customParameters?.method.toLowerCase() : GET]
                        }
                        Map methods = methodNames.collectEntries { methodName ->
                            def actionName = mapping.actionName ? mapping.actionName[methodName.toUpperCase()] : actionNameFromParameter
                            if (!isControllerActionExist(controllerName, actionName)) {
                                throwError(mapping, "Action not found in ${controllerName.capitalize()}Controller: $actionName")
                            }
                            return [(methodName): getMethodDescription(methodName, actionName, tag, constraints, fixedParameters)]
                        }
                        if (!paths.containsKey(urlPattern)) {
                            paths[urlPattern] = [:]
                        }
                        paths[urlPattern].putAll(methods)
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

    private Map getMethodDescription(String methodName, String actionName, String tag, List<ConstrainedProperty> constraints, Map fixedParameters) {
        def description
        def responses = [:]
        if (actionName == 'save' && methodName == POST) {
            responses['201'] = 'Created - Sucessful creation'
            description = "Create a new $tag"
        } else if (actionName == 'update' && methodName == PUT) {
            responses['200'] = 'OK - Sucessful update'
            description = "Update the $tag located at this URL"
        } else if (actionName == 'delete' && methodName == DELETE) {
            responses['204'] = 'No Content - Sucessful deletion'
            description = "Delete the $tag located at this URL"
        } else if (actionName == 'show' && methodName == GET) {
            responses['200'] = 'OK - Sucessful get'
            description = "Get the $tag located at this URL"
        } else if (actionName == 'index' && methodName == GET) {
            responses['200'] = 'OK - Sucessful list'
            description = "Get the list of $tag"
        } else {
            responses['200'] = 'OK - Sucessful operation'
            description = ''
        }
        responses.putAll([
                '400': 'Bad Request - The request content is invalid',
                '401': 'Unauthorized - The provided user token is missing or invalid',
                '403': 'Forbidden - The provided user does not have sufficient permissions to perform this action',
                '404': 'Not Found - The requested ressource was not found on the server',
                '500': 'Internal Server Error - Unhandled validation error or server bug'
        ])
        def methodDescription = [
                tags       : [tag],
                description: description,
                responses  : responses.collectEntries { key, value -> [(key): [description: value]] }
        ]
        if (constraints) {
            methodDescription.parameters = constraints.collect { constraint ->
                def parameterName = getParameterName(constraint.propertyName, fixedParameters)
                def parameter = [
                        name       : parameterName,
                        description: getParameterDescription(tag, parameterName),
                        in         : 'path',
                        required   : true,
                        schema     : [:]
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

    private String getParameterDescription(String tag, String parameterName) {
        def descriptions = [
                project  : 'Project ID (integer) or Key (alphanumeric)',
                portfolio: 'Portfolio ID (integer) or Key (alphanumeric)',
                id       : "Technical ID of the $tag",
                uid      : "Business ID of the $tag"
        ]
        if (descriptions.containsKey(parameterName)) {
            return descriptions[parameterName]
        } else {
            return ''
        }
    }

    private String getUrlPattern(UrlMapping mapping, Map fixedParameters) {
        if (mapping instanceof ResponseCodeUrlMapping) {
            throwError(mapping, "Don't know what to do with double ResponseCodeUrlMapping")
        }
        List urlPattern = []
        int constraintIndex = 0
        mapping.urlData.tokens.eachWithIndex { String token, int i ->
            boolean containsParameter = token.contains(UrlMapping.CAPTURED_WILDCARD) || token.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)
            if (containsParameter) {
                String finalToken = token
                boolean stop = false
                while (containsParameter && !stop) {
                    if (finalToken.contains(UrlMapping.CAPTURED_WILDCARD)) {
                        def constraint = mapping.constraints[constraintIndex++]
                        if (fixedParameters.containsKey(constraint.propertyName) && fixedParameters[constraint.propertyName] == null) {
                            stop = true
                        } else {
                            if (fixedParameters[constraint.propertyName]) {
                                finalToken = fixedParameters[constraint.propertyName]
                            } else {
                                finalToken = finalToken.replaceFirst(/\(\*\)/, '\\{' + getParameterName(constraint.propertyName, fixedParameters) + '}')
                            }
                        }
                    } else if (finalToken.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)) {
                        throwError(mapping, "Don't know what to do with double wildCard")
                    }
                    containsParameter = finalToken.contains(UrlMapping.CAPTURED_WILDCARD) || finalToken.contains(UrlMapping.CAPTURED_DOUBLE_WILDCARD)
                }
                if (stop) {
                    return
                }
                urlPattern << finalToken
            } else {
                urlPattern << token
            }
        }
        if (mapping.urlData.hasOptionalExtension()) {
            throwError(mapping, "Don't know what to do with optional extension")
        }
        return UrlMapping.SLASH + urlPattern.join(UrlMapping.SLASH).replaceAll('\\?', '')
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

    // For a list of optional parameters [a, b, c] generate combinations [[:], [c: null], [c: null, b: null], [c: null, b: null, a: null]]
    private List getOptionalParameterCombinations(List<ConstrainedProperty> optionalParameters) {
        optionalParameters = optionalParameters.reverse()
        List combinations = [[:]]
        optionalParameters.size().times { index ->
            combinations << optionalParameters.take(index + 1).collectEntries { [(it.propertyName): null] }
        }
        combinations
    }
}
