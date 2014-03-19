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

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class FeatureController {

    def featureService
    def springSecurityService

    @Secured('productOwner() and !archivedProduct()')
    def save = {
        if (!params.feature){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        def feature = new Feature()
        try {
            Feature.withTransaction {
                bindData(feature, this.params, [include:['name','description','notes','color','type','value','rank']], "feature")
                feature.tags = params.feature.tags instanceof String ? params.feature.tags.split(',') : (params.feature.tags instanceof String[] || params.feature.tags instanceof List) ? params.feature.tags : null
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
    def update = {
        if (!params.feature){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        withFeature{ Feature feature ->
            Feature.withTransaction {
                bindData(feature, this.params, [include:['name','description','notes','color','type','value','rank']], "feature")
                if (params.feature.tags != null) {
                    feature.tags = params.feature.tags instanceof String ? params.feature.tags.split(',') : (params.feature.tags instanceof String[] || params.feature.tags instanceof List) ? params.feature.tags : null
                }
                featureService.update(feature)
                entry.hook(id:"${controllerName}-${actionName}", model:[feature:feature]) // TODO check if still needed
                withFormat {
                    html { render status: 200, contentType: 'application/json', text:feature as JSON }
                    json { renderRESTJSON(text:feature) }
                    xml  { renderRESTXML(text:feature) }
                }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete = {
        withFeatures{ List<Feature> features ->
            Feature.withTransaction {
                features.each { feature ->
                    featureService.delete(feature)
                }
                withFormat {
                    html { render(status: 200)  }
                    json { render(status: 204) }
                    xml { render(status: 204) }
                }
            }
        }
    }

    @Cacheable(cache = "featuresCache", keyGenerator= 'featuresKeyGenerator')
    def list = {
        def features = Feature.searchAllByTermOrTag(params.long('product'), params.term).sort { Feature feature -> feature.rank }
        withFormat{
            html { render(status: 200, text: features as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text:features) }
            xml  { renderRESTXML(text:features) }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def copyToBacklog = {
        withFeatures{ List<Feature> features ->
            List<Story> stories = featureService.copyToBacklog(features)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:stories as JSON) }
                json { renderRESTJSON(text:stories, status:201) }
                xml  { renderRESTXML(text:stories, status:201) }
            }
        }
    }

    def productParkingLotChart = {
        forward controller: 'project', action: 'productParkingLotChart', params: ['controllerName': controllerName]
    }

    def print = {
        def currentProduct = Product.get(params.product)
        def values = featureService.productParkingLotValues(currentProduct)
        def data = []
        if (!values) {
            returnError(text:message(code: 'is.report.error.no.data'))
            return
        } else if (params.get) {
            currentProduct.features.eachWithIndex { feature, index ->
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
            outputJasperReport('features', params.format, [[product: currentProduct.name, features: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
        }
    }

    @Cacheable(cache = 'featureCache', keyGenerator='featureKeyGenerator')
    def index = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        withFeature{ Feature feature ->
            withFormat {
                json { renderRESTJSON(text:feature) }
                xml { renderRESTXML(text:feature) }
            }
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    @Secured('productOwner() and !archivedProduct()')
    def attachments = {
        withFeature { feature ->
            manageAttachmentsNew(feature)
        }
    }

    // TODO cache
    def view = {
        render(template: "${params.type ?: 'window'}/view")
    }

    // TODO cache
    def right = {
        render template: "window/right", model: [exportFormats: getExportFormats()]
    }

    //@Cacheable(cache = "featuresCache", keyGenerator= 'featuresKeyGenerator')
    def featureEntries = {
        withProduct { product ->
            def featureEntries = product.features.collect { [id: it.id, text: it.name, color:it.color] }
            if (params.term) {
                featureEntries = featureEntries.findAll { it.text.contains(params.term) }
            }
            render status: 200, contentType: 'application/json', text: featureEntries as JSON
        }
    }
}
