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
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User

class ProductIntegrationTests extends GrailsUnitTestCase {
  /**
   * Test a product deletion and its effect on its associations
   */
  void testProductDeletion() {
    // Initialize test data
    // Product
    def prod1 = new Product(name: 'proj1', startDate: new Date())
    prod1.save()

    // Release
    def rel = new Release(backlog: prod1, name: "rr", startDate: new Date(), endDate: new Date(), goal: "do this")
    rel.save()
    prod1.addToReleases(rel)

    // Sprint
    def sprint = new Sprint(parentRelease: rel, goal: "do that", orderNumber: 1, state: Sprint.STATE_WAIT, startDate: new Date(), endDate: new Date() + 1)
    sprint.save()
    rel.addToSprints(sprint)

    // User
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language: "en")
    user.save()

    // Impediment
    def prob = new Impediment(backlog:prod1, creator:user, name:'prob1')
    prob.save()
    prod1.addToImpediments(prob)

    // CustomRoles
    def cr = new Actor(product:prod1, name:'Chicken')
    cr.save()
    prod1.addToActors(cr)

    // Feature (Feature)
    def th = new Feature(backlog:prod1, name:'A certain feature')
    th.save()
    prod1.addToFeatures(th)

    // Cliche
    def cl = new Cliche(backlog:prod1, datePrise:new Date())
    cl.save()
    prod1.addToCliches(cl)

    // PBIs
    def pbis = [
            new Story(name: 'Story0', parentSprint: sprint, creator: user, state: Story.STATE_INPROGRESS),
            new Story(name: 'Story1', parentSprint: sprint, creator: user, state: Story.STATE_INPROGRESS),
            new Story(name: 'Story2', feature:th, backlog: prod1, creator: user, state: Story.STATE_SUGGESTED),
            new Story(name: 'Story3', backlog: prod1, creator: user, state: Story.STATE_ACCEPTED, rank: 3),
            new Story(name: 'Story4', backlog: prod1, creator: user, state: Story.STATE_DONE),
            new Story(name: 'Story5', parentSprint: sprint, creator: user, state: Story.STATE_DONE)
    ]
    pbis*.save(flush: true)
    prod1.addToStories(pbis[2]).addToStories(pbis[3]).addToStories(pbis[4])
    sprint.addToStories(pbis[0]).addToStories(pbis[1]).addToStories(pbis[5])
    th.addToStories(pbis[2])

    // Check if all the data have been successfully persisted
    assertEquals 'Product has not been persisted successfully.', 1, Product.count()
    assertEquals 'Release has not been persisted successfully.', 1, Release.count()
    assertEquals 'Sprint has not been persisted successfully.', 1, Sprint.count()
    assertEquals 'Impediment has not been persisted successfully.', 1, Impediment.count()
    assertEquals 'Actor has not been persisted successfully.', 1, Actor.count()
    assertEquals 'Feature has not been persisted successfully.', 1, Feature.count()
    assertEquals 'Cliche has not been persisted successfully.', 1, Cliche.count()
    assertEquals 'ProductBacklogItems have not been persisted successfully.', 6, Story.count()
    assertEquals 'User has not been persisted successfully.', 1, User.count()
    
    // When a product is deleted, everything associated with it should be deleted as well, except:
    // - User attached to a project (via their role) must not be deleted from the application (only their Role)
    user.removeFromRoles(role)
    user.removeFromRoles(role2)
    prod1.delete(flush: true)

    // Check if all the data have been successfully deleted, except the Users
    assertEquals 'Product has not been deleted successfully.', 0, Product.count()
    assertEquals 'Release has not been deleted successfully.', 0, Release.count()
    assertEquals 'Sprint has not been deleted successfully.', 0, Sprint.count()
    assertEquals 'Impediment has not been deleted successfully.', 0, Impediment.count()
    assertEquals 'Actor has not been deleted successfully.', 0, Actor.count()
    assertEquals 'Feature has not been deleted successfully.', 0, Feature.count()
    assertEquals 'Cliche has not been deleted successfully.', 0, Cliche.count()
    assertEquals 'ProductBacklogItems have not been deleted successfully.', 0, Story.count()
    assertEquals 'User should not have been deleted.', 1, User.count()

    // Check if the user actually no longer has its association with the role deleted
    //assertEquals 'User still reference supposedly deleted roles.', 0, user.roles.size()
  }
}
