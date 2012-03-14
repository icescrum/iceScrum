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
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Story

@Secured('inProduct()')
class FeatureController {
    def featureService
    def springSecurityService

    static final id = 'feature'

    @Secured('productOwner() and !archivedProduct()')
    def save = {
        def feature = new Feature(params.feature as Map)
        try {
            featureService.save(feature, Product.get(params.product))
            this.manageAttachments(feature)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: feature as JSON }
                json { render status: 200, contentType: 'application/json', text: feature as JSON }
                xml { render status: 200, contentType: 'text/xml', text: feature  as XML }
            }
        } catch (RuntimeException e) {
                returnError(exception:e, object:feature)
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update = {
        withFeature('feature.id'){ Feature feature ->
             // If the version is different, the feature has been modified since the last loading
            if (params.long('feature.version') != feature.version) {
                returnError(text:message(code: 'is.stale.object', args: [message(code: 'is.feature')]))
                return
            }

            def successRank = true

            if (params.int('feature.rank') && feature.rank != params.int('feature.rank')) {
                if (!featureService.rank(feature, params.int('feature.rank'))) {
                    successRank = false
                }
            }

            if (successRank) {
                feature.properties = params.feature
                this.manageAttachments(feature)
                featureService.update(feature)

                if (params.table && params.boolean('table')) {
                    def returnValue
                    if (params.name == 'type')
                        returnValue = message(code: BundleUtils.featureTypes[feature.type])
                    else if (params.name == 'description') {
                        returnValue = feature.description?.encodeAsHTML()?.encodeAsNL2BR()
                    }
                    else
                        returnValue = feature."${params.name}".encodeAsHTML()

                    def version = feature.isDirty() ? feature.version + 1 : feature.version
                    render(status: 200, text: [version: version, value: returnValue ?: '', object: feature] as JSON)
                    return
                }
                def next = null
                if (params.continue) {
                    next = Feature.findByBacklogAndRank(feature.backlog, feature.rank + 1, [cache: true])
                }
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: [feature: feature, next: next?.id ?: null] as JSON }
                    json { render status: 200, contentType: 'application/json', text: feature as JSON }
                    xml { render status: 200, contentType: 'text/xml', text: feature  as XML }
                }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete = {
        withFeatures{ List<Feature> features ->
            features.each { feature ->
                featureService.delete(feature)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: ids as JSON }
                json { render status: 200, contentType: 'application/json', text: [result:'success'] as JSON }
                xml { render status: 200, contentType: 'text/xml', text: [result:'success']  as XML }
            }
        }
    }

    def list = {
        def features = (params.term && params.term != '') ? Feature.findInAll(params.long('product'), '%' + params.term + '%').list() : Feature.findAllByBacklog(Product.load(params.product), [cache: true, sort: 'rank'])
        withFormat{
            html {
                def template = (session['widgetsList']?.contains(id)) ? 'widget/widgetView' : session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'

                def currentProduct = Product.get(params.product)
                def maxRank = Feature.countByBacklog(currentProduct)
                def effortFeature = { feature ->
                    feature.stories?.sum {it.effort ?: 0}
                }
                def linkedDoneStories = { feature ->
                    feature.stories?.sum {(it.state == Story.STATE_DONE) ? 1 : 0}
                }
                //Pour la vue tableau
                def rankSelect = ''
                maxRank.times { rankSelect += "'${it + 1}':'${it + 1}'" + (it < maxRank - 1 ? ',' : '') }
                def typeSelect = BundleUtils.featureTypes.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                def suiteSelect = "'?':'?',"

                def currentSuite = PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)

                currentSuite = currentSuite.eachWithIndex { t, i ->
                    suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
                }
                render(template: template, model: [features: features, effortFeature: effortFeature, linkedDoneStories: linkedDoneStories, id: id, typeSelect: typeSelect, rankSelect: rankSelect, suiteSelect: suiteSelect], params: [product: params.product])
            }
            json { render status: 200, contentType: 'application/json', text: features as JSON }
            xml { render status: 200, contentType: 'text/xml', text: features  as XML }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def rank = {
        withFeature{ Feature feature ->
            def position = params.int('feature.rank')
            if (feature == null || position == null) {
                returnError(text:message(code: 'is.feature.rank.error'))
            }
            if (featureService.rank(feature, position)) {
               withFormat {
                    html { render status: 200, text:'success' }
                    json { render status: 200, contentType: 'application/json', text: feature as JSON }
                    xml { render status: 200, contentType: 'text/xml', text: feature as XML }
                }
            } else {
                returnError(text:message(code: 'is.feature.rank.error'))
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def add = {
        def currentProduct = Product.get(params.product)
        def valuesList = PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)

        render(template: 'window/manage', model: [valuesList: valuesList,
                colorsLabels: BundleUtils.colorsSelect.values().collect { message(code: it) },
                colorsKeys: BundleUtils.colorsSelect.keySet().asList(),
                id: id,
                typesNames: BundleUtils.featureTypes.values().collect {v -> message(code: v)},
                typesId: BundleUtils.featureTypes.keySet().asList()
        ])
    }

    @Secured('productOwner() and !archivedProduct()')
    def edit = {
        withFeature{ Feature feature ->
            Product product = (Product) feature.backlog
            def valuesList = PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)

            def rankList = []
            def maxRank = Feature.countByBacklog(product)
            maxRank.times { rankList << (it + 1) }

            def next = Feature.findByBacklogAndRank(product, feature.rank + 1, [cache: true])
            render(template: 'window/manage', model: [valuesList: valuesList,
                    rankList: rankList,
                    id: id,
                    next: next?.id ?: '',
                    colorsLabels: BundleUtils.colorsSelect.values().collect { message(code: it) },
                    colorsKeys: BundleUtils.colorsSelect.keySet().asList(),
                    feature: feature,
                    typesNames: BundleUtils.featureTypes.values().collect {v -> message(code: v)},
                    typesId: BundleUtils.featureTypes.keySet().asList()
            ])
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def copyFeatureToBacklog = {
        withFeature{ Feature feature ->
            def story = featureService.copyToBacklog(feature)
            withFormat {
                html { render status: 200, text:'success' }
                json { render status: 200, contentType: 'application/json', text: story as JSON }
                xml { render status: 200, contentType: 'text/xml', text: story as XML }
            }
        }
    }

    @Cacheable(cache = "projectCache", keyGenerator= 'featuresKeyGenerator')
    def productParkingLotChart = {
        def currentProduct = Product.get(params.product)
        def values = featureService.productParkingLotValues(currentProduct)
        def indexF = 1
        def valueToDisplay = []
        values.value?.each {
            def value = []
            value << it.toString()
            value << indexF
            valueToDisplay << value
            indexF++
        }
        if (valueToDisplay.size() > 0)
            render(template: 'charts/productParkinglot', model: [
                    id: id,
                    withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
                    values: valueToDisplay as JSON,
                    featuresNames: values.label as JSON])
        else {
            returnError(text: message(code: 'is.chart.error.no.values'))
        }
    }

    def print = {
        def currentProduct = Product.get(params.product)
        def values = featureService.productParkingLotValues(currentProduct)
        def data = []
        def effortFeature = { feature ->
            feature.stories?.sum {it.effort ?: 0}
        }
        def linkedDoneStories = { feature ->
            feature.stories?.sum {(it.state == Story.STATE_DONE) ? 1 : 0}
        }
        if (!values) {
            returnError(text:message(code: 'is.report.error.no.data'))
            return
        } else if (params.get) {
            currentProduct.features.eachWithIndex { feature, index ->
                data << [
                        name: feature.name,
                        description: feature.description,
                        notes: feature.notes?.replaceAll(/<.*?>/, ''),
                        rank: feature.rank,
                        type: feature.type,
                        value: feature.value,
                        effort: effortFeature(feature),
                        associatedStories: Story.countByFeature(feature),
                        associatedStoriesDone: linkedDoneStories(feature),
                        parkingLotValue: values[index].value
                ]
            }
            outputJasperReport('features', params.format, [[product: currentProduct.name, features: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            render(template: 'dialogs/report', model: [id: id])
        }
    }

    @Cacheable(cache = 'featureCache', keyGenerator='featureKeyGenerator')
    def show = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }

        withFeature{ Feature feature ->
            withFormat {
                json { render(status: 200, contentType: 'application/json', text: feature as JSON) }
                xml { render(status: 200, contentType: 'text/xml', text: feature as XML) }
            }
        }
    }

    private manageAttachments(def feature) {
        def user = springSecurityService.currentUser
        def needPush = false

        if (feature.id && !params.feature.list('attachments') && feature.attachments*.id.size() > 0) {
            feature.removeAllAttachments()
            needPush = true
        } else if (feature.attachments*.id.size() > 0) {
            feature.attachments*.id.each {
                if (!params.feature.list('attachments').contains(it.toString()))
                    feature.removeAttachment(it)
                    needPush = true
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles){
            feature.addAttachments(user, uploadedFiles)
            needPush = true
        }
        session.uploadedFiles = null

        if (needPush){
            feature.lastUpdated = new Date()
            broadcast(function: 'update', message: feature)
        }
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }
}
