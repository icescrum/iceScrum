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

class BuildTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Build)
    mockDomain(Product)
    mockDomain(Test)
    mockDomain(ExecTest)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints
   */
  void testBuildInit() {
    // Test minimal Build persistence validation, it should only need a name, a date and a backlog
    def dumProd = new Product(name: 'proj1', startDate: new Date())
    dumProd.save()
    def dumBuild = new Build(name: 'build1', date: new Date(), backlog: dumProd)

    assertTrue 'Build instanciated with name, date, and backlog parameters failed validation', dumBuild.validate()
    dumBuild.save(flush: true)

    // Check if the instance has been persisted
    assertEquals 1, Build.list().size()

    // Test of Build instanciation without parameter, it should fail validation
    dumBuild = new Build()
    assertFalse 'Build with no parameters should have failed validation', dumBuild.validate()

    // Test of Build constraints :
    // -> date is required
    dumBuild = new Build(name: "build2", backlog: dumProd)
    assertTrue 'Build with date parameter should have pass validation', dumBuild.validate()

    // -> name is unique and required
    dumBuild = new Build(date: new Date(), backlog: dumProd)
    assertFalse 'Build without name parameter should have failed validation', dumBuild.validate()

    // -> backlog is required
    dumBuild = new Build(name: 'build3', date: new Date())
    assertFalse 'Build without backlog parameter should have failed validation', dumBuild.validate()
  }

  /**
   * Test the class compareTo and equals methods
   */
  void testBuildComparators() {
    // Two instances of Build are equals if they share the same name, description, state and execTests
    def execTestsExample = [new ExecTest(date: new Date()), new ExecTest(date: new Date())]
    mockDomain(ExecTest, execTestsExample)
    def prod1 = new Product(name: 'proj1', startDate: new Date())
    def prod2 = new Product(name: 'proj2', startDate: new Date())
    def date1 = new Date()
    def build1 = new Build(name: 'build1', date: date1, description: 'somedesc',
            state: 1, backlog: prod2, execTests: execTestsExample)
    def build2 = new Build(name: 'build1', date: new Date(), description: 'somedesc',
            state: 1, backlog: prod1, execTests: execTestsExample)
    def build3 = new Build(name: 'build2', date: new Date(), description: 'somedesc',
            state: 1, backlog: prod1, execTests: null)
    def build4 = new Build(name: 'build2', date: new Date(), description: 'someotherdesc',
            state: 1, backlog: prod1, execTests: null)

    // Do NOT use assertEquals or the == operator to test equality: Groovy 1.x use the compareTo() method
    // on classes implementing the Comparable interface when using one of these instead of the equals() method !
    assertTrue 'Builds with the same name, description, state and execTests should have been considered equals',
            build1.equals(build2)
    assertFalse 'Builds with different execTests list should not have been considered equals', build1.equals(build3)
    assertFalse 'Builds with different description should not have been considered equals', build3.equals(build4)

    // The class compareTo method should apply a comparison on the build date
    def build5 = new Build(name: 'build2', date: date1, description: 'somedesc',
            state: 1, backlog: prod1, execTests: execTestsExample)
    assertTrue 'build1 date is earlier than build2 date and should have been considered being after',
            (build1 <=> build2) > 0
    assertTrue 'build2 date is later than build1 date and should have been considered being before',
            (build2 <=> build1) < 0
    assertTrue 'Two build with the same date should have been considered at the same comparable level',
            (build1 <=> build5) == 0
  }

  /**
   * Test the various methods of the class, injected getters & setters excluded
   */
  void testBuildMethods() {
    def prod1 = new Product(name: 'proj1', startDate: new Date())
    Build build1 = new Build(name: 'build', date: new Date(), description: 'somedesc',
            state: 1, backlog: prod1)
    def testsExample = [
            new Test(name:'test1', description:'dummy test 1', state:Test.STATE_UNTESTED),
            new Test(name:'test2', description:'dummy test 2', state:Test.STATE_UNTESTED),
            new Test(name:'test3', description:'dummy test 3', state:Test.STATE_FAILED),
            new Test(name:'test4', description:'dummy test 4', state:Test.STATE_TESTED)
    ]
    mockDomain(Test, testsExample)
    def date1 = new Date()
    def date2 = new Date() + 1
    def execTestsExample = [
            new ExecTest(date: date1, state:ExecTest.STATE_NOT_YET_TESTED, build:build1, test:testsExample[0]),
            new ExecTest(date: date1, state:ExecTest.STATE_NOT_YET_TESTED, build:build1, test:testsExample[1]),
            new ExecTest(date: date1, state:ExecTest.STATE_NOT_YET_TESTED, build:build1, test:testsExample[2]),
            new ExecTest(date: date1, state:ExecTest.STATE_NOT_YET_TESTED, build:build1, test:testsExample[3]),
            new ExecTest(date: date2, state:Test.STATE_UNTESTED, build:build1, test:testsExample[0]),
            new ExecTest(date: date2, state:Test.STATE_UNTESTED, build:build1, test:testsExample[1]),
            new ExecTest(date: date2, state:Test.STATE_FAILED, build:build1, test:testsExample[2]),
            new ExecTest(date: date2, state:Test.STATE_TESTED, build:build1, test:testsExample[3])
    ]
    mockDomain(ExecTest, execTestsExample)
    // Associate the execTest with the build
    execTestsExample.each {
      build1.addToExecTests(it)
    }
    
    // GetNbTests() should return the distinct number of tests associate with the build through
    // its execTests attribute
    assertEquals 'GetNbTests() failed', 4, build1.getNbTests()

    // GetNbTestsSucces should return the number of ExecTest with Test.STATE_TESTED state
    assertEquals 'GetNbTestsSucces() failed', 1, build1.getNbTestsSucces()

    // GetNbTestsEchec should return the number of ExecTest with Test.STATE_FAILED state
    assertEquals 'GetNbTestsEchec() failed', 1, build1.getNbTestsEchec()

    // GetNbTotalTests should return the number of tests in the product
    // TODO
  }
}
