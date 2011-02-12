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


package org.icescrum.core.support

import org.codehaus.groovy.grails.commons.ApplicationHolder

class ApplicationSupport {
  static public generateFolders = {
    def config = ApplicationHolder.application.config
    def dirPath = config.icescrum.baseDir.toString() + File.separator + "images" + File.separator + "users" + File.separator
    def dir = new File(dirPath)
    if (!dir.exists())
      dir.mkdirs()
    println dirPath
    config.icescrum.images.users.dir = dirPath

    dirPath = config.icescrum.baseDir.toString() + File.separator + "images" + File.separator + "products" + File.separator
    dir = new File(dirPath)
    if (!dir.exists())
      dir.mkdirs()
    config.icescrum.products.users.dir = dirPath

    dirPath = config.icescrum.baseDir.toString() + File.separator + "images" + File.separator + "teams" + File.separator
    dir = new File(dirPath)
    if (!dir.exists())
      dir.mkdirs()
    config.icescrum.products.teams.dir = dirPath
  }

  // See http://jira.codehaus.org/browse/GRAILS-6515
  public static booleanValue(def value) {
      if (value.class == java.lang.Boolean) {
          // because 'true.toBoolean() == false' !!!
          return value
      } else if(value.class == ConfigObject){
        return value.asBoolean()
      } else if(value.class == Closure){
        return value()
      }
      else {
          return value.toBoolean()
      }
  }

}
