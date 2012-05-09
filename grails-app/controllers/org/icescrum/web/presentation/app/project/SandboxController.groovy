/*
 * Copyright (c) 2010 iceScrum Technologies
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

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Sprint

@Secured('stakeHolder() or inProduct()')
class SandboxController {

    def springSecurityService
    def storyService
    def dropImportService
    def securityService

    @Secured('productOwner() and !archivedProduct()')
    def openDialogAcceptAs = {
        def sprint = Sprint.findCurrentSprint(params.long('product')).list()[0]
        render(template: 'dialogs/acceptAs', model: [sprint: sprint])
    }

    def list = {
        def currentProduct = Product.load(params.product)
        def stories = (params.term) ? Story.findInStoriesSuggested(params.long('product'), '%' + params.term + '%').list() : Story.findAllByBacklogAndState(currentProduct, Story.STATE_SUGGESTED, [sort: 'suggestedDate', order: 'desc'])

        def template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
        def typeSelect = BundleUtils.storyTypes.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')

        def featureSelect = "'':'${message(code: 'is.ui.sandbox.manage.chooseFeature')}'"
        if (currentProduct.features) {
            featureSelect += ','
            featureSelect += currentProduct.features.collect {v -> "'$v.id':'${v.name.encodeAsHTML().encodeAsJavaScript()}'"}.join(',')
        }

        def sprint = Sprint.findCurrentSprint(currentProduct.id).list()[0]
        def user = null
        if (springSecurityService.isLoggedIn())
            user = springSecurityService.currentUser
        render(template: template, model: [stories: stories, typeSelect: typeSelect, featureSelect: featureSelect, sprint: sprint, user: user])
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def add = {
        def currentProduct = Product.get(params.product)
        render(template: '/story/manage', model: [
                referrer: controllerName,
                typesLabels: BundleUtils.storyTypes.values().collect {v -> message(code: v)},
                typesKeys: BundleUtils.storyTypes.keySet().asList(),
                featureSelect: currentProduct.features.asList(),
                story: params.story,
                isUsedTemplate: false
        ])
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: controllerName, id: params.id, product: params.product])
    }

    /**
     * Import stories via drag&drop (and more)
     */
    @Secured('isAuthenticated() and !archivedProduct()')
    def dropImport = {
        if (!params.data) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.error.import.no.data')]] as JSON)
            return
        }
        def data = params.data
        def currentProduct = Product.get(params.long('product'))
        // The actual story field available to import
        def mapping = [
                name: 'is.story.name',
                description: 'is.backlogelement.description',
                feature: 'is.feature',
                notes: 'is.backlogelement.notes'
        ]

        def parsedData = dropImportService.parseText(params.data)

        // When the data is dropped
        if (!params.mapping) {
            // If the data submitted is not considered to be a valid table, then
            // we suggest the user to create a new story with the text he has input as a description
            if (!parsedData) {
                render(text: include(action: 'list', params: [product: params.product]))
                render(template: "dialogs/import", model: [data: data])
                return
            } else {
                // if the data is considered valid, then we ask the user to match his columns with
                // the actual mapping
                if (parsedData.columns.size() > 0 && !params.confirm) {

                    def dialog = g.render(template: "dialogs/import", model: [data: data,
                            columns: parsedData.columns,
                            mapping: mapping,
                            matchValues: dropImportService.matchBundle(mapping, parsedData.columns)])

                    render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                    return
                }
            }
        }

        // When the data is validated and the mapping available
        def story = null
        try {
            def currentUserInstance = User.get(springSecurityService.principal.id)
            def propertiesMap
            def stories = []
            for (int i = 0; i < parsedData.count; i++) {
                propertiesMap = [:]

                params.mapping.each {
                    propertiesMap."${it.key}" = parsedData.data."${it.value}" ? parsedData.data."${it.value}"[i] : null
                }
                // Try to find an existing feature if that field is filled
                if (propertiesMap.feature) {
                    propertiesMap.feature = Feature.findByNameLike(propertiesMap.feature.toString(), [cache: true])
                }
                story = new Story(propertiesMap)
                storyService.save(story, currentProduct, currentUserInstance)
                stories << story
            }
            render(status:200, contentType: 'application/json', text: stories as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    def print = {
        def currentProduct = Product.get(params.product)
        def data = []
        def stories = Story.findAllByBacklogAndState(currentProduct, Story.STATE_SUGGESTED, [sort: 'suggestedDate', order: 'desc'])
        if (!stories) {
            returnError(text:message(code: 'is.report.error.no.data'))
            return
        } else if (params.get) {
            stories.each {
                data << [
                        name: it.name,
                        description: it.description,
                        notes: it.notes?.replaceAll(/<.*?>/, ''),
                        type: message(code: BundleUtils.storyTypes[it.type]),
                        suggestedDate: it.suggestedDate,
                        creator: it.creator.firstName + ' ' + it.creator.lastName,
                        feature: it.feature?.name,
                ]
            }
            outputJasperReport('sandbox', params.format, [[product: currentProduct.name, stories: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            render(template: 'dialogs/report')
        }
    }
}
