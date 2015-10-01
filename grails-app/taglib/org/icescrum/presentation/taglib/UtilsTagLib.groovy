/*
 * Copyright (c) 2014 Kagilum SAS.
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

package org.icescrum.presentation.taglib

import org.icescrum.core.ui.UiDefinition
import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.utils.BundleUtils
import org.apache.commons.lang.StringEscapeUtils
import groovy.xml.MarkupBuilder
import org.springframework.validation.Errors

class UtilsTagLib {

    static returnObjectForTags = ['internationalizeValues', 'exportFormats', 'getMenuBarFromUiDefinitions']

    static namespace = 'is'

    def grailsApplication
    def uiDefinitionService
    def menuBarSupport

    def loadJsVar = { attrs, body ->

        def current = pageScope.variables?.space ? pageScope.space.object : null
        def p = current ? pageScope.space.params : [:]
        def locale = attrs.locale ? attrs.locale : RCU.getLocale(request).toString()
        def jsCode = """var icescrum = {
                          grailsServer:"${grailsApplication.config.grails.serverURL}",
                          baseUrl: "${createLink(controller: 'scrumOS')}",
                          versionUrl: "${createLink(controller: 'scrumOS', action:'version')}",
                          baseUrlSpace: ${p ? '\'' + createLink(controller: 'scrumOS', params: p, mapping:'baseUrl'+pageScope.variables.space.name.capitalize()) + '/\'' : null},
                          urlOpenWindow:"${createLink(controller: 'scrumOS', action: 'openWindow', params: p)}",
                          deleteConfirmMessage:"${message(code: 'is.confirm.delete').encodeAsJavaScript()}",
                          cancelFormConfirmMessage:"${message(code: 'is.confirm.cancel.form').encodeAsJavaScript()}",
                          more:"${message(code: 'is.menu.more').encodeAsJavaScript()}",
                          uploading:"${message(code:'is.upload.inprogress.wait').encodeAsJavaScript()}",
                          locale:'${locale}'
                };"""
        out << g.javascript(null, jsCode)
    }

    def changeRank = { attrs, body ->

        attrs.addParams = "params = jQuery.extend({}, params, ${attrs.params as JSON});"
        out << """\$.icescrum.changeRank(${attrs.selector ? '\'' + attrs.selector + '\'' : 'container'}, this, ${attrs.ui ?: 'ui.item'}, '${attrs.name?:'position'}',function(params, ui) { ${ attrs.addParams ?: '' }
    ${
            remoteFunction(
                    action: attrs.action,
                    controller: attrs.controller,
                    id: attrs.id,
                    params: 'params',
                    onSuccess: attrs.onSuccess,
                    onFailure: "\$(ui).sortable(\"cancel\"); ${ attrs.onFailure?:'' }" )
        }})"""
    }

    def header = { attrs, body ->
        def menus = getMenuBarFromUiDefinitions()
        out << g.render(template: '/scrumOS/header',
                model: [
                        menus: menus.visible.sort{ it.position },
                        menusHidden: menus.hidden.sort{ it.position },
                        importEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                        exportEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                        creationProjectEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                ]
        )
    }

    def exportFormats = { attrs, body ->
        def exportFormats = uiDefinitionService.getDefinitionById(controllerName).exportFormats
        if (exportFormats instanceof Closure){
            exportFormats.delegate = delegate
            exportFormats.resolveStrategy = Closure.DELEGATE_FIRST
            exportFormats = exportFormats()
        }
        entry.hook(id:"${controllerName}-getExportFormats", model:[exportFormats:exportFormats])
        return exportFormats
    }

    def internationalizeValues = { attrs ->
        Map internationalizedMap = [:]
        attrs.map.collect { k, v -> internationalizedMap[k] = message(code: v) }
        return internationalizedMap
    }

    def bundleLocaleToJs = { attrs ->
        assert attrs.bundle
        def val = [:]
        attrs.bundle.each {
            val."${it.key}" = attrs.code ? [value:message(code: it.value), code:it.value.split(/\./).last()] : message(code: it.value)
        }
        out << "${val as JSON}"
    }

    def errors = {
        def trueError = grailsApplication.config.icescrum.errors?.find{ it.error }
        if (grailsApplication.config.icescrum.errors){
            out << """<a class="show-warning" ng-click="showAbout()" href tooltip-append-to-body="true" tooltip-placement="right" tooltip="${g.message(code:'is.warning')}"><i class="text-danger fa ${trueError ? 'fa-warning' : 'fa-cloud-download'}"></i></a>"""
        }
    }

    def appId = {
        out << grailsApplication.config.icescrum.appID
    }

    //TODO REMOVE
    def bundle = {attrs, body ->
        out << g.message(code: BundleUtils."${attrs.bundle}".get(attrs.value))
    }

    //TODO REMOVE
    def onStream = { attrs ->
        if (request.noPush){
            return
        }
        def jqCode = ""
        attrs.events.each { it ->
            def events = [];
            it.events.each { event ->
                events << event + '_' + it.object + '.stream'
            }
            jqCode += "jQuery(${attrs.on? '\''+attrs.on+'\'' : 'document.body' }).bind('${events.join(' ')}',function(event,${it.object}){ "
            jqCode += "var type = event.type.split('_')[0];"
            def callback = attrs.callback ?: "jQuery.icescrum.${it.object}[type].apply(${it.object}${attrs.template ? ",['" + attrs.template + "']" : ''});"
            jqCode += attrs.constraint ? " if ( ${attrs.constraint} ) { $callback }" : callback
            jqCode += "});"
        }
        out << jq.jquery(null, jqCode)
    }

    /**
     * Loops through each error and renders it using one of the supported mechanisms (defaults to "list" if unsupported).
     *
     * @attr bean REQUIRED The bean to check for errors
     * @attr field The field of the bean or model reference to check
     * @attr model The model reference to check for errors
     */
    def renderErrors = { attrs, body ->
        def renderAs = attrs.remove('as')
        if (!renderAs) renderAs = 'list'

        if (renderAs == 'list') {
            def codec = attrs.codec ?: 'HTML'
            if (codec == 'none') codec = ''

            out << "<ul>"
            out << eachErrorInternal(attrs, {
                out << "<li>${message(error:it, encodeAs:codec)}</li>"
            })
            out << "</ul>"
        }
        else if (renderAs.equalsIgnoreCase("json")) {
            def errors = []
            eachErrorInternal(attrs, {
                    errors << [error:[object: it.objectName,field: it.field, message: message(error:it)?.toString(),'rejected-value': StringEscapeUtils.escapeXml(it.rejectedValue.toString())]]
                })
            out << (errors as JSON).toString()
        }
        else if (renderAs.equalsIgnoreCase("xml")) {
            def mkp = new MarkupBuilder(out)
            mkp.errors() {
                eachErrorInternal(attrs, {
                    error(object: it.objectName,
                          field: it.field,
                          message: message(error:it)?.toString(),
                            'rejected-value': StringEscapeUtils.escapeXml(it.rejectedValue.toString()))
                })
            }
        }
    }

    def eachErrorInternal(attrs, body, boolean outputResult = false) {
        def errorsList = extractErrors(attrs)
        def var = attrs.var
        def field = attrs.field

        def errorList = []
        for (errors in errorsList) {
            if (field) {
                if (errors.hasFieldErrors(field)) {
                    errorList += errors.getFieldErrors(field)
                }
            }
            else {
                errorList += errors.allErrors
            }
        }

        for (error in errorList) {
            def result
            if (var) {
                result = body([(var):error])
            }
            else {
                result = body(error)
            }
            if (outputResult) {
                out << result
            }
        }

        null
    }

    def extractErrors(attrs) {
        def model = attrs.model
        def checkList = []
        if (attrs.containsKey('bean')) {
            if (attrs.bean) {
                checkList << attrs.bean
            }
        }
        else if (attrs.containsKey('model')) {
            if (model) {
                checkList = model.findAll {it.value?.errors instanceof Errors}.collect {it.value}
            }
        }
        else {
            for (attributeName in request.attributeNames) {
                def ra = request[attributeName]
                if (ra) {
                    def mc = GroovySystem.metaClassRegistry.getMetaClass(ra.getClass())
                    if (ra instanceof Errors && !checkList.contains(ra)) {
                        checkList << ra
                    }
                    else if (mc.hasProperty(ra, 'errors') && ra.errors instanceof Errors && !checkList.contains(ra.errors)) {
                        checkList << ra.errors
                    }
                }
            }
        }

        def resultErrorsList = []

        for (i in checkList) {
            def errors = null
            if (i instanceof Errors) {
                errors = i
            }
            else {
                def mc = GroovySystem.metaClassRegistry.getMetaClass(i.getClass())
                if (mc.hasProperty(i, 'errors')) {
                    errors = i.errors
                }
            }
            if (errors?.hasErrors()) {
                // if the 'field' attribute is not provided then we should output a body,
                // otherwise we should check for field-specific errors
                if (!attrs.field || errors.hasFieldErrors(attrs.field)) {
                    resultErrorsList << errors
                }
            }
        }

        resultErrorsList
    }

    def getMenuBarFromUiDefinitions = { attrs ->
        def splitHidden = attrs.splitHidden != false
        def menus = splitHidden ? [visible:[], hidden:[]] : []
        uiDefinitionService.getDefinitions().each { String id, UiDefinition uiDefinition ->
            def menuBar = uiDefinition.menuBar
            if(menuBar?.spaceDynamicBar) {
                menuBar.show = menuBarSupport.spaceDynamicBar(id, menuBar.defaultVisibility, menuBar.defaultPosition, uiDefinition.space)
            }
            def show = menuBar?.show
            if (show in Closure) {
                show.delegate = delegate
                show = show()
            }

            def menu = [title: message(code:menuBar?.title),
                    id: id,
                    shortcut: "ctrl+${(menus.visible.size() + menus.hidden.size() + 1)}",
                    icon: uiDefinition.icon,
                    position: show instanceof Map ? show.pos.toInteger() ?: 1 : 1]

            if (splitHidden){
                if (show && show.visible) {
                    menus.visible << menu
                } else if (show) {
                    menus.hidden << menu
                }
            } else {
                if (show){
                    menus << menu
                }
            }
        }
        return menus
    }

}