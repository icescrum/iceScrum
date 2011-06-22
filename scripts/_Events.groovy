import grails.util.PluginBuildSettings
import java.util.regex.Matcher
import grails.util.GrailsNameUtils
import org.codehaus.groovy.grails.cli.GrailsScriptRunner
import org.apache.catalina.connector.Connector
import org.apache.tools.ant.taskdefs.Ant

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
*/

eventCreateWarStart = {warname, stagingDir ->
    Ant.propertyfile(file: "${stagingDir}/WEB-INF/classes/application.properties") {
        Ant.antProject.properties.findAll({k, v -> k.startsWith('environment')}).each { k, v ->
            entry(key: k, value: v)
        }
        entry(key: 'scm.version', value: getRevision())
        entry(key: 'build.date', value: new Date())
    }
}

def getRevision() {
    def determineRevisionClosure = buildConfig.buildinfo.determineRevision
    if (determineRevisionClosure instanceof Closure) {
        return determineRevisionClosure()
    }

    // try to get revision from Hudson
    def scmVersion = Ant.antProject.properties."environment.SVN_REVISION"

    // if Hudson env variable not found, try file system (for SVN)
    if (!scmVersion) {
        File entries = new File(basedir, '.svn/entries')
        if (entries.exists()) {
            scmVersion = entries.text.split('\n')[3].trim()
        }
    }

    return scmVersion ?: 'UNKNOWN'
}

eventConfigureTomcat = {tomcat ->
    def ajpConnector = new Connector("org.apache.coyote.http11.Http11NioProtocol")
    ajpConnector.port = 8009
    ajpConnector.setProperty("redirectPort", "8443")
    ajpConnector.setProperty("protocol", "AJP/1.3")
    ajpConnector.setProperty("enableLookups", "false")
    tomcat.service.addConnector ajpConnector
}