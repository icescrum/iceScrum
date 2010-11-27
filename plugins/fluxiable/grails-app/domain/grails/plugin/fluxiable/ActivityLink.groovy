/* Copyright 2006-2007 Graeme Rocher
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package grails.plugin.fluxiable

import grails.util.GrailsNameUtils

class ActivityLink {

  static belongsTo = [activity: grails.plugin.fluxiable.Activity]

  Long activityRef
  String type

  static constraints = {
    type blank: false
  }

  static mapping = {
    cache true
    table 'fluxiable_activity_link'
  }

  static namedQueries = {

    getAllByPoster{ poster ->
      activity{
        eq "posterId", posterId
        eq "posterClass", posterClass
      }
      cache true
    }

    getActivities {instance, link->
      if (!link) {
        projections {
          property "activity"
        }
      }
      eq "activityRef", instance?.id
      eq "type", GrailsNameUtils.getPropertyName(instance.class)
    }

    getTotalActivities {instance ->
      projections {
        rowCount()
      }
      eq "activityRef", instance?.id
      eq "type", GrailsNameUtils.getPropertyName(instance.class)
    }

    getRecentActivities {clazz, link ->
      if (!link) {
        projections {
          property "activity"
        }
      }
      eq "type", GrailsNameUtils.getPropertyName(clazz)
      maxResults 5
      cache true
      activity {
        order "dateCreated", "desc"
      }
    }
  }
}