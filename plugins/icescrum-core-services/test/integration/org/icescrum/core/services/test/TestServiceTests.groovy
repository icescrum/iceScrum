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
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User

class TestServiceTests extends GrailsUnitTestCase {
  TestService testServiceT
  def product
  User usr
  def testMockSaveFailed
  def testStory

  protected void setUp() {
    super.setUp()

    mockDomain(User)
    mockDomain(Product)
    mockDomain(Sprint)
    mockDomain(Actor)
    mockDomain(Story)
    mockDomain(Test)

    // Data for all the tests
    testServiceT = new TestService()
    product = new Product(name: 'proj1', startDate: new Date())
    product.save()
    usr = new User(username: "a",
            email: "abdb@mail.com",
            password: "dfvdfvdfvdfba",
            language: "en"
    )
    usr.save()

    testStory = new Story(
            name: 'TitreST',
            type: 1,
            effort: 5,
            notes: 'notesST',
            description: 'descStory',
            backlog: product
    )
    testStory.save()

    // Mock for BusinessRulesService
    def businessMock = mockFor(BusinessRulesService, true)
    businessMock.demand.isSh(0..3) {User u, Product pb -> return u.admin }
    businessMock.demand.isPo(0..3) {User u, Product pb -> return u.admin }
    businessMock.demand.isTestAction(0..3) {User u, Product pb -> return u.admin }

    testServiceT.businessRulesService = businessMock.createMock()
  }

  void testSaveTest() {
    def testStory = new Story(
            name: 'TitreST',
            type: 1,
            effort: 5,
            notes: 'notesST',
            description: 'descStory',
            backlog: product
    )
    testStory.save()

    // Data for testing purpose
    Test test = new Test()

    // Check if the Test Service return TestService.ACTION_ERROR_NO_STORY when trying to save
    // a test without a story
    test.name = 'Nom_Test'
    assertEquals 'TestService.saveTest did not return the expected result (ACTION_ERROR_NO_STORY): ',
            TestService.ACTION_ERROR_NO_STORY,
            testServiceT.saveTest(test, null, usr)

    product.addToStories(testStory)

    // Check if the TestService return TestService.VALIDATE if the test has a name
    // and a parentStory
    test.parentStory = testStory
    assertEquals 'TestService.saveTest method did not return the expected result (VALIDATE): ',
            TestService.ACTION_VALIDATE,
            testServiceT.saveTest(test, testStory, usr)

    // Check if the TestService return TestService.ACTION_ERROR_NAME if the test has empty name
    test.name = ''
    assertEquals 'TestService.saveTest method did not return the expected result (ACTION_ERROR_NAME): ',
            TestService.ACTION_ERROR_NAME,
            testServiceT.saveTest(test, testStory, usr)
  }

  void testClone() {
    mockDomain(Test)
    Test testTest = new Test()

    testTest.name = 'Nom_Test'
    def testStory = new Story(
            name: 'TitreSsT',
            type: 1,
            effort: 5,
            notes: 'notesST',
            description: 'descStory',
            backlog: product
    )
    product.addToStories(testStory)
    testStory.save()

    testTest.parentStory = testStory
    testServiceT.saveTest(testTest, testStory, usr)

    assertEquals 'TestService.cloneTest method did not return the expected result (VALIDATE): ',
            TestService.ACTION_VALIDATE,
            testServiceT.cloneTest(testTest, usr, product)
  }

  void testFilters() {
    // Dummy Tests
    def tests = [new Test(), new Test()]
    mockDomain(Test, tests)

    // Dummy object, just so the list() method can be called on it
    def dummy = new Expando()
    dummy.list = { return tests }

    // Mock the test namedQueries
    def testFilterMock = mockFor(Test, true)
    testFilterMock.demand.static.filterByProduct(1..1){pb -> return dummy}
    testFilterMock.demand.static.filterByProductAndState(1..3){pb, st -> return dummy}
    testFilterMock.createMock()

    // Test the filter behaviour
    assertTrue 'getTestsByProduct did not return the expected result: ', testServiceT.getTestsByProduct(product) == tests
    assertTrue 'filterByPendingTest did not return the expected result: ', testServiceT.filterByPendingTest(product) == tests
    assertTrue 'filterByFailedTest did not return the expected result: ', testServiceT.filterByFailedTest(product) == tests
    assertTrue 'filterByPassedTest did not return the expected result: ', testServiceT.filterByPassedTest(product) == tests
  }
}
