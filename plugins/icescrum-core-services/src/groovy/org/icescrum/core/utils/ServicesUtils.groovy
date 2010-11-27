package org.icescrum.core.utils

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

class ServicesUtils {

  public static boolean isDateWeekend(Date date){
    def c = Calendar.getInstance()
    c.setTime(date)
    switch (c.get(Calendar.DAY_OF_WEEK)){
      case Calendar.SATURDAY:
      case Calendar.SUNDAY:
        return true
        break
      default:
        return false
    }
  }
}