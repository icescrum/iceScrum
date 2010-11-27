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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */


package org.icescrum.core.services

import grails.util.Environment
import org.icescrum.core.security.AuthorityManager
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.test.DummyPopulator

class BootStrapService {

  void start() {

    AuthorityManager.initSecurity()
    ApplicationSupport.generateFolders()

    if (Environment.current == Environment.DEVELOPMENT)
      DummyPopulator.dummyze()
  }
}
