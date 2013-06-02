/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation

import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.apache.commons.io.FilenameUtils
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.support.ProgressSupport
import org.icescrum.web.upload.AjaxMultipartResolver
import org.springframework.mail.MailException
import org.icescrum.core.domain.Sprint
import grails.plugin.springcache.annotations.Cacheable
import org.springframework.security.acls.domain.BasePermission
import org.icescrum.core.domain.preferences.ProductPreferences
import sun.misc.BASE64Decoder

class ScrumOSController {

    def springSecurityService
    def menuBarSupport
    def notificationEmailService
    def securityService
    def uiDefinitionService
    def grailsApplication
    def servletContext

    def index = {
        def currentUserInstance = null
        if (springSecurityService.isLoggedIn()) {
            currentUserInstance = User.get(springSecurityService.principal.id)
        }
        def currentProductInstance = params.product ? Product.get(params.long('product')) : null

        if (currentProductInstance?.preferences?.hidden && !securityService.inProduct(currentProductInstance, springSecurityService.authentication) && !securityService.stakeHolder(currentProductInstance,springSecurityService.authentication,false)){
            if (springSecurityService.isLoggedIn())
                forward(action:'error403',controller:'errors')
            else{
                forward(action:'error401',controller:'errors')
            }
            return
        }

        if (currentProductInstance && currentUserInstance && !securityService.hasRoleAdmin(currentUserInstance) && currentUserInstance.preferences.lastProductOpened != currentProductInstance.pkey){
            currentUserInstance.preferences.lastProductOpened = currentProductInstance.pkey
            currentUserInstance.save()
        }
        //For PO / SM : WRITE - TM / SH : READ
        def products = currentUserInstance ? Product.findAllByRole(currentUserInstance, [BasePermission.WRITE,BasePermission.READ] , [cache:true, max:11], true, false) : []
        def pCount = products?.size()

        [user: currentUserInstance,
                lang: RCU.getLocale(request).toString().substring(0, 2),
                product: currentProductInstance,
                publicProductsExists: ProductPreferences.countByHidden(false,[cache:true]) ? true : false,
                productFilteredsListCount: pCount,
                productFilteredsList: pCount > 9 ? products?.subList(0,9) : products]
    }


    def openWidget = {
        if (!request.xhr){
            redirect(controller: 'scrumOS', action: 'index')
            return
        }

        if (!params.window) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.no.widget')]] as JSON)
            return
        }


        def uiRequested = params.window
        def uiDefinition = uiDefinitionService.getDefinitionById(uiRequested)
        if (uiDefinition) {
            def paramsWidget = null
            if (params.product) {
                paramsWidget = [product: params.product]
            }

            def url = createLink(controller: params.window, action: uiDefinition.widget?.init, params: paramsWidget).toString() - request.contextPath
            if (!menuBarSupport.permissionDynamicBar(url)) {
                render(status: 400)
                return
            }

            render is.widget([
                    id: params.window,
                    hasToolbar: uiDefinition.widget?.toolbar,
                    closeable: uiDefinition.widget?.closeable,
                    sortable: uiDefinition.widget?.sortable,
                    windowable: uiDefinition.window ? true : false,
                    resizable: uiDefinition.widget?.resizable ?: false,
                    hasTitleBarContent: uiDefinition.widget?.titleBarContent,
                    title: message(code: uiDefinition.widget?.title),
                    init: uiDefinition.widget?.init
            ], {})
        }
    }

    def openWindow = {
        if (!params.window) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.no.window')]] as JSON)
            return
        }
        params.viewType = params.viewType ?: 'postitsView'

        def uiRequested = params.window
        def uiDefinition = uiDefinitionService.getDefinitionById(uiRequested)
        if (uiDefinition) {

            def projectName = null, projectKey = null
            def param = [:]
            def p = null
            if (params.product) {
                p  = Product.get(params.long('product'))
                projectName = p?.name
                projectKey = p?.pkey
                param = [product: params.product]
            }

            if (!request.xhr){
                def fragment = createLink(controller: params.window, action: params.actionWindow ?: uiDefinition.window?.init, params: [product: projectKey]).toString() - createLink(params: [product: projectKey]) - '/'
                redirect(url:createLink(absolute: true, params: [product: projectKey], fragment: fragment))
                return
            }

            def url = createLink(controller: params.window, action: params.actionWindow ?: uiDefinition.window?.init, params: param).toString() - request.contextPath

            if (!menuBarSupport.permissionDynamicBar(url)){
                if (springSecurityService.isLoggedIn()){
                    render(status:403)
                } else {
                    render(status:401, contentType: 'application/json', text:[url:params.window ? '#'+params.window + (params.actionWindow ? '/'+params.actionWindow : '') + (params.id ? '/'+params.id : '') + (params.uid ? '/?uid='+params.uid : '') : ''] as JSON)
                }
                return
            }

            def _continue = true
            if (uiDefinition.window.before){
                uiDefinition.window.before.delegate = delegate
                uiDefinition.window.before.resolveStrategy = Closure.DELEGATE_FIRST
                _continue = uiDefinition.window.before(p, params.actionWindow ?: uiDefinition.window?.init)
            }
            if (!_continue){
                render(status:404)
            } else {
                render is.window([
                        window: params.window,
                        projectName: projectName,
                        title: message(code: uiDefinition.window?.title),
                        help: message(code: uiDefinition.window?.help),
                        shortcuts: uiDefinition.shortcuts,
                        hasToolbar: uiDefinition.window?.toolbar,
                        hasTitleBarContent: uiDefinition.window?.titleBarContent,
                        maximizeable: uiDefinition.window?.maximizeable,
                        closeable: uiDefinition.window?.closeable,
                        widgetable: uiDefinition.widget ? true : false,
                        init: params.actionWindow ?: uiDefinition.window?.init
                ], {})
            }
        }
    }

    def reloadToolbar = {
        if (!params.window) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.no.window.toolbar')]] as JSON)
            return
        }
        def uiRequested = params.window
        def uiDefinition = uiDefinitionService.getDefinitionById(uiRequested)
        if (uiDefinition) {
            forward(controller: params.window, action: 'toolbar', params: params)
        }
    }

    @Secured('isAuthenticated()')
    def upload = {
        def upfile = request.getFile('file')
        def filename = FilenameUtils.getBaseName(upfile.originalFilename)
        def ext = FilenameUtils.getExtension(upfile.originalFilename)
        def tmpF = session.createTempFile(filename, '.' + ext)
        request.getFile("file").transferTo(tmpF)
        if (!session.uploadedFiles)
            session.uploadedFiles = [:]
        session.uploadedFiles["${params."X-Progress-ID"}"] = tmpF.toString()
        log.info "upload done for session: ${session?.id} / fileID: ${params."X-Progress-ID"}"
        render(status: 200)
    }

    @Secured('isAuthenticated()')
    def uploadStatus = {
        log.debug "upload status for session: ${session?.id} / fileID: ${params?."X-Progress-ID" ?: 'null'}"
        if (params."X-Progress-ID" && session[AjaxMultipartResolver.progressAttrName(params."X-Progress-ID")]) {
            if (((ProgressSupport) session[AjaxMultipartResolver.progressAttrName(params."X-Progress-ID")])?.complete) {
                render(status: 200, contentType: 'application/json', text: session[AjaxMultipartResolver.progressAttrName(params."X-Progress-ID")] as JSON)
                session.removeAttribute([AjaxMultipartResolver.progressAttrName(params."X-Progress-ID")])
            } else {
                render(status: 200, contentType: 'application/json', text: session[AjaxMultipartResolver.progressAttrName(params."X-Progress-ID")] as JSON)
            }
        } else {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.upload.error')]] as JSON)
        }
    }

    def about = {
        def locale = RCU.getLocale(request)
        def file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_${locale}.xml")
        if (!file.exists()) {
            file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_en.xml")
        }
        def aboutXml = new XmlSlurper().parse(file)
        def dialog = g.render(template: "about/index", model: [server:servletContext.getServerInfo(),about: aboutXml,errors:grailsApplication.config.icescrum.errors?:false])
        render(status: 200, contentType: 'application/json', text:[dialog:dialog] as JSON)
    }

    def textileParser = {
        if (params.truncate) {
            params.data = is.truncated([size: params.int('truncate')], params.data)
        }
        if (params.withoutHeader) {
            render(text: '<div class="rich-content">'+wikitext.renderHtml([markup: "Textile"], params.data)+'</div>')
        } else {
            render(status: 200, template: 'textileParser')
        }
    }

    def reportError = {
        try {
            notificationEmailService.send([
                    from: springSecurityService.currentUser?.email?:null,
                    to: grailsApplication.config.icescrum.alerts.errors.to,
                    subject: "[iceScrum][report] Rapport d'erreur",
                    view: '/emails-templates/reportError',
                    model: [error: params.stackError,
                            comment: params.comments,
                            appID: grailsApplication.config.icescrum.appID,
                            ip: request.getHeader('X-Forwarded-For') ?: request.getRemoteAddr(),
                            date: g.formatDate(date: new Date(), formatName: 'is.date.format.short.time'),
                            version: g.meta(name: 'app.version')]
            ]);
            render(status: 200, contentType: 'application/json', text: [notice: [text: message(code: 'is.blame.sended'), type: 'notice']] as JSON)
        } catch (MailException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.mail.error')]] as JSON)
            return
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: re.getMessage())]] as JSON)
            return
        } catch (Exception e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.mail.error')]] as JSON)
            return
        }
    }

    @Cacheable(cache = 'projectCache', keyGenerator = 'projectUserKeyGenerator')
    def templates = {
        def currentSprint = null
        def product = null
        if (params.long('product')) {
            product = Product.get(params.product)
            currentSprint = Sprint.findCurrentSprint(product.id).list() ?: null
        }
        def tmpl = g.render(
                template: 'templatesJS',
                model: [id: controllerName,
                        currentSprint: currentSprint,
                        product:product
                ])

        tmpl = "${tmpl}".split("<div class='templates'>")
        tmpl[1] = tmpl[1].replaceAll('%3F', '?').replaceAll('%3D', '=').replaceAll('<script type="text/javascript">', '<js>').replaceAll('</script>', '</js>').replaceAll('<template ', '<script type="text/x-jqote-template" ').replaceAll('</template>', '</script>')
        render(text: tmpl[0] + '<div class="templates">' + tmpl[1], status: 200)
    }

    def saveImage = {
        if (!params.image){
            render(status:404)
            return
        }
        String imageEncoded = URLDecoder.decode(params.image)
        String title = URLDecoder.decode(params.title)
        imageEncoded = imageEncoded.substring(imageEncoded.indexOf("base64,") + "base64,".length(), imageEncoded.length());
        response.contentType = 'image/png'
        ['Content-disposition': "attachment;filename=\"${title+'.png'}\"",'Cache-Control': 'private','Pragma': ''].each {k, v ->
            response.setHeader(k, v)
        }
        response.outputStream << new BASE64Decoder().decodeBuffer(imageEncoded)
    }

    def version = {
        withFormat{
            html {
                render(status:'200', text:g.meta([name:'app.version']))
            }
            xml {
                renderRESTXML(text:[version:g.meta([name:'app.version'])])
            }
            json {
                renderRESTJSON(text:[version:g.meta([name:'app.version'])])
            }
        }
    }
}
