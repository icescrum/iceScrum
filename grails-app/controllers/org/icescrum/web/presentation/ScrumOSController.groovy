/*
 * Copyright (c) 2015 Kagilum SAS.
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

import grails.converters.XML
import grails.util.BuildSettingsHolder
import org.icescrum.core.support.ApplicationSupport
import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.springframework.mail.MailException
import org.icescrum.core.domain.Sprint
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
    def messageSource
    def productService

    def index() {
        def user = springSecurityService.isLoggedIn() ? User.get(springSecurityService.principal.id) : null

        def space = ApplicationSupport.getCurrentSpace(params)
        if (space){
            space.indexScrumOS.delegate = this
            space.indexScrumOS(space, user, securityService, springSecurityService)
        }

        def products = user ? productService.getAllActiveProductsByUser().take(10) : []
        def productsLimit = 9
        def moreProductExist = products?.size() > productsLimit
        def browsableProductsCount = request.admin ? Product.count() : ProductPreferences.countByHidden(false,[cache:true])

        def attrs = [user: user,
                     lang: RCU.getLocale(request).toString().substring(0, 2),
                     space:space,
                     browsableProductsExist: browsableProductsCount > 0,
                     moreProductsExist: moreProductExist,
                     productFilteredsList: products.take(productsLimit)]
        if (space) {
            attrs."$space.name" = space.object
        }
        attrs
    }

    def openWindow() {

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
                        icon: uiDefinition.icon,
                        spaceName: space?.object?.name,
                        flex: uiDefinition.window?.flex,
                        details: uiDefinition.window?.details,
                        printable: uiDefinition.window?.printable,
                        fullScreen: uiDefinition.window?.fullScreen,
                        help: message(code: uiDefinition.window?.help),
                        title: message(code: uiDefinition.window?.title),
                        init: params.actionWindow ?: uiDefinition.window?.init
                ], {})
            }
        } else {
            render(status:404)
        }
    }

    def about() {
        def file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_${RCU.getLocale(request)}.xml")
        if (!file.exists()) {
            file = new File(grailsAttributes.getApplicationContext().getResource("/infos").getFile().toString() + File.separatorChar + "about_en.xml")
        }
        render(status: 200, template: "about/index", model: [server:servletContext.getServerInfo(),about: new XmlSlurper().parse(file),errors:grailsApplication.config.icescrum.errors?:false])
    }

    def textileParser() {
        render(text: wikitext.renderHtml([markup: "Textile"], params.data))
    }

    def reportError() {
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
                            version: g.meta(name: 'app.version')],
                    async: true
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

    def templates() {
        def currentSprint = null
        def product = null
        if (params.long('product')) {
            product = Product.get(params.product)
            currentSprint = Sprint.findCurrentSprint(product.id).list() ?: null
        }
        def i18nMessages = messageSource.getAllMessages(RCU.getLocale(request))
        def tmpl = g.render(
                template: 'templatesJS',
                model: [id: controllerName,
                        user:springSecurityService.currentUser,
                        product: product,
                        currentSprint: currentSprint,
                        i18nMessages: i18nMessages as JSON])

        tmpl = "${tmpl}".split("<div class='templates'>")
        tmpl[1] = tmpl[1].replaceAll('%3F', '?').replaceAll('%3D', '=')
                .replaceAll('<template ', '<script type="text/x-jqote-template" ').replaceAll('</template>', '</script>')
                .replaceAll('<underscore ', '<script type="text/icescrum-template" ').replaceAll('</underscore>', '</script>')
        render(text: tmpl[0] + '<div class="templates">' + tmpl[1], status: 200)
    }

    def saveImage() {
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

    def whatsNew() {
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

    def version() {
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

    def progress() {
        if(session.progress) {
            withFormat {
                html {
                    render(status:200, contentType:"application/json", text:session.progress  as JSON)
                }
                xml {
                    render(status:200, contentType:"text/xml", text:session.progress  as XML)
                }
                json {
                    render(status:200, contentType:"application/json", text:session.progress  as JSON)
                }
            }
            //we already sent the error so reset progress
            if (session.progress.error || session.progress.complete){
                session.progress = null
            }
        } else {
            render(status: 404)
        }
    }

    def languages() {
        List locales = []
        def i18n
        if (grailsApplication.warDeployed) {
            i18n = grailsAttributes.getApplicationContext().getResource("WEB-INF/grails-app/i18n/").getFile().toString()
        } else {
            i18n = "$BuildSettingsHolder.settings.baseDir/grails-app/i18n"
        }
        //Default language
        locales << new Locale("en")
        new File(i18n).eachFile {
            def arr = it.name.split("[_.]")
            if (arr[1] != 'svn' && arr[1] != 'properties' && arr[0].startsWith('messages')) {
                locales << (arr.length > 3 ? new Locale(arr[1], arr[2]) : arr.length > 2 ? new Locale(arr[1]) : new Locale(""))
            }
        }
        def returnLocales = locales.collect { locale ->
            [id: locale.toString(), name: locale.getDisplayName(locale).capitalize()]
        }
        render(returnLocales as JSON)
    }

    def timezones() {
        def timezones = TimeZone.availableIDs.sort().findAll {
            it.matches("^(Africa|America|Asia|Atlantic|Australia|Europe|Indian|Pacific)/.*")
        }.collect {
            TimeZone timeZone = TimeZone.getTimeZone(it)
            def offset = timeZone.rawOffset
            def offsetSign = offset < 0 ? '-' : '+'
            Integer hour = Math.abs(offset / (60 * 60 * 1000))
            Integer min = Math.abs(offset / (60 * 1000)) % 60
            def calendar = Calendar.instance
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, min)
            return [id: it, name: "$timeZone.ID (UTC$offsetSign${String.format('%tR', calendar)})"]
        }
        render(timezones as JSON)
    }
}
