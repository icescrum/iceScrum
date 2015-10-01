/*
 * Copyright (c) 2014 Kagilum SAS
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 *
 */
package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Feed
import org.icescrum.core.domain.User

class HomeController {

    def userService
    def springSecurityService

    def panels(){
        User user= (User)springSecurityService.currentUser
        def userData  = User.findByPreferences(user.preferences)
        def userPreferences =userData.preferences
        def panel=userPreferences.panel
        panel = panel.collect{
            return [id : it.key  , position : it.value]
        }.sort{ it.position }
        render(status: 200, contentType: 'application/json', text: panel  as JSON)

    }
    @Secured('isAuthenticated()')
    def position(String id, String position) {
        if (!id && !position) {
            returnError(text:message(code: 'is.user.preferences.error.panel'))
            return
        }
        try {
            userService.panel((User)springSecurityService.currentUser, id, position)
            render(status: 200)
        } catch (RuntimeException e) {
            returnError(text:message(code: 'is.user.preferences.error.panel'), exception:e)
        }
    }

    @Secured('isAuthenticated()')
    def feed(long id) {
        Feed feed = Feed.findByUserAndId((User)springSecurityService.currentUser, id)
        def connection = new URL(feed.feedUrl).openConnection()
        def xmlFeed = new XmlSlurper().parse(connection.inputStream)
        def channel = xmlFeed.channel
        def jsonFeed = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text(), pubDate: channel.pubDate.text()]]
        channel.item.each { xmlItem ->
            jsonFeed.channel.items.add([item: [link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: xmlItem.pubDate.text()]])
        }
        render(status: 200, contentType: "application/json", text: jsonFeed as JSON)
    }

    @Secured('isAuthenticated()')
    def saveFeed() {
        Feed feed = new Feed()
        try {
            Feed.withTransaction {
                bindData( feed, params.feed, [include: ['feedUrl']])
                 feed.user = springSecurityService.currentUser
                if (! feed.save(flush: true)) {
                    throw new RuntimeException( feed.errors?.toString())
                }
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:  feed as JSON) }
                json { renderRESTJSON(status: 201, text:  feed) }
                xml { renderRESTXML(status: 201, text:  feed) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object:  feed, exception: e)
        }
    }

    @Secured('isAuthenticated()')
    def deleteFeed(long id) {
        try {
            def feedToDelete = Feed.findById(id)
            feedToDelete.delete()
            withFormat {
                html { render(status: 200) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        } catch (RuntimeException e) {
            returnError(exception: e)
        }
    }

    @Secured('isAuthenticated()')
    def feedByUser() {
        def user = springSecurityService.currentUser
        def feedUser = Feed.findAllByUser(user);
        render(status: 200, contentType: 'application/json', text: feedUser as JSON)
    }

    @Secured('isAuthenticated()')
    def allFeeds() {
        def allJsonFeed = []
        def allUserFeed = Feed.findAllByUser((User)springSecurityService.currentUser)
        allUserFeed.collect {
            it.feedUrl
        }.each { url ->
            def connection = new URL(url).openConnection()
            def xmlFeed = new XmlSlurper().parse(connection.inputStream)
            def channel = xmlFeed.channel
            def jsonFeed = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text(), pubDate: channel.pubDate.text()]]
            channel.item.each { xmlItem ->
                jsonFeed.channel.items.add([item: [link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: Date.parse("EEE', 'dd' 'MMM' 'yyyy' 'HH:mm:ss' 'Z", xmlItem.pubDate.text())]])
            }
            allJsonFeed.addAll(jsonFeed.channel.items)
        }
        render(status: 200, contentType: "application/json", text: allJsonFeed as JSON)
    }
}
