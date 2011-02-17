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
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */

package org.icescrum.core.services

import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User

class ImpedimentService {

  static transactional = true

  def productService

  int saveImpediment(Impediment impediment, Product p, User u) {

    impediment.name = impediment.name?.trim()

    if (!impediment.name)
      return NAME_REQUIRE

    impediment.backlog = p
    impediment.rank = (Impediment.rankMax(p.id).list()[0] ?: 0) + 1
    impediment.creator = u

    if (!impediment.save())
      return ERROR
    
    u.addToImpediments(impediment).save()
    p.addToImpediments(impediment).save()

    return VALIDATE
  }

  int updateImpediment(Impediment _impediment,  User uCurrent, Product p) {
    _impediment.name = _impediment.name?.trim()

    if (!_impediment.name)
      return NAME_REQUIRE
    if (_impediment.state != Impediment.TODO)
      if (!businessRulesService.isSM(uCurrent, p))
        return NO_RIGHTS
    if (_impediment.state == Impediment.SOLVED && !_impediment.solution?.trim())
      return NO_SOLUTION
    assert _impediment.validate()
    try{
      if (!_impediment.save(flush:true))
        return ERROR
    } catch(Exception e) {
      if (log.debugEnabled) e.printStackTrace()
    }
    return VALIDATE
  }

  int deleteImpediment(Impediment _impediment, Product p, User uCurrent) {
    // Verify rights
    if (!businessRulesService.isSM(uCurrent, p) && (_impediment.creator != uCurrent) )
      return NO_RIGHTS

    int rank = _impediment.rank
    p.removeFromImpediments(_impediment)
    p.save()
    resetRank(p, rank)

    return VALIDATE
  }

  //vieu code
  void changeRank(Product product, Impediment movedItem, Impediment targetItem) {
    int newRank
    int targetRank = targetItem.rank

    // Move item after targetItem
    if (movedItem.rank < targetItem.rank) {
      newRank = movedItem.rank
      product.impediments.each { pb ->
        if(pb.rank > movedItem.rank && pb.rank <= targetRank) {
          pb.rank = newRank++
          pb.save()
        }
      }
    // Move item before targetItem
    } else {
      newRank = targetRank
      product.impediments.each { pb ->
        if(pb.rank >= targetRank){
          pb.rank = ++newRank
          pb.save()
        }
      }
    }
    movedItem.rank = targetRank
    movedItem.save()

    product.impediments = product.impediments.sort() as Set
    productService.updateProduct(product, false)
  }

  void resetRank(Product product, int newPbiRank) {
    int i = newPbiRank
    product.impediments.each { pb ->
      if (pb.rank >= newPbiRank) {
        pb.rank = i++
        pb.save()
      }
    }
  }

  List<Impediment> filterByUnassignedImpediments(Product p) {
    return Impediment.filterByUnassignedImpediments(p).list()
  }

  List<Impediment> filterBySolvingImpediments(Product p) {
    return Impediment.filterBySolvingImpediments(p).list()
  }

  List<Impediment> filterBySolvedImpediments(Product p) {
    return Impediment.filterBySolvedImpediments(p).list()
  }
}