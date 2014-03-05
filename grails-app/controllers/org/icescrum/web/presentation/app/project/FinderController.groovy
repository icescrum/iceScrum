package org.icescrum.web.presentation.app.project

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import grails.plugins.springsecurity.Secured

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class FinderController {

        def springSecurityService

        def index = {
            withProduct { Product product ->
                def data = [:]

                data.actors =  Actor.search(product.id, [tag:params.tag, term:params.term, actor: params.withActors ? params.actor : null])
                data.stories = Story.search(product.id, [tag:params.tag, term:params.term, story: params.withStories ? params.story : null])
                data.features = Feature.search(product.id, [tag:params.tag, term:params.term, feature: params.withFeatures ? params.feature : null])
                data.tasks = Task.search(product, [tag:params.tag, term:params.term, task: params.withTasks ? params.task : null])

                if (!data.actors && !data.stories && !data.features && !data.tasks && !params.term && !params.tag && !params.withActors && !params.withStories && !params.withFeatures && !params.withTasks){
                    data = null
                }

                withFormat{
                    html {
                        render(template: 'window/postitsView', model: [
                                data: data,
                                user:(User)springSecurityService.currentUser,
                                estimates:product.stories*.effort.unique().findAll { it != null }.sort(),
                                creators:(product.allUsers + product.stories*.creator.unique()).unique(),
                                tasksCreators:(product.allUsers + Task.getAllCreatorsInProduct(product.id)).unique(),
                                tasksResponsibles:(product.allUsers + Task.getAllResponsiblesInProduct(product.id)).unique(),
                                product:product])
                    }
                    json { renderRESTJSON(text:data) }
                    xml  { renderRESTXML(text:data) }
                }
            }
        }

        def tag = {
            withProduct{ Product p ->
                if ((p.preferences.hidden && !request.inProduct) || (!p.preferences.hidden && !springSecurityService.isLoggedIn())){
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

                def tags = Tag.executeQuery(findTagsByTermAndProduct, [term: term +'%', product: p.id])
                tags.addAll(Tag.executeQuery(findTagsByTermAndProductInTasks, [term: term +'%', product: p.id]))
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
}
