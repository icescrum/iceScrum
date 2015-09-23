/*
 * Copyright (c) 2015 Kagilum.
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
 * Marwah Soltani (msoltani@kagilum.com)
 *
 */


package org.icescrum.web.presentation.app.project
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Rss

@Secured('isAuthenticated()')
class RssController {

    def springSecurityService

    @Secured('isAuthenticated()')
    def save() {
        Rss rss = new Rss()
        try {
            Rss.withTransaction {
                bindData(rss, params.rss, [include: ['rssUrl']])
                rss.user = springSecurityService.currentUser
                if (!rss.save(flush: true)) {
                    throw new RuntimeException(rss.errors?.toString())
                }
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: rss as JSON) }
                json { renderRESTJSON(status: 201, text: rss) }
                xml { renderRESTXML(status: 201, text: rss) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: rss, exception: e)
        }
    }

    @Secured('isAuthenticated()')
    def rssByUser() {
        def user = springSecurityService.currentUser
        def rssUser = Rss.findAllByUser(user);
        render(status: 200, contentType: 'application/json', text: rssUser as JSON)
    }

    @Secured('isAuthenticated()')
    def getFeed(long id) {
        Rss rss = Rss.findByUserAndId(springSecurityService.currentUser, id)
        def connection = new URL(rss.rssUrl).openConnection()
        def xmlRss = new XmlSlurper().parse(connection.inputStream)
        def channel = xmlRss.channel
        def jsonRss = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text(), pubDate: channel.pubDate.text()]]
        channel.item.each { xmlItem ->
            jsonRss.channel.items.add([item: [link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: xmlItem.pubDate.text()]])
        }
        render(status: 200, contentType: "application/json", text: jsonRss as JSON)
    }


    @Secured('isAuthenticated()')
    def getAllFeeds() {
        def allJsonRss = []
        def allUserRss = Rss.findAllByUser(springSecurityService.currentUser)
        allUserRss.collect {
            it.rssUrl
        }.each { url ->
            def connection = new URL(url).openConnection()
            def xmlRss = new XmlSlurper().parse(connection.inputStream)
            def channel = xmlRss.channel
            def jsonRss = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text(), pubDate: channel.pubDate.text()]]
            channel.item.each { xmlItem ->
                jsonRss.channel.items.add([item: [link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: Date.parse("EEE', 'dd' 'MMM' 'yyyy' 'HH:mm:ss' 'Z", xmlItem.pubDate.text())]])
            }
            allJsonRss.addAll(jsonRss.channel.items)
        }
        render(status: 200, contentType: "application/json", text: allJsonRss as JSON)
    }

    @Secured('isAuthenticated()')
    def delete(long id) {
        try {
            def rssToDelete = Rss.findById(id)
            rssToDelete.delete()
            withFormat {
                html { render(status: 200) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        } catch (RuntimeException e) {
            returnError(exception: e)
        }
    }
}







