package org.icescrum.core.services

import org.springframework.context.ApplicationListener
import org.icescrum.core.event.IceScrumStoryEvent
import org.icescrum.core.domain.Story
import org.grails.comments.Comment
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.User
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import org.springframework.web.context.request.RequestContextHolder as RCH


class NotificationEmailService implements ApplicationListener<IceScrumStoryEvent>{

  def mailService
  def grailsApplication
  def g = new org.codehaus.groovy.grails.plugins.web.taglib.ApplicationTagLib()

  void onApplicationEvent(IceScrumStoryEvent e) {

    if(e.type in IceScrumStoryEvent.EVENT_CUD){
      sendAlertCUD((Story)e.source, e.type)

    }else if(e.type in IceScrumStoryEvent.EVENT_STATE_LIST){
      sendAlertState((Story)e.source, e.type)

    }else if(e.type in IceScrumStoryEvent.EVENT_COMMENT_LIST){
      sendAlertComment((Story)e.source,e.type,e.comment)

    }else if(e.type in IceScrumStoryEvent.EVENT_ACCEPTED_AS_LIST){
      sendAlertAcceptedAs((BacklogElement)e.source,e.type)

    }

  }

  private void sendAlertCUD(Story story, String type){
    story.getFollowers().each{
      println "${story.name} send email to: ${it.firstName} event: ${type}"
    }
  }

  private void sendAlertState(Story story, String type){
    story.getFollowers().each{
      println "${story.name} send email to: ${it.firstName} event: ${type}"
    }
  }

  private void sendAlertComment(Story story, String type, Comment comment){
    story.getFollowers().each{
      println "${story.name} send email to: ${it.firstName} event: ${type} comment by : ${comment.poster.firstName}, body : ${comment.body}"
    }
  }

  private void sendAlertAcceptedAs(BacklogElement element, String type){
    story.getFollowers().each{
      println "${element.name} send email to: ${it.firstName} event: ${type} accepted as : ${element.class}"
    }
  }

  void sendNewPassword(User user,String password){
      def link = grailsApplication.config.grails.serverURL+'/login'
      setLocaleForUser(user)
      def request = RCH.currentRequestAttributes().getRequest()
      send([
              to:user.email,
              subject:g.message(code:'is.template.retrieve.subject',args:[user.username]),
              view:"/emails-templates/retrieve",
              model:[user:user,password:password,ip:request.getHeader('X-Forwarded-For')?:request.getRemoteAddr(),link:link]
      ])
  }

  void send(def options){

    assert options.to
    assert options.view
    assert options.subject

    mailService.sendMail {
      if (options.from)
        from options.from
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

  private void setLocaleForUser(User user){
    def webRequest = RCH.currentRequestAttributes()
    def request = webRequest.getRequest()
    def response = webRequest.getResponse()
    RCU.getLocaleResolver(request).setLocale(request, response, new Locale(user.preferences.language))
  }

}
