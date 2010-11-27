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
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.services.ActorService

class ActorServiceTests extends GrailsUnitTestCase {
  ActorService actorServices
  def productTest
  def userPOTest
  def userNotPOTest
  
  protected void setUp() {
    super.setUp()
    mockDomain(Product)
    mockDomain(User)
    mockDomain(Actor)
    actorServices = new ActorService()
    actorServices.businessRulesService = new BusinessRulesService()

    // User
    userPOTest = new User(
            username:'TestUserPO',
            password:'test',
            email:'test@test.com'
    )
    userPOTest.save()
    userNotPOTest = new User(
            username:'TestUserNotPO',
            password:'test',
            email:'test@test.com'
    )
    userNotPOTest.save()

    // Product
    productTest = new Product(name:'TestProduct', startDate:new Date(2007,9,12))
    productTest.save()

    // Put Users on Product with roles
  }

  public void testActorRole() throws Exception {
    // Test add a custom role without name
    Actor actorTest = new Actor()

    // Verify no custom role in database before add
    assertEquals productTest.actors, null

    try {
      actorServices.addActor(actorTest, userPOTest, productTest)
      assertFalse true
    } catch(Exception e){
      assertEquals 'is_actor_no_name', e.getMessage()
    }

    // Verify always no custom role in database after add with error
    assertEquals productTest.actors, null

    // Test add correctly a custom role
    actorTest.name = 'CUSTOM ROLE TEST'
    try {
      actorServices.addActor(actorTest, userPOTest, productTest)
    } catch(Exception e) {
      assertFalse 'Add actor should have worked', true
    }


    // Verify only one custom role in database after add correctly
    assertEquals productTest.actors.size(), 1

    // Test add a custom role with a existing name
    Actor actorTest2 = new Actor()
    actorTest2.name = 'CUSTOM ROLE TEST'
    try {
      actorServices.addActor(actorTest2, userPOTest, productTest)
      assertFalse true
    } catch(Exception e){
      assertEquals 'is_actor_same_name', e.getMessage()
    }

    // Verify always only one custom role in database after add with error
    assertEquals productTest.actors.size(), 1

    // test add a custom role with the same with spaces at the end or at beginning
    def actorTest4 = new Actor()
    actorTest4.name = ' CUSTOM ROLE TEST '
    try {
      actorServices.addActor(actorTest4, userPOTest, productTest)
      assertFalse true
    } catch(Exception e){
      assertEquals 'is_actor_same_name', e.getMessage()
    }
  }

  public void testDeleteCustomRole() {
    // Add the role to delete
    Actor actorTest = new Actor()
    actorTest.name = 'CUSTOM ROLE TEST'
    actorServices.addActor(actorTest, userPOTest, productTest)

    // Verify one custom role in database before delete
    assertEquals productTest.actors.size(), 1

    // Test to delete a custom role correctly
    assertEquals ActorService.VALIDATE, actorServices.deleteActor(actorTest, userPOTest, productTest)

    // Verify no custom role in database before delete after delete correctly
    assertEquals productTest.actors.size(), 0
  }

  public void testDeleteAllCustomRole() {
    // Add roles to delete
    Actor actorTest1 = new Actor()
    actorTest1.name = 'CUSTOM ROLE TEST 1'
    Actor actorTest2 = new Actor()
    actorTest2.name = 'CUSTOM ROLE TEST 2'
    actorServices.addActor(actorTest1, userPOTest, productTest)
    actorServices.addActor(actorTest2, userPOTest, productTest)

    // Verify two custom role in database
    assertEquals productTest.actors.size(), 2

    // Test to delete custom roles without the PO role
    assertEquals ActorService.NOT_PO, actorServices.deleteAllActors(userNotPOTest, productTest)

    // Verify always two custom role in database
    assertEquals productTest.actors.size(), 2

    // Test to delete custom roles correctly
    assertEquals ActorService.VALIDATE, actorServices.deleteAllActors(userPOTest, productTest)

    // Verify no custom role in database
    assertEquals productTest.actors.size(), 0
  }

  public void testUpdateCustomRole() {
    // Add the role to update
    Actor actor = new Actor()
    actor.name = 'CUSTOM ROLE TEST'
    actorServices.addActor(actor, userPOTest, productTest)
    actor.name = 'CUSTOM ROLE TEST UPDATED'

    // Test to update a custom role correctly
    try {
      actorServices.updateActor(actor, userPOTest, productTest)
    } catch(RuntimeException) {
      assertFalse 'Update actor failed', true
    }

  }
}
