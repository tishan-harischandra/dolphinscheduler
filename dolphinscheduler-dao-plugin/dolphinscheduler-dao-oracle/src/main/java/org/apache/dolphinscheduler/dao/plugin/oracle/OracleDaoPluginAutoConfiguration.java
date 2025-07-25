/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.dolphinscheduler.dao.plugin.oracle;

import org.apache.dolphinscheduler.dao.plugin.api.DaoPluginConfiguration;
import org.apache.dolphinscheduler.dao.plugin.api.dialect.DatabaseDialect;
import org.apache.dolphinscheduler.dao.plugin.api.monitor.DatabaseMonitor;
import org.apache.dolphinscheduler.dao.plugin.oracle.dialect.OracleDialect;
import org.apache.dolphinscheduler.dao.plugin.oracle.monitor.OracleMonitor;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

import com.baomidou.mybatisplus.annotation.DbType;

@Configuration(proxyBeanMethods = false)
@Conditional(OracleDatabaseEnvironmentCondition.class)
public class OracleDaoPluginAutoConfiguration implements DaoPluginConfiguration {

    @Autowired
    private DataSource dataSource;

    @Override
    public DbType dbType() {
        return DbType.ORACLE;
    }

    @Override
    public DatabaseMonitor databaseMonitor() {
        return new OracleMonitor(dataSource);
    }

    @Override
    public DatabaseDialect databaseDialect() {
        return new OracleDialect(dataSource);
    }
}
