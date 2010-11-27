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
 *
 */

import org.codehaus.groovy.grails.plugins.web.taglib.JavascriptTagLib
import org.icepush.PushContext
import org.springframework.web.context.request.RequestContextHolder as RCH
import org.springframework.context.ApplicationContext
import org.codehaus.groovy.grails.web.context.ServletContextHolder as SCH

class IcepushJqueryGrailsPlugin {
  // the plugin version
  def version = "0.1"
  // the version or versions of Grails the plugin is designed for
  def grailsVersion = "1.2.0 > *"
  // the other plugins this plugin depends on
  def dependsOn = [:]
  // resources that are excluded from plugin packaging
  def pluginExcludes = [
          "grails-app/views/**", "grails-app/conf/**",
          "web-app/**"
  ]



  def observe = ["services", "controllers"]

  def loadAfter = ["controllers", "services"]

  def author = "iceScrum Technologies"
  def authorEmail = "vincent.barrier@icescrum.com"
  def title = "ICEpush with jQuery integration"
  def description = '''\\
ICEpush is a notification framework, it doesn't carry data unlike Cometd. However you can register callbacks such as page/fragment refresh and script invokation. By combining 1 Tag and 1 Call (from javascript/ser/ver side), you add a new dimension in your webware.
You can push, join/leave channels from controllers/gsp and add support for services.

This plugin can be mixed with the coming ICEfaces 2 integration to allow collaborative application scaffolding and push capabilities for JSF2.
'''

  // URL to the plugin's documentation
  def documentation = "http://grails.org/plugin/icepush-jquery"

  def doWithWebDescriptor = { xml ->
    //if (!manager.hasGrailsPlugin("icefaces2")) {
    def servlets = xml.servlet[0]
    def mappings = xml.'servlet-mapping'[0]

    servlets + {
      servlet {
        'servlet-name'('icepush')
        'servlet-class'('org.icepush.servlet.ICEpushServlet')
        'load-on-startup'(1)
      }
    }
    mappings + {
      'servlet-mapping' {
        'servlet-name'('icepush')
        'url-pattern'('*.icepush')
      }
    }
    //}
  }

  def doWithSpring = {

  }

  def doWithDynamicMethods = { ctx ->
    JavascriptTagLib.LIBRARY_MAPPINGS.icepush = ["code.icepush"]

    if (manager.hasGrailsPlugin("controllers")) {
      for (bean in application.controllerClasses)
        addPushMethods(bean.metaClass, application)
    }
    if (application.config.icepush?.injectServices && manager.hasGrailsPlugin("services")) {
      for (bean in application.serviceClasses)
        addPushMethods(bean.metaClass, application)
    }
  }

  private addPushMethods(MetaClass mc, application) {

    def pc = {->
      PushContext.getInstance(SCH.servletContext)
    }
    def pushid = {->
      try {
        pc().createPushId(RCH.currentRequestAttributes().currentRequest, RCH.currentRequestAttributes().response)
      } catch (e) {
        null
      }
    }

    mc.getPushContext = {->
      pc()
    }

    mc.getPushId = {->
      pushid()
    }

    mc.addToPushGroup = {String name ->
      def pushId = pushid()
      pc().addGroupMember name, pushId
      pushId
    }
    mc.addToPushGroup = {String name, String _pushid ->
      pc().addGroupMember name, _pushid
    }
    mc.removeFromPushGroup = {String name, String _pushid ->
      pc().removeGroupMember name, _pushid
    }

    if (application.config.icepush?.disabled) {

      mc.push = { }
      mc.push = {s -> }
      mc.pushOthers = {s -> }

    } else {

      mc.push = {
        if (application.config.icepush?.disabled)
          return
        pc().push "context-push"
      }

      mc.push = {s ->
        if (application.config.icepush?.disabled)
          return
        pc().push s?.toString()
      }

      mc.pushOthers = {s ->
        if (application.config.icepush?.disabled)
          return
        def pushContext = pc()
        def cookieValue = pushContext.getBrowserIDFromCookie(RCH.currentRequestAttributes().currentRequest) + ':'

        def idList = pushContext.pushGroupManager.groupMap?.getAt(s.toString())?.pushIDs?.findAll {id ->
          !id.startsWith(cookieValue)
        } as String[]

        if (idList) pushContext.pushGroupManager.outboundNotifier.notifyObservers(idList)
      }
    }

  }

  def doWithApplicationContext = { applicationContext ->
  }

  def onChange = { event ->

    if (application.isArtefactOfType('Controller', event.source) || (application.config.icepush?.injectServices && application.isArtefactOfType('Service', event.source))) {
      event.manager?.getGrailsPlugin("icepush-jquery")?.doWithDynamicMethods(event.ctx)
    }
  }

  def onConfigChange = { event ->
  }
}