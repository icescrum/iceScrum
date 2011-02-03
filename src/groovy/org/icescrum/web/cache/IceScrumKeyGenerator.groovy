package org.icescrum.web.cache

import grails.plugin.springcache.web.key.AbstractKeyGenerator
import grails.plugin.springcache.key.CacheKeyBuilder
import grails.plugin.springcache.web.FilterContext

/**
 * Created by IntelliJ IDEA.
 * User: vbarrier
 * Date: 03/02/11
 * Time: 09:49
 * To change this template use File | Settings | File Templates.
 */

import org.codehaus.groovy.grails.commons.ApplicationHolder
import grails.plugins.springsecurity.SpringSecurityService
import org.icescrum.core.services.SecurityService
import org.springframework.context.i18n.LocaleContextHolder

class IceScrumKeyGenerator extends AbstractKeyGenerator{

  @Override
  protected void generateKeyInternal(CacheKeyBuilder builder, FilterContext context) {

        def currentLocale = context.request.session?.getAttribute("org.springframework.web.servlet.i18n.SessionLocaleResolver.LOCALE")
		currentLocale = currentLocale?currentLocale:context.request?.getLocale()

        builder << context.controllerName
		builder << context.actionName
        builder << currentLocale

        context.params?.sort { it.key }?.each { entry ->
			if (!(entry.key in ["controller", "action"])) {
				builder << entry
			}
		}
  }
}
