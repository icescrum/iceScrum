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
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product

class ActorTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Product)
    mockDomain(Actor)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints
   */
  void testActorInit() {
    // Test minimal persitence validation, a custom role only needs a name and a backlog parameter to persist
    def prod = new Product(name:'proj', startDate:new Date())
    prod.save()
    def act = new Actor(backlog:prod, name:'Chicken')
    assertTrue 'Actor with backlog and name parameters should have been validated.', act.validate()
    act.save(flush:true)
    prod.addToActors(act)

    // Check if the custom role has actually been persisted
    assertEquals 'Actor has not been successfully persisted.', 1, Actor.count()

    // Test basic constraints
    // A Actor cannot be validated if he has no name
    def act2 = new Actor(backlog:prod)
    assertFalse 'Actor without name should have failed validation.', act2.validate()

    // A Actor cannot be validated if he has no backlog
    act2 = new Actor(name:'Chicken')
    assertFalse 'Actor without backlog should have failed validation.', act2.validate()
  }
}
