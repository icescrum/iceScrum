/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */

package org.icescrum.core.services

import org.springframework.security.core.context.SecurityContextHolder as SCH
import org.codehaus.groovy.grails.plugins.springsecurity.SecurityRequestHolder as SRH

import grails.plugin.springcache.key.CacheKeyBuilder
import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsHibernateUtil
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.codehaus.groovy.grails.plugins.springsecurity.acl.AclClass
import org.codehaus.groovy.grails.plugins.springsecurity.acl.AclObjectIdentity
import org.codehaus.groovy.grails.plugins.springsecurity.acl.AclSid
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.domain.security.UserAuthority
import org.springframework.security.acls.domain.BasePermission
import org.springframework.security.acls.domain.PrincipalSid
import org.springframework.security.core.Authentication
import org.springframework.util.Assert
import static org.springframework.security.acls.domain.BasePermission.*
import org.springframework.security.acls.model.*
import org.icescrum.core.event.IceScrumUserEvent

class SecurityService {

  static transactional = true

  def aclUtilService
  def objectIdentityRetrievalStrategy
  def springSecurityService
  def grailsUrlMappingsHolder
  def springcacheService
  def grailsApplication
  def aclService


  static final String TEAM_ATTR = 'team_id'
  static final String TEAM_URL_ATTR = 'team'
  static final String PRODUCT_ATTR = 'product_id'
  static final String PRODUCT_URL_ATTR = 'product'



  static final CACHE_TEAMMEMBER = 'teamMemberCache'
  static final CACHE_PRODUCTOWNER = 'productOwnerCache'
  static final CACHE_SCRUMMASTER = 'scrumMasterCache'
  static final CACHE_STAKEHOLDER = 'stakeHolderCache'
  static final CACHE_PRODUCTTEAM = 'productTeamCache'
  static final CACHE_OPENPRODUCTTEAM = 'teamProductCache'
  static final CACHE_OWNER = 'ownerCache'

  static final teamMemberPermissions = [BasePermission.READ]
  static final productOwnerPermissions = [BasePermission.WRITE]
  static final scrumMasterPermissions = [BasePermission.WRITE]

  Acl secureDomain(o) {
    createAcl objectIdentityRetrievalStrategy.getObjectIdentity(o)
  }


  Acl secureDomain(o, parent) {
    createAcl objectIdentityRetrievalStrategy.getObjectIdentity(o), aclService.retrieveObjectIdentity(objectIdentityRetrievalStrategy.getObjectIdentity(parent))
  }

  Acl secureDomainByProduct(o, Product product) {
    createAcl objectIdentityRetrievalStrategy.getObjectIdentity(o), aclService.retrieveObjectIdentity(objectIdentityRetrievalStrategy.getObjectIdentity(product))
  }

  void unsecureDomain(o) {
    aclUtilService.deleteAcl o
  }

  void changeOwner(User u, o) {
    aclUtilService.changeOwner o, u.username
    springcacheService.flush(SecurityService.CACHE_OWNER)
    publishEvent(new IceScrumUserEvent(u,o,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_IS_OWNER))
  }

  void createProductOwnerPermissions(User u, Product p) {
    aclUtilService.addPermission p, u.username, WRITE
    springcacheService.flush(SecurityService.CACHE_PRODUCTOWNER)
    publishEvent(new IceScrumUserEvent(u,p,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_IS_PRODUCTOWNER))
  }

  void createScrumMasterPermissions(User u, Team t) {
    aclUtilService.addPermission t, u.username, WRITE
    springcacheService.flush(SecurityService.CACHE_SCRUMMASTER)
    publishEvent(new IceScrumUserEvent(u,t,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_IS_SCRUMMASTER))
  }

  void createStakeHolderPermissions(User u, Product p) {
    aclUtilService.addPermission p, u.username, READ
    springcacheService.flush(SecurityService.CACHE_STAKEHOLDER)
  }

  void createTeamMemberPermissions(User u, Team t) {
    aclUtilService.addPermission t, u.username, READ
    springcacheService.flush(SecurityService.CACHE_TEAMMEMBER)
    publishEvent(new IceScrumUserEvent(u,t,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_IS_MEMBER))
  }

  void deleteProductOwnerPermissions(User u, Product p) {
    aclUtilService.deletePermission p, u.username, WRITE
    aclUtilService.deletePermission p, u.username, ADMINISTRATION
    springcacheService.flush(SecurityService.CACHE_PRODUCTOWNER)
    publishEvent(new IceScrumUserEvent(u,p,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_NOT_PRODUCTOWNER))
  }

  void deleteScrumMasterPermissions(User u, Team t) {
    aclUtilService.deletePermission t, u.username, WRITE
    aclUtilService.deletePermission t, u.username, ADMINISTRATION
    springcacheService.flush(SecurityService.CACHE_SCRUMMASTER)
    publishEvent(new IceScrumUserEvent(u,t,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_NOT_SCRUMMASTER))
  }

  void deleteStakeHolderPermissions(User u, Product p) {
    aclUtilService.deletePermission p, u.username, READ
    springcacheService.flush(SecurityService.CACHE_STAKEHOLDER)
  }

  void deleteTeamMemberPermissions(User u, Team t) {
    aclUtilService.deletePermission t, u.username, READ
    springcacheService.flush(SecurityService.CACHE_TEAMMEMBER)
    publishEvent(new IceScrumUserEvent(u,t,this.class,User.get(springSecurityService.principal?.id),IceScrumUserEvent.EVENT_NOT_MEMBER))
  }

  boolean inProduct(product, auth) {

    if (!springSecurityService.isLoggedIn())
      return false

    boolean authorized = productOwner(product, auth)


    if (!authorized) {
      def p
      if (!product)
        product = parseCurrentRequestProduct()
      else if (product in Product) {
        //p = GrailsHibernateUtil.unwrapIfProxy(product)
        product = product.id
      }

      if (product) {
        authorized = springcacheService.doWithCache(CACHE_PRODUCTTEAM, new CacheKeyBuilder().append(product).append(auth.principal.id).toCacheKey()) {

          if (!p) p = Product.get(product)

          if (!p || !auth) return

          for (team in p.teams) {
            if (inTeam(team, auth)) {
              return true
            }
          }
        }
      }
    }


    return authorized
  }

  boolean inTeam(team, auth) {
    if (!springSecurityService.isLoggedIn())
      return false

    teamMember(team, auth) || scrumMaster(team, auth)
  }

  Team openProductTeam(Long productId, Long principalId) {
    springcacheService.doWithCache(CACHE_OPENPRODUCTTEAM, new CacheKeyBuilder().append(productId).append(principalId).toCacheKey()) {
      def team = Team.productTeam(productId, principalId).list(max: 1)
      if (team)
        team[0]
      else
        null
    }

  }


  boolean scrumMaster(team, auth) {
    if (!springSecurityService.isLoggedIn())
      return false

    if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN))
      return true

    def t
    def parsedTeam
    def parsedProduct

    if (!team) {
      parsedTeam = parseCurrentRequestTeam()
      parsedProduct = parseCurrentRequestProduct()
      if (!parsedTeam && parsedProduct) {
        t = openProductTeam(parsedProduct, springSecurityService.principal.id)
        team = t?.id
      } else {
        team = parsedTeam
      }
    }
    else if (team in Team) {
      t = GrailsHibernateUtil.unwrapIfProxy(team)
      team = t.id
    }

    isScrumMaster(team, auth, t)
  }

  boolean isScrumMaster(team, auth, t = null) {
    if (team) {
      def res = springcacheService.doWithCache(CACHE_SCRUMMASTER, new CacheKeyBuilder().append(team).append(auth.principal.id).toCacheKey()) {
        if (!t) t = Team.get(team)

        if (!t || !auth) return false

        return aclUtilService.hasPermission(auth, t, SecurityService.scrumMasterPermissions)
      }
      return res
    }
    else
      return false
  }


  boolean stakeHolder(product, auth) {
    def p

    if (!product)
      product = parseCurrentRequestProduct()
    else if (product in Product) {
      p = GrailsHibernateUtil.unwrapIfProxy(product)
      product = product.id
    }

    if (product) {
      return springcacheService.doWithCache(CACHE_STAKEHOLDER, new CacheKeyBuilder().append(product).toCacheKey()) {
        p = Product.get(product)

        if (!p || !auth) return false

        return !p.preferences.hidden
      }
    }
    else
      return false
  }

  boolean productOwner(product, auth) {
    if (!springSecurityService.isLoggedIn())
      return false

    if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN))
      return true

    def p

    if (!product)
      product = parseCurrentRequestProduct()
    else if (product in Product) {
      p = GrailsHibernateUtil.unwrapIfProxy(product)
      product = product.id
    }

    isProductOwner(product, auth, p)
  }

  boolean admin(auth) {
    if (!springSecurityService.isLoggedIn())
      return false

    return SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)
  }

  boolean isProductOwner(product, auth, p = null) {
    if (product) {
      return springcacheService.doWithCache(CACHE_PRODUCTOWNER, new CacheKeyBuilder().append(product).append(auth.principal.id).toCacheKey()) {
        if (!p) p = Product.get(product)

        if (!p || !auth) return false

        return aclUtilService.hasPermission(auth, p, SecurityService.productOwnerPermissions)
      }
    }
    else
      return false
  }

  boolean teamMember(team, auth) {
    if (!springSecurityService.isLoggedIn())
      return

    if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN))
      return true

    def t
    def parsedTeam
    def parsedProduct

    if (!team) {
      parsedTeam = parseCurrentRequestTeam()
      parsedProduct = parseCurrentRequestProduct()
      if (!parsedTeam && parsedProduct) {
        t = openProductTeam(parsedProduct, springSecurityService.principal.id)
        team = t?.id
      } else {
        team = parsedTeam
      }
    }
    else if (team in Team) {
      t = GrailsHibernateUtil.unwrapIfProxy(team)
      team = team.id
    }

    if (team) {
      return springcacheService.doWithCache(CACHE_TEAMMEMBER, new CacheKeyBuilder().append(team).append(auth.principal.id).toCacheKey()) {
        if (!t) t = Team.get(team)

        if (!t || !auth) return false

        return aclUtilService.hasPermission(auth, t, SecurityService.teamMemberPermissions)
      }
    }
    else
      return false
  }

  boolean hasRoleAdmin(User user) {
    UserAuthority.countByAuthorityAndUser(Authority.findByAuthority(Authority.ROLE_ADMIN, [cache: true]), user, [cache: true])
  }

  Long parseCurrentRequestProduct() {
    def res = SRH.request[PRODUCT_ATTR]
    if (!res) {
      def param = SRH.request.getParameter(PRODUCT_URL_ATTR)
      if (!param) {
        def mappingInfo = grailsUrlMappingsHolder.match(SRH.request.forwardURI.replaceFirst(SRH.request.contextPath, ''))
        res = mappingInfo?.parameters?.getAt(PRODUCT_URL_ATTR)?.decodeProductKey()?.toLong()
      } else {
        res = param?.decodeProductKey()?.toLong()
      }
      SRH.request[PRODUCT_ATTR] = res
    }

    res
  }

  Long parseCurrentRequestTeam() {
    def res = SRH.request[TEAM_ATTR]
    if (!res) {
      def param = SRH.request.getParameter(TEAM_URL_ATTR)
      if (!param) {
        def mappingInfo = grailsUrlMappingsHolder.match(SRH.request.forwardURI.replaceFirst(SRH.request.contextPath, ''))
        res = mappingInfo?.parameters?.getAt(TEAM_URL_ATTR)?.toLong()
      } else {
        res = param?.toLong()
      }
      SRH.request[TEAM_ATTR] = res
    }

    res
  }


  MutableAcl createAcl(ObjectIdentity objectIdentity, parent = null) throws AlreadyExistsException {
    Assert.notNull objectIdentity, 'Object Identity required'

    // Check this object identity hasn't already been persisted
    if (aclService.retrieveObjectIdentity(objectIdentity)) {
      throw new AlreadyExistsException("Object identity '$objectIdentity' already exists")
    }

    // Need to retrieve the current principal, in order to know who "owns" this ACL (can be changed later on)
    PrincipalSid sid = new PrincipalSid(SCH.context.authentication)

    // Create the acl_object_identity row
    createObjectIdentity objectIdentity, sid, parent

    return aclService.readAclById(objectIdentity)
  }

  protected void createObjectIdentity(ObjectIdentity object, Sid owner, parent = null) {
    AclSid ownerSid = aclService.createOrRetrieveSid(owner, true)
    AclClass aclClass = aclService.createOrRetrieveClass(object.type, true)
    aclService.save new AclObjectIdentity(
            aclClass: aclClass,
            objectId: object.identifier,
            owner: ownerSid,
            parent: parent,
            entriesInheriting: true)
  }

  public boolean owner(domain, Authentication auth) {
    if (!springSecurityService.isLoggedIn())
      return false

    if (SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN))
      return true

    def d
    def parsedDomain
    def domainClass

    if (!domain) {
      parsedDomain = parseCurrentRequestProduct()
      if (!parsedDomain) {
        domain = parseCurrentRequestTeam()
        domainClass = grailsApplication.getDomainClass(Team.class.name).newInstance()
      } else {
        domain = parsedDomain
        domainClass = grailsApplication.getDomainClass(Product.class.name).newInstance()
      }
    } else {
      d = GrailsHibernateUtil.unwrapIfProxy(domain)
      domainClass = d
      if (!d) return false
      domain = d.id
    }
    isOwner(domain, auth, domainClass, d)
  }

  boolean isOwner(domain, auth, domainClass, d = null) {
    if (domain && domainClass) {
      springcacheService.doWithCache(CACHE_OWNER, new CacheKeyBuilder().append(domain).append(domainClass.class.name).append(auth.principal.id).toCacheKey()) {
        if (!d) d = domainClass.get(domain)

        if (!d || !auth) return false

        def acl = aclService.readAclById(objectIdentityRetrievalStrategy.getObjectIdentity(d))
        return acl.owner == new PrincipalSid(auth)
      }
    }
    else
      return false
  }

}
