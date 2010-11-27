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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */


package org.icescrum.core.domain

class PlanningPokerGame {
  static final Integer INTEGER_SUITE = 0;
  static final Integer FIBO_SUITE = 1;
  static final int SPECIALCARD_UNKNOW_NUMBER = -2;
  static final int SPECIALCARD_HALF_NUMBER = -3;

  static List<Integer> getInteger(int type, Integer max = 100) {
    def suite = []
    if (type == INTEGER_SUITE) {
      max.times{
        suite << it
      }
    } else if (type == FIBO_SUITE) {
      suite << 0 << 1 << 2 << 3 << 5 << 8 << 13 << 21 << 34
    }
    return suite
  }

  static List<PlanningPokerCard> get(int type, Integer max = 100) {
    List<PlanningPokerCard> suite = new ArrayList<PlanningPokerCard>()
    if (type == INTEGER_SUITE) {
      for (int i = 0; i <= max; i++) {
        suite << new PlanningPokerCard(i)
      }
    } else if (type == FIBO_SUITE) {
      suite << new PlanningPokerCard(0)
      suite << new PlanningPokerCard(1)
      suite << new PlanningPokerCard(2)
      suite << new PlanningPokerCard(3)
      suite << new PlanningPokerCard(5)
      suite << new PlanningPokerCard(8)
      suite << new PlanningPokerCard(13)
      suite << new PlanningPokerCard(21)
      suite << new PlanningPokerCard(34)
    }

    return suite
  }
}
