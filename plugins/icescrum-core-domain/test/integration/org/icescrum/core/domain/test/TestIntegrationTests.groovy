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
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Story

class TestIntegrationTests extends GrailsUnitTestCase {
  /**
   * Test the named queries behaviors
   */
  void testNamedQueries() {
    def prod = new Product(name: 'proj1', startDate: new Date())
    prod.save()
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language: "en")
    user.save()
    def pbi = new Story(name: 'Story0', backlog: prod, creator: user, state: Story.STATE_INPROGRESS, estimatedDate: new Date())
    def pbi2 = new Story(name: 'Story1', backlog: prod, creator: user, state: Story.STATE_INPROGRESS, estimatedDate: new Date())
    pbi.save()
    pbi2.save()
    pbi.creationDate = new Date() - 3;
    pbi2.creationDate = new Date() - 3;

    prod.addToStories(pbi)
    prod.addToStories(pbi2)
    def tests = [
            new Test(parentStory: pbi, name: 'test0', state: Test.STATE_FAILED),
            new Test(parentStory: pbi, name: 'test1', state: Test.STATE_TESTED),
            new Test(parentStory: pbi, name: 'test2', state: Test.STATE_UNTESTED),
            new Test(parentStory: pbi, name: 'test3', state: Test.STATE_FAILED),
            new Test(parentStory: pbi2, name: 'test4', state: Test.STATE_UNTESTED),
            new Test(parentStory: pbi2, name: 'test5', state: Test.STATE_UNTESTED)
    ]
    tests*.save(flush: true)

    tests.each {
      if(it.parentStory.equals(pbi))
        pbi.addToTests(it)
      else if (it.parentStory.equals(pbi2))
        pbi2.addToTests(it)
    }

    // Check the persistence of the test data
    assertEquals 'Product has not been successfully persisted', 1, Product.count()
    assertEquals 'Product has not been successfully persisted', 6, Test.count()

    // Check the filterByProductAndState named query
    // It should return the number of tests that match the state specified in argument for the specified product
    assertEquals 'filterByProductAndState on STATE_FAILED did not return the expected result: ', 2, Test.filterByProductAndState(prod, Test.STATE_FAILED).list().size()
    assertEquals 'filterByProductAndState on STATE_TESTED did not return the expected result: ', 1, Test.filterByProductAndState(prod, Test.STATE_TESTED).list().size()
    assertEquals 'filterByProductAndState on STATE_UNTESTED did not return the expected result: ', 3, Test.filterByProductAndState(prod, Test.STATE_UNTESTED).list().size()

    // Check the countByProductAndSprintDone named query
    // It should return the number of tests that are in sprints which state are SPRINT.STATE_DONE for a product
    def release = new Release(backlog:prod, name:"rr", startDate:new Date(), endDate:new Date(), goal:"do this")
    release.save()
    prod.addToReleases(release)
    def sprints = [
            new Sprint(parentRelease:release, goal:"do that", orderNumber:1, state:Sprint.STATE_DONE, startDate:new Date(), endDate:new Date()+1),
            new Sprint(parentRelease:release, goal:"do that", orderNumber:2, state:Sprint.STATE_WAIT, startDate:new Date(), endDate:new Date()+1)
    ]
    sprints*.save()
    pbi.parentSprint = sprints[0]
    sprints[0].addToStories(pbi)
    pbi2.parentSprint = sprints[1]
    sprints[1].addToStories(pbi2)
    assertEquals 'countByProductAndSprintDone did not return the expected result: ', 4, Test.countByProductAndSprintDone(prod).list()[0]

  }
}
