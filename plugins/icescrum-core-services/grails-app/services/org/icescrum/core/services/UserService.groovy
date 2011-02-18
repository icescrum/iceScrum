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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

package org.icescrum.core.services

import org.icescrum.core.domain.User
import org.springframework.security.access.prepost.PreAuthorize
import groovy.util.slurpersupport.NodeChild

import org.icescrum.core.domain.preferences.UserPreferences

import org.springframework.transaction.annotation.Transactional

import org.apache.commons.io.FilenameUtils
import org.icescrum.core.utils.ImageConvert
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumUserEvent

/**
 * The UserService class monitor the operations on the User domain requested by the web layer.
 * It acts as a "Facade" between the UI and the domain operations
 */
class UserService {
  
  def productService
  def grailsApplication
  def springSecurityService
  def burningImageService
  def notificationEmailService

  static transactional = true

  void saveUser(User _user) {
    //TODO remettre users_limit
    // If the maximum number of users allowed to join is reached, the user can't be persisted
//    if (Integer.valueOf(grailsApplication.config.icescrum2.users_limit) < User.count() + 1) {
//      _user.errors.rejectValue('id','users.max.reached')
//      throw new IllegalStateException('is.user.error.maxusers')
//    }
    _user.password = springSecurityService.encodePassword(_user.password)
    if (!_user.save())
      throw new RuntimeException()
    publishEvent(new IceScrumUserEvent(_user,this.class,_user,IceScrumEvent.EVENT_CREATED))
  }

  void updateUser(User _user, String pwd = null, String avatarPath = null, boolean scale = true) {
    if (pwd)
      _user.password = springSecurityService.encodePassword(pwd)

    try {
      if (avatarPath){
        if (FilenameUtils.getExtension(avatarPath) != 'png'){
          def oldAvatarPath = avatarPath
          def newAvatarPath = avatarPath.replace(FilenameUtils.getExtension(avatarPath),'png')
          ImageConvert.convertToPNG(oldAvatarPath,newAvatarPath)
          avatarPath = newAvatarPath
        }
        burningImageService.doWith(avatarPath, grailsApplication.config.icescrum.images.users.dir)
        .execute (_user.id.toString(), {
          if(scale)
            it.scaleAccurate(40, 40)
        })
      }
    }
    catch(RuntimeException e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException('is.convert.image.error')
    }

    if (!_user.save(flush:true))
      throw new RuntimeException()
    publishEvent(new IceScrumUserEvent(_user,this.class,_user,IceScrumEvent.EVENT_UPDATED))
  }

  @PreAuthorize("ROLE_ADMIN")
  boolean deleteUser(User _user) {
    try {
      _user.delete()
      publishEvent(new IceScrumUserEvent(_user,this.class,_user,IceScrumEvent.EVENT_DELETED))
      return true
    } catch (Exception e) {
      return false
    }
  }

  def resetPassword(User user) {
    def pool = ['a'..'z','A'..'Z',0..9,'_'].flatten()
    Random rand = new Random(System.currentTimeMillis())
    def passChars = (0..10).collect { pool[rand.nextInt(pool.size())] }
    def password = passChars.join()
    user.password = springSecurityService.encodePassword(password)
    if (!user.save()){
      throw new RuntimeException('is.user.error.reset.password')
    }
    notificationEmailService.sendNewPassword(user,password)
  }


  @PreAuthorize("ROLE_ADMIN")
  List<User> getUsersList() {
    return User.list()
  }

  void changeMenuOrder(User _u, String id, String position, boolean hidden){
    def currentMenu
    if (hidden){
      currentMenu = _u.preferences.menuHidden
      if(!currentMenu.containsKey(id)){
        currentMenu.put(id,(currentMenu.size()+1).toString())
        if (_u.preferences.menu.containsKey(id)){
          this.changeMenuOrder (_u,id,_u.preferences.menuHidden.size().toString(),true)
        }
        _u.preferences.menu.remove(id)
      }
    }
    else{
      currentMenu = _u.preferences.menu
      if(!currentMenu.containsKey(id)){
        currentMenu.put(id,(currentMenu.size()+1).toString())
        if (_u.preferences.menuHidden.containsKey(id)){
          this.changeMenuOrder (_u,id,_u.preferences.menuHidden.size().toString(),true)
        }
        _u.preferences.menuHidden.remove(id)
      }
    }
    def from =  currentMenu.get(id)?.toInteger()
    from = from?:1
    def to = position.toInteger()

    if (from != to){

        if(from > to){
            currentMenu.entrySet().each{it ->
            if(it.value.toInteger() >= to && it.value.toInteger() <= from && it.key != id){
              it.value = (it.value.toInteger() + 1).toString()
            }
            else if(it.key == id){
              it.value = position
            }
          }
        }
        else{
          currentMenu.entrySet().each{it ->
            if(it.value.toInteger() <= to && it.value.toInteger() >= from && it.key != id){
              it.value = (it.value.toInteger() - 1).toString()
            }
            else if(it.key == id){
              it.value = position
            }
          }
        }
    }
    if(!_u.save()){
      throw new RuntimeException()
    }
  }

  @Transactional(readOnly = true)
  def unMarshallUser(NodeChild user){
    try {
      def u = User.findByUsernameAndEmail(user.username.text(),user.email.text())
      if (!u){
        u = new User(
          lastName: user.lastName.text(),
          firstName: user.firstName.text(),
          username: user.username.text(),
          email: user.email.text(),
          password: user.password.text(),
          enabled: user.enabled.text().toBoolean()?:true,
          accountExpired: user.accountExpired.text().toBoolean()?:false,
          accountLocked : user.accountLocked.text().toBoolean()?:false,
          passwordExpired: user.passwordExpired.text().toBoolean()?:false,
          idFromImport:user.@id.text().toInteger()
        )

        u.preferences = new UserPreferences(
                language:user.preferences.language.text(),
                activity:user.preferences.activity.text(),
                filterTask:user.preferences.filterTask.text(),
                menu:user.preferences.menu.text(),
                menuHidden: user.preferences.menu.text(),
                hideDoneState: user.preferences.hideDoneState.text()?.toBoolean()?:false
        )
      }else{
        u.idFromImport = user.@id.text().toInteger()
      }
      return u
    }catch(Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }
  }
}