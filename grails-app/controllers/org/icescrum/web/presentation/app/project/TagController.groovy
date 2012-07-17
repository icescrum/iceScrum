package org.icescrum.web.presentation.app.project

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.Product

class TagController {

        def springSecurityService

        def find = {
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
}
