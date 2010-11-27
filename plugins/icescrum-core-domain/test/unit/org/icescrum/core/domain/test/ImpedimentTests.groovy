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

package org.icescrum.core.domain.test

import grails.test.GrailsUnitTestCase
import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User

class ImpedimentTests extends GrailsUnitTestCase {
  /**
   * Test basic instanciation and persistence of the class, and its constraints 
   */
  void testImpedimentInit() {
    // Mock the domain classes used
    mockDomain(Product)
    mockDomain(User)
    mockDomain(Impediment)

    // Def dummy product & user
    def product = new Product(name:"theproject", startDate:new Date(), description:"some desc")
    def product2 = new Product(name:'someProject2', startDate:new Date(), description:"some desc2")
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "dfvdfvdfvdfba",
            language: "en"
    )
    def user2 = new User(username: "ab",
            email: "abdb@mail.com",
            password: "adfvdfvdfvdfv",
            language: "en"
    )
    product.save()
    product2.save()
    user.save()
    user2.save(flush:true)

    // A Impediment only need a name, a backlog and a poster to be persisted
    def dumImp = new Impediment(backlog:product, creator:user, name:'prob1')
    assertTrue 'Impediment instanciated with a name, backlog and poster should have been validated', dumImp.validate()

    // Test class constraints :
    // - A problem without backlog cannot be persisted
    dumImp = new Impediment(creator:user, name:'prob1')
    assertFalse 'Impediment without backlog should have failed validation', dumImp.validate()

    // - A problem without name cannot be persisted
    dumImp = new Impediment(backlog:product, creator:user)
    assertFalse 'Impediment without name should have failed validation', dumImp.validate()

    [
            new Impediment(backlog:product, creator:user, name:'prob1', rank:1),
            new Impediment(backlog:product, creator:user, name:'prob2', rank:4),
            new Impediment(backlog:product2, creator:user, name:'prob4', rank:2)
    ]*.save(flush:true)

    assertEquals 3, Impediment.list().size()
  }
}
