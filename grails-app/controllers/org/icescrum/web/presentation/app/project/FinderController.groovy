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
import org.icescrum.core.domain.PlanningPokerGame

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
                withFormat{
                    html {
                        render tags.unique() as JSON
                    }
                    json { renderRESTJSON(text:tags.unique()) }
                    xml  { renderRESTXML(text:tags.unique()) }
                 }
            }
        }

        @Secured('inProduct()')
        def list = {
            withProduct { Product product ->
                def data = [:]

                params.term = params.term ? '%'+params.term+'%' : null
                data.actors =  searchInActors(product.id, [tag:params.tag, term:params.term, actor: params.withActors ? params.actor : null])
                data.stories = searchInStories(product.id, [tag:params.tag, term:params.term, story: params.withStories ? params.story : null])
                data.features = searchInFeatures(product.id, [tag:params.tag, term:params.term, feature: params.withFeatures ? params.feature : null])
                data.tasks = searchInTasks(product, [tag:params.tag, term:params.term, task: params.withTasks ? params.task : null])

                if (!data.actors && !data.stories && !data.features && !data.tasks){
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
                                update: params.update ?: false,
                                suiteSelect:suiteSelect,
                                product:product])
                    }
                    json { renderRESTJSON(text:data) }
                    xml  { renderRESTXML(text:data) }
                }
            }
        }

        private searchInStories(product, options){
            List<Story> stories = []
            def criteria = {
                backlog {
                    eq 'id', product
                }
                if (options.term || options.story){
                    if (options.term) {
                        or {
                            ilike 'name', options.term
                            ilike 'textAs', options.term
                            ilike 'textICan', options.term
                            ilike 'textTo', options.term
                            ilike 'description', options.term
                            ilike 'notes', options.term
                        }
                    }
                    if (options.story?.feature?.isLong()){
                        feature {
                            eq 'id', options.story.feature.toLong()
                        }
                    }
                    if (options.story?.actor?.isLong()){
                        actor {
                            eq 'id', options.story.actor.toLong()
                        }
                    }
                    if (options.story?.state?.isInteger()){
                        eq 'state', options.story.state.toInteger()
                    }
                    if (options.story?.parentRelease?.isLong()){
                        parentSprint {
                            parentRelease{
                                eq 'id', options.story.parentRelease.toLong()
                            }
                        }
                    }
                    if (options.story?.parentSprint?.isLong()){
                        parentSprint {
                            eq 'id', options.story.parentSprint.toLong()
                        }
                    }
                    if (options.story?.creator?.isLong()){
                        creator {
                            eq 'id', options.story.creator.toLong()
                        }
                    }
                    if (options.story?.type?.isInteger()){
                        eq 'type', options.story.type.toInteger()
                    }
                    if (options.story?.dependsOn?.isLong()){
                        dependsOn {
                            eq 'id', options.story.dependsOn.toLong()
                        }
                    }
                    if (options.story?.effort?.isInteger()){
                        eq 'effort', options.story.effort.toInteger()
                    }
                    if (options.story?.affectedVersion){
                        eq 'affectVersion', options.story.affectedVersion
                    }
                    if (options.story?.deliveredVersion){
                        parentSprint {
                            eq 'deliveredVersion', options.story.deliveredVersion
                        }
                    }
                }
            }
            if (options.tag){
                stories = Story.findAllByTagWithCriteria(options.tag) {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else if(options.term || options.story) {
                stories = Story.createCriteria().list {
                    criteria.delegate = delegate
                    criteria.call()
                }
            }
            if (stories){
                Map storiesGrouped = stories?.groupBy{ it.feature }
                stories = []
                storiesGrouped?.each{
                    it.value?.sort{ st -> st.state }
                    stories.addAll(it.value)
                }
            }
            return stories ?: Collections.EMPTY_LIST
        }

        private searchInActors(product, options){
            def criteria = {
                backlog {
                    eq 'id', product
                }
                if (options.term || options.actor){
                    if(options.term) {
                        or {
                            ilike 'name', options.term
                            ilike 'description', options.term
                            ilike 'notes', options.term
                            ilike 'satisfactionCriteria', options.term
                        }
                    }
                    if (options.actor?.frequency?.isInteger()){
                        eq 'useFrequency', options.actor.frequency.toInteger()
                    }
                    if (options.actor?.level?.isInteger()){
                        eq 'expertnessLevel', options.actor.level.toInteger()
                    }
                    if (options.actor?.instance?.isInteger()){
                        eq 'instances', options.actor.instance.toInteger()
                    }
                }
            }
            if (options.tag){
                return Actor.findAllByTagWithCriteria(options.tag) {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else if(options.term || options.actor) {
                return Actor.createCriteria().list {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else {
                return Collections.EMPTY_LIST
            }
        }

        private searchInFeatures(product, options){
            def criteria = {
                backlog {
                    eq 'id', product
                }
                if (options.term || options.feature){
                    if (options.term){
                        or {
                            ilike 'name', options.term
                            ilike 'description', options.term
                            ilike 'notes', options.term
                        }
                    }
                    if (options.feature?.type?.isInteger()){
                        eq 'type', options.feature.type.toInteger()
                    }
                }
            }
            if (options.tag){
                return Feature.findAllByTagWithCriteria(options.tag) {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else if(options.term || options.feature)  {
                return Feature.createCriteria().list {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else {
                return Collections.EMPTY_LIST
            }
        }

        private searchInTasks(product, options){

            def criteria = {
                backlog {
                    if (options.task?.parentSprint?.isLong() && options.task.parentSprint.toLong() in product.releases*.sprints*.id.flatten()){
                        eq 'id', options.task.parentSprint.toLong()
                    } else if (options.task?.parentRelease?.isLong() && options.task.parentRelease.toLong() in product.releases*.id){
                        'in' 'id', product.releases.find{it.id == options.task.parentRelease.toLong()}.sprints*.id
                    } else {
                        'in' 'id', product.releases*.sprints*.id.flatten()
                    }
                }

                if (options.term || options.task){
                    if (options.term){
                        or {
                            ilike 'name', options.term
                            ilike 'description', options.term
                            ilike 'notes', options.term
                        }
                    }
                    if (options.task?.type?.isInteger()){
                        eq 'type', options.task.type.toInteger()
                    }
                    if (options.task?.state?.isInteger()){
                        eq 'state', options.task.state.toInteger()
                    }
                    if (options.task?.parentStory?.isLong()){
                        parentStory{
                            eq 'id', options.task.parentStory.toLong()
                        }
                    }
                    if (options.task?.creator?.isLong()){
                        creator {
                            eq 'id', options.task.creator.toLong()
                        }
                    }
                    if (options.task?.responsible?.isLong()){
                        responsible {
                            eq 'id', options.task.responsible.toLong()
                        }
                    }
                }
            }
            if (options.tag){
                return Task.findAllByTagWithCriteria(options.tag) {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else if(options.term || options.task)  {
                return Task.createCriteria().list {
                    criteria.delegate = delegate
                    criteria.call()
                }
            } else {
                return Collections.EMPTY_LIST
            }
        }
}
