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
import grails.plugin.cache.Cacheable
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Story
import org.icescrum.core.error.ControllerErrorHandler

@Secured('inProject() or stakeHolder()')
class FeatureController implements ControllerErrorHandler {

    def featureService
    def springSecurityService
    def grailsApplication

    @Cacheable(value = 'featuresCache')
    def index(long project) {
        def options = [feature: [:]]
        if (params.term) {
            options.term = params.term
        }
        def features = Feature.search(project, options).sort { Feature feature -> feature.rank }
        render(status: 200, text: features as JSON, contentType: 'application/json')
    }

    @Secured('isAuthenticated()')
    def show() {
        def features = Feature.withFeatures(params)
        def returnData = features.size() > 1 ? features : features.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('productOwner() and !archivedProject()')
    def save(long project) {
        def featureParams = params.feature
        if (!featureParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        def feature = new Feature()
        Feature.withTransaction {
            bindData(feature, featureParams, [include: ['name', 'description', 'notes', 'color', 'type', 'value', 'rank']])
            feature.tags = featureParams.tags instanceof String ? featureParams.tags.split(',') : (featureParams.tags instanceof String[] || featureParams.tags instanceof List) ? featureParams.tags : null
            def _project = Project.load(project)
            featureService.save(feature, _project)
            render(status: 201, contentType: 'application/json', text: feature as JSON)
        }
    }

    @Secured('productOwner() and !archivedProject()')
    def update() {
        List<Feature> features = Feature.withFeatures(params)
        def featureParams = params.feature
        if (!featureParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        def tagParams = featureParams.tags instanceof String ? featureParams.tags.split(',') : (featureParams.tags instanceof String[] || featureParams.tags instanceof List) ? featureParams.tags : null
        tagParams = tagParams?.findAll { it } // remove empty tags
        def commonTags
        if (features.size() > 1) {
            features.each { Feature feature ->
                commonTags = commonTags == null ? feature.tags : commonTags.intersect(feature.tags)
            }
        }
        features.each { Feature feature ->
            Feature.withTransaction {
                bindData(feature, featureParams, [include: ['name', 'description', 'notes', 'color', 'type', 'value', 'rank']])
                def oldTags = feature.tags
                if (features.size() > 1) {
                    (tagParams - oldTags).each { tag ->
                        feature.addTag(tag)
                    }
                    (commonTags - tagParams).each { tag ->
                        if (oldTags.contains(tag)) {
                            feature.removeTag(tag)
                        }
                    }
                } else {
                    feature.tags = tagParams
                }
                featureService.update(feature)
            }
        }
        def returnData = features.size() > 1 ? features : features.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('productOwner() and !archivedProject()')
    def delete() {
        Feature.withTransaction {
            def features = Feature.withFeatures(params)
            features.each { feature ->
                featureService.delete(feature)
            }
            def returnData = features.size() > 1 ? features.collect { [id: it.id] } : (features ? [id: features.first().id] : [:])
            render(status: 200, text: returnData as JSON)
        }
    }

    def projectParkingLotChart() {
        forward(controller: 'project', action: 'projectParkingLotChart', params: ['controllerName': controllerName])
    }

    @Secured('isAuthenticated()')
    def print(long project, String format) {
        def _project = Project.withProject(project)
        def values = featureService.projectParkingLotValues(_project)
        if (!values) {
            returnError(code: 'is.report.error.no.data')
        } else {
            def data = values.collect { valueEntry ->
                Feature feature = valueEntry.feature
                return [
                        uid                  : feature.uid,
                        name                 : feature.name,
                        description          : feature.description,
                        notes                : feature.notes?.replaceAll(/<.*?>/, ''),
                        rank                 : feature.rank,
                        type                 : message(code: grailsApplication.config.icescrum.resourceBundles.featureTypes[feature.type]),
                        value                : feature.value,
                        effort               : feature.effort,
                        associatedStories    : Story.countByFeature(feature),
                        associatedStoriesDone: feature.countDoneStories,
                        parkingLotValue      : valueEntry.value
                ]
            }
            renderReport('features', format ? format.toUpperCase() : 'PDF', [[project: _project.name, features: data ?: null]], _project.name)
        }
    }

    @Secured(['permitAll()'])
    def permalink(int uid, long project) {
        Project _project = Project.withProject(project)
        Feature feature = Feature.findByBacklogAndUid(_project, uid)
        if (feature) {
            redirect(uri: "/p/$_project.pkey/#/feature/$feature.id")
        } else {
            redirect(controller: 'errors', action: 'error404')
        }
    }

    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def colors(long project) {
        def results = ['#C6FFA3', '#FFB593', '#F97C81', '#D39661', '#840048', '#FFFFC7', '#548687', '#473335', '#FFB593', '#B0413E', '#E8AE68', '#FFD275', '#A57F60', '#E3A587', '#DB5A42', '#DDFFD9', '#6C4B5E', '#B3679B', '#E3A587', '#DB5A42', '#4281A4', '#9CAFB7', '#88665D', '#E3A587', '#895B1E']
        def _project = Project.withProject(project)
        def usedColor = _project.features?.collect { it ->
            it.color
        }
        def colors = results - usedColor
        Collections.shuffle(colors)
        colors = colors.size() > 8 ? colors.subList(0, 7) : colors
        render(status: 200, contentType: 'application/json', text: colors as JSON)
    }

    protected def indexCacheKey() {
        if (request.getAttribute("_cachedKeyRequest")) {
            return request.getAttribute("_cachedKeyRequest")
        }
        def key = Feature.createCriteria().get {
            eq('backlog.id', params.project.toLong())
            projections {
                count('lastUpdated')
                max('lastUpdated')
            }
        }.join('_')
        request.setAttribute("_cachedKeyRequest", key)
        return key
    }
}
