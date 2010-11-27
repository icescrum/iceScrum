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
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User

class ReleaseIntegrationTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
  }

  void testNamedQueries() {
    // Initialize test data
    // Product
    def prod = new Product(name: 'test', startDate: new Date())
    assertTrue 'Product failed validation', prod.validate()
    prod.save()
    // Release
    def rel = new Release(backlog: prod, name: 'r1', goal: 'g1', startDate: new Date(), endDate: new Date() + 1)
    assertTrue 'Release failed validation.', rel.validate()
    rel.save()
    prod.addToReleases(rel)

    // Sprint
    def sprint = new Sprint(parentRelease: rel, goal: "do that", orderNumber: 1, state: Sprint.STATE_WAIT, startDate: new Date(), endDate: new Date() + 1)
    sprint.save()
    assertTrue 'Sprint failed validation.', sprint.validate()
    rel.addToSprints(sprint)

    // User
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language: "en")
    assertTrue 'User failed validation.', user.validate()
    user.save(flush:true)

    // PBIs
    def pbis = [
            new Story(name: 'Story0', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_INPROGRESS),
            new Story(name: 'Story1', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_INPROGRESS),
            new Story(name: 'Story2', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_SUGGESTED),
            new Story(name: 'Story3', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_ACCEPTED, rank: 3),
            new Story(name: 'Story4', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_DONE),
            new Story(name: 'Story5', backlog:prod, parentSprint:sprint, creator: user, state: Story.STATE_DONE)
    ]
    pbis*.save(flush: true)
    pbis.each { prod.addToStories(it) }
    pbis.each { sprint.addToStories(it) }
    pbis*.setEffort(1)

    // Check the pointsForOneRelease named query,
    // it should return the sum of the effort of the pbi in the release
    assertEquals 'pointsForOneRelease namedQuery did not return the expected result:', 6, Release.pointsForOneRelease(rel, false).list()[0]

    // Check the pointsForOneRelease named query,
    // it should return the sum of the effort of the pbi in the release
    assertEquals 'pointsForOneRelease namedQuery did not return the expected result:', 5, Release.pointsForOneRelease(rel, true).list()[0]
  }

  void testReleaseDeletion() {
    def prod = new Product(name: 'test', startDate: new Date())
    prod.save()
    def rel = new Release(backlog: prod, name: 'r1', goal: 'g1', startDate: new Date(), endDate: new Date() + 1)
    assertTrue 'Release failed validation.', rel.validate()
    rel.save()
    prod.addToReleases(rel)

    // Check if the objects have actually been persisted
    assertEquals 'Product not persisted', 1, Product.count()
    assertEquals 'Release not persisted', 1, Release.count()
    assertEquals 'Session release not in product', 1, prod.releases.size()

    prod.removeFromReleases(rel)

    // Check if the release has actually been deleted
    assertEquals 'Product deleted', 1, Product.count()
    assertEquals 'Release not deleted', 0, Release.count()
    assertEquals 'Session release still in product', 0, prod.releases.size()
  }
}
