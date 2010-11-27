/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 *
 */

package grails.plugin.attachmentable

class AttachmentsTagLib {

	static namespace = "attachments"

	def each =  { attrs, body ->
		def bean = attrs.bean
		def varName = attrs.var ?: "attachment"
		if(bean?.metaClass?.hasProperty(bean, "attachments")) {
			bean.attachments?.each {
				out << body((varName):it)
			}
		}
	}

	def eachRecent = { attrs, body ->
		def domain = attrs.domain
		if(!domain && attrs.bean) domain = attrs.bean?.class
		def varName = attrs.var ?: "attachment"

		if(domain) {
			domain.recentAttachments?.each {
				out << body((varName):it)
			}
		}
	}
}
