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
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 */


import grails.util.Environment
import grails.util.GrailsNameUtils

grails.servlet.version = "3.0"
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.7
grails.project.source.level = 1.7
grails.project.war.file = "target/${appName}.war"
grails.project.dependency.resolver = "maven"
grails.project.war.osgi.headers = false
grails.tomcat.nio = true

def jvmArgs = ['-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005',
               '-Dicescrum.plugins.dir=' + System.getProperty("icescrum.plugins.dir"),
//               '-Dicescrum.noDummyze=true',
//               '-Dicescrum.largeDummyze=true',
               '-Dicescrum.clean=true',
               '-Dfile.encoding=UTF-8',
               '-Duser.timezone=UTC']

grails.project.fork = [
        test: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, daemon: true],
        run : [maxMemory: 1024, minMemory: 512, debug: false, maxPerm: 256, forkReserve: false, jvmArgs: jvmArgs],
        war : [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve: false]
]

if (Environment.current != Environment.PRODUCTION) {
    println "use inline plugin in env: ${Environment.current}"
    grails.plugin.location.'icescrum-core' = '../plugins/icescrum-core'
    //grails.plugin.location.'kagilum-licenseable' = '../plugins/kagilum-licenseable'
}

grails.war.resources = { stagingDir ->
    copy(todir: "${stagingDir}/WEB-INF/classes/grails-app/i18n") {
        fileset(dir: "grails-app/i18n") {
            include(name: "report*")
        }
    }
}

grails.project.dependency.resolution = {
    inherits("global") {
        excludes "xml-apis", "maven-publisher", "itext"
    }
    log "warn"
    repositories {
        grailsPlugins()
        grailsCentral()
        grailsHome()
        mavenCentral()
        // To help grails to compile and find jar depencies form icescrum-core, otherwise it's limited to one / day
        mavenRepo("http://repo.spring.io/libs-release") {
            updatePolicy "interval:1"
        }
        mavenRepo("http://repo.icescrum.org/artifactory/plugins-release/") {
            updatePolicy "interval:1"
        }
        mavenRepo("http://repo.icescrum.org/artifactory/plugins-snapshot/") {
            updatePolicy "interval:1"
        }
    }
    dependencies {
        build 'com.lowagie:itext:2.1.7'
        runtime 'mysql:mysql-connector-java:5.1.40'
    }
    plugins {
        compile ':cache-headers:1.1.7'
        compile ':asset-pipeline:2.11.0'
        compile ':less-asset-pipeline:2.11.0'
        compile ':browser-detection:2.8.0'
        runtime ':hibernate4:4.3.10'
        runtime 'org.grails.plugins:database-migration:1.4.1'
        build ':tomcat:7.0.70'
        compile 'org.icescrum:entry-points:1.4'
        if (Environment.current == Environment.PRODUCTION) {
            compile 'org.icescrum:icescrum-core:1.7-SNAPSHOT'
            compile 'org.icescrum:standalone:8.5.27.3'
        }
    }
}

def iceScrumPluginsDir = System.getProperty("icescrum.plugins.dir") ?: false
println "Compile and use icescrum plugins : ${iceScrumPluginsDir ? true : false}"

if (iceScrumPluginsDir) {
    "${iceScrumPluginsDir}".split(";").each {
        File dir = new File(it.toString())
        println "Scanning plugin dir : ${dir.canonicalPath}"

        if (dir.exists()) {
            File descriptor = dir.listFiles(new FilenameFilter() {
                public boolean accept(File file, String s) {
                    return s.endsWith("GrailsPlugin.groovy");
                }
            })[0] ?: null;

            if (descriptor) {
                String name = GrailsNameUtils.getPluginName(descriptor.getName());
                println "found plugin : ${name}"
                grails.plugin.location."${name}" = "${it}"
            }
        } else {
            println "no plugin found in dir"
        }

    }
}