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

import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.User
import org.codehaus.groovy.grails.web.metaclass.BindDynamicMethod
import org.codehaus.groovy.grails.commons.metaclass.GroovyDynamicMethodsInterceptor

import groovy.util.slurpersupport.NodeChild
import java.text.SimpleDateFormat
import org.springframework.transaction.annotation.Transactional
import org.icescrum.core.event.IceScrumEvent
import org.icescrum.core.event.IceScrumFeatureEvent

class FeatureService {

   FeatureService() {
      GroovyDynamicMethodsInterceptor i = new GroovyDynamicMethodsInterceptor(this)
      i.addDynamicMethodInvocation(new BindDynamicMethod())
   }

  static transactional = true
  def productService
  def springSecurityService

  void saveFeature(Feature feature, Product p) {

    feature.name = feature.name.trim()

    def rankProvided = null
    if (feature.rank != null)
      rankProvided = feature.rank

    //We force last rank (if another rank has benn provide we will update it below    
    feature.rank = p.features?.size() + 1

    feature.backlog = p
    if (!feature.save()){
      throw new RuntimeException()
    }
    p.addToFeatures(feature).save()

    //We put the real rank if we need
    if(rankProvided)
      changeRank(p,feature,rankProvided)

    publishEvent(new IceScrumFeatureEvent(feature,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_CREATED))
  }

  void deleteFeature(Feature _feature, Product p) {

    def stillHasPbi = p.stories.any {it.feature?.id == _feature.id}
    if(stillHasPbi)
      throw new RuntimeException()

    def oldRank = _feature.rank
    p.removeFromFeatures(_feature)

    //update rank on all features after that one
    p.features.each { it ->
      if (it.rank > oldRank) {
        it.rank = it.rank - 1
        it.save()
      }
    }
    publishEvent(new IceScrumFeatureEvent(_feature,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_DELETED))
  }

  void updateFeature(Feature _feature, Product p) {
    _feature.name = _feature.name.trim()

    if (!_feature.save(flush:true)){
      throw new RuntimeException()
    }
    publishEvent(new IceScrumFeatureEvent(_feature,this.class,User.get(springSecurityService.principal?.id),IceScrumEvent.EVENT_UPDATED))
  }

  void copyFeatureToProductBacklog(long featureID, long userID){
    def feature = Feature.get(featureID)
    def story = new Story(
            name:feature.name,
            description:feature.description,
            suggestedDate:new Date(),
            acceptedDate:new Date(),
            state:Story.STATE_ACCEPTED,
            feature:feature,
            creator:User.get(userID),
            rank:Story.findAllAcceptedOrEstimated(feature.backlog.id).list().size() + 1,
            backlog:feature.backlog
    )
    if(!story.save()){
      throw new RuntimeException(story.errors.toString())
    }
    publishEvent(new IceScrumFeatureEvent(feature,story,this.class,User.get(springSecurityService.principal?.id),IceScrumFeatureEvent.EVENT_COPIED_AS_STORY))
  }

  double calculateFeatureCompletion(Feature _feature, Product _p, Release _r = null) {
    def stories = Story.filterByFeature(_p, _feature, _r).list()

    if (stories.size() == 0)
      return 0d

    double items = stories.size()
    double itemsDone = stories.findAll{it.state == Story.STATE_DONE}.size()

    return itemsDone / items
  }

  boolean changeRank(Product product, Feature movedItem, int rank) {
      if (movedItem.rank != rank){
        if(movedItem.rank > rank){
            product.features.sort().each{it ->
            if(it.rank >= rank && it.rank <= movedItem.rank && it != movedItem){
              it.rank = it.rank + 1
              it.save()
            }
          }
        }else{
          product.features.sort().each{it ->
            if(it.rank <= rank && it.rank >= movedItem.rank && it != movedItem){
              it.rank = it.rank - 1
              it.save()
            }
          }
        }
        movedItem.rank = rank
        return movedItem.save()
      }else{
        return false
      }
  }

  def productParkingLotValues(Product product){
      def values = []
      product.features?.each{ it ->
        def value = 100d * calculateFeatureCompletion(it, product)
        values << [label:it.name, value:value]
      }
      return values
  }

  def releaseParkingLotValues(Release release){
      def values = []
      release.parentProduct.features?.each{ it ->
        def value = 100d * calculateFeatureCompletion(it, release.parentProduct, release)
        values << [label:it.name, value:value]
      }
      return values
  }

  @Transactional(readOnly = true)
  def unMarshallFeature(NodeChild feat){
    try{
       def f = new Feature(
          name: feat.name.text(),
          description: feat.description.text(),
          notes: feat.notes.text(),
          color: feat.color.text(),
          creationDate: new SimpleDateFormat('yyyy-MM-dd HH:mm:ss').parse(feat.creationDate.text()),
          value: feat.value.text().toInteger(),
          type : feat.type.text().toInteger(),
          rank: feat.rank.text()?.toInteger()?:null,
          idFromImport:feat.@id.text().toInteger()
       )
      return f
    }catch (Exception e){
      if (log.debugEnabled) e.printStackTrace()
      throw new RuntimeException(e)
    }
  }
}