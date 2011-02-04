/*
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */
package org.icescrum.core.services

import org.springframework.context.ApplicationListener
import org.icescrum.core.event.IceScrumStoryEvent
import org.icescrum.core.domain.Story
import org.grails.comments.Comment
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.User
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import org.springframework.web.context.request.RequestContextHolder as RCH
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.Feature
import org.icescrum.core.support.ApplicationSupport


class NotificationEmailService implements ApplicationListener<IceScrumStoryEvent> {

  def mailService
  def grailsApplication
  def messageSource

  void onApplicationEvent(IceScrumStoryEvent e) {
    if (log.debugEnabled) {
        log.debug "Receive event ${e.type}"
    }
    try {
      if(e.type in IceScrumStoryEvent.EVENT_CUD){
        sendAlertCUD((Story)e.source, (User)e.doneBy, e.type)

      }else if(e.type in IceScrumStoryEvent.EVENT_STATE_LIST){
        sendAlertState((Story)e.source, (User)e.doneBy, e.type)

      }else if(e.type in IceScrumStoryEvent.EVENT_COMMENT_LIST){
        sendAlertComment((Story)e.source, (User)e.doneBy, e.type, e.comment)

      }else if(e.type in IceScrumStoryEvent.EVENT_ACCEPTED_AS_LIST){
        sendAlertAcceptedAs((BacklogElement)e.source, (User)e.doneBy, e.type)

      }
    }catch(Exception expt){
      expt.printStackTrace()
    }

  }

  private void sendAlertCUD(Story story, User user, String type){

    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.alerts.enable)){
      return
    }

    def listTo = []
    def subjectArgs = [story.backlog.name,story.id]
    def permalink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'-'+story.id
    def projectLink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'#project'

    if (type == IceScrumEvent.EVENT_CREATED){
      story.backlog.productOwners.findAll{it.id != user.id}.each{
        listTo << [email:it.email,locale:new Locale(it.preferences.language)]
      }
    }
    else {
      story.followers?.findAll{it.id != user.id}?.each{ listTo << [email:it.email,locale:new Locale(it.preferences.language)] }
    }

    def event = (IceScrumEvent.EVENT_CREATED == type)?'Created':(IceScrumEvent.EVENT_UPDATED == type?'Updated':'Deleted')
    listTo?.unique()?.groupBy{it.locale}?.each{ locale,  group ->
      if (log.debugEnabled) {
        log.debug "Send email, event:${type} to : ${group*.email.toArray()} with locale : ${locale}"
      }
      send([
              bcc:group*.email.toArray(),
              subject:getMessage('is.template.email.story.'+event.toLowerCase()+'.subject',(Locale)locale, subjectArgs),
              view:'/emails-templates/story'+event,
              model:[locale:locale,storyName:story.name,permalink:permalink,linkName:story.backlog.name,link:projectLink]
      ])
    }
  }

  private void sendAlertState(Story story, User user, String type){

    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.alerts.enable)){
      return
    }

    def listTo = []
    def subjectArgs = [story.backlog.name,story.id]
    def permalink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'-'+story.id
    def projectLink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'#project'

    story.followers?.findAll{it.id != user.id}?.each{ listTo << [email:it.email,locale:new Locale(it.preferences.language)] }
    listTo?.unique()?.groupBy{it.locale}?.each{ locale, group ->
      if (log.debugEnabled) {
          log.debug "Send email, event:${type} to : ${group*.email.toArray()} with locale : ${locale}"
      }
      send([
              bcc:group*.email.toArray(),
              subject:getMessage('is.template.email.story.changedState.subject',(Locale)locale,subjectArgs),
              view:'/emails-templates/storyChangedState',
              model:[state:getMessage('is.template.email.story.changedState.'+type.toLowerCase(),(Locale)locale),locale:locale,storyName:story.name,permalink:permalink,linkName:story.backlog.name,link:projectLink]
      ])
    }

  }

  private void sendAlertComment(Story story, User user, String type, Comment comment){

    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.alerts.enable)){
      return
    }

    def listTo = []
    def subjectArgs = [story.backlog.name,story.id]
    def permalink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'-'+story.id
    def projectLink = grailsApplication.config.grails.serverURL+'/p/'+story.backlog.pkey+'#project'

    if (type == IceScrumStoryEvent.EVENT_COMMENT_ADDED){
      story.followers?.findAll{it.id != user.id}?.each{ listTo << [email:it.email,locale:new Locale(it.preferences.language)] }
      listTo?.unique()?.groupBy{it.locale}?.each{ locale, group ->
        if (log.debugEnabled) {
          log.debug "Send email, event:${type} to : ${group*.email.toArray()} with locale : ${locale}"
        }
        send([
                bcc:group*.email.toArray(),
                subject:getMessage('is.template.email.story.commented.subject',(Locale)locale,subjectArgs),
                view:'/emails-templates/storyCommented',
                model:[by:comment.poster.firstName+" "+comment.poster.lastName,locale:locale,storyName:story.name,permalink:permalink,linkName:story.backlog.name,link:projectLink]
        ])
      }
    } else if (type == IceScrumStoryEvent.EVENT_COMMENT_UPDATED){
      story.followers?.findAll{it.id != user.id}?.each{ listTo << [email:it.email,locale:new Locale(it.preferences.language)] }
      listTo?.unique()?.groupBy{it.locale}?.each{ locale, group ->
        if (log.debugEnabled) {
          log.debug "Send email, event:${type} to : ${group*.email.toArray()} with locale : ${locale}"
        }
        send([
                bcc:group*.email.toArray(),
                subject:getMessage('is.template.email.story.commentEdited.subject',(Locale)locale,subjectArgs),
                view:'/emails-templates/storyCommentEdited',
                model:[by:user.firstName+" "+user.lastName,locale:locale,storyName:story.name,permalink:permalink,linkName:story.backlog.name,link:projectLink]
        ])
      }
    }/* else {
      send([
              to:comment.poster.email,
              subject:getMessage('is.template.email.story.commentDeleted.subject',(Locale)locale,subjectArgs),
              view:'/emails-templates/storyCommentDeleted',
              model:[by:user.firstName+" "+user.lastName,locale:locale,storyName:story.name,permalink:permalink,linkName:story.backlog.name,link:projectLink]
      ])
    }*/
  }

  private void sendAlertAcceptedAs(BacklogElement element, User user, String type){

    if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.alerts.enable)){
      return
    }

    def listTo = []
    def product = element instanceof Feature ? element.backlog : element.backlog.parentRelease.parentProduct
    def subjectArgs = [product.name,element.id]
    def projectLink = grailsApplication.config.grails.serverURL+'/p/'+product.pkey+'#project'
    element.followers?.findAll{it.id != user.id}?.each{ listTo << [email:it.email,locale:new Locale(it.preferences.language)] }

    listTo?.unique()?.groupBy{it.locale}?.each{ locale, group ->
      def acceptedAs = getMessage(element instanceof Feature ? 'is.feature' : 'is.task',(Locale)locale)
      subjectArgs << acceptedAs
      if (log.debugEnabled) {
        log.debug "Send email, event:${type} to : ${group*.email.toArray()} with locale : ${locale}"
      }
      send([
              bcc:group*.email.toArray(),
              subject:getMessage('is.template.email.story.acceptedAs.subject',(Locale)locale,subjectArgs),
              view:'/emails-templates/storyAcceptedAs',
              model:[acceptedAs:acceptedAs,locale:locale,elementName:element.name,linkName:product.name,link:projectLink]
      ])
    }
  }

  void sendNewPassword(User user,String password){
    def link = grailsApplication.config.grails.serverURL+'/login'
    def request = RCH.currentRequestAttributes().getRequest()
    if (log.debugEnabled) {
        log.debug "Send email, retrieve password to : ${user.email} (${user.username})"
    }
    send([
            to:user.email,
            subject:getMessage('is.template.email.user.retrieve.subject',new Locale(user.preferences.language),[user.username]),
            view:"/emails-templates/retrieve",
            model:[locale:new Locale(user.preferences.language),user:user,password:password,ip:request.getHeader('X-Forwarded-For')?:request.getRemoteAddr(),link:link]
    ])
  }

  void send(def options){

    assert options.to || options.bcc || options.cc
    assert options.view
    assert options.subject

    mailService.sendMail {
      if (options.from)
        from options.from
      if (options.to)
        to options.to
      if (options.cc)
        cc options.cc
      if (options.bcc)
        bcc options.bcc
      subject options.subject
      body(
              view:options.view,
              plugin:options.plugin?:"icescrum-core-services",
              model:options.model?:[]
      )
    }
  }

  String getMessage(String code,Locale locale, args = null,String defaultCode = null){
    return messageSource.getMessage(code,args?args.toArray():null,defaultCode?:code,locale)
  }
}
