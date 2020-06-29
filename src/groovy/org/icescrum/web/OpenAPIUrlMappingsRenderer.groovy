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
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.support.ApplicationSupport

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
                def controllerNames = controllerAttribute ? [controllerAttribute != 'scrumOS' ? controllerAttribute : 'server'] : mapping.constraints.find { it.propertyName == 'controller' }.inList
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
//                            if (!isControllerActionExist(controllerName, actionName)) {
//                                throwError(mapping, "Action not found in ${controllerName.capitalize()}Controller: $actionName")
//                            }
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
        def uniqueTags = tags.unique().sort()
        return [
                openapi     : '3.0.2',
                info        : [
                        title      : 'iceScrum REST API',
                        description: 'Access iceScrum programmatically',
                        version    : '1.0',
                        contact    : [
                                email: 'support@kagilum.com'
                        ]
                ],
                servers     : [
                        [
                                url: ApplicationSupport.serverURL() + '/ws'
                        ]
                ],
                paths       : paths,
                components  : [
                        schemas        : uniqueTags.collectEntries { tag ->
                            [
                                    (tag): getObjectSchema(tag)
                            ]
                        },
                        responses      : [
                                '200'       : [description: 'OK - Sucessful operation'],
                                '201'       : [description: 'Created - Sucessful creation'],
                                '204-DELETE': [description: 'No Content - Sucessful deletion'],
                                '400'       : [description: 'Bad Request - The request content is invalid'],
                                '401'       : [description: 'Unauthorized - The provided user token is missing or invalid'],
                                '403'       : [description: 'Forbidden - The provided user does not have sufficient permissions to perform this action'],
                                '404'       : [description: 'Not Found - The requested ressource was not found on the server'],
                                '500'       : [description: 'Internal Server Error - Unhandled validation error or server bug']
                        ],
                        securitySchemes: [
                                api_key         : [
                                        type: 'apiKey',
                                        name: 'x-icescrum-token',
                                        in  : 'header'
                                ],
                                api_key_unsecure: [
                                        type: 'apiKey',
                                        name: 'icescrum-token',
                                        in  : 'query'
                                ]
                        ]
                ],
                security    : [
                        [
                                'api_key'         : [],
                                'api_key_unsecure': []
                        ]
                ],
                tags        : uniqueTags.collect { [name: it] },
                externalDocs: [
                        description: 'Learn more on the offical website',
                        url        : 'https://www.icescrum.com/documentation/rest-api/'
                ]
        ]
    }

    private Map getMethodDescription(String methodName, String actionName, String tag, List<ConstrainedProperty> constraints, Map fixedParameters) {
        def description
        def responses = [:]
        def requestBody
        if (actionName == 'save' && methodName == POST) {
            requestBody = [
                    content : ['application/json': [schema: [type: 'object', properties: [(tag): [$ref: "#/components/schemas/$tag"]]]]],
                    required: true
            ]
            responses['201'] = [
                    description: 'Created - Sucessful creation',
                    content    : ['application/json': [schema: [$ref: "#/components/schemas/$tag"]]]
            ]
            description = "Create a new $tag"
        } else if (actionName == 'update' && methodName == PUT) {
            responses['200'] = [
                    description: 'OK - Sucessful update',
                    content    : ['application/json': [schema: [$ref: "#/components/schemas/$tag"]]]
            ]
            description = "Update the $tag located at this URL"
        } else if (actionName == 'delete' && methodName == DELETE) {
            responses['204'] = [$ref: '#/components/responses/204-DELETE']
            description = "Delete the $tag located at this URL"
        } else if (actionName == 'show' && methodName == GET) {
            responses['200'] = [
                    description: 'OK - Sucessful get',
                    content    : ['application/json': [schema: [$ref: "#/components/schemas/$tag"]]]
            ]
            description = "Get the $tag located at this URL"
        } else if (actionName == 'index' && methodName == GET) {
            responses['200'] = [
                    description: 'OK - Sucessful list',
                    content    : ['application/json': [schema: [type: 'array', items: [$ref: "#/components/schemas/$tag"]]]]
            ]
            description = "Get the list of $tag"
        } else {
            responses['200'] = [$ref: '#/components/responses/200']
            description = ''
        }
        responses.putAll([
                '400': [$ref: '#/components/responses/400'],
                '401': [$ref: '#/components/responses/401'],
                '403': [$ref: '#/components/responses/403'],
                '404': [$ref: '#/components/responses/404'],
                '500': [$ref: '#/components/responses/500']
        ])
        def methodDescription = [
                tags   : [tag],
                summary: description
        ]
        if (constraints) {
            methodDescription.parameters = constraints.collect { constraint ->
                def parameterName = getParameterName(constraint.propertyName, fixedParameters)
                def parameter = [
                        name       : parameterName,
                        description: getParameterDescription(tag, parameterName),
                        in         : 'path',
                        required   : true
                ]
                if (constraint.matches == '\\d*') {
                    parameter.schema = getTypeLong()
                } else {
                    parameter.schema = [type: 'string']
                    if (constraint.inList) {
                        parameter.schema.enum = constraint.inList
                    }
                }
                return parameter
            }
        }
        if (requestBody) {
            methodDescription.requestBody = requestBody
        }
        methodDescription.responses = responses
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
            } else if (i > 0 || token != 'ws') {
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

    private Map getObjectSchema(String tag) {
        def object = [type: 'object']
        def schemas = [
                acceptanceTest: [
                        properties: [
                                id         : getTypeLong(),
                                uid        : getTypeInt(),
                                name       : getTypeString(),
                                description: getTypeString(1000),
                                state      : getTypeIntEnum(AcceptanceTest.AcceptanceTestState.values()*.id),
                                parentStory: [type: 'object', properties: [id: getTypeLong()]],
                                rank       : getTypeRank(),
                        ],
                        required  : ['name', 'parentStory']
                ]
        ]
        if (schemas.containsKey(tag)) {
            object.putAll(schemas[tag])
        }
        return object
    }

    private Map getTypeLong() {
        return [type: 'integer', format: 'int64']
    }

    private Map getTypeInt() {
        return [type: 'integer', format: 'int32']
    }

    private Map getTypeIntEnum(List enumValues) {
        return [type: 'integer', enum: enumValues]
    }

    private Map getTypeString(Integer maxLength = 255) {
        return [type: 'string', maxLength: maxLength]
    }

    private Map getTypeRank() {
        def typeRank = getTypeInt()
        typeRank.put('minimum', 1)
        return typeRank
    }
}
