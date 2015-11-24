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

@Secured('isAuthenticated()')
class HomeController {

    def userService
    def springSecurityService

    @Secured(['permitAll()'])
    def panel() {
        User user = (User) springSecurityService.currentUser
        def panelsLeft
        def panelsRight
        if (user) {
            panelsLeft = user.preferences.panelsLeft.collect { return [id: it.key, position: it.value] }.sort { it.position }
            panelsRight = user.preferences.panelsRight.collect { return [id: it.key, position: it.value] }.sort { it.position }
        } else {
            panelsLeft = [[id: 'login']]
            panelsRight = [[id: 'publicProjects']]
        }
        def panels = [panelsLeft: panelsLeft, panelsRight: panelsRight]
        render(status: 200, contentType: 'application/json', text: panels as JSON)
    }

    def updatePanelPosition(String id, String position, Boolean right) {
        if (id == null || position == null || right == null) {
            returnError(text: message(code: 'is.user.preferences.error.panel'))
            return
        }
        try {
            userService.updatePanelPosition((User) springSecurityService.currentUser, id, position, right)
            render(status: 200)
        } catch (RuntimeException e) {
            returnError(text: message(code: 'is.user.preferences.error.panel'), exception: e)
        }
    }

    def saveFeed() {
        Feed feed = new Feed()
        try {
            def connection = new URL(params.feed.feedUrl).openConnection()
            def xmlFeed = new XmlSlurper().parse(connection.inputStream)
            def channel = xmlFeed.channel
            def title = channel.title.text()
            Feed.withTransaction {
                bindData(feed, params.feed, [include: ['feedUrl']])
                feed.user = springSecurityService.currentUser
                feed.title = title
                if (!feed.save(flush: true)) {
                    throw new RuntimeException(feed.errors?.toString())
                }
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: feed as JSON) }
                json { renderRESTJSON(status: 201, text: feed) }
                xml { renderRESTXML(status: 201, text: feed) }
            }
        } catch (RuntimeException e) {
            returnError(object: feed, exception: e)
        } catch (Exception e) {
            returnError(text: message(code: 'todo.is.ui.panel.feed.error'), exception: e)
        }
    }

    def deleteFeed(long id) {
        User user = (User) springSecurityService.currentUser
        try {
            def feedToDelete = Feed.findById(id)
            if (user.preferences.feed == feedToDelete) {
                userService.saveFeed(user, null)
            }
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

    def listFeeds() {
        def user = (User) springSecurityService.currentUser
        def feeds = []
        if (grailsApplication.config.icescrum.feed.default.url != null && grailsApplication.config.icescrum.feed.default.title != null) {
            feeds << [feedUrl: grailsApplication.config.icescrum.feed.default.url, title: grailsApplication.config.icescrum.feed.default.title, id: "defaultFeed"]
        }
        feeds.addAll(Feed.findAllByUser(user));
        render(status: 200, contentType: 'application/json', text: feeds as JSON)
    }

    def userFeed() {
        User user = (User) springSecurityService.currentUser
        def feed
        if (user.preferences.feed != null) {
            feed = user.preferences.feed
        } else if (grailsApplication.config.icescrum.feed.default.url != null && grailsApplication.config.icescrum.feed.default.title != null) {
            feed = [feedUrl: grailsApplication.config.icescrum.feed.default.url, title: grailsApplication.config.icescrum.feed.default.title, id: "defaultFeed"]
        }
        render(status: 200, contentType: 'application/json', text: feed as JSON)
    }

    def contentFeed(long id) {
        User user = (User) springSecurityService.currentUser
        Feed feed = Feed.findByUserAndId(user, id)
        userService.saveFeed(user, feed)
        def urlPath = feed ? feed.feedUrl : grailsApplication.config.icescrum.feed.default.url
        URL url = new URL(urlPath)
        try {
            def connection = url.openConnection()
            def xmlFeed = new XmlSlurper().parse(connection.inputStream)
            def channel = xmlFeed.channel
            def jsonFeed = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text()]]
            channel.item.each { xmlItem ->
                jsonFeed.channel.items.add([item: [link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: Date.parse("EEE', 'dd' 'MMM' 'yyyy' 'HH:mm:ss' 'Z", xmlItem.pubDate.text()).time]])
            }
            render(status: 200, contentType: "application/json", text: jsonFeed as JSON)
        } catch (Exception e) {
            def text = '<a target="_blank" href="' + urlPath + '">' + urlPath + '</a><br/>' + message(code: 'todo.is.ui.panel.feed.error')
            returnError(text: text, exception: e, silent: true)
        }
    }

    def mergedContentFeed() {
        def allJsonFeed = []
        User user = (User) springSecurityService.currentUser
        userService.saveFeed(user, null)
        def allUserFeed = Feed.findAllByUser(user)
        def allUsersFeedUrls = allUserFeed.collect {
            it.feedUrl
        }
        if (grailsApplication.config.icescrum.feed.default.url != null) {
             allUsersFeedUrls << grailsApplication.config.icescrum.feed.default.url
        }
        def currentFeed
        try {
            allUsersFeedUrls.each { url ->
                currentFeed = url
                def connection = new URL(url).openConnection()
                def xmlFeed = new XmlSlurper().parse(connection.inputStream)
                def channel = xmlFeed.channel
                def jsonFeed = [channel: [items: [], title: channel.title.text(), description: channel.description.text(), copyright: channel.copyright.text(), link: channel.link.text(), pubDate: channel.pubDate.text()]]
                channel.item.each { xmlItem ->
                    jsonFeed.channel.items.add([item: [titlefeed: channel.title.text(), link: xmlItem.link.text(), title: xmlItem.title.text(), description: xmlItem.description.text(), pubDate: Date.parse("EEE', 'dd' 'MMM' 'yyyy' 'HH:mm:ss' 'Z", xmlItem.pubDate.text()).time]])
                }
                allJsonFeed.addAll(jsonFeed.channel.items)
            }
            render(status: 200, contentType: "application/json", text: allJsonFeed as JSON)
        } catch (Exception e) {
            def text = '<a target="_blank" href="' + currentFeed + '">' + currentFeed + '</a><br/>' + message(code: 'todo.is.ui.panel.feed.error')
            returnError(text: text, exception: e, silent: true)
        }
    }
}
