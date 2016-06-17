/*
 * Copyright (c) 2014 Kagilum SAS.
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

package org.icescrum.web.presentation.windows

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story
import org.icescrum.core.exception.ControllerExceptionHandler

import static grails.async.Promises.task

@Secured('inProduct() or stakeHolder()')
class FeatureController implements ControllerExceptionHandler {

    def featureService
    def springSecurityService
    def grailsApplication

    def index(long product) {
        def features = Feature.searchAllByTermOrTag(product, params.term).sort { Feature feature -> feature.rank }
        render(status: 200, text: features as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def show() {
        def features = Feature.withFeatures(params)
        def returnData = features.size() > 1 ? features : features.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def save(long product) {
        def featureParams = params.feature
        if (!featureParams){
            returnError(code:'todo.is.ui.no.data')
            return
        }
        def feature = new Feature()
        Feature.withTransaction {
            bindData(feature, featureParams, [include:['name','description','notes','color','type','value','rank']])
            feature.tags = featureParams.tags instanceof String ? featureParams.tags.split(',') : (featureParams.tags instanceof String[] || featureParams.tags instanceof List) ? featureParams.tags : null
            def _product = Product.load(product)
            featureService.save(feature, _product)
            entry.hook(id:"${controllerName}-${actionName}", model:[feature:feature]) // TODO check if still needed
            render(status: 201, contentType: 'application/json', text: feature as JSON)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update() {
        List<Feature> features = Feature.withFeatures(params)
        def featureParams = params.feature
        if (!featureParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        features.each { Feature feature ->
            Feature.withTransaction {
                bindData(feature, featureParams, [include: ['name', 'description', 'notes', 'color', 'type', 'value', 'rank']])
                if (featureParams.tags != null) {
                    feature.tags = featureParams.tags instanceof String ? featureParams.tags.split(',') : (featureParams.tags instanceof String[] || featureParams.tags instanceof List) ? featureParams.tags : null
                }
                featureService.update(feature)
                entry.hook(id: "${controllerName}-${actionName}", model: [feature: feature]) // TODO check if still needed
            }
        }
        def returnData = features.size() > 1 ? features : features.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete() {
        Feature.withTransaction {
            def features = Feature.withFeatures(params)
            features.each { feature ->
                featureService.delete(feature)
            }
            def returnData = features.size() > 1 ? features.collect {[id : it.id]} : (features ? [id: features.first().id] : [:])
            render(status: 200, text: returnData as JSON)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def copyToBacklog() {
        List<Feature> features = Feature.withFeatures(params)
        List<Story> stories = featureService.copyToBacklog(features)
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text:returnData as JSON)

    }

    def productParkingLotChart() {
        forward(controller: 'project', action: 'productParkingLotChart', params: ['controllerName': controllerName])
    }

    @Secured('isAuthenticated()')
    def print(long product, String format) {
        def _product = Product.withProduct(product)
        def values = featureService.productParkingLotValues(_product)
        def features = _product.features
        if (!features) {
            returnError(code: 'is.report.error.no.data')
        } else {
            return task {
                def data = []
                Feature.withNewSession {
                    features.eachWithIndex { feature, index ->
                        data << [
                                uid: feature.uid,
                                name: feature.name,
                                description: feature.description,
                                notes: feature.notes?.replaceAll(/<.*?>/, ''),
                                rank: feature.rank,
                                type: message(code: grailsApplication.config.icescrum.resourceBundles.featureTypes[feature.type]),
                                value: feature.value,
                                effort: feature.effort,
                                associatedStories: Story.countByFeature(feature),
                                associatedStoriesDone: feature.countDoneStories,
                                parkingLotValue: values[index].value
                        ]
                    }
                }
                renderReport('features', format ? format.toUpperCase() : 'PDF', [[product: _product.name, features: data ?: null]], _product.name)
            }
        }
    }

    @Secured(['permitAll()'])
    def permalink(int uid, long product) {
        Product _product = Product.withProduct(product)
        Feature feature = Feature.findByBacklogAndUid(_product, uid)
        redirect(uri: "/p/$_product.pkey/#/feature/$feature.id")
    }
}
