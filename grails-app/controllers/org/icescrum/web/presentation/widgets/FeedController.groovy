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
package org.icescrum.web.presentation.widgets

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Widget

class FeedController {

    def springSecurityService

    @Secured(['isAuthenticated()'])
    def index() {

        def content
        def url = params.url
        User user = springSecurityService.currentUser
        try {
            if(user && params.widgetId) {
                Widget widgetFeed = Widget.findByUserPreferencesAndId(user.preferences, params.long('widgetId'))
                def selectedFeed = widgetFeed.settings.feeds?.find{it -> it.selected }
                if(selectedFeed){
                    content = getFeedContent(selectedFeed.url)
                } else {
                    content  = [items:[]]
                    widgetFeed.settings.feeds?.each { feed ->
                        content.items.addAll(getFeedContent(feed.url).items)
                    }
                }
            }
            if (content){
                render(status: 200, contentType: "application/json", text: content as JSON)
            } else {
                render(status: 204)
            }
        } catch (Exception e) {
            def text = '<a target="_blank" href="' + url + '">' + url + '</a><br/>' + message(code: 'todo.is.ui.panel.feed.error')
            returnError(text: text, exception: e, silent: true)
        }
    }

    private static getFeedContent(def url){
        def channel = new XmlSlurper().parse(url).channel
        def contentFeed = [title: channel.title.text(), description: channel.description.text()]
        contentFeed.items = channel.item.collect { xmlItem ->
            return [feed: channel.title.text(),
                    link: xmlItem.link.text(),
                    title: xmlItem.title.text(),
                    feedTitle: contentFeed.title,           //repeated for combined feed
                    description: xmlItem.description.text(),
                    pubDate: Date.parse("EEE', 'dd' 'MMM' 'yyyy' 'HH:mm:ss' 'Z", xmlItem.pubDate.text()).time]
        }
        return contentFeed
    }
}
