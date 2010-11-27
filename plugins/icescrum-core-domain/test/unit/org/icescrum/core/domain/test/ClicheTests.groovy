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
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Product

class ClicheTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Product)
    mockDomain(Cliche)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints
   */
  void testClicheInit() {
    // Test minimal persitence validation, a cliche only needs a datePrise and a product parameters to persist
    def prod = new Product(name:'proj', startDate:new Date())
    prod.save()
    def cl = new Cliche(backlog:prod, datePrise:new Date())
    assertTrue 'Cliche with product and datePrise parameters should have been validated.', cl.validate()
    cl.save(flush:true)
    prod.addToCliches(cl)

    // Check if the cliche has actually been persisted
    assertEquals 'Cliche has not been successfully persisted.', 1, Cliche.count()

    // Test basic constraints
    // A Cliche cannot be validated if he has no datePrise
    def cl2 = new Cliche(backlog:prod)
    assertFalse 'Cliche without datePrise should have failed validation.', cl2.validate()

    // A Cliche cannot be validated if he has no product
    cl2 = new Cliche(datePrise:new Date())
    assertFalse 'Actor without product should have failed validation.', cl2.validate()
  }
}
