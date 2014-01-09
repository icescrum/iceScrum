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
 * Nicolas Noullet (nnoullet@kagilum.com)
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

    @Secured('productOwner() and !archivedProduct()')
    def openDialogAcceptAs = {
        def sprint = Sprint.findCurrentSprint(params.long('product')).list()
        def dialog = g.render(template: 'dialogs/acceptAs', model: [sprint: sprint])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    def index = {
        def story = Story.getInProduct(params.long('product'), params.long('id')).list()
        if (story && story.state == Story.STATE_SUGGESTED) {
            render status: 200, contentType: 'application/json', text: story as JSON
        } else {
            render status: 404
        }
    }

    def list = {
        def currentProduct = Product.load(params.product)
        def stories = Story.searchByTermOrTagInSandbox(currentProduct.id, params.term).sort { Story s1, Story s2 -> s2.suggestedDate <=> s1.suggestedDate }
        def template = params.windowType == 'widget' ? 'widget/widgetView' : params.viewType ? 'window/' + params.viewType : 'window/postitsView'
        def typeSelect = BundleUtils.storyTypes.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')

        def featureSelect = "'':'${message(code: 'is.ui.sandbox.manage.chooseFeature')}'"
        if (currentProduct.features) {
            featureSelect += ','
            featureSelect += currentProduct.features.collect {v -> "'$v.id':'${v.name.encodeAsHTML().encodeAsJavaScript()}'"}.join(',')
        }

        def sprint = Sprint.findCurrentSprint(currentProduct.id).list()
        def user = null
        if (springSecurityService.isLoggedIn())
            user = springSecurityService.currentUser
        render(template: template, model: [stories: stories, typeSelect: typeSelect, featureSelect: featureSelect, sprint: sprint, user: user])
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def add = {
        def currentProduct = Product.get(params.product)

        render(template: '/story/window/manage', model: [
                referrer: controllerName,
                typesLabels: BundleUtils.storyTypes.values().collect {v -> message(code: v)},
                typesKeys: BundleUtils.storyTypes.keySet().asList(),
                featureSelect: currentProduct.features.asList(),
                storiesSelect: Story.findAllByStateGreaterThanEqualsAndBacklog(Story.STATE_SUGGESTED, currentProduct),
                story: params.story
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
                def dialog = g.render(template: "dialogs/import", model: [data: data])
                render(status:200, contentType: 'application/json', text:[dialog:dialog] as JSON)
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
                        uid: it.uid,
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
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
        }
    }

    def right = {
        Product product = Product.get(params.long('product'))
        def storyCount = Story.countByBacklogAndState(product, Story.STATE_SUGGESTED)
        render template: "window/right", model: [product: product, storyCount: storyCount]
    }

    private getExportFormats() {
        def exportFormats = [
                [code:'rtf',name:message(code:'is.report.format.rtf'), params:[product:params.product, format:'RTF']],
                [code:'docx',name:message(code:'is.report.format.docx'), params:[product:params.product, format:'DOCX']],
                [code:'odt',name:message(code:'is.report.format.odt'), params:[product:params.product, format:'ODT']]
        ]
        entry.hook(id:"${controllerName}-getExportFormats", model:[exportFormats:exportFormats])
        return exportFormats
    }
}
