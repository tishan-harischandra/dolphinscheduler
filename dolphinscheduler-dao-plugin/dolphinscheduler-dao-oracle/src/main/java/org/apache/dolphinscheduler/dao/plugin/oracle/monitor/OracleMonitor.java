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
        monitorRecord.setDbType(DbType.ORACLE);
        monitorRecord.setState(DatabaseMetrics.DatabaseHealthStatus.YES);

        try (
                Connection connection = dataSource.getConnection();
                Statement pstmt = connection.createStatement()) {

            // Get max sessions (Oracle equivalent to max connections)
            try (ResultSet rs1 = pstmt.executeQuery("SELECT value FROM v$parameter WHERE name = 'sessions'")) {
                if (rs1.next()) {
                    monitorRecord.setMaxConnections(Long.parseLong(rs1.getString("value")));
                }
            }

            // Get current session information
            try (ResultSet rs2 = pstmt.executeQuery("SELECT status, count(*) as cnt FROM v$session GROUP BY status")) {
                long totalSessions = 0;
                long activeSessions = 0;
                while (rs2.next()) {
                    String status = rs2.getString("status");
                    long count = rs2.getLong("cnt");
                    totalSessions += count;
                    if ("ACTIVE".equals(status)) {
                        activeSessions = count;
                    }
                }
                monitorRecord.setThreadsConnections(totalSessions);
                monitorRecord.setThreadsRunningConnections(activeSessions);
            }

            // Oracle doesn't have a direct equivalent to MySQL's max_used_connections
            // We'll set it to current total sessions as an approximation
            monitorRecord.setMaxUsedConnections(monitorRecord.getThreadsConnections());

        }
        return monitorRecord;
    }
}
