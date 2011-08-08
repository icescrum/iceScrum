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

import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.domain.*
import org.icescrum.core.utils.BundleUtils
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugin.springcache.annotations.CacheFlush

@Secured('inProduct()')
class FeatureController {
    def featureService
    def springSecurityService

    static ui = true

    static final id = 'feature'
    static menuBar = MenuBarSupport.productDynamicBar('is.ui.feature', id, false, 2)
    static window = [title: 'is.ui.feature', help: 'is.ui.feature.help', init: 'list', toolbar: true]
    static widget = [title: 'is.ui.feature', init: 'list', toolbar: true, height: 143]

    static shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.feature.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.feature.ctrla.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.feature.ctrln.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.feature.space.text']
    ]

    @Secured('productOwner()')
    @CacheFlush(caches = 'addStory', cacheResolver = 'projectCacheResolver')
    def save = {
        def feature = new Feature(params.feature as Map)
        try {
            featureService.save(feature, Product.get(params.product))
            this.manageAttachments(feature)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: feature as JSON }
                json { render status: 200, text: feature as JSON }
                xml { render status: 200, text: feature  as XML }
            }
        } catch (RuntimeException e) {
                returnError(exception:e, object:feature)
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner()')
    @CacheFlush(caches = 'addSandbox', cacheResolver = 'projectCacheResolver')
    def update = {
        def msg
        if (!params.long('feature.id')) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        def feature = Feature.getInProduct(params.long('product'),params.long('feature.id')).list()[0]

        if (!feature) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        // If the version is different, the feature has been modified since the last loading
        if (params.long('feature.version') != feature.version) {
            msg = message(code: 'is.stale.object', args: [message(code: 'is.feature')])
            returnError(text:msg)
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
            try {
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
                    render(status: 200, text: [version: version, value: returnValue ?: ''] as JSON)
                }
                def next = null
                if (params.continue) {
                    next = Feature.findByBacklogAndRank(feature.backlog, feature.rank + 1, [cache: true])
                }
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: [feature: feature, next: next?.id ?: null] as JSON }
                    json { render status: 200, text: feature as JSON }
                    xml { render status: 200, text: feature  as XML }
                }
            } catch (RuntimeException e) {
                returnError(exception:e, object:feature)
            } catch (AttachmentException e) {
                returnError(exception:e)
            }
        }
    }

    @Secured('productOwner()')
    def delete = {

        if (!params.id) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        def features = Feature.getAll(params.list('id'))
        if (!features) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        try {
            features.each { feature ->
                featureService.delete(feature)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: ids as JSON }
                json { render status: 200, text: [result:'success'] as JSON }
                xml { render status: 200, text: [result:'success']  as XML }
            }
        } catch (RuntimeException e) {
            returnError(exception:e,text: message(code: 'is.feature.error.linked.story'))
        }
    }

    def list = {

        def features = (params.term && params.term != '') ? Feature.findInAll(params.long('product'), '%' + params.term + '%').list() : Feature.findAllByBacklog(Product.load(params.product), [cache: true, sort: 'rank'])
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
        def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }
        render(template: template, model: [features: features, effortFeature: effortFeature, linkedDoneStories: linkedDoneStories, id: id, typeSelect: typeSelect, rankSelect: rankSelect, suiteSelect: suiteSelect], params: [product: params.product])
    }

    @Secured('productOwner()')
    def rank = {
        def featureMoved = Feature.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!featureMoved) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        def position = params.int('feature.rank')
        if (featureMoved == null || position == null) {
            returnError(text:message(code: 'is.feature.rank.error'))
        }
        if (featureService.rank(featureMoved, position)) {
           withFormat {
                html { render status: 200, text:'success' }
                json { render status: 200, text: featureMoved as JSON }
                xml { render status: 200, text: featureMoved as XML }
            }
        } else {
            returnError(text:message(code: 'is.feature.rank.error'))
        }
    }

    @Secured('productOwner()')
    def add = {
        def currentProduct = Product.get(params.product)
        def valuesList = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

        def rankList = []
        def maxRank = Feature.countByBacklog(currentProduct) + 1
        maxRank.times { rankList << it + 1 }

        render(template: 'window/manage', model: [valuesList: valuesList,
                rankList: rankList.asList(),
                colorsLabels: BundleUtils.colorsSelect.values().collect { message(code: it) },
                colorsKeys: BundleUtils.colorsSelect.keySet().asList(),
                id: id,
                typesNames: BundleUtils.featureTypes.values().collect {v -> message(code: v)},
                typesId: BundleUtils.featureTypes.keySet().asList()
        ])
    }

    @Secured('productOwner()')
    def edit = {

        if (!params.id) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        def feature = Feature.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!feature) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        Product product = (Product) feature.backlog
        def valuesList = PlanningPokerGame.getInteger(product.planningPokerGameType)

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

    @Secured('productOwner()')
    def copyFeatureToBacklog = {
        if (!params.id) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        def feature = Feature.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!feature) {
            returnError(text:message(code: 'is.feature.error.not.exist'))
            return
        }

        try {
            def story = featureService.copyToBacklog(feature)
            withFormat {
                html { render status: 200, text:'success' }
                json { render status: 200, text: story as JSON }
                xml { render status: 200, text: story as XML }
            }
        } catch (RuntimeException e) {
            returnError(text: message(code: 'story.name.unique'), exception:e)
        }
    }

    @Cacheable(cache = "productChartCache", cacheResolver = "projectCacheResolver", keyGenerator= 'localeKeyGenerator')
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
        def user = springSecurityService.currentUser

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
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.report.error.no.data')]] as JSON)
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
            try {
                session.progress = new ProgressSupport()
                session.progress.updateProgress(99, message(code: 'is.report.processing'))
                def model = [[product: currentProduct.name, features: data ?: null]]
                def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "") + '-' + 'features' + '-' + (g.formatDate(formatName: 'is.date.file'))
                chain(controller: 'jasper',
                        action: 'index',
                        model: [data: model],
                        params: [locale: user.preferences.language, _format: params.format, _file: 'features', _name: fileName])
                session.progress?.completeProgress(message(code: 'is.report.complete'))
            } catch (Exception e) {
                if (log.debugEnabled) e.printStackTrace()
                session.progress.progressError(message(code: 'is.report.error'))
            }
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            render(template: 'dialogs/report', model: [id: id])
        }
    }

    private manageAttachments(def feature) {
        def user = springSecurityService.currentUser
        if (feature.id && !params.feature.list('attachments') && feature.attachments*.id.size() > 0) {
            feature.removeAllAttachments()
        } else if (feature.attachments*.id.size() > 0) {
            feature.attachments*.id.each {
                if (!params.feature.list('attachments').contains(it.toString()))
                    feature.removeAttachment(it)
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles)
            feature.addAttachments(user, uploadedFiles)
        session.uploadedFiles = null
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }
}
