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

import grails.test.*
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User

class StoriesIntegrationTests extends GrailsUnitTestCase {
    void testNamedQueries() {
      // Initialize test data
      // User
      def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language: "en")
      user.save()

      // Product
      def product = new Product(name:"test", startDate:new Date())
      product.save()

      // Feature (feature)
      def th = new Feature(backlog:product, name:'A certain feature')
      th.save()

      // Release
      def release = new Release(backlog:product, name:"rr", startDate:new Date(), endDate:new Date(), goal:"do this")
      release.save()
      product.addToReleases(release)

      // Sprints
      def sprint = new Sprint(parentRelease:release, goal:"do that", orderNumber:1, state:Sprint.STATE_WAIT, startDate:new Date(), endDate:new Date()+1)
      def sprint2 = new Sprint(parentRelease:release, goal:"do that", orderNumber:2, state:Sprint.STATE_WAIT, startDate:new Date()+2, endDate:new Date()+3)
      sprint.save()
      sprint2.save()
      release.addToSprints(sprint)
              .addToSprints(sprint2)

      // ProductBacklogItems
      def pbis = [
              new Story(name:'Story0', backlog:product, parentSprint:sprint, creator:user, state:Story.STATE_INPROGRESS, estimatedDate: new Date()),
              new Story(name:'Story1', parentSprint:sprint, creator:user, state:Story.STATE_INPROGRESS, estimatedDate: new Date()),
              new Story(name:'Story2', parentSprint:sprint2, creator:user, state:Story.STATE_PLANNED, estimatedDate:new Date()),
              new Story(name:'Story3', backlog:product, creator:user, state:Story.STATE_SUGGESTED),
              new Story(name:'Story4', parentSprint:sprint2, creator:user, state:Story.STATE_PLANNED, estimatedDate:new Date(), rank:4),
              new Story(name:'Story5', backlog:product, creator:user, state:Story.STATE_ESTIMATED, estimatedDate:new Date()-3),
              new Story(name:'Story6', backlog:product, creator:user, state:Story.STATE_ESTIMATED, estimatedDate:new Date()),
              new Story(name:'Story7', backlog:product, creator:user, state:Story.STATE_ESTIMATED, estimatedDate:new Date()),
              new Story(name:'Story8', backlog:product, creator:user, state:Story.STATE_ACCEPTED),
              new Story(name:'Story9', backlog:product, creator:user, state:Story.STATE_ACCEPTED, rank:1),
              new Story(name:'Story10', backlog:product, creator:user, state:Story.STATE_ACCEPTED, rank:2),
              new Story(name:'Story11', backlog:product, creator:user, state:Story.STATE_ACCEPTED, rank:3),
              new Story(name:'Story12', backlog:product, creator:user, state:Story.STATE_DONE),
              new Story(name:'Story13', parentSprint:sprint, creator:user, state:Story.STATE_DONE, estimatedDate: new Date())
      ]
      // Set some estimated points to the sprints that are in state STATE_ESTIMATED or in a sprint
      pbis[0].setEffort(1)
      pbis[1].setEffort(1)
      pbis[2].setEffort(1)
      pbis[4].setEffort(1)
      pbis[5].setEffort(1)
      pbis[6].setEffort(1)
      pbis[7].setEffort(1)
      pbis[13].setEffort(1)
      pbis*.save(flush:true)
      pbis[0].creationDate = new Date() - 3
      pbis.each { product.addToStories(it) }
      th.addToStories(pbis[1])
      th.addToStories(pbis[2])
      sprint.addToStories(pbis[0])
              .addToStories(pbis[1])
              .addToStories(pbis[13])
      sprint2.addToStories(pbis[2])
              .addToStories(pbis[4])

      // Check the filterByAllItems namedQuery
      // it should return the all the Pbi of the product (pseudo-stories excludes)
      assertEquals 'filterByAllItems namedQuery did not return the expected result:', 14, Story.filterByAllItems(product).size()

      // Check the filterByFeature namedQuery
      assertEquals 'filterByFeature namedQuery did not return the expected result:', 2, Story.filterByFeature(product, th).list().size()

      // Check the countByItemsBtwCreationDate method (use 2 namedQueries)
      // it should return the number of Pbi of the product which
      // creation date is between a certain interval specified as arguments
      def startDate = new Date()
      def endDate = new Date()+1
      // In this test, one of the PBI's creation date has been set to (new Date() - 3),
      // so pnly the number of result should be (totalNumberOfPBI - 1) 
      assertEquals 'countByItemsBtwCreationDate method did not return the expected result:',
              13,
              Story.countByItemsBtwCreationDate(product, startDate-1, endDate)

      // Check the countByItemsBtwEstimationDate method (use 2 namedQueries)
      // it should return the number of Pbi of the product which
      // estimation date is between a certain interval specified as arguments
      assertEquals 'countByItemsBtwEstimationDate method did not return the expected result:',
              8,
              Story.countByItemsBtwEstimationDate(product, startDate-4, endDate)

      // Check the countByIdentifiedItemsProductBeforeDate method (use 2 namedQueries)
      // it should return the number of Pbi of the product which
      // creation date is before a certain specified date if specified and estimatedPoint != SPRINT_POINT
      assertEquals 'countByIdentifiedItemsProductBeforeDate method did not return the expected result:',
              1,
              Story.countByIdentifiedItemsProductBeforeDate(product, startDate-1)
      
      // If date == null, count the number of PBI which estimatedPoint != SPRINT_POINT
      assertEquals 'countByIdentifiedItemsProductBeforeDate with null date method did not return the expected result:',
              14,
              Story.countByIdentifiedItemsProductBeforeDate(product, null)

      // Check the countByEstimatedItemsProductBeforeDate method (use 2 namedQueries)
      // it should return the number of Pbi of the product which
      // estimation date is before a certain specified date and state is at least STATE_ESTIMATED
      assertEquals 'countByEstimatedItemsProductBeforeDate method did not return the expected result:',
              1,
              Story.countByEstimatedItemsProductBeforeDate(product, startDate-1)

      // Check the pointsFromBacklog method (use 1 namedQuery)
      // it should return the total number of points in the backlog
      // (product backlog only, pbis in sprints are not taken in account)
      assertEquals 'pointsFromBacklog method did not return the expected result:',
              3,
              Story.totalPoint(product.id).list()[0]
    }
}
