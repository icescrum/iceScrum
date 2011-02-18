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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

package org.icescrum.core.services

import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.domain.User
import org.icescrum.core.event.IceScrumActorEvent

class ActorService {

  static transactional = true
  def springSecurityService

  void addActor(Actor act, Product p) {
    act.name = act.name?.trim()
    act.backlog = p

    if (!act.save())
      throw new RuntimeException()
    publishEvent(new IceScrumActorEvent(act,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
  }

  void deleteActor(Actor act) {
    act.delete()
    publishEvent(new IceScrumActorEvent(act,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
  }

  void updateActor(Actor act) {
    act.name = act.name?.trim()
    if (!act.save(flush:true))
      throw new RuntimeException()
    publishEvent(new IceScrumActorEvent(act,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }

  @Transactional(readOnly = true)
  def unMarshallActor(NodeChild actor){
    try{
       def a = new Actor(
            name:actor.name.text(),
            description:actor.description.text(),
            notes:actor.notes.text(),
            creationDate:new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(actor.creationDate.text()),
            instances:(actor.instances.text().isNumber())?actor.instances.text().toInteger():0,
            useFrequency:(actor.useFrequency.text().isNumber())?actor.useFrequency.text().toInteger():2,
            expertnessLevel:(actor.expertnessLevel.text().isNumber())?actor.expertnessLevel.text().toInteger():1,
            satisfactionCriteria:actor.satisfactionCriteria.text(),
            idFromImport:actor.@id.text().toInteger()
       )
      return a
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }
  }
}