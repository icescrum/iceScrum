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

package org.icescrum.web.presentation.app.project

import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story

import static grails.async.Promises.task

@Secured('inProduct() or stakeHolder()')
class FeatureController {

    def featureService
    def springSecurityService

    def index() {
        def features = Feature.searchAllByTermOrTag(params.long('product'), params.term).sort { Feature feature -> feature.rank }
        withFormat{
            html { render(status: 200, text: features as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text:features) }
            xml  { renderRESTXML(text:features) }
        }
    }

    @Secured('isAuthenticated()')
    def show(long id, long product) {
        Feature feature = Feature.withFeature(product, id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: feature as JSON }
            json { renderRESTJSON(text: feature) }
            xml { renderRESTXML(text: feature) }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def save() {
        def featureParams = params.feature
        if (!featureParams){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        def feature = new Feature()
        try {
            Feature.withTransaction {
                bindData(feature, featureParams, [include:['name','description','notes','color','type','value','rank']])
                feature.tags = featureParams.tags instanceof String ? featureParams.tags.split(',') : (featureParams.tags instanceof String[] || featureParams.tags instanceof List) ? featureParams.tags : null
                def product = Product.load(params.long('product'))
                featureService.save(feature, product)
                entry.hook(id:"${controllerName}-${actionName}", model:[feature:feature]) // TODO check if still needed
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: feature as JSON) }
                    json { renderRESTJSON(text: feature, status: 201) }
                    xml { renderRESTXML(text: feature, status: 201) }
                }
            }
        } catch (RuntimeException e) {
            returnError(exception:e, object:feature)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update() {
        List<Feature> features = Feature.withFeatures(params)
        def featureParams = params.feature
        if (!featureParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
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
        withFormat {
            html { render status: 200, contentType: 'application/json', text:returnData as JSON }
            json { renderRESTJSON(text:returnData) }
            xml  { renderRESTXML(text:returnData) }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete() {
        Feature.withTransaction {
            def features = Feature.withFeatures(params)
            features.each { feature ->
                featureService.delete(feature)
            }
            def data = features.size() > 1 ? features.collect {[id : it.id]} : (features ? [id: features.first().id] : [:])
            withFormat {
                html { render(status: 200, text: data as JSON)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def copyToBacklog() {
        List<Feature> features = Feature.withFeatures(params)
        List<Story> stories = featureService.copyToBacklog(features)
        withFormat {
            def returnData = stories.size() > 1 ? stories : stories.first()
            html { render(status: 200, contentType: 'application/json', text:returnData as JSON) }
            json { renderRESTJSON(text:returnData, status:201) }
            xml  { renderRESTXML(text:returnData, status:201) }
        }
    }

    def productParkingLotChart() {
        forward controller: 'project', action: 'productParkingLotChart', params: ['controllerName': controllerName]
    }

    @Secured('isAuthenticated()')
    def print(long product, String format) {
        def _product = Product.get(product)
        def values = featureService.productParkingLotValues(_product)
        def features = _product.features
        if (!features) {
            returnError(text:message(code: 'is.report.error.no.data'))
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
                                type: message(code: BundleUtils.featureTypes[feature.type]),
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

    @Secured('productOwner() and !archivedProduct()')
    def attachments(long id, long product) {
        Feature feature = Feature.withFeature(product, id)
        manageAttachmentsNew(feature)
    }

    @Secured(['permitAll()'])
    def permalink(long id, long product){
        Feature feature = Feature.withFeature(product, id)
        redirect(uri:"/p/$feature.backlog.pkey/#/feature/$feature.id")
    }

    @Secured('isAuthenticated()')
    def view() {
        render(template: "view")
    }
}
