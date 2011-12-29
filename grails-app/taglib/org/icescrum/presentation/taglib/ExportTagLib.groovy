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
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */
package org.icescrum.presentation.taglib

class ExportTagLib {
  static namespace = 'is'

  def objectAsXML = { attrs,body ->
    assert attrs.object
    pageScope.object = attrs.object
    pageScope.propertiesObject = []
    pageScope.listsObjects = []
    pageScope.propertiesChildObject = []
    attrs.indentLevel = attrs.indentLevel?attrs.indentLevel.toInteger():0

    def id = pageScope.object.id?:null
    def uid = pageScope.object.hasProperty('uid')?pageScope.object.uid:null

    body()
    if (attrs.root){
      out << "<?xml version='1.0' encoding='UTF-8'?>\n"  
    }else{
      (attrs.indentLevel).times{out << "\t"}      
    }

    if (uid != null){
        out << "<${attrs.node} ${uid != null ?'uid=\''+uid+'\'':''}>\n"
    }else{
        out << "<${attrs.node} ${id?'id=\''+id+'\'':''}>\n"
    }

    pageScope.propertiesObject.each{
      if (it.value != null){
        (attrs.indentLevel+1).times{out << "\t"}
        out << "<${it.node?:it.name}>"
        out << (it.cdata?'<![CDATA[':'')+it.value+(it.cdata?']]>':'')        
        out << "</${it.node?:it.name}>\n"
      }else{
        (attrs.indentLevel+1).times{out << "\t"}
         out << "<${it.node?:it.name}/>\n"
      }
    }

    pageScope.propertiesChildObject.each{
      (attrs.indentLevel+1).times{out << "\t"}

      if (it.propertiesObject){
        out << "<${it.name}>\n"
        it.propertiesObject.each{ it2 ->
          (attrs.indentLevel+2).times{out << "\t"}          
          out << "<${it2.node}>"
          out << it2.value
          out << "</${it2.node}>\n"
        }
        (attrs.indentLevel+1).times{out << "\t"}
        out << "</${it.name}>\n"
      }else {
        out << "<${it.name} ${it.uid != null ?'uid=\''+it.uid+'\'': it.id?'id=\''+it.id+'\'':'' }/>\n"
      }

    }

    pageScope.listsObjects.each{
      out << it
    }
    attrs.indentLevel.times{out << "\t"}
    out << "</${attrs.node}>\n"
  }

  def propertyAsXML = { attrs, body ->
    if(!pageScope.propertiesObject && !pageScope.propertiesChildObject && !attrs.name)
      return

    def options
    if (attrs.object){
       def object = [:]
       object.name = attrs.object
       object.id = pageScope.object."${attrs.object}"?.id?:null
       if (pageScope.object."${attrs.object}"?.hasProperty('uid')){
           object.uid = pageScope.object."${attrs.object}"?.uid?:null
       }
       object.propertiesObject = []
       if (attrs.name){
        attrs.name.each {
          object.propertiesObject << [value:pageScope.object."${attrs.object}"."${it}",node:it]
        }
       }
       pageScope.propertiesChildObject << object  

    }
    else if (attrs.name instanceof List){
      attrs.name.each {
         options = [
              value:pageScope.object."${it}",
              node:attrs.node?:it,
              cdata:attrs.cdata?:false,
              name:it
            ]
         pageScope.propertiesObject << options
      }
    }else{
       options = [
              value:pageScope.object."${attrs.name}",
              node:attrs.node?:attrs.name,
              cdata:attrs.cdata?:false,
              name:attrs.name
            ]
       pageScope.propertiesObject << options
    }
  }

  def listAsXML = { attrs, body ->
    if(!pageScope.listsObjects && !attrs.template)
      return
    attrs.indentLevel = attrs.indentLevel?attrs.indentLevel.toInteger():1

    if (attrs.deep && !(attrs.deep instanceof List)){
      attrs.deep = attrs.deep?attrs.deep.toBoolean():true
    }else if(!attrs.deep){
      attrs.deep = true  
    }

    def objects
    if (attrs.expr){
      objects = pageScope.object."${attrs.name}".findAll(attrs.expr)  
    }else{
      objects = pageScope.object."${attrs.name}"
    }
    if (objects){
      attrs.indentLevel.times{pageScope.listsObjects << "\t"}
      pageScope.listsObjects << "<${attrs.node?:attrs.name}>\n"
      objects.each{
        if (attrs.deep == true || (attrs.deep instanceof List && attrs.child in attrs.deep)){
          pageScope.listsObjects << render(template:attrs.template, model:[object:it,deep:attrs.deep,indentLevel:attrs.indentLevel+1])
        }else{
          (attrs.indentLevel+1).times{pageScope.listsObjects << "\t"}
          pageScope.listsObjects << "<${attrs.child} ${it.hasProperty('uid') ? 'uid=\''+it.uid+'\'' : 'id=\''+it.id+'\''}/>\n"
        }
      }
      attrs.indentLevel.times{pageScope.listsObjects << "\t"}
      pageScope.listsObjects << "</${attrs.node?:attrs.name}>\n"
    }else{
      attrs.indentLevel.times{pageScope.listsObjects << "\t"}
      pageScope.listsObjects << "<${attrs.node?:attrs.name}/>\n"
    }
  }
}
