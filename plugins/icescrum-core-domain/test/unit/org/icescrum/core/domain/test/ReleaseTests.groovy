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
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint

class ReleaseTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Product)
    mockDomain(Release)
    mockDomain(Sprint)
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testReleaseInit() {
    // Product
    def product = new Product(name: "test", startDate: new Date())
    product.save()

    // Release persistence test
    def release = new Release(backlog: product, name: "rr", startDate: new Date(), endDate: new Date(), description: 'do this')
    assertTrue 'Release should have passed validation.', release.validate()
    release.save()

    assertEquals 'Release not persisted', 1, Release.count()
  }

  void testReleaseGetFirstDate() {
    // Product
    def product = new Product(name: "test", startDate: new Date())
    product.save()

    // Release
    def release = new Release(backlog: product, name: "rr", startDate: new Date(), endDate: new Date(), description: 'do this')
    release.save()

    // Test getFirstDate without sprint, it should return the release's startDate
    assertEquals '[NoSprint] getFirstDate() method should have returned the release\'s startDate', release.startDate, release.getFirstDate()

    // Add sprint to release and try again
    def sprint = new Sprint(parentRelease:release, description:'do that', orderNumber:1, state:Sprint.STATE_WAIT, startDate:new Date(), endDate:new Date()+1)
    release.addToSprints(sprint)
    assertEquals '[Sprint] getFirstDate() method should have returned the release\'s last sprint endDate', release.sprints.asList().last().endDate, release.getFirstDate()
  }
}
