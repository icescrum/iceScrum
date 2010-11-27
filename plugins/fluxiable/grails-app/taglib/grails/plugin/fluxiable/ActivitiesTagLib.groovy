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

class ActivitiesTagLib {

	static namespace = "activities"
	
	def each =  { attrs, body ->
		def bean = attrs.bean
		def varName = attrs.var ?: "activity"
		if(bean?.metaClass?.hasProperty(bean, "comments")) {
			bean.activities?.each {
				out << body((varName):it)
			}
		}
	}
	
	def eachRecent = { attrs, body ->
		def domain = attrs.domain
		if(!domain && attrs.bean) domain = attrs.bean?.class
		def varName = attrs.var ?: "activity"
				
		if(domain) {
			domain.recentActivity?.each {
				out << body((varName):it)				
			}
		}
	}


}