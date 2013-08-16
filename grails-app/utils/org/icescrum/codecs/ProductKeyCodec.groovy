/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

package org.icescrum.codecs

import org.icescrum.core.domain.Product

class ProductKeyCodec {

  static final numeric = /[0-9]*/

  static decode = { theTarget ->

    if (!theTarget || theTarget ==~ numeric ) {
      return theTarget
    }

    Product.createCriteria().get {
      eq 'pkey', theTarget
      projections {
        property 'id'
      }
      cache true
    }

  }

}
