package org.icescrum.web.presentation.app.project

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.PlanningPokerGame

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

                def suiteSelect = [:]
                PlanningPokerGame.getInteger(product.planningPokerGameType).eachWithIndex { t, i ->
                    suiteSelect."${t}" = t
                }

                withFormat{
                    html {
                        render(template: 'window/postitsView', model: [
                                data: data,
                                user:(User)springSecurityService.currentUser,
                                suiteSelect:suiteSelect,
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

                def tags = Tag.executeQuery(findTagsByTermAndProduct, [term: params.term+'%', product: p.id])
                tags.addAll(Tag.executeQuery(findTagsByTermAndProductInTasks, [term: params.term+'%', product: p.id]))
                withFormat{
                    html {
                        render tags.unique() as JSON
                    }
                    json { renderRESTJSON(text:tags.unique()) }
                    xml  { renderRESTXML(text:tags.unique()) }
                 }
            }
        }
}
