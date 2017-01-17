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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */

import grails.util.GrailsNameUtils
import grails.util.Environment

grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.war.file = "target/${appName}.war"

grails.project.war.osgi.headers = false

def environment = Environment.getCurrent()

if (environment != Environment.PRODUCTION){
    println "use inline plugin in env: ${environment}"
    grails.plugin.location.'icescrum-core' = '../plugins/icescrum-core'
}

coverage {
    enabledByDefault = false
    xml = true
}

grails.war.resources = { stagingDir ->
    copy(todir: "${stagingDir}/WEB-INF/classes/grails-app/i18n") {
        fileset(dir: "grails-app/i18n") {
            include(name: "report*")
        }
    }
}

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global"){
        excludes 'mail', 'xml-apis'
    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    repositories {
        grailsPlugins()
        grailsCentral()
        grailsHome()

        // uncomment the below to enable remote dependency resolution
        // from public Maven repositories
        //mavenLocal()
        mavenCentral()
        //mavenRepo "http://snapshots.repository.codehaus.org"
        mavenRepo "http://repository.codehaus.org"
        mavenRepo "http://repo.icescrum.org/artifactory/plugins-release/"
        mavenRepo "http://repo.icescrum.org/artifactory/plugins-snapshot/"
    }

    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
        runtime 'mysql:mysql-connector-java:5.1.37'
        runtime 'commons-dbcp:commons-dbcp:1.4'
        compile 'javax.mail:mail:1.4.7' // By default, grails installs 1.4.3 which doesn't support NTLM
    }

    plugins {
        compile "org.icescrum:entry-points:0.4.2"
        compile ":cache-headers:1.1.5"
        compile ":cached-resources:1.0"
        compile ":feeds:1.5"
        compile ":hibernate:1.3.9"
        compile ":resources:1.1.6"
        compile ":session-temp-files:1.0"
        compile ":zipped-resources:1.0"
        compile ":yui-minify-resources:0.1.5"
        compile ":browser-detection:0.4.3"
        if (environment == Environment.PRODUCTION){
            compile "org.icescrum:icescrum-core:1.6-SNAPSHOT"
            compile ":tomcat:1.3.9"
        }else{
            compile ":tomcatnio:1.3.4"
        }
    }
}

//iceScrum plugins management
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