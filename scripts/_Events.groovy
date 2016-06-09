import grails.util.Environment

/*
* Copyright (c) 2015 Kagilum SAS
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
*/
eventCreateWarStart = {warname, stagingDir ->
    ant.propertyfile(file: "${stagingDir}/WEB-INF/classes/application.properties") {
        ant.antProject.properties.findAll({k, v -> k.startsWith('environment')}).each { k, v ->
            entry(key: k, value: v)
        }
        entry(key: 'scm.version', value: getRevision())
        entry(key: 'build.date', value: new Date())
        if (System.getProperty("app.version.suffix")){
            println "app.version.suffix has been set to: ${System.getProperty("app.version.suffix")}"
            entry(key: 'app.version', value: ' '+System.getProperty("app.version.suffix"), operation:'+')
        }
        else if (System.getProperty("app.version.cloud")){
            println "app.version.cloud has been set to: Pro Cloud"
            entry(key: 'app.version', value: ' Pro Cloud', operation:'+')
        }
    }
}

eventSetClasspath = {
        if (System.getProperty('icescrum.clean') == 'true'){
            println "----- DELETE OLD ICESCRUM CORE START ---------"
            String iceScrumCore = "${userHome}/.ivy2/cache/org.icescrum/icescrum-core"
            String iceScrumCoreP = "${projectWorkDir}/plugins/icescrum-core-1.7-SNAPSHOT"
            file = new File(iceScrumCore)
            if (file.exists()){
                println "----- deleting.... ${iceScrumCore}--------"
                ant.delete(dir:iceScrumCore)
            }
            file = new File(iceScrumCoreP)
            if (file.exists()){
                println "----- deleting.... ${iceScrumCoreP}--------"
                ant.delete(dir:iceScrumCoreP)
            }
            println "----- DELETE OLD ICESCRUM CORE END ----------"
        }
}

def getRevision() {
    def determineRevisionClosure = buildConfig.buildinfo.determineRevision
    if (determineRevisionClosure instanceof Closure) {
        return determineRevisionClosure()
    }

    // try to get revision from Hudson
    def scmVersion = ant.antProject.properties."environment.SVN_REVISION"

    // if Hudson env variable not found, try file system (for SVN)
    if (!scmVersion) {
        File entries = new File(basedir, '.svn/entries')
        if (entries.exists()) {
            scmVersion = entries.text.split('\n')[3].trim()
        }
    }

    return scmVersion ?: 'UNKNOWN'
}