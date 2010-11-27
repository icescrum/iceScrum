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

class ProductTests extends GrailsUnitTestCase {

  protected void setUp() {
    super.setUp()
    // Mock the domain classes
    mockDomain(Product)
  }

  /**
   * Test basic instanciation and persistence of the class, and its constraints 
   */
  void testProductInit() {
    // Test minimal Product persistence validation, it should only need a productName and a startDate
    def dumProd = new Product(name: 'proj1', startDate: new Date())
    assertTrue 'Product instanciated with productName and startDate parameters pass validation', dumProd.validate()
    dumProd.save(flush: true)

    // Check if the instance has been persisted
    assertEquals 1, Product.list().size()

    // Test of Product instanciation without parameter, it should fail validation
    dumProd = new Product()
    assertFalse 'Product with no parameters should have failed validation', dumProd.validate()

    // Test of Product constraints :
    // -> startDate is required
    dumProd = new Product(name: 'proj2')
    assertFalse 'Product without startDate parameter should have failed validation', dumProd.validate()

    // -> productName is unique and required
    dumProd = new Product(startDate: new Date())
    assertFalse 'Product without productName parameter should have failed validation', dumProd.validate()
    dumProd = new Product(name: 'proj1', startDate: new Date())
    assertFalse 'Product with duplicate name should have failed validation', dumProd.validate()
  }

  /**
   * Test the class compareTo and equals methods
   */
  void testProductComparators() {
    // Two instances of Product are equals if they share the same productName
    def prod1 = new Product(name: 'proj1', startDate: new Date())
    def prod2 = new Product(name: 'proj1', startDate: new Date())
    def prodDiff = new Product(name: 'proj2', startDate: new Date())
    assertTrue 'Product with the same productName should have been considered equals', prod1.equals(prod2)
    assertFalse 'Product with different productName should not have been considered equals', prod1.equals(prodDiff)

    // The class compareTo method should apply a lexical comparison on the productName (string-based comparison)
    def prod3 = new Product(name: 'aProj', startDate: new Date())
    def prod4 = new Product(name: 'zProj', startDate: new Date())
    //assertTrue 'Product named "aProj" should have been considered before the product "zProj"', (prod3 <=> prod4) < 0
    //assertTrue 'Product named "zProj" should have been considered before the product "aProj"', (prod4 <=> prod3) > 0
    assertTrue 'Two instances of a Product named "proj1" should have been considered equals', (prod1 <=> prod2) == 0

    // Test the compareTo effect when sorting
    def toSort = [prod4, prod3, prod1]
    def shouldBe = [prod3, prod1, prod4]
    assertEquals 'Array of Product instances failed ascending sorting', toSort.sort(), shouldBe
  }
}
