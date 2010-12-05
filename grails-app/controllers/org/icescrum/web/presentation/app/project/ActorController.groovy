/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import grails.converters.JSON
import org.icescrum.core.domain.Story
import org.icescrum.web.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport

@Secured('inProduct()')
class ActorController {
  def actorService
  def springSecurityService

  static ui = true

  static final id = 'actor'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.actor',id , false, 3)
  static window =  [title:'is.ui.actor',help:'is.ui.actor.help',init:'list',toolbar:true]
  static widget =  [title:'is.ui.actor',init:'list',toolbar:true,height:143]

  static instancesBundle = [
          (Actor.NUMBER_INSTANCES_INTERVAL_1): '1',
          (Actor.NUMBER_INSTANCES_INTERVAL_2): '2-5',
          (Actor.NUMBER_INSTANCES_INTERVAL_3): '6-10',
          (Actor.NUMBER_INSTANCES_INTERVAL_4): '11-100',
          (Actor.NUMBER_INSTANCES_INTERVAL_5): '100+'
  ]

  static levelsBundle = [
          (Actor.EXPERTNESS_LEVEL_LOW): 'is.actor.it.low',
          (Actor.EXPERTNESS_LEVEL_MEDIUM): 'is.actor.it.medium',
          (Actor.EXPERTNESS_LEVEL_HIGH): 'is.actor.it.high'
  ]

  static frequenciesBundle = [
          (Actor.USE_FREQUENCY_HOUR): 'is.actor.use.frequency.hour',
          (Actor.USE_FREQUENCY_DAY): 'is.actor.use.frequency.day',
          (Actor.USE_FREQUENCY_WEEK): 'is.actor.use.frequency.week',
          (Actor.USE_FREQUENCY_MONTH): 'is.actor.use.frequency.month',
          (Actor.USE_FREQUENCY_TRIMESTER): 'is.actor.use.frequency.quarter'
  ]

  def index = { }

  def search = {
    def actors = Actor.findActorByProductAndTerm(params.long('product'),'%' + params.term + '%').list()
    def result = []
    actors?.each {
      result << [label: it.name, value: it.name]
    }

    render(result as JSON)
  }

  @Secured('productOwner()')
  def save = {
    if(!params.actor) return

    def actor = new Actor(params.actor)
    def product = Product.load(params.product)
    try {
      actorService.addActor(actor, product)
      this.manageAttachments(actor)
      flash.notice = [text: message(code: 'is.actor.saved'), type: 'notice']
      if (params.continue) {
        redirect(action: 'add', params:[product:params.product])
      } else {
        redirect(action: 'list', params:[product:params.product])
      }
      pushOthers "${params.product}-${id}"
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:actor)]] as JSON)
    }                                                           
  }

  @Secured('productOwner()')
  def update = {
    if(!params.actor) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }

    def actor = Actor.get(params.actor.id)

    if(!actor) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }

    actor.properties = params.actor 
    try {
      actorService.updateActor(actor)
      this.manageAttachments(actor)
      //if success for table view
      if (params.table && params.boolean('table')){
        def returnValue
        if (params.name == 'instances')
          returnValue = message(code:instancesBundle[actor.instances])
        else if (params.name == 'expertnessLevel')
          returnValue =  message(code:levelsBundle[actor.expertnessLevel])
        else if (params.name == 'useFrequency')
          returnValue =  message(code:frequenciesBundle[actor.useFrequency])
        else if (params.name == 'description' || params.name == 'satisfactionCriteria'){
          returnValue = actor."${params.name}"?.encodeAsHTML()?.encodeAsNL2BR()
        }
        else
           returnValue = actor."${params.name}".encodeAsHTML()
        render(status: 200, text: returnValue?:'')
        pushOthers "${params.product}-${id}"
        return
      }

      flash.notice = [text: message(code: 'is.actor.updated'), type: 'notice']
      if (params.continue) {
        def actors = Actor.findAllByBacklog(Product.load(params.product), [sort:'useFrequency', order:'asc']);
        def nextId = null
        def actorIndex = actors.indexOf(actor)
        if(actors.size() > actorIndex + 1)
          nextId = actors[actorIndex + 1].id
        if(nextId){
          redirect(action: 'edit',params:[id:nextId,product:params.product])
        } else {
          redirect(action: 'list',params:[product:params.product])
        }
        pushOthers "${params.product}-${id}"
      } else {
        redirect(action: 'list',params:[product:params.product])
      }
    } catch (RuntimeException re) {
      re.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:actor)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def delete = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }
    def actors = Actor.getAll(params.list('id'))

    if(!actors) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }

    def msg
    try {
      actors.each { actor ->
        actorService.deleteActor(actor)
      }
      flash.notice = [text: message(code: 'is.actor.deleted'), type: 'notice']
      redirect(action: 'list',params:[product:params.product])
      pushOthers "${params.product}-${id}"
    } catch (Exception e) {
      render(status: 400, contentType:'application/json', text: message(code: 'is.actor.error.not.deleted'))
    }
  }

  def changeView = {
    if (!params.id) return
    session['currentView'] = params.id
    render(include(action: 'list', controller: 'actor', id: params.id))
  }

  def list = {
    def actors
    if(params.term)
      actors = Actor.findActorByProductAndTerm(params.long('product'),'%' + params.term + '%').list()
    else
      actors = Actor.findAllByBacklog(Product.load(params.product), [sort:'useFrequency', order:'asc']);
    def template
    if (session.widgetsList?.contains(id))
      template = 'widget/widgetView'
    else {
      if (!actors){
        render(template:'window/blank',model:[id:id])
        return
      }
      template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
    }
    def frequenciesSelect = frequenciesBundle.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
    def instancesSelect = instancesBundle.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
    def levelsSelect = levelsBundle.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')

    render(template: template, model: [actors: actors, id: id, frequenciesSelect:frequenciesSelect, instancesSelect:instancesSelect, levelsSelect:levelsSelect])
  }

  @Secured('productOwner()')
  def add = {
    render(template: 'window/manage', model: [
            id: id,
            currentPanel: 'add',
            instancesValues:instancesBundle.values().collect {v -> message(code: v)},
            instancesKeys:instancesBundle.keySet().asList(),
            levelsValues:levelsBundle.values().collect {v -> message(code: v)},
            levelsKeys:levelsBundle.keySet().asList(),
            frequenciesValues:frequenciesBundle.values().collect {v -> message(code: v)},
            frequenciesKeys:frequenciesBundle.keySet().asList(),
    ])
  }
  
  @Secured('productOwner()')
  def edit = {

    if(!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }

    def actor = Actor.get(params.long('id'))

    if(!actor) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
      return
    }

    def actors = Actor.findAllByBacklog(Product.load(params.product), [sort:'useFrequency', order:'asc']);
    def nextId = null
    def actorIndex = actors.indexOf(actor)
    if(actors.size() > actorIndex + 1)
      nextId = actors[actorIndex + 1].id

    render(template: 'window/manage', model: [
            id: id,
            actor:actor,
            currentPanel: 'edit',
            nextActorId:nextId?:'',
            instancesValues:instancesBundle.values().collect {v -> message(code: v)},
            instancesKeys:instancesBundle.keySet().asList(),
            levelsValues:levelsBundle.values().collect {v -> message(code: v)},
            levelsKeys:levelsBundle.keySet().asList(),
            frequenciesValues:frequenciesBundle.values().collect {v -> message(code: v)},
            frequenciesKeys:frequenciesBundle.keySet().asList(),
    ])
  }

  private manageAttachments(def actor){
    def user = User.load(springSecurityService.principal.id)
    if (actor.id && !params.actor.list('attachments') && actor.attachments*.id.size() > 0){
      actor.removeAllAttachments()
    }else if (actor.attachments*.id.size() > 0){
      actor.attachments*.id.each {
        if (!params.actor.list('attachments').contains(it.toString()))
         actor.removeAttachment(it)
      }
    }
    def uploadedFiles = []
    params.list('attachments')?.each{ attachment ->
       attachment.split(':').with {
         if (session.uploadedFiles[it[0]])
           uploadedFiles << [file:new File(session.uploadedFiles[it[0]]),name:it[1]]
       }
    }
    if (uploadedFiles)
      actor.addAttachments(user,uploadedFiles)
    session.uploadedFiles = null
  }

  def print = {
    def user = User.load(springSecurityService.principal.id)

    def currentProduct = Product.load(params.product)
    def data = []
    def actors = Actor.findAllByBacklog(currentProduct, [sort:'useFrequency', order:'asc']);
    if(!actors){
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.report.error.no.data')]] as JSON)
      return
    } else if(params.get){
      actors.each {
        data << [
                name:it.name,
                description:it.description,
                notes:it.notes?.replaceAll(/<.*?>/, ''),
                expertnessLevel:message(code:levelsBundle[it.expertnessLevel]),
                satisfactionCriteria:it.satisfactionCriteria,
                useFrequency:message(code:frequenciesBundle[it.useFrequency]),
                instances:instancesBundle[it.instances],
                associatedStories:Story.findAllByTextAsIlike(it.name).size()?:0
        ]
      }
      try {
        session.progress = new ProgressSupport()
        session.progress.updateProgress(99,message(code:'is.report.processing'))
        def model = [[product:currentProduct.name,actors:data?:null]]
        def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+'actors'+'-'+(g.formatDate(value:new Date(),formatName:'is.date.file'))
        chain(controller: 'jasper',
                action: 'index',
                model: [data: model],
                params: [locale:user.preferences.language,
                        _format:params.format,
                        _file:'actors',
                        _name:fileName])

        session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch (Exception e) {
        e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    } else if(params.status){
      render(status:200,contentType: 'application/json', text:session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id])
    }
  }

  def download = {
    forward(action:'download',controller:'attachmentable',id:params.id)
    return
  }
}
