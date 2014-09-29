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
 */

dataSource {
    driverClassName = "org.hsqldb.jdbcDriver"
    username = "sa"
    password = ""
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}

// environment specific settings
environments {
    development {
        dataSource {
            /*driverClassName="com.mysql.jdbc.Driver"
            dialect="org.hibernate.dialect.MySQL5InnoDBDialect"
            url="jdbc:mysql://localhost:3306/icescrum?useUnicode=true&characterEncoding=utf8"
            username="root"
            password="root"
            driverClassName = "oracle.jdbc.driver.OracleDriver"
            dialect = "org.hibernate.dialect.Oracle10gDialect"
            username = "kagilum"
            password = "kagilum"
            dbCreate = "update" // one of 'create', 'create-drop','update'
            url = "jdbc:oracle:thin:@192.168.0.10:1521:XE"*/
            //dbCreate = "update"
            dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            url = "jdbc:hsqldb:file:devDba"
            loggingSql = false

            // POSTGRESQL
/*            driverClassName = "org.postgresql.Driver"
            username = "postgres"
            password = "root"
            url = "jdbc:postgresql://localhost:5432/icescrum"*/

            // SQL Server
/*            driverClassName = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
            username = "sa"
            password = "root"
            url = "jdbc:sqlserver://localhost:1433;databaseName=icescrum"*/

            // Oracle
/*            dataSource.driverClassName = "oracle.jdbc.driver.OracleDriver"
            dataSource.dialect = "org.hibernate.dialect.Oracle10gDialect"
            dataSource.url = "jdbc:oracle:thin:@localhost:1521:XE"
            dataSource.username = "root"
            dataSource.password = "root"*/
        }
    }
    test {
        dataSource {
            dbCreate = "create-drop"
            url = "jdbc:hsqldb:file:testDba"
        }
    }
    production {
        dataSource {
            dbCreate = "update"
            url = "jdbc:hsqldb:file:prodDba;shutdown=true"
            pooled = true
            properties {
                maxActive = 50
                maxIdle = 25
                minIdle = 5
                initialSize = 5
                minEvictableIdleTimeMillis = 180000
                timeBetweenEvictionRunsMillis = 180000
                maxWait = 10000
                numTestsPerEvictionRun = 3
                testOnBorrow = true
                testWhileIdle = true
                testOnReturn = true
                validationQuery = "SELECT 1"
            }
        }
    }
}