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
import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User

class ImpedimentIntegrationTests extends GrailsUnitTestCase {
  /**
   * Test the namedQueries of the domain class
   */
  void testNamedQueries() {
    // Create dummy projects and user
    def product = new Product(name:"proj1", startDate:new Date())
    def product2 = new Product(name: 'someProject2', startDate: new Date())
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language:"en"
    )
    def user2 = new User(username: "ab",
            email: "abdb@mail.com",
            password: "defgsngfdgsdhfvsvcbs",
            language:"en"
    )
    product.save()
    product2.save()
    user.save()
    user2.save()

    // Persists a few Impediment in the BD
    [
            new Impediment(backlog: product, creator: user, name: 'prob1', rank: 1, state: Impediment.TODO),
            new Impediment(backlog: product, creator: user, name: 'prob2', rank: 4, state: Impediment.TODO),
            new Impediment(backlog: product2, creator: user, name: 'prob3', rank: 3, state: Impediment.SOLVING),
            new Impediment(backlog: product2, creator: user, name: 'prob4', rank: 2, state: Impediment.SOLVED)
    ]*.save(flush: true)

    // Check that the impediment have actually been persisted
    assertEquals Impediment.list().size(), 4

    // Check the filterByUnassignedImpediments namedQuery,
    // it should return the impediment which states are Impediment.UNASSIGNED from the product specified
    def test = Impediment.filterByUnassignedImpediments(product).count()
    assertEquals 'FilterByUnassignedProblems namedQuery did not return the expected result', 2, test

    // Check the filterBySolvingImpediments namedQuery,
    // it should return the impediment which states are Impediment.SOLVING from the product specified
    test = Impediment.filterBySolvingImpediments(product2).count()
    assertEquals 'FilterBySolvingProblems namedQuery did not return the expected result', 1, test

    // Check the filterBySolvedImpediments namedQuery,
    // it should return the impediment which states are Impediment.SOLVED from the product specified
    test = Impediment.filterBySolvedImpediments(product2).count()
    assertEquals 'FilterBySolvedProblem namedQuery did not return the expected result', 1, test

    // Check the rankMax namedQuery,
    // it should return the highest rank for a specified product id
    def maxForProduct1 = Impediment.rankMax(product.id).list()[0]
    assertEquals 'Rankmax namedQuery did not return the expected result', 4, maxForProduct1
  }
}