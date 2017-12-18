/*
 * Copyright (c) 2014 Kagilum SAS.
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
hibernate {
    jdbc.batch_size = 30
    order_inserts = true
    order_updates = true
    batch_versioned_data = true
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.region.factory_class = 'grails.plugin.cache.ehcache.hibernate.BeanEhcacheRegionFactory4'
}

dataSource {
    configClass = 'org.icescrum.core.domain.IceScrumGormConfiguration'
//    logSql = true
}

environments {
    development {
//        dataSource {
//            dbCreate = "create-drop"
//            username = "sa"
//            password = ""
//            driverClassName = "org.h2.Driver"
//            url = "jdbc:h2:mem:devDb"
//        }
        dataSource {
            dbCreate = "update"
            username = "root"
            password = "root"
            driverClassName = "com.mysql.jdbc.Driver"
            dialect = "org.hibernate.dialect.MySQL5InnoDBDialect"
            url = "jdbc:mysql://localhost:3306/icescrum?useUnicode=true&characterEncoding=utf8"
        }
//        dataSource {
//            dbCreate = "update"
//            username = "root"
//            password = "root"
//            driverClassName = "org.postgresql.Driver"
//            url = "jdbc:postgresql://localhost:5432/icescrum"
//        }
//        dataSource {
//            dbCreate = "update"
//            username = "system"
//            password = "oracle"
//            driverClassName = "oracle.jdbc.driver.OracleDriver"
//            dialect = "com.kagilum.hibernate.OracleCustomDialect"
//            url = "jdbc:oracle:thin:@localhost:49161:XE" // docker run -d -p 49160:22 -p 49161:1521 --name oracle -e ORACLE_PASSWORD_VERIFY=true wnameless/oracle-xe-11g
////            url = "jdbc:oracle:thin:@localhost:1521:xe" // docker run -d -p 8090:8080 -p 1521:1521 --name oracle sath89/oracle-12c
//        }
//        dataSource {
//            dbCreate = "update"
//            username = "sa"
//            password = "<YourStrong!Passw0rd>"
//            driverClassName = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
//            url = "jdbc:sqlserver://localhost:1401;databaseName=icescrum" // docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=<YourStrong!Passw0rd>' -p 1401:1433 --name sql1 -d microsoft/mssql-server-linux:2017-latest
////            url = "jdbc:sqlserver://localhost:1433;databaseName=icescrum"
//        }
    }
    test {
        dataSource {
            dbCreate = "create-drop"
            url = "jdbc:h2:mem:testDb"
            driverClassName = "org.h2.Driver"
            username = "sa"
            password = ""
        }
    }
    production {
        dataSource {
            pooled = true
            username = "sa"
            password = ""
            driverClassName = "org.h2.Driver"
            url = "jdbc:h2:prodDb"
            dbCreate = "update"
            properties {
                initialSize = 5
                maxActive = 50
                minIdle = 5
                maxIdle = 25
                maxWait = 10000
                maxAge = 10 * 60000
                timeBetweenEvictionRunsMillis = 5000
                minEvictableIdleTimeMillis = 60000
                validationQuery = "SELECT 1"
                validationQueryTimeout = 3
                validationInterval = 15000
                testOnBorrow = true
                testWhileIdle = true
                testOnReturn = true
                jdbcInterceptors = "ConnectionState"
                defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_COMMITTED
            }
        }
    }
}