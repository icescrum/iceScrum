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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */


package org.icescrum.core.services

import grails.util.BuildSettingsHolder
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware

class DropImportService implements ApplicationContextAware {
  ApplicationContext applicationContext
  def messageSource
  def grailsApplication

  /**
   * Parse a text and try to retrieve sets of data
   * @param data
   * @return A Map containing a list of columns and values, or NULL if the data is not a table (see isTabFormat method)
   */
  def parseText(data) {
    if(!isTabFormat(data)){
      return null
    }
    // Parse the first line of the string, each tab character is considered as a
    // column separator
    def parsedData = [
            columns: data.toString().replace('\r', '').split("\n")[0].split("\t"),
            count:0,
            data:[:]
    ]

    // The whole text is then split on tab character
    def splittedData = data.replace('\r', '').replace('\n', "\t").split("\t")
    def processedData = [:]

    parsedData.columns.each {
      processedData."${it}" = []
    }

    def nbCols = parsedData.columns.size()

    // The splitted data are affected to the columns retrieved
    for (int i = nbCols; i < splittedData.size(); i++) {
      processedData[splittedData[i % nbCols]] << splittedData[i]
    }
    parsedData.data = processedData
    parsedData.count = (splittedData.size() / nbCols) - 1
    
    return parsedData
  }

  /**
   * Try to automatically match the columns' names (submitted by a user) and the
   * actual mapping name, using the resource bundle
   * @param mapping
   * @param columns
   * @return
   */
  def matchBundle(mapping, columns){
    // Retrieve the list of available locales
    List locales = []
    def i18n
    if (grailsApplication.warDeployed) {
      i18n = applicationContext.getResource("WEB-INF/grails-app/i18n/").getFile().toString()
    } else {
      i18n = "$BuildSettingsHolder.settings.baseDir/grails-app/i18n"
    }
    //Default language
    locales <<  new Locale("en")
    new File(i18n).eachFile {
      def arr = it.name.split("[_.]")
      if (arr[1] != 'svn' && arr[1] != 'properties')
        locales << (arr.length > 3 ? new Locale(arr[1], arr[2]) : arr.length > 2 ? new Locale(arr[1]) : new Locale(""))
    }

    // For each locale, try to find a match with the column's name
    def matchValues = [:]
    locales.each {locale ->
      mapping.each { mapEntry ->
        def match = columns.find { messageSource.getMessage(mapEntry.value, null, null, locale).toLowerCase() == it.toLowerCase() }
        if(match){
          matchValues."${mapEntry.key}" = match
        }
      }
    }

    return matchValues
  }

  /**
   * Determine whether the data is a valid tab formated table or not
   * @param data
   * @return
   */
  def isTabFormat(data) {
    // The text must have at least 2 lines
    // (first line for the columns names, one (or more) line(s) for the values)
    def splitted = data.split('\n')
    if(splitted.size() < 2){
      return false
    }

    // In order to distinguish an actual table to raw data, we set a limit of characters on the columns name
    if(true in (splitted[0].split('\t')*.length().collect{ it > 40})){
      return false
    }
    
    // If there are more than 1 column (at least 1 tabulation on the first line), then the following lines
    // must have the same number of tab character
    def colsNb = splitted[0].count('\t')
    def maxLines = splitted.size()

    for(int i = 0; i < maxLines; i++){
      if(splitted[i].count('\t') != colsNb){
        return false
      }
    }
    
    return true
  }
}
