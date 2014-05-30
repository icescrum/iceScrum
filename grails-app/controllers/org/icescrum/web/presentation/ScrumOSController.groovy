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

package org.icescrum.web.presentation

import org.icescrum.core.support.ApplicationSupport
import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
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
        def user = springSecurityService.isLoggedIn() ? User.get(springSecurityService.principal.id) : null

        def space = ApplicationSupport.getCurrentSpace(params)
        if (space){
            space.indexScrumOS.delegate = delegate
            space.indexScrumOS(space, user, securityService, springSecurityService)
        }

        //For PO / SM : WRITE - TM / SH : READ
        def products = user ? Product.findAllByRole(user, [BasePermission.WRITE,BasePermission.READ] , [cache:true, max:11], true, false) : []
        def pCount = products?.size()
        def productsLimit = 9
        def browsableProductsCount = request.admin ? Product.count() : ProductPreferences.countByHidden(false,[cache:true])

        def attrs = [user: user,
                     lang: RCU.getLocale(request).toString().substring(0, 2),
                     space:space,
                     browsableProductsExist: browsableProductsCount > 0,
                     moreProductsExist: pCount > productsLimit,
                     productFilteredsList: pCount > productsLimit ? products?.subList(0, productsLimit) : products]
        if (space)
            attrs."$space.name" = space.object
        attrs
    }


    def openWidget = {
        if (!request.xhr){
            redirect(controller: 'scrumOS', action: 'index')
            return
        }

        if (!params.window) {
            returnError(text:message(code: 'is.error.no.widget'))
            return
        }


        def uiRequested = params.window
        def uiDefinition = uiDefinitionService.getDefinitionById(uiRequested)
        if (uiDefinition) {
            def paramsWidget = null
            if (params."$uiDefinition.space") {
                paramsWidget = ApplicationSupport.getCurrentSpace(params,uiDefinition.space)
                if (!paramsWidget){
                    render(status:404)
                    return
                }else{
                    paramsWidget = paramsWidget.params
                }
            }

            def url = createLink(controller: params.window, action: uiDefinition.widget?.init, params: paramsWidget).toString() - request.contextPath
            if (!menuBarSupport.permissionDynamicBar(url)) {
                render(status: 400)
                return
            }

            render is.widget([
                    id: params.window,
                    toolbar: uiDefinition.widget?.toolbar,
                    closeable: uiDefinition.widget?.closeable,
                    sortable: uiDefinition.widget?.sortable,
                    icon: uiDefinition.icon,
                    windowable: uiDefinition.window ? true : false,
                    resizable: uiDefinition.widget?.resizable ?: false,
                    title: message(code: uiDefinition.widget?.title),
                    init: uiDefinition.widget?.init
            ], {})
        } else {
            render(status:404)
        }
    }

    def openWindow = {

        if (!params.window) {
            returnError(text:message(code: 'is.error.no.window'))
            return
        }

        def uiRequested = params.window
        def uiDefinition = uiDefinitionService.getDefinitionById(uiRequested)
        if (uiDefinition) {

            def space = null
            if (uiDefinition.space) {
                space = ApplicationSupport.getCurrentSpace(params,uiDefinition.space)
                if (!space){
                    render(status:404)
                    return
                }
            }

            def url = createLink(controller: params.window, action: params.actionWindow ?: uiDefinition.window?.init, params:space?.params?:null).toString() - request.contextPath

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
                _continue = uiDefinition.window.before(space?.object, params.actionWindow ?: uiDefinition.window?.init)
            }
            if (!_continue){
                render(status:404)
            } else {
                render is.window([
                        window: params.window,
                        spaceName: space?.object?.name,
                        title: message(code: uiDefinition.window?.title),
                        help: message(code: uiDefinition.window?.help),
                        icon: uiDefinition.icon,
                        right: uiDefinition.window?.right,
                        toolbar: uiDefinition.window?.toolbar,
                        printable: uiDefinition.window?.printable,
                        fullScreen: uiDefinition.window?.fullScreen,
                        widgetable: uiDefinition.widget ? true : false,
                        init: params.actionWindow ?: uiDefinition.window?.init
                ], {})
            }
        } else {
            render(status:404)
        }
    }

    def about = {
        def file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_${RCU.getLocale(request)}.xml")
        if (!file.exists()) {
            file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_en.xml")
        }
        render(status: 200, template: "about/index", model: [server:servletContext.getServerInfo(),about: new XmlSlurper().parse(file),errors:grailsApplication.config.icescrum.errors?:false])
    }

    def textileParser = {
        render(text: wikitext.renderHtml([markup: "Textile"], params.data))
    }

    def reportError = {
        try {
            notificationEmailService.send([
                    from: springSecurityService.currentUser?.email?:null,
                    to: grailsApplication.config.icescrum.alerts.errors.to,
                    subject: "[iceScrum][report] Rapport d'erreur",
                    view: '/emails-templates/reportError',
                    model: [error: params.report.stack,
                            comment: params.report.comment,
                            appID: grailsApplication.config.icescrum.appID,
                            ip: request.getHeader('X-Forwarded-For') ?: request.getRemoteAddr(),
                            date: g.formatDate(date: new Date(), formatName: 'is.date.format.short.time'),
                            version: g.meta(name: 'app.version')]
            ]);
            //render(status: 200, contentType: 'application/json', text:message(code: 'is.blame.sended') as JSON)
            render(status: 200)
        } catch (MailException e) {
            returnError(text:message(code: 'is.mail.error'), exception:e)
            return
        } catch (RuntimeException re) {
            returnError(text:message(code: re.getMessage()), exception:re)
            return
        } catch (Exception e) {
            returnError(text:message(code: 'is.mail.error'), exception:e)
            return
        }
    }

    //TODO replace cache when dev finish and clean old code
    //@Cacheable(cache = 'projectCache', keyGenerator = 'projectUserKeyGenerator')
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
        tmpl[1] = tmpl[1].replaceAll('%3F', '?').replaceAll('%3D', '=')
                .replaceAll('<template ', '<script type="text/x-jqote-template" ').replaceAll('</template>', '</script>')
                .replaceAll('<underscore ', '<script type="text/icescrum-template" ').replaceAll('</underscore>', '</script>')
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

    def whatsNew = {
        if (params.hide){
            if(springSecurityService.currentUser?.preferences?.displayWhatsNew){
                springSecurityService.currentUser.preferences.displayWhatsNew = false
            }
            render(status:200)
            return
        }
        def dialog = g.render(template: "about/whatsNew")
        render(status: 200, contentType: 'application/json', text:[dialog:dialog] as JSON)
    }

    @Cacheable(cache = 'applicationCache')
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
