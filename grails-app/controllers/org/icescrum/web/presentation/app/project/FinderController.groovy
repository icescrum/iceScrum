package org.icescrum.web.presentation.app.project

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Actor
import org.icescrum.core.utils.BundleUtils
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import grails.plugins.springsecurity.Secured

class FinderController {

        def springSecurityService

        def tag = {
            withProduct{ Product p ->
                if ((p.preferences.hidden && !request.inProduct) || (!p.preferences.hidden && !springSecurityService.isLoggedIn())){
                    render status:403, text:''
                    return
                }

                String findTagsByTermAndProduct = """SELECT DISTINCT tagLink.tag.name
                           FROM Story story, Feature feature, Actor actor, org.grails.taggable.TagLink tagLink
                           WHERE ((story.id = tagLink.tagRef AND story.backlog.id = :product)
                                  OR (feature.id = tagLink.tagRef AND feature.backlog.id = :product)
                                  OR (actor.id = tagLink.tagRef AND actor.backlog.id = :product))
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
                render tags.unique() as JSON
            }
        }

        @Secured('inProduct()')
        def list = {
            def data = [:]
            if (params.term){
                data.actors =  Actor.findAllByTagWithCriteria(params.term) {
                    backlog {
                        eq 'id', params.long('product')
                    }
                }

                data.features = Feature.findAllByTagWithCriteria(params.term) {
                    backlog {
                        eq 'id', params.long('product')
                    }
                }

                data.stories = Story.findAllByTagWithCriteria(params.term) {
                    backlog {
                        eq 'id', params.long('product')
                    }
                }

                def queryTasks ="""SELECT task
                                   FROM Task task,org.grails.taggable.TagLink tagLink
                                   WHERE   task.id = tagLink.tagRef
                                           AND tagLink.type = 'task'
                                           AND tagLink.tag.name LIKE :term
                                   ORDER BY task.name"""

                data.tasks = Task.executeQuery(queryTasks, [term: params.term+'%'])
            }
            withFormat{
                html {
                    render(template: 'window/postitsView', model: [data: data, user:(User)springSecurityService.currentUser])
                }
                json { renderRESTJSON(text:data) }
                xml  { renderRESTXML(text:data) }
             }
        }
}
