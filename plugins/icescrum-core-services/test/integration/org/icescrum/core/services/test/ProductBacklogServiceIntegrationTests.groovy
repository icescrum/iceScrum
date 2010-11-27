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
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release

class ProductBacklogServiceIntegrationTests extends GrailsUnitTestCase {
  def productBacklogService
  def sprintService
  def roleService
  
  def userTest
  def productTest
  def releaseTest
  Sprint sprintTest
  Story _item
  Actor _cr

  protected void setUp() {
    super.setUp()

    userTest = new User(
            username:'TestUser',
            password:'test',
            email:'test@test.com'
    )
    userTest.save()

    productTest = new Product(name:'TestProduct', startDate:new Date(2007,9,12))
    productTest.save()

    _cr = new Actor(product:productTest, name:'Chicken')
    _cr.save()

    releaseTest = new Release(
            name:'RELEASE TEST',
            goal:'Do this',
            backlog:productTest,
            startDate:new Date(),
            endDate:new Date()+80
    )
    releaseTest.save()
    if(releaseTest.hasErrors()) {
      releaseTest.errors.each {
        println it
      }
    }

    assertTrue releaseTest.validate()
  }

  public void testSaveStory() {
    _item = new Story()

    _item.name = 'testItem'
    productBacklogService.saveStory(_item, productTest, userTest)
    assertTrue productTest.stories.contains(_item)
  }

  public void testValidateStory() {
    _item = new Story(name:'testItem')
    productBacklogService.acceptStoryToProductBacklog(_item, userTest, productTest)
    assertTrue _item.state == Story.STATE_ACCEPTED
  }
                            
  public void testDeleteStory() {
    _item = new Story()
    _item.name = 'testItem'
    productBacklogService.saveStory(_item, productTest, userTest)

    productBacklogService.deleteStory(_item, productTest, userTest)
    assertTrue Story.get(_item.id) == null 
  }

  public void testUpdateStory() {
    _item = new Story()

    _item.name = 'testItem'
    productBacklogService.saveStory(_item, productTest, userTest)

    _item.name = 'testUpdate'
    productBacklogService.updateStory(_item)

    assertEquals _item.name, 'testUpdate'
  }

  public void testCountPbi() {
    Story _item0 = new Story()
    _item0.name = 'testItem0'
    productBacklogService.saveStory(_item0, productTest, userTest)
    _item0.state = Story.STATE_ACCEPTED
    productBacklogService.estimateStory(_item0, 4)

    Story _item1 = new Story()
    _item1.name = 'testItem1'
    productBacklogService.saveStory(_item1, productTest,userTest)
    _item1.state = Story.STATE_ACCEPTED
    productBacklogService.estimateStory(_item1, 2)

    Story _item2 = new Story()
    _item2.name = 'testItem2'
    productBacklogService.saveStory(_item2, productTest, userTest)

    Story _item3 = new Story()
    _item3.name = 'testItem3'
    productBacklogService.saveStory(_item3, productTest, userTest)

    Story _item4 = new Story()
    _item4.name = 'testItem4'
    productBacklogService.saveStory(_item4, productTest, userTest)

    assertEquals 2, productBacklogService.countStories(productTest, Story.STATE_ESTIMATED)
    assertEquals 3, productBacklogService.countStories(productTest, Story.STATE_SUGGESTED)
  }

  public void testEstimatedItem() {
    _item = new Story()
    _item.name = 'TEST ESTIMATED ITEM'
    productBacklogService.saveStory(_item, productTest, userTest)
    _item.state = Story.STATE_ACCEPTED
    productBacklogService.estimateStory(_item, 3)
    assertEquals _item.state, Story.STATE_ESTIMATED
  }

  public void testAssociatedItem() {
    sprintTest = new Sprint(startDate:new Date(), endDate:new Date()+14)
    sprintService.saveSprint(sprintTest, releaseTest)

    _item = new Story()
    _item.name = 'TEST ASSOCIATED ITEM'
    productBacklogService.saveStory(_item, productTest, userTest)
    _item.state = Story.STATE_ACCEPTED
    productBacklogService.estimateStory(_item, 3)
    productBacklogService.associateStory(sprintTest, _item, userTest)
    assertTrue _item in sprintTest.stories
  }

  public void testDissociatedItem() {
    sprintTest = new Sprint(startDate:new Date(), endDate:new Date()+14)
    sprintService.saveSprint(sprintTest, releaseTest)

    _item = new Story()
    _item.name = 'TEST ASSOCIATED ITEM'
    productBacklogService.saveStory(_item, productTest, userTest)
    _item.state = Story.STATE_ACCEPTED
    productBacklogService.estimateStory(_item, 4)
    productBacklogService.associateStory(sprintTest, _item, productTest, null, userTest)
    assertTrue _item in sprintTest.stories

    productBacklogService.dissociateStory(sprintTest, _item)
    assertTrue _item in productTest.stories.asList()
    assertFalse _item in sprintTest.stories.asList()
  }

  public void testPlanifAuto() {
    // TODO (not the same behavior as in R2#15.1 or before)
  }

  public void testDissociatedAllItems() {
    sprintTest = new Sprint(startDate:new Date(), endDate:new Date()+14)
    sprintService.saveSprint(sprintTest, releaseTest)

    Story _item0 = new Story()
    _item0.effort = 2
    _item0.name = 'testItem0'
    productBacklogService.saveStory(_item0, productTest, userTest)

    Story _item1 = new Story()
    _item1.effort = 2
    _item1.name = 'testItem1'
    productBacklogService.saveStory(_item1, productTest,userTest)

    Story _item2 = new Story()
    _item2.effort = 2
    _item2.name = 'testItem2'
    productBacklogService.saveStory(_item2, productTest, userTest)

    Story _item3 = new Story()
    _item3.effort = 2
    _item3.name = 'testItem3'
    productBacklogService.saveStory(_item3, productTest,userTest)

    Story _item4 = new Story()
    _item4.effort = 2
    _item4.name = 'testItem4'
    productBacklogService.saveStory(_item4, productTest,userTest)

    Story _item5 = new Story()
    _item5.effort = 2
    _item5.name = 'testItem5'
    productBacklogService.saveStory(_item5, productTest, userTest)

    productBacklogService.associateStory(sprintTest, _item0, productTest, null, userTest)
    productBacklogService.associateStory(sprintTest, _item1, productTest, null, userTest)
    productBacklogService.associateStory(sprintTest, _item2, productTest, null, userTest)
    productBacklogService.associateStory(sprintTest, _item3, productTest, null, userTest)
    productBacklogService.associateStory(sprintTest, _item4, productTest, null, userTest)
    productBacklogService.associateStory(sprintTest, _item5, productTest, null, userTest)

    productBacklogService.dissociatedAllStories(releaseTest.sprints)
    assertEquals 0, sprintTest.stories.size() // Story.findByParentSprint(sprintTest)?.count()
    assertEquals 6, Story.findByBacklog(productTest)?.count()
  }

  public void testResetRank() {
    Story _item0 = new Story()
    _item0.rank = 0
    _item0.name = 'testItem0'
    productBacklogService.saveStory(_item0, productTest, userTest)

    Story _item1 = new Story()
    _item1.rank = 1
    _item1.name = 'testItem1'
    productBacklogService.saveStory(_item1, productTest, userTest)

    Story _item2 = new Story()
    _item2.rank = 2
    _item2.name = 'testItem2'
    productBacklogService.saveStory(_item2, productTest, userTest)

    Story _item3 = new Story()
    _item3.rank = 3
    _item3.name = 'testItem3'
    productBacklogService.saveStory(_item3, productTest, userTest)

    Story _item4 = new Story()
    _item4.rank = 4
    _item4.name = 'testItem4'
    productBacklogService.saveStory(_item4, productTest, userTest)

    Story _item5 = new Story()
    _item5.rank = 5
    _item5.name = 'testItem5'
    productBacklogService.saveStory(_item5, productTest, userTest)

    _item0.rank = 1
    _item0.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item0)
    _item1.rank = 2
    _item1.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item1)
    _item2.rank = 3
    _item2.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item2)
    _item3.rank = 4
    _item3.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item3)
    _item4.rank = 5
    _item4.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item4)
    _item5.rank = 6
    _item5.state = Story.STATE_ACCEPTED
    productBacklogService.updateStory(_item5)
    productBacklogService.resetRank(productTest, 1)

    assertEquals 1, _item0.rank
    assertEquals 1, _item1.rank
    assertEquals 2, _item2.rank
    assertEquals 3, _item3.rank
    assertEquals 4, _item4.rank
    assertEquals 5, _item5.rank
  }
}
