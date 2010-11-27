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
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Product

class FeatureTests extends GrailsUnitTestCase {
  protected void setUp() {
    super.setUp()
    mockDomain(Product)
    mockDomain(Feature)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints
   */
  void testFeatureInit() {
    // Test basic persistence, a Feature only need a name and a product as parameters
    def prod = new Product(name:'proj', startDate:new Date())
    prod.save()

    def feat = new Feature(backlog:prod, name:'A certain feature')
    assertTrue 'Feature with product and name parameters should have been validated.', feat.validate()
    feat.save(flush:true)
    prod.addToFeatures(feat)
    
    // Check if the custom role has actually been persisted
    assertEquals 'Feature has not been successfully persisted.', 1, Feature.count()

    // Test basic constraints
    // A Actor cannot be validated if he has no name
    def feat2 = new Feature(backlog:prod)
    assertFalse 'Feature without name should have failed validation.', feat2.validate()

    // A Actor cannot be validated if he has no product
    feat2 = new Feature(name:'A certain feature')
    assertFalse 'Feature without backlog should have failed validation.', feat2.validate()
  }
}
