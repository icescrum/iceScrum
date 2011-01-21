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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

package org.icescrum.components

import org.codehaus.groovy.grails.commons.ArtefactHandlerAdapter
import org.codehaus.groovy.grails.commons.DefaultGrailsClass
import org.codehaus.groovy.grails.commons.GrailsClass

class UiControllerArtefactHandler extends ArtefactHandlerAdapter {
  static final TYPE = "UIController"
  static final PROPERTY = 'ui'
  static final PLUGINNAME = 'pluginName'

  UiControllerArtefactHandler() {
    super(TYPE, GrailsClass, DefaultGrailsClass, TYPE)
  }

  boolean isArtefactClass(Class clazz) {
    // The default isArtefactClass() is not used to match the UIController classes
    // in order to prevent interference with the controllers plugin artefact handler.
    // The matching is done manually in the doWithDynamicMethods closure in the plugin descriptor
    return false
  }
}
