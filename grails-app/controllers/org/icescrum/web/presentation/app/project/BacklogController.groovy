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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport

import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.PlanningPokerGame
import org.springframework.web.servlet.support.RequestContextUtils as RCU

@Secured('stakeHolder() or inProduct()')
class BacklogController {
    def storyService
    def springSecurityService

    static ui = true

    static final id = 'backlog'
    static menuBar = MenuBarSupport.productDynamicBar('is.ui.backlog', id, true, 3)
    static window = [title: 'is.ui.backlog', help: 'is.ui.backlog.help', init: 'list', toolbar: true]
    static widget = [title: 'is.ui.backlog', init: 'list', toolbar: false, height: 143]

    static shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],

            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.backlog.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.backlog.ctrla.text'],
            [code: 'is.ui.shortcut.ctrlshiftc.code', text: 'is.ui.shortcut.backlog.ctrlshiftc.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.backlog.space.text']
    ]

    final featureTerm = /feature:(\w)/
    final typeTerm = /type:(\w)/

    def list = {
        def currentProduct = Product.get(params.product)

        def stories = params.term ? Story.findInStoriesAcceptedEstimated(params.long('product'), '%' + params.term + '%').list() : Story.findAllByBacklogAndStateBetween(currentProduct, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED, [cache: true, sort: 'rank'])
        stories = session['widgetsList']?.contains(id) ? stories.findAll {it.state == Story.STATE_ESTIMATED} : stories
        def template = session['widgetsList']?.contains(id) ? 'widget/widgetView' : session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'

        def typeSelect = BundleUtils.storyTypes.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
        def rankSelect = ''

        def maxRank = Story.countAllAcceptedOrEstimated(currentProduct?.id)?.list()[0] ?: 0
        maxRank.times { rankSelect += "'${it + 1}':'${it + 1}'" + (it < maxRank - 1 ? ',' : '') }

        def featureSelect = "'':'${message(code: 'is.ui.sandbox.manage.chooseFeature')}'"

        if (currentProduct.features) {
            featureSelect += ','
            featureSelect += currentProduct.features.collect {v -> "'$v.id':'${v.name.encodeAsHTML().encodeAsJavaScript()}'"}.join(',')
        }

        def suiteSelect = "'?':'?',"
        def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }

        render(template: template, model: [
                stories: stories,
                id: id,
                featureSelect: featureSelect,
                typeSelect: typeSelect,
                suiteSelect: suiteSelect,
                rankSelect: rankSelect],
                user: springSecurityService.currentUser,
                params: [product: params.product])
    }


    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id, id: params.id, product: params.product])
    }

    def print = {
        def user = (User) springSecurityService.currentUser
        def currentProduct = Product.get(params.product)
        def data = []
        def stories = Story.findAllByBacklogAndStateBetween(currentProduct, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED, [cache: true, sort: 'rank'])
        if (!stories) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.report.error.no.data')]] as JSON)
            return
        } else if (params.get) {
            stories.each {
                data << [
                        name: it.name,
                        rank: it.rank,
                        effort: it.effort,
                        description: it.description,
                        notes: wikitext.renderHtml([markup: 'Textile', text: it.notes], null),
                        type: message(code: BundleUtils.storyTypes[it.type]),
                        acceptedDate: it.acceptedDate,
                        estimatedDate: it.estimatedDate,
                        creator: it.creator.firstName + ' ' + it.creator.lastName,
                        feature: it.feature?.name,
                ]
            }
            try {
                session.progress = new ProgressSupport()
                session.progress.updateProgress(99, message(code: 'is.report.processing'))
                def model = [[product: currentProduct.name, stories: data ?: null]]
                def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "") + '-' + 'backlog' + '-' + (g.formatDate(formatName: 'is.date.file'))

                chain(controller: 'jasper',
                        action: 'index',
                        model: [data: model],
                        params: [locale: user?.preferences?.language?:RCU.getLocale(request).toString().substring(0, 2), _format: params.format, _file: 'backlog', _name: fileName])
                session.progress?.completeProgress(message(code: 'is.report.complete'))
            } catch (Exception e) {
                if (log.debugEnabled) e.printStackTrace()
                session.progress.progressError(message(code: 'is.report.error'))
            }
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session?.progress as JSON)
        } else {
            render(template: 'dialogs/report', model: [id: id])
        }
    }
}