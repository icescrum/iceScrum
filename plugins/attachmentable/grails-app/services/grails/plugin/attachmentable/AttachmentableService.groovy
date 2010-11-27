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

import javax.activation.MimetypesFileTypeMap
import org.apache.commons.io.FilenameUtils
import grails.util.GrailsNameUtils
import org.codehaus.groovy.grails.commons.ConfigurationHolder as CH
import org.codehaus.groovy.grails.commons.GrailsClassUtils
import org.apache.commons.io.FileUtils

class AttachmentableService {

    static transitional = true

    def grailsApplication

    def addAttachment(def poster, def delegate, File file, def originalName = null) {

        if (delegate.id == null) throw new AttachmentException("You must save the entity [${delegate}] before calling addAttachment")
        if (!file?.length()) throw new AttachmentException("Error file : ${file.getName()} is empty (${file.getAbsolutePath()})")

        def posterClass = poster.class.name
        def i = posterClass.indexOf('_$$_javassist')
        if (i > -1) posterClass = posterClass[0..i - 1]

        def mimetypesFileTypeMap = new MimetypesFileTypeMap()
        def name = originalName?:file.name

        def a = new Attachment(posterId: poster.id,
                               posterClass: posterClass,
                               inputName:name,
                               name: FilenameUtils.getBaseName(name),
                               ext: FilenameUtils.getExtension(name),
                               length: file.length(), contentType: mimetypesFileTypeMap.getContentType(file))

        if (!a.validate()) throw new AttachmentException("Cannot create attachment for arguments [$poster, $file], they are invalid.")
        a.save()

        def delegateClass = delegate.class.name
        i = delegateClass.indexOf('_$$_javassist')
        if (i > -1) delegateClass = delegateClass[0..i - 1]

        def link = new AttachmentLink(attachment: a, attachmentRef: delegate.id, type: GrailsNameUtils.getPropertyName(delegate.class), attachmentRefClass:delegateClass)
        link.save()

        //save the file on disk
        def diskFile = new File(getFileDir(delegate),"${a.id + (a.ext?'.'+a.ext:'')}")
        FileUtils.moveFile(file,diskFile)

        try {
          delegate.onAddAttachment(a)
        } catch (MissingMethodException e) {}

        return delegate
    }

  def removeAttachment(def attachment, def delegate){

    def diskFile = new File(getFileDir(delegate),"${attachment.id + (attachment.ext?'.'+attachment.ext:'')}")
    diskFile.delete()
    try {
      delegate.onRemoveAttachment(attachment)
    } catch (MissingMethodException e) {}

    return delegate
  }

  def removeAttachmentDir(def delegate){
    getFileDir(delegate).deleteDir()
    return delegate
  }

  private getFileDir(def object){
    def dir = CH.config.grails.attachmentable.baseDir
        if (CH.config.grails.attachmentable?."${GrailsClassUtils.getShortName(object.class).toLowerCase()}Dir")
           dir = "${dir}${CH.config.grails.attachmentable?."${GrailsClassUtils.getShortName(object.class).toLowerCase()}Dir"(object)}"
    def fileDir = new File(dir)
    fileDir.mkdirs()
    return fileDir
  }

  def getFile(def attachment){
    def link = AttachmentLink.findByAttachment(attachment)
    def delegate = getClass().classLoader.loadClass(link.attachmentRefClass).get(link.attachmentRef)
    def diskFile = new File(getFileDir(delegate),"${attachment.id + (attachment.ext?'.'+attachment.ext:'')}")
    if (!diskFile){
      throw new  FileNotFoundException()
    }
    return diskFile
  }
}
