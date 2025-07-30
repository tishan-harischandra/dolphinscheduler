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

package org.apache.dolphinscheduler.dao.plugin.oracle.monitor;

import org.apache.dolphinscheduler.dao.plugin.api.monitor.DatabaseMetrics;
import org.apache.dolphinscheduler.dao.plugin.api.monitor.DatabaseMonitor;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;

import javax.sql.DataSource;

import lombok.SneakyThrows;

import com.baomidou.mybatisplus.annotation.DbType;

public class OracleMonitor implements DatabaseMonitor {

    private final DataSource dataSource;

    public OracleMonitor(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @SneakyThrows
    @Override
    public DatabaseMetrics getDatabaseMetrics() {
        DatabaseMetrics monitorRecord = new DatabaseMetrics();
        monitorRecord.setDate(new Date());
        monitorRecord.setDbType(DbType.ORACLE_12C);
        monitorRecord.setState(DatabaseMetrics.DatabaseHealthStatus.YES);

        try (
                Connection connection = dataSource.getConnection();
                Statement pstmt = connection.createStatement()) {

            // Get maximum allowed sessions from V$RESOURCE_LIMIT
            try (
                    ResultSet rs1 = pstmt.executeQuery(
                            "SELECT CURRENT_UTILIZATION, MAX_UTILIZATION, LIMIT_VALUE " +
                                    "FROM V$RESOURCE_LIMIT " +
                                    "WHERE RESOURCE_NAME = 'sessions'")) {
                if (rs1.next()) {
                    // Set max connections to the limit value
                    long limitValue = rs1.getLong("LIMIT_VALUE");
                    monitorRecord.setMaxConnections(limitValue);

                    // Set max used connections to the max utilization
                    long maxUtilization = rs1.getLong("MAX_UTILIZATION");
                    monitorRecord.setMaxUsedConnections(maxUtilization);
                }
            }

            // Get current number of sessions from V$SESSION
            try (
                    ResultSet rs2 = pstmt.executeQuery(
                            "SELECT COUNT(*) AS session_count FROM V$SESSION")) {
                if (rs2.next()) {
                    monitorRecord.setThreadsConnections(rs2.getLong("session_count"));
                }
            }

            // Get number of active sessions from V$SESSION
            try (
                    ResultSet rs3 = pstmt.executeQuery(
                            "SELECT COUNT(*) AS active_count FROM V$SESSION WHERE STATUS = 'ACTIVE'")) {
                if (rs3.next()) {
                    monitorRecord.setThreadsRunningConnections(rs3.getLong("active_count"));
                }
            }
        }
        return monitorRecord;
    }
}
