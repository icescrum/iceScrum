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
 */

package org.icescrum.core.services.test

import grails.test.GrailsUnitTestCase
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.services.UserService

class UserServiceTests extends GrailsUnitTestCase {

  protected void setUp() {
    super.setUp()
    mockDomain(User)
    mockDomain(Product)
  }

  void testCheckAdmin() {
    def userService = new UserService()

    userService.grailsApplication = [config: [
            icescrum2: [
                    admin: [login: "sa", pwd: "sa"]
            ]
    ]]

    def u = userService.checkAdmin("sa", "sa")

    assertTrue "Authentication failed, not admin", u?.admin

  }

  void testSaveUser() {
    def userService = new UserService()
    def springSecurityService = [
            encodePassword:{return "encoded"}
    ]
    userService.springSecurityService = springSecurityService

    def _user = new User(
            firstName: "Chuck",
            lastName: "Norris",
            username: "chuck",
            password: "norris",
            email: "chuck@norris.net"
    )

    userService.grailsApplication = [config: [
            icescrum2: [
                    admin: [login: "sa", pwd: "sa"],
                    users_limit: 1
            ]
    ]]

    userService.saveUser(_user)

    assertTrue "Authentication failed, not admin", _user.id == 1
    assertTrue "Password not correctly encrypted", _user.password == springSecurityService.encodePassword("norris")


    def _user2 = new User()
    assertTrue "Max users number unreached", UserService.MAX_USERS == userService.saveUser(_user2)

    userService.grailsApplication.config.icescrum2.users_limit = 2
    assertTrue "Validating fail on User", UserService.NOT_LOGIN == userService.saveUser(_user2)

  }

  void testUpdateUser(){
    mockDomain User
    mockForConstraintsTests User
    def springSecurityService = [
            encodePassword:{return "encoded"}
    ]

    def _user = new User(
            firstName: "Chuck",
            lastName: "Norris",
            username: "chuck",
            password: "norris",
            email: "chuck@norris.net"
    ).save()

    def userService = new UserService()
    userService.springSecurityService = springSecurityService
    
    assertTrue "Updating fail", UserService.SAVE_EFFECTUATED == userService.updateUser(_user)
    assertTrue "Password altered", _user.password == "norris"
    assertTrue "Updating without password fail", UserService.SAVE_EFFECTUATED == userService.updateUser(_user)
    assertTrue "Updating with password fail", UserService.SAVE_EFFECTUATED == userService.updateUser(_user,"norris2")
    assertTrue "Password updated", _user.password == springSecurityService.encodePassword("norris2")
  }
}