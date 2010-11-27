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
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User

class StoryTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Story)
    mockDomain(Product)
    mockDomain(User)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints
   */
  void testStoryInit() {
    // Test minimal PBI persistence validation, it should need a label and a backlog as parameters
    def dumProd = new Product(name: 'proj1', startDate: new Date())
    dumProd.save()
    def dumPbi = new Story(name:'A certain story', backlog:dumProd)
    assertTrue 'Story instanciated with label and backlog should have succeed validation', dumPbi.validate()
    dumPbi.save(flush:true)

    // Check that the Pbi has actually been persisted
    assertEquals 'Persistence of valid dumPbi failed ', 1, Story.list().size()

    // Test constraints
    // The PBI must have a label
    dumPbi = new Story(backlog:dumProd)
    assertFalse 'Validation of Story without label should have failed', dumPbi.validate()

    // The PBI must have a backlog
    assertFalse 'Validation of Story without backlog should have failed', dumPbi.validate()
  }
}
