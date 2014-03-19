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

import grails.plugin.fluxiable.Activity
import org.icescrum.core.ui.UiDefinition
import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.utils.BundleUtils
import org.apache.commons.lang.StringEscapeUtils
import groovy.xml.MarkupBuilder
import org.springframework.validation.Errors
import grails.plugin.springcache.key.CacheKeyBuilder
import org.codehaus.groovy.grails.web.pages.GroovyPageOutputStack
import org.codehaus.groovy.grails.web.pages.FastStringWriter
import grails.plugin.springcache.taglib.ResultAndBuffer

import java.text.SimpleDateFormat

class UtilsTagLib {

    static returnObjectForTags = ['internationalizeValues', 'exportFormats', 'iconActivity']

    static namespace = 'is'

    def grailsApplication
    def springcacheService
    def uiDefinitionService
    def menuBarSupport

    def loadJsVar = { attrs, body ->

        def current = pageScope.variables?.space ? pageScope.space.object : null
        def p = current ? pageScope.space.params : [:]
        def locale = attrs.locale ? attrs.locale : RCU.getLocale(request).toString()
        def jsCode = """var icescrum = {
                          isPro:${ApplicationSupport.isProVersion()},
                          grailsServer:"${grailsApplication.config.grails.serverURL}",
                          baseUrl: "${createLink(controller: 'scrumOS')}",
                          versionUrl: "${createLink(controller: 'scrumOS', action:'version')}",
                          baseUrlSpace: ${p ? '\'' + createLink(controller: 'scrumOS', params: p, mapping:'baseUrl'+pageScope.variables.space.name.capitalize()) + '/\'' : null},
                          urlOpenWidget:"${createLink(controller: 'scrumOS', action: 'openWidget', params: p)}",
                          urlOpenWindow:"${createLink(controller: 'scrumOS', action: 'openWindow', params: p)}",
                          deleteConfirmMessage:"${message(code: 'is.confirm.delete').encodeAsJavaScript()}",
                          cancelFormConfirmMessage:"${message(code: 'is.confirm.cancel.form').encodeAsJavaScript()}",
                          more:"${message(code: 'is.menu.more').encodeAsJavaScript()}",
                          uploading:"${message(code:'is.upload.inprogress.wait').encodeAsJavaScript()}",
                          locale:'${locale}',
                          push:{
                            enable:${grailsApplication.config.icescrum.push.enable?:false},
                            websocket:${grailsApplication.config.icescrum.push.websocket?:false},
                            url:"${createLink(controller: 'scrumOS', absolute: true)}stream/app${p ? '?'+pageScope.space.name+'=' + current.id : '' }"
                          },
                          dialogErrorContent:"<div id=\'dialog\'><form method=\'post\' class=\'box-form box-form-250 box-form-250-legend\'><div  title=\'${message(code: 'is.dialog.sendError.title')}\' class=\' panel ui-corner-all\'><h3 class=\'panel-title\'>${message(code: 'is.dialog.sendError.title')}</h3><p class=\'field-information\'>${message(code: 'is.dialog.sendError.description')}</p><p class=\'field-area clearfix field-noseparator\' for=\'stackError\' label=\'${message(code: 'is.dialog.sendError.stackError')}\'><label for=\'stackError\'>${message(code: 'is.dialog.sendError.stackError')}</label><span class=\'area area-large\' id=\'stackError-field\'><span class=\'start\'></span><span class=\'content\'><textarea id=\'stackError\' name=\'stackError\' ></textarea></span><span class=\'end\'></span></span></p><p class=\'field-area clearfix field-noseparator\' for=\'comments\' label=\'${message(code: 'is.dialog.sendError.comments')}\'><label for=\'comments\'>${message(code: 'is.dialog.sendError.comments')}</label><span class=\'area area-large\' id=\'comments-field\'><span class=\'start\'></span><span class=\'content\'><textarea id=\'comments\' name=\'comments\' ></textarea></span><span class=\'end\'></span></span></p></div></form></div>"
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
                        menus: menus.visible.sort {it.position},
                        menusHidden: menus.hidden.sort {it.position},
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
            val."${it.key}" = message(code: it.value)
        }
        out << "${val as JSON}"
    }

    def timeago = { attrs, body ->
        SimpleDateFormat ISO8601UTC = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        ISO8601UTC.setTimeZone(TimeZone.getTimeZone("UTC"))
        out << "<time class='timeago' datetime='${ISO8601UTC.format(attrs.date)}'>${formatDate([date:attrs.date, formatName:'is.date.format.short.time', timeZone:attrs.timezone?:null])}</time>"
    }

    def cache = { attrs, body ->
        if (attrs.disabled){
            out << body()
            return
        }

        attrs.role = attrs.role ?: true
        attrs.locale = attrs.locale ?: true
        def role = ''

        def key  = new CacheKeyBuilder()
        key.append(attrs.key)

        if (attrs.role){
            if (request.admin) {
                role = 'adm'
            } else {
                if (request.archivedProduct) {
                    role += 'archived'
                } else{
                    if (request.scrumMaster)  {  role += 'scm'  }
                    if (request.teamMember)   {  role += 'tm'  }
                    if (request.productOwner) {  role += 'po'  }
                    if (!role && request.stakeHolder) {  role += 'sh'  }
                }
            }
            role = role ?: 'anonymous'
            key.append(role)
        }

        if (attrs.locale)
            key.append(RCU.getLocale(request).toString().substring(0, 2))

        if (request.customKey){
            key.append(request.customKey)
        }

        def resultAndBuffer = springcacheService.doWithCache(attrs.cache, key.toCacheKey()) {
            def outputStack = GroovyPageOutputStack.currentStack()
            def writer = new FastStringWriter()
            outputStack.push(writer, true)
            def result = body()
            outputStack.pop()
            new ResultAndBuffer(result: result, buffer: writer.buffer)
        }

        GroovyPageOutputStack.currentWriter() << resultAndBuffer.buffer
        out << resultAndBuffer.result
    }

    def errors = {
        def trueError = grailsApplication.config.icescrum.errors?.find{ it.error }
        if (grailsApplication.config.icescrum.errors){
            out << """<a data-ajax="true" href="${createLink(controller:'scrumOS',action:'about')}">
                        <li class='navigation-line warning ${trueError ? 'warning-icon' : 'upgrade-icon'}' title="${g.message(code:'is.warning')}"></li>
                      </a>"""
        }
    }

    //TODO make it work for all codes type
    def iconActivity = { attrs, body ->
        assert attrs.code
        def code = null
        switch (attrs.code){
            case Activity.CODE_SAVE:
                code = "fa fa-plus"
                break
            case Activity.CODE_UPDATE:
                code = "fa fa-edit"
                break
            case Activity.CODE_DELETE:
                code = "fa fa-times"
                break
            case "acceptAs":
                code = "fa fa-thumbs-up"
                break
            default:
                code = ""
                break
        }
        return code
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

    private getMenuBarFromUiDefinitions(boolean splitHidden = true) {
        def menus = splitHidden ? [visible:[], hidden:[]] : []
        uiDefinitionService.getDefinitions().each {String id, UiDefinition uiDefinition ->
            def menuBar = uiDefinition.menuBar
            if(menuBar?.spaceDynamicBar) {
                menuBar.show = menuBarSupport.spaceDynamicBar(id, menuBar.defaultVisibility, menuBar.defaultPosition, uiDefinition.space)
            }
            def show = menuBar?.show
            if (show in Closure) {
                show.delegate = delegate
                show = show()
            }

            def menu = [title: menuBar?.title,
                    id: id,
                    icon: uiDefinition.icon,
                    position: show instanceof Map ? show.pos.toInteger() ?: 1 : 1,
                    widgetable: uiDefinition.widget ? true : false]

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