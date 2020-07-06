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
import org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib
import org.codehaus.groovy.grails.validation.ConstrainedProperty
import org.codehaus.groovy.grails.web.mapping.ResponseCodeUrlMapping
import org.codehaus.groovy.grails.web.mapping.UrlMapping
import org.codehaus.groovy.grails.web.mapping.reporting.UrlMappingsRenderer
import org.icescrum.core.domain.*
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
            def customConfig = it.parameterValues.oapi
            it.urlData.tokens[0] == 'ws' && !customConfig?.hide
        }
        def tags = []
        def paths = new TreeMap<String, Map>()
        restUrlMappings.groupBy { it.controllerName }.each { controllerAttribute, mappings ->
            mappings.each { mapping ->
                def customConfig = mapping.parameterValues.oapi ?: [:]
                def controllerNames = controllerAttribute ? [controllerAttribute != 'scrumOS' ? controllerAttribute : 'server'] : mapping.constraints.find { it.propertyName == 'controller' }.inList
                def actions = mapping.constraints.find { it.propertyName == 'action' }?.inList ?: ['']
                def workspaceTypes = mapping.constraints.find { it.propertyName == 'workspaceType' }?.inList ?: ['']
                workspaceTypes.remove('portfolio') // TMP
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
                        String tag = customConfig.tag ?: controllerName
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
                            methodNames = [customConfig.method ? customConfig.method.toLowerCase() : GET]
                        }
                        Map methods = methodNames.collectEntries { methodName ->
                            def actionName = mapping.actionName ? mapping.actionName[methodName.toUpperCase()] : actionNameFromParameter
//                            if (!isControllerActionExist(controllerName, actionName)) {
//                                throwError(mapping, "Action not found in ${controllerName.capitalize()}Controller: $actionName")
//                            }
                            return [(methodName): getMethodDescription(methodName, actionName, tag, constraints, fixedParameters, customConfig)]
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
        def components = getComponents()
        return [
                openapi     : '3.0.2',
                info        : [
                        title      : 'iceScrum REST API',
                        description: "This documentation lists the endpoints to access iceScrum programmatically through its REST HTTP API.\n\nThis documentation applies to iceScrum **${getApplicationTagLib().meta([name: 'app.version'])}**. If you use your own server (on-premise) then append */api* to its URL to read the corresponding documentation.",
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
                        schemas        : components,
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

    private Map getMethodDescription(String methodName, String actionName, String tag, List<ConstrainedProperty> constraints, Map fixedParameters, Map customConfig) {
        def description
        def responses = [:]
        def requestBody
        def tagObject = components[tag] ? [$ref: "#/components/schemas/$tag"] : [type: 'object']
        if (actionName == 'save' && methodName == POST) {
            requestBody = [
                    content : ['application/json': [schema: [type: 'object', properties: [(tag): tagObject]]]],
                    required: true
            ]
            responses['201'] = [
                    description: 'Created - Sucessful creation',
                    content    : ['application/json': [schema: tagObject]]
            ]
            description = "Create a new $tag"
        } else if (actionName == 'update' && methodName == PUT) {
            responses['200'] = [
                    description: 'OK - Sucessful update',
                    content    : ['application/json': [schema: tagObject]]
            ]
            description = "Update the $tag"
        } else if (actionName == 'delete' && methodName == DELETE) {
            responses['204'] = [$ref: '#/components/responses/204-DELETE']
            description = "Delete the $tag"
        } else if (actionName in ['show', 'uid'] && methodName == GET) {
            responses['200'] = [
                    description: 'OK - Sucessful get',
                    content    : ['application/json': [schema: tagObject]]
            ]
            description = "Get the $tag"
        } else if (actionName == 'index' && methodName == GET) {
            responses['200'] = [
                    description: 'OK - Sucessful list',
                    content    : ['application/json': [schema: [type: 'array', items: tagObject]]]
            ]
            description = "Get the list of $tag"
        } else {
            responses['200'] = [$ref: '#/components/responses/200']
            description = ''
        }
        if (customConfig.requestBody) {
            requestBody = [content: ['application/json': [schema: [type: 'object', properties: customConfig.requestBody]]]]
        }
        if (customConfig.description) {
            description = customConfig.description
        }
        if (customConfig.responses) {
            responses.putAll(customConfig.responses)
        }
        if (customConfig.app) {
            if (description) {
                description += ' - '
            }
            description += 'Requires enabling '
            if (customConfig.app.startsWith('is.ui')) {
                description += 'the ' + getApplicationTagLib().message(code: customConfig.app) + ' App'
            } else {
                description += customConfig.app
            }
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
        if (constraints || customConfig.queryParameters) {
            methodDescription.parameters = []
            if (constraints) {
                methodDescription.parameters.addAll(constraints.collect { constraint ->
                    def parameterName = getParameterName(constraint.propertyName, fixedParameters)
                    def parameter = [
                            name       : parameterName,
                            description: getParameterDescription(tag, parameterName),
                            in         : 'path',
                            required   : true
                    ]
                    if (constraint.matches == '\\d*') {
                        parameter.schema = [type: 'integer']
                    } else {
                        parameter.schema = [type: 'string']
                        if (constraint.inList) {
                            parameter.schema.enum = constraint.inList
                        }
                    }
                    return parameter
                })
            }
            if (customConfig.queryParameters) {
                methodDescription.parameters.addAll(customConfig.queryParameters.collect { queryParameter ->
                    return queryParameter + [in: 'query']
                })
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

    private Map getComponents() {
        return [
                acceptanceTest: [
                        type      : 'object',
                        properties: [
                                id         : getTypeId(),
                                uid        : getTypeUid(),
                                name       : getTypeString(),
                                description: getTypeString(1000),
                                state      : getTypeIntEnum(AcceptanceTest.AcceptanceTestState.values()*.id, AcceptanceTest.AcceptanceTestState.TOCHECK, '1: to check, 5: failed, 10: success'),
                                parentStory: getTypeNestedObject(),
                                rank       : getTypeRank(),
                        ],
                        required  : ['name', 'parentStory']
                ],
                actor         : [
                        type      : 'object',
                        properties: [
                                id  : getTypeId(),
                                uid : getTypeUid(),
                                name: getTypeString(100),
                        ],
                        required  : ['name']
                ],
                availability  : [
                        type      : 'object',
                        properties: [
                                id                  : getTypeId(),
                                sprint              : getTypeNestedObject(true),
                                user                : getTypeNestedObject(true),
                                days                : [type: 'array', items: [type: 'decimal', minimum: 0]],
                                expectedAvailability: [type: 'decimal', readOnly: true]
                        ],
                        required  : ['days']
                ],
                build: [
                        type: 'object',
                        properties: [
                                builtOn: [type: 'string', maxLength: 255, description: 'Name of the CI platform used to generate the build (e.g. Travis)'],
                                jobName: getTypeString(),
                                name: getTypeString(),
                                number: [type: 'integer'],
                                url: getTypeString(),
                                date: getTypeDate(),
                                status: getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.buildStatus*.key, null, '1: success, 5: failed, 10: error, 15: pending, 20: fixed, 25: broken, 30: still, 35: canceled'),
                        ],
                        required: ['builtOn', 'jobName', 'name', 'number', 'url', 'date', 'status']
                ],
                comment       : [
                        type      : 'object',
                        properties: [
                                id         : getTypeId(),
                                body       : [type: 'string'],
                                commentable: [type: 'object', writeOnly: true, properties: [id: [type: 'integer'], 'class': [type: 'string', enum: ['Story', 'Task', 'Feature']]]]
                        ],
                        required  : ['body', 'commentable']
                ],
                event: [
                        type: 'object',
                        properties: [
                                id: getTypeId(),
                                name: getTypeString(100),
                                shape: getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.eventShapes*.key, null, 'circle: 0, cross: 1, diamond: 2, square: 3, triangleUp: 4, triangleDown: 5'),
                                roadmap: getTypeNestedObject(),
                                feature: getTypeNestedObject()
                        ],
                        required: ['name', 'roadmap', 'shape']
                ],
                feature       : [
                        type      : 'object',
                        properties: [
                                id         : getTypeId(),
                                uid        : getTypeUid(),
                                name       : getTypeString(100),
                                description: getTypeString(1000),
                                notes      : getTypeString(3000),
                                tags       : getTypeTags(),
                                color      : getTypeColor('#0067e8'),
                                state      : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.featureStates*.key, Feature.STATE_BUSY, '-1: draft (portfolio), 0: todo, 1: in progress, 2: done', true),
                                type       : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.featureTypes*.key, Feature.TYPE_FUNCTIONAL, '0: functional, 1: enabler'),
                                rank       : getTypeRank(),
                                value      : [type: 'integer', minimum: 0, maximum: 99]
                        ],
                        required  : ['name']
                ],
                hook          : [
                        type      : 'object',
                        properties: [
                                url      : getTypeString(1000),
                                events   : [type: 'array', items: [type: 'string', enum: ['acceptanceTest.create', 'acceptanceTest.delete', 'acceptanceTest.state', 'acceptanceTest.update', 'actor.create', 'actor.delete', 'actor.update', 'availability.create', 'availability.delete', 'availability.update', 'build.create', 'build.delete', 'build.update', 'commit.create', 'commit.delete', 'commit.update', 'event.create', 'event.delete', 'event.update', 'feature.addedComment', 'feature.create', 'feature.delete', 'feature.removedComment', 'feature.update', 'feature.updatedComment', 'meeting.create', 'meeting.delete', 'meeting.update', 'release.create', 'release.delete', 'release.state', 'release.update', 'roadmap.create', 'roadmap.delete', 'roadmap.update', 'sprint.create', 'sprint.delete', 'sprint.state', 'sprint.update', 'story.addedComment', 'story.create', 'story.delete', 'story.removedComment', 'story.state', 'story.update', 'story.updatedComment', 'task.addedComment', 'task.create', 'task.delete', 'task.removedComment', 'task.state', 'task.update', 'task.updatedComment', 'template.create', 'template.delete', 'template.update']]],
                                enabled  : [type: 'boolean', default: true],
                                ignoreSsl: [type: 'boolean', default: false],
                                secret   : getTypeString()
                        ],
                        required  : ['url', 'events']
                ],
                label         : [
                        type      : 'object',
                        properties: [
                                name     : getTypeString(),
                                labelList: getTypeNestedObject(),
                                color    : getTypeColor('#ffffff'),
                                rank     : getTypeRank()
                        ],
                        required  : ['name', 'labelList']
                ],
                labelList     : [
                        type      : 'object',
                        properties: [
                                name         : getTypeString(),
                                itemType     : [type: 'string', enum: ['story', 'task', 'feature']],
                                allowMultiple: [type: 'boolean', default: false]
                        ],
                        required  : ['name', 'itemType']
                ],
                release       : [
                        type      : 'object',
                        properties: [
                                startDate       : getTypeDate(),
                                endDate         : getTypeDate(),
                                name            : getTypeString(),
                                vision          : [type: 'string'],
                                firstSprintIndex: [type: 'integer'],
                                state           : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.releaseStates*.key, Release.STATE_WAIT, '1: todo, 2: in progress, 3: done', true)
                        ],
                        required  : ['startDate', 'endDate', 'name']
                ],
                sprint        : [
                        type      : 'object',
                        properties: [
                                startDate       : getTypeDate(),
                                endDate         : getTypeDate(),
                                parentRelease   : getTypeNestedObject(),
                                goal            : [type: 'string'],
                                retrospective   : [type: 'string'],
                                doneDefinition  : [type: 'string'],
                                deliveredVersion: getTypeString(),
                                state           : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.sprintStates*.key, Sprint.STATE_WAIT, '1: todo, 2: in progress, 3: done', true)
                        ],
                        required  : ['startDate', 'endDate', 'parentRelease']
                ],
                story         : [
                        type      : 'object',
                        properties: [
                                id           : getTypeId(),
                                uid          : getTypeUid(),
                                name         : getTypeString(100),
                                description  : getTypeString(1000),
                                notes        : getTypeString(3000),
                                tags         : getTypeTags(),
                                state        : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.storyStates*.key, Story.STATE_SUGGESTED, '1: suggested (sandbox), 2: accepted (backlog), 3: estimated (backlog), 4: planned (sprint), 5: in progress (sprint), 6: in review (sprint), 7: done (sprint), -1: frozen ("all" backlog)', true),
                                type         : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.storyTypes*.key, Story.TYPE_USER_STORY, '0: user story, 2: defect, 3: technical story, 4: epic story'),
                                rank         : getTypeRank(),
                                feature      : getTypeNestedObject(),
                                dependsOn    : getTypeNestedObject(),
                                creator      : getTypeNestedObject(),
                                parentSprint : getTypeNestedObject(),
                                value        : [type: 'integer', minimum: 0, maximum: 99],
                                effort       : [type: 'number'],
                                affectVersion: [type: 'string'],
                                origin       : [type: 'string'],
                                testState    : getTypeIntEnum(Story.TestState.values()*.id, null, '0: no test, 1: to check, 5: failed, 10: success', true),

                        ],
                        required  : ['name']
                ],
                task          : [
                        type      : 'object',
                        properties: [
                                id         : getTypeId(),
                                uid        : getTypeUid(),
                                name       : getTypeString(100),
                                description: getTypeString(1000),
                                notes      : getTypeString(3000),
                                tags       : getTypeTags(),
                                color      : getTypeColor('#ffcc01'),
                                state      : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.taskStates*.key, Task.STATE_WAIT, '0: todo, 1: in progress, 2: done', true),
                                type       : getTypeIntEnum(Holders.grailsApplication.config.icescrum.resourceBundles.taskTypes*.key, null, '10: recurrent, 11: urgent, null: has a parentStory'),
                                rank       : getTypeRank(),
                                parentStory: getTypeNestedObject(),
                                responsible: getTypeNestedObject(),
                                sprint     : getTypeNestedObject(true),
                                blocked    : [type: 'boolean', default: false],
                                estimation : [type: 'number'],
                                initial    : [type: 'number'],
                                spent      : [type: 'number']
                        ],
                        required  : ['name']
                ]
        ]
    }

    private Map getTypeId() {
        return [type: 'integer', readOnly: true]
    }

    private Map getTypeUid() {
        return [type: 'integer', readOnly: true]
    }

    private Map getTypeTags() {
        return [type: 'array', items: [type: 'string']]
    }

    private Map getTypeIntEnum(List enumValues, defaultValue = null, String description = '', boolean readOnly = false) {
        def type = [type: 'integer', enum: enumValues]
        if (description) {
            type.description = description
        }
        if (readOnly) {
            type.readOnly = true
        }
        if (defaultValue != null
        ) {
            type.default = defaultValue
        }
        return type
    }

    private Map getTypeString(Integer maxLength = 255) {
        return [type: 'string', maxLength: maxLength]
    }

    private Map getTypeRank() {
        return [type: 'integer', minimum: 1]
    }

    private Map getTypeColor(String defaultColor) {
        return [type: 'string', description: 'Hex color starting with #', default: defaultColor]
    }

    private Map getTypeNestedObject(boolean readOnly = false) {
        def type = [type: 'object', properties: [id: [type: 'integer']]]
        if (readOnly) {
            type.readOnly = true
        }
        return type
    }

    private Map getTypeDate() {
        return [type: 'string', format: 'date-time']
    }

    private ApplicationTagLib getApplicationTagLib() {
        Holders.grailsApplication.mainContext.getBean('org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib')
    }
}
