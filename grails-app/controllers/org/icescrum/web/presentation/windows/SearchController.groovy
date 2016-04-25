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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.windows

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import grails.plugin.springsecurity.annotation.Secured

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class SearchController {

    def springSecurityService

    def index(long product) {
        Product _product = Product.withProduct(product)
        def data = [:]

        data.actors =  Actor.search(product, [tag:params.tag, term:params.term, actor: params.withActors ? params.actor : null])
        data.stories = Story.search(product, [tag:params.tag, term:params.term, story: params.withStories ? params.story : null])
        data.features = Feature.search(product, [tag:params.tag, term:params.term, feature: params.withFeatures ? params.feature : null])
        data.tasks = Task.search(product, [tag:params.tag, term:params.term, task: params.withTasks ? params.task : null])

        if (!data.actors && !data.stories && !data.features && !data.tasks && !params.term && !params.tag && !params.withActors && !params.withStories && !params.withFeatures && !params.withTasks){
            data = null
        }

        withFormat{
            html {
                render(template: 'window/postitsView', model: [
                        data: data,
                        user:(User)springSecurityService.currentUser,
                        estimates:_product.stories*.effort.unique().findAll { it != null }.sort(),
                        creators:(_product.allUsers + _product.stories*.creator.unique()).unique(),
                        tasksCreators:(_product.allUsers + Task.getAllCreatorsInProduct(_product.id)).unique(),
                        tasksResponsibles:(_product.allUsers + Task.getAllResponsiblesInProduct(_product.id)).unique(),
                        product:_product])
            }
            json { renderRESTJSON(text:data) }
            xml  { renderRESTXML(text:data) }
        }
    }

    def tag(long product) {
        Product _product = Product.withProduct(product)
        if ((_product.preferences.hidden && !request.inProduct) || (!_product.preferences.hidden && !springSecurityService.isLoggedIn())){
            render status:403, text:''
            return
        }
        String findTagsByTermAndProduct = """SELECT DISTINCT tagLink.tag.name
                   FROM org.grails.taggable.TagLink tagLink
                   WHERE (
                            tagLink.tagRef IN (SELECT story.id From Story story where story.backlog.id = :product)
                          OR tagLink.tagRef IN (SELECT feature.id From Feature feature where feature.backlog.id = :product)
                          OR tagLink.tagRef IN (SELECT actor.id From Actor actor where actor.backlog.id = :product)
                   )
                   AND tagLink.tag.name LIKE :term
                   ORDER BY tagLink.tag.name"""

        String findTagsByTermAndProductInTasks = """SELECT DISTINCT tagLink.tag.name
                   FROM Task task, org.grails.taggable.TagLink tagLink
                   WHERE task.id = tagLink.tagRef
                   AND tagLink.type = 'task'
                   AND task.backlog.id IN (select sprint.id from Sprint sprint, Release release WHERE sprint.parentRelease.id = release.id AND release.parentProduct.id = :product)
                   AND tagLink.tag.name LIKE :term
                   ORDER BY tagLink.tag.name"""

        def term = params.term
        if (params.withKeyword) {
            if (BacklogElement.hasTagKeyword(term)) {
                term = BacklogElement.removeTagKeyword(term)
            }
        }

        if (term == null) {
            term = '%'
        }

        def tags = Tag.executeQuery(findTagsByTermAndProduct, [term: term +'%', product: _product.id])
        tags.addAll(Tag.executeQuery(findTagsByTermAndProductInTasks, [term: term +'%', product: _product.id]))
        tags.unique()

        if (params.withKeyword) {
            tags = tags.collect { BacklogElement.TAG_KEYWORD + it }
        }

        withFormat{
            html {
                render tags as JSON
            }
            json { renderRESTJSON(text:tags.unique()) }
            xml  { renderRESTXML(text:tags.unique()) }
        }
    }
}
