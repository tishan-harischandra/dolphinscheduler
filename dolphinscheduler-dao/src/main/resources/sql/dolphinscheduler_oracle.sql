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

@helpers-oracle.sql

drop_table_if_exists('QRTZ_FIRED_TRIGGERS');
drop_table_if_exists('QRTZ_PAUSED_TRIGGER_GRPS');
drop_table_if_exists('QRTZ_SCHEDULER_STATE');
drop_table_if_exists('QRTZ_LOCKS');
drop_table_if_exists('QRTZ_SIMPLE_TRIGGERS');
drop_table_if_exists('QRTZ_SIMPROP_TRIGGERS');
drop_table_if_exists('QRTZ_CRON_TRIGGERS');
drop_table_if_exists('QRTZ_BLOB_TRIGGERS');
drop_table_if_exists('QRTZ_TRIGGERS');
drop_table_if_exists('QRTZ_JOB_DETAILS');
drop_table_if_exists('QRTZ_CALENDARS');

CREATE TABLE qrtz_job_details
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    JOB_NAME  VARCHAR2(200) NOT NULL,
    JOB_GROUP VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(250) NULL,
    JOB_CLASS_NAME VARCHAR2(250) NOT NULL,
    IS_DURABLE VARCHAR2(1) NOT NULL,
    IS_NONCONCURRENT VARCHAR2(1) NOT NULL,
    IS_UPDATE_DATA VARCHAR2(1) NOT NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NOT NULL,
    JOB_DATA BLOB NULL,
    CONSTRAINT QRTZ_JOB_DETAILS_PK PRIMARY KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE qrtz_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    JOB_NAME  VARCHAR2(200) NOT NULL,
    JOB_GROUP VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(250) NULL,
    NEXT_FIRE_TIME NUMBER(13) NULL,
    PREV_FIRE_TIME NUMBER(13) NULL,
    PRIORITY NUMBER(13) NULL,
    TRIGGER_STATE VARCHAR2(16) NOT NULL,
    TRIGGER_TYPE VARCHAR2(8) NOT NULL,
    START_TIME NUMBER(13) NOT NULL,
    END_TIME NUMBER(13) NULL,
    CALENDAR_NAME VARCHAR2(200) NULL,
    MISFIRE_INSTR NUMBER(2) NULL,
    JOB_DATA BLOB NULL,
    CONSTRAINT QRTZ_TRIGGERS_PK PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    CONSTRAINT QRTZ_TRIGGER_TO_JOBS_FK FOREIGN KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
        REFERENCES QRTZ_JOB_DETAILS(SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE qrtz_simple_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    REPEAT_COUNT NUMBER(7) NOT NULL,
    REPEAT_INTERVAL NUMBER(12) NOT NULL,
    TIMES_TRIGGERED NUMBER(10) NOT NULL,
    CONSTRAINT QRTZ_SIMPLE_TRIG_PK PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    CONSTRAINT QRTZ_SIMPLE_TRIG_TO_TRIG_FK FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_cron_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    CRON_EXPRESSION VARCHAR2(120) NOT NULL,
    TIME_ZONE_ID VARCHAR2(80),
    CONSTRAINT QRTZ_CRON_TRIG_PK PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    CONSTRAINT QRTZ_CRON_TRIG_TO_TRIG_FK FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_simprop_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    STR_PROP_1 VARCHAR2(512) NULL,
    STR_PROP_2 VARCHAR2(512) NULL,
    STR_PROP_3 VARCHAR2(512) NULL,
    INT_PROP_1 NUMBER(10) NULL,
    INT_PROP_2 NUMBER(10) NULL,
    LONG_PROP_1 NUMBER(13) NULL,
    LONG_PROP_2 NUMBER(13) NULL,
    DEC_PROP_1 NUMERIC(13,4) NULL,
    DEC_PROP_2 NUMERIC(13,4) NULL,
    BOOL_PROP_1 VARCHAR2(1) NULL,
    BOOL_PROP_2 VARCHAR2(1) NULL,
    CONSTRAINT QRTZ_SIMPROP_TRIG_PK PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    CONSTRAINT QRTZ_SIMPROP_TRIG_TO_TRIG_FK FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_blob_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    BLOB_DATA BLOB NULL,
    CONSTRAINT QRTZ_BLOB_TRIG_PK PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    CONSTRAINT QRTZ_BLOB_TRIG_TO_TRIG_FK FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_calendars
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    CALENDAR_NAME  VARCHAR2(200) NOT NULL,
    CALENDAR BLOB NOT NULL,
    CONSTRAINT QRTZ_CALENDARS_PK PRIMARY KEY (SCHED_NAME,CALENDAR_NAME)
);

CREATE TABLE qrtz_paused_trigger_grps
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    TRIGGER_GROUP  VARCHAR2(200) NOT NULL,
    CONSTRAINT QRTZ_PAUSED_TRIG_GRPS_PK PRIMARY KEY (SCHED_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_fired_triggers
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    ENTRY_ID VARCHAR2(95) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    INSTANCE_NAME VARCHAR2(200) NOT NULL,
    FIRED_TIME NUMBER(13) NOT NULL,
    SCHED_TIME NUMBER(13) NOT NULL,
    PRIORITY NUMBER(13) NOT NULL,
    STATE VARCHAR2(16) NOT NULL,
    JOB_NAME VARCHAR2(200) NULL,
    JOB_GROUP VARCHAR2(200) NULL,
    IS_NONCONCURRENT VARCHAR2(1) NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NULL,
    CONSTRAINT QRTZ_FIRED_TRIGGER_PK PRIMARY KEY (SCHED_NAME,ENTRY_ID)
);

CREATE TABLE qrtz_scheduler_state
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    INSTANCE_NAME VARCHAR2(200) NOT NULL,
    LAST_CHECKIN_TIME NUMBER(13) NOT NULL,
    CHECKIN_INTERVAL NUMBER(13) NOT NULL,
    CONSTRAINT QRTZ_SCHEDULER_STATE_PK PRIMARY KEY (SCHED_NAME,INSTANCE_NAME)
);

CREATE TABLE qrtz_locks
(
    SCHED_NAME VARCHAR2(120) NOT NULL,
    LOCK_NAME  VARCHAR2(40) NOT NULL,
    CONSTRAINT QRTZ_LOCKS_PK PRIMARY KEY (SCHED_NAME,LOCK_NAME)
);

create index idx_qrtz_j_req_recovery on qrtz_job_details(SCHED_NAME,REQUESTS_RECOVERY);
create index idx_qrtz_j_grp on qrtz_job_details(SCHED_NAME,JOB_GROUP);

create index idx_qrtz_t_j on qrtz_triggers(SCHED_NAME,JOB_NAME,JOB_GROUP);
create index idx_qrtz_t_jg on qrtz_triggers(SCHED_NAME,JOB_GROUP);
create index idx_qrtz_t_c on qrtz_triggers(SCHED_NAME,CALENDAR_NAME);
create index idx_qrtz_t_g on qrtz_triggers(SCHED_NAME,TRIGGER_GROUP);
create index idx_qrtz_t_state on qrtz_triggers(SCHED_NAME,TRIGGER_STATE);
create index idx_qrtz_t_n_state on qrtz_triggers(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_STATE);
create index idx_qrtz_t_n_g_state on qrtz_triggers(SCHED_NAME,TRIGGER_GROUP,TRIGGER_STATE);
create index idx_qrtz_t_next_fire_time on qrtz_triggers(SCHED_NAME,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_st on qrtz_triggers(SCHED_NAME,TRIGGER_STATE,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_misfire on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_st_misfire on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_STATE);
create index idx_qrtz_t_nft_st_misfire_grp on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_GROUP,TRIGGER_STATE);

create index idx_qrtz_ft_trig_inst_name on qrtz_fired_triggers(SCHED_NAME,INSTANCE_NAME);
create index idx_qrtz_ft_inst_job_req_rcvry on qrtz_fired_triggers(SCHED_NAME,INSTANCE_NAME,REQUESTS_RECOVERY);
create index idx_qrtz_ft_j_g on qrtz_fired_triggers(SCHED_NAME,JOB_NAME,JOB_GROUP);
create index idx_qrtz_ft_jg on qrtz_fired_triggers(SCHED_NAME,JOB_GROUP);
create index idx_qrtz_ft_t_g on qrtz_fired_triggers(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP);
create index idx_qrtz_ft_tg on qrtz_fired_triggers(SCHED_NAME,TRIGGER_GROUP);


--------------------------------------------------------------------------------
-- Drop all tables (call once)
--------------------------------------------------------------------------------
BEGIN
  drop_table_if_exists('T_DS_ACCESS_TOKEN');
  drop_table_if_exists('T_DS_ALERT');
  drop_table_if_exists('T_DS_ALERTGROUP');
  drop_table_if_exists('T_DS_COMMAND');
  drop_table_if_exists('T_DS_DATASOURCE');
  drop_table_if_exists('T_DS_ERROR_COMMAND');
  drop_table_if_exists('T_DS_WORKFLOW_DEFINITION');
  drop_table_if_exists('T_DS_WORKFLOW_DEFINITION_LOG');
  drop_table_if_exists('T_DS_TASK_DEFINITION');
  drop_table_if_exists('T_DS_TASK_DEFINITION_LOG');
  drop_table_if_exists('T_DS_WORKFLOW_TASK_RELATION');
  drop_table_if_exists('T_DS_WORKFLOW_TASK_RELATION_LOG');
  drop_table_if_exists('T_DS_WORKFLOW_INSTANCE');
  drop_table_if_exists('T_DS_PROJECT');
  drop_table_if_exists('T_DS_PROJECT_PARAMETER');
  drop_table_if_exists('T_DS_PROJECT_PREFERENCE');
  drop_table_if_exists('T_DS_QUEUE');
  drop_table_if_exists('T_DS_RELATION_DATASOURCE_USER');
  drop_table_if_exists('T_DS_RELATION_WORKFLOW_INSTANCE');
  drop_table_if_exists('T_DS_RELATION_PROJECT_USER');
  drop_table_if_exists('T_DS_RELATION_RESOURCES_USER');
  drop_table_if_exists('T_DS_RELATION_UDFS_USER');
  drop_table_if_exists('T_DS_RESOURCES');
  drop_table_if_exists('T_DS_SCHEDULES');
  drop_table_if_exists('T_DS_SESSION');
  drop_table_if_exists('T_DS_TASK_INSTANCE');
  drop_table_if_exists('T_DS_TASK_INSTANCE_CONTEXT');
  drop_table_if_exists('T_DS_TENANT');
  drop_table_if_exists('T_DS_UDFS');
  drop_table_if_exists('T_DS_USER');
  drop_table_if_exists('T_DS_VERSION');
  drop_table_if_exists('T_DS_WORKER_GROUP');
  drop_table_if_exists('T_DS_RELATION_PROJECT_WORKER_GROUP');
  drop_table_if_exists('T_DS_PLUGIN_DEFINE');
  drop_table_if_exists('T_DS_ALERT_PLUGIN_INSTANCE');
  drop_table_if_exists('T_DS_ENVIRONMENT');
  drop_table_if_exists('T_DS_ENVIRONMENT_WORKER_GROUP_RELATION');
  drop_table_if_exists('T_DS_TASK_GROUP_QUEUE');
  drop_table_if_exists('T_DS_TASK_GROUP');
  drop_table_if_exists('T_DS_AUDIT_LOG');
  drop_table_if_exists('T_DS_K8S');
  drop_table_if_exists('T_DS_K8S_NAMESPACE');
  drop_table_if_exists('T_DS_RELATION_NAMESPACE_USER');
  drop_table_if_exists('T_DS_ALERT_SEND_STATUS');
  drop_table_if_exists('T_DS_CLUSTER');
  drop_table_if_exists('T_DS_FAV_TASK');
  drop_table_if_exists('T_DS_RELATION_SUB_WORKFLOW');
  drop_table_if_exists('T_DS_WORKFLOW_TASK_LINEAGE');
  drop_table_if_exists('T_DS_JDBC_REGISTRY_DATA');
  drop_table_if_exists('T_DS_JDBC_REGISTRY_LOCK');
  drop_table_if_exists('T_DS_JDBC_REGISTRY_CLIENT_HEARTBEAT');
  drop_table_if_exists('T_DS_JDBC_REGISTRY_DATA_CHANGE_EVENT');
END;

--------------------------------------------------------------------------------
-- TABLES
--------------------------------------------------------------------------------

CREATE TABLE T_DS_ACCESS_TOKEN (
                                   ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                   USER_ID       NUMBER(10),
                                   TOKEN         VARCHAR2(64),
                                   EXPIRE_TIME   TIMESTAMP(6),
                                   CREATE_TIME   TIMESTAMP(6),
                                   UPDATE_TIME   TIMESTAMP(6),
                                   CONSTRAINT PK_T_DS_ACCESS_TOKEN PRIMARY KEY (ID)
);

CREATE TABLE T_DS_ALERT (
                            ID                         NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                            TITLE                      VARCHAR2(512),
                            SIGN                       VARCHAR2(40) DEFAULT '' NOT NULL,
                            CONTENT                    CLOB,
                            ALERT_STATUS               NUMBER(10) DEFAULT 0,
                            WARNING_TYPE               NUMBER(10) DEFAULT 2,
                            LOG                        CLOB,
                            ALERTGROUP_ID              NUMBER(10),
                            CREATE_TIME                TIMESTAMP(6),
                            UPDATE_TIME                TIMESTAMP(6),
                            PROJECT_CODE               NUMBER(19),
                            WORKFLOW_DEFINITION_CODE   NUMBER(19),
                            WORKFLOW_INSTANCE_ID       NUMBER(10),
                            ALERT_TYPE                 NUMBER(10),
                            CONSTRAINT PK_T_DS_ALERT PRIMARY KEY (ID)
);
COMMENT ON COLUMN T_DS_ALERT.SIGN IS 'sign=sha1(content)';

CREATE INDEX IDX_STATUS ON T_DS_ALERT (ALERT_STATUS);
CREATE INDEX IDX_SIGN   ON T_DS_ALERT (SIGN);

CREATE TABLE T_DS_ALERTGROUP (
                                 ID               NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                 ALERT_INSTANCE_IDS VARCHAR2(255),
                                 CREATE_USER_ID   NUMBER(10),
                                 GROUP_NAME       VARCHAR2(255),
                                 DESCRIPTION      VARCHAR2(255),
                                 CREATE_TIME      TIMESTAMP(6),
                                 UPDATE_TIME      TIMESTAMP(6),
                                 CONSTRAINT PK_T_DS_ALERTGROUP PRIMARY KEY (ID),
                                 CONSTRAINT T_DS_ALERTGROUP_NAME_UN UNIQUE (GROUP_NAME)
);

CREATE TABLE T_DS_COMMAND (
                              ID                            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                              COMMAND_TYPE                  NUMBER(10),
                              WORKFLOW_DEFINITION_CODE      NUMBER(19) NOT NULL,
                              COMMAND_PARAM                 CLOB,
                              TASK_DEPEND_TYPE              NUMBER(10),
                              FAILURE_STRATEGY              NUMBER(10) DEFAULT 0,
                              WARNING_TYPE                  NUMBER(10) DEFAULT 0,
                              WARNING_GROUP_ID              NUMBER(10),
                              SCHEDULE_TIME                 TIMESTAMP(6),
                              START_TIME                    TIMESTAMP(6),
                              EXECUTOR_ID                   NUMBER(10),
                              UPDATE_TIME                   TIMESTAMP(6),
                              WORKFLOW_INSTANCE_PRIORITY    NUMBER(10) DEFAULT 2,
                              WORKER_GROUP                  VARCHAR2(255),
                              TENANT_CODE                   VARCHAR2(64) DEFAULT 'default',
                              ENVIRONMENT_CODE              NUMBER(19) DEFAULT -1,
                              DRY_RUN                       NUMBER(10) DEFAULT 0,
                              WORKFLOW_INSTANCE_ID          NUMBER(10) DEFAULT 0,
                              WORKFLOW_DEFINITION_VERSION   NUMBER(10) DEFAULT 0,
                              CONSTRAINT PK_T_DS_COMMAND PRIMARY KEY (ID)
);

CREATE INDEX PRIORITY_ID_INDEX ON T_DS_COMMAND (WORKFLOW_INSTANCE_PRIORITY, ID);

CREATE TABLE T_DS_DATASOURCE (
                                 ID                 NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                 NAME               VARCHAR2(64) NOT NULL,
                                 NOTE               VARCHAR2(255),
                                 TYPE               NUMBER(10) NOT NULL,
                                 USER_ID            NUMBER(10) NOT NULL,
                                 CONNECTION_PARAMS  CLOB NOT NULL,
                                 CREATE_TIME        TIMESTAMP(6) NOT NULL,
                                 UPDATE_TIME        TIMESTAMP(6),
                                 CONSTRAINT PK_T_DS_DATASOURCE PRIMARY KEY (ID),
                                 CONSTRAINT T_DS_DATASOURCE_NAME_UN UNIQUE (NAME, TYPE)
);

CREATE TABLE T_DS_ERROR_COMMAND (
                                    ID                            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                    COMMAND_TYPE                  NUMBER(10),
                                    WORKFLOW_DEFINITION_CODE      NUMBER(19) NOT NULL,
                                    COMMAND_PARAM                 CLOB,
                                    TASK_DEPEND_TYPE              NUMBER(10),
                                    FAILURE_STRATEGY              NUMBER(10) DEFAULT 0,
                                    WARNING_TYPE                  NUMBER(10) DEFAULT 0,
                                    WARNING_GROUP_ID              NUMBER(10),
                                    SCHEDULE_TIME                 TIMESTAMP(6),
                                    START_TIME                    TIMESTAMP(6),
                                    EXECUTOR_ID                   NUMBER(10),
                                    UPDATE_TIME                   TIMESTAMP(6),
                                    WORKFLOW_INSTANCE_PRIORITY    NUMBER(10) DEFAULT 2,
                                    WORKER_GROUP                  VARCHAR2(255),
                                    TENANT_CODE                   VARCHAR2(64) DEFAULT 'default',
                                    ENVIRONMENT_CODE              NUMBER(19) DEFAULT -1,
                                    DRY_RUN                       NUMBER(10) DEFAULT 0,
                                    MESSAGE                       CLOB,
                                    WORKFLOW_INSTANCE_ID          NUMBER(10) DEFAULT 0,
                                    WORKFLOW_DEFINITION_VERSION   NUMBER(10) DEFAULT 0,
                                    CONSTRAINT PK_T_DS_ERROR_COMMAND PRIMARY KEY (ID)
);

CREATE TABLE T_DS_WORKFLOW_DEFINITION (
                                          ID                    NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                          CODE                  NUMBER(19) NOT NULL,
                                          NAME                  VARCHAR2(255),
                                          VERSION               NUMBER(10) DEFAULT 1 NOT NULL,
                                          DESCRIPTION           CLOB,
                                          PROJECT_CODE          NUMBER(19),
                                          RELEASE_STATE         NUMBER(10),
                                          USER_ID               NUMBER(10),
                                          GLOBAL_PARAMS         CLOB,
                                          LOCATIONS             CLOB,
                                          WARNING_GROUP_ID      NUMBER(10),
                                          FLAG                  NUMBER(10),
                                          TIMEOUT               NUMBER(10) DEFAULT 0,
                                          EXECUTION_TYPE        NUMBER(10) DEFAULT 0,
                                          CREATE_TIME           TIMESTAMP(6),
                                          UPDATE_TIME           TIMESTAMP(6),
                                          CONSTRAINT PK_T_DS_WORKFLOW_DEFINITION PRIMARY KEY (ID),
                                          CONSTRAINT WORKFLOW_DEFINITION_UNIQUE UNIQUE (NAME, PROJECT_CODE)
);

CREATE UNIQUE INDEX UNIQ_WORKFLOW_DEFINITION_CODE
    ON T_DS_WORKFLOW_DEFINITION (CODE);
CREATE INDEX WORKFLOW_DEFINITION_INDEX_PROJECT_CODE
    ON T_DS_WORKFLOW_DEFINITION (PROJECT_CODE);

CREATE TABLE T_DS_WORKFLOW_DEFINITION_LOG (
                                              ID                    NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                              CODE                  NUMBER(19) NOT NULL,
                                              NAME                  VARCHAR2(255),
                                              VERSION               NUMBER(10) DEFAULT 1 NOT NULL,
                                              DESCRIPTION           CLOB,
                                              PROJECT_CODE          NUMBER(19),
                                              RELEASE_STATE         NUMBER(10),
                                              USER_ID               NUMBER(10),
                                              GLOBAL_PARAMS         CLOB,
                                              LOCATIONS             CLOB,
                                              WARNING_GROUP_ID      NUMBER(10),
                                              FLAG                  NUMBER(10),
                                              TIMEOUT               NUMBER(10) DEFAULT 0,
                                              EXECUTION_TYPE        NUMBER(10) DEFAULT 0,
                                              OPERATOR              NUMBER(10),
                                              OPERATE_TIME          TIMESTAMP(6),
                                              CREATE_TIME           TIMESTAMP(6),
                                              UPDATE_TIME           TIMESTAMP(6),
                                              CONSTRAINT PK_T_DS_WORKFLOW_DEFINITION_LOG PRIMARY KEY (ID)
);

CREATE UNIQUE INDEX UNIQ_IDX_CODE_VERSION
    ON T_DS_WORKFLOW_DEFINITION_LOG (CODE, VERSION);
CREATE INDEX WORKFLOW_DEFINITION_LOG_INDEX_PROJECT_CODE
    ON T_DS_WORKFLOW_DEFINITION_LOG (PROJECT_CODE);

CREATE TABLE T_DS_TASK_DEFINITION (
                                      ID                    NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                      CODE                  NUMBER(19) NOT NULL,
                                      NAME                  VARCHAR2(255),
                                      VERSION               NUMBER(10) DEFAULT 1 NOT NULL,
                                      DESCRIPTION           CLOB,
                                      PROJECT_CODE          NUMBER(19),
                                      USER_ID               NUMBER(10),
                                      TASK_TYPE             VARCHAR2(50),
                                      TASK_EXECUTE_TYPE     NUMBER(10) DEFAULT 0,
                                      TASK_PARAMS           CLOB,
                                      FLAG                  NUMBER(10),
                                      TASK_PRIORITY         NUMBER(10) DEFAULT 2,
                                      WORKER_GROUP          VARCHAR2(255),
                                      ENVIRONMENT_CODE      NUMBER(19) DEFAULT -1,
                                      FAIL_RETRY_TIMES      NUMBER(10),
                                      FAIL_RETRY_INTERVAL   NUMBER(10),
                                      TIMEOUT_FLAG          NUMBER(10),
                                      TIMEOUT_NOTIFY_STRATEGY NUMBER(10),
                                      TIMEOUT               NUMBER(10) DEFAULT 0,
                                      DELAY_TIME            NUMBER(10) DEFAULT 0,
                                      TASK_GROUP_ID         NUMBER(10),
                                      TASK_GROUP_PRIORITY   NUMBER(10) DEFAULT 0,
                                      RESOURCE_IDS          CLOB,
                                      CPU_QUOTA             NUMBER(10) DEFAULT -1 NOT NULL,
                                      MEMORY_MAX            NUMBER(10) DEFAULT -1 NOT NULL,
                                      CREATE_TIME           TIMESTAMP(6),
                                      UPDATE_TIME           TIMESTAMP(6),
                                      CONSTRAINT PK_T_DS_TASK_DEFINITION PRIMARY KEY (ID)
);

CREATE INDEX TASK_DEFINITION_INDEX
    ON T_DS_TASK_DEFINITION (PROJECT_CODE, ID);

CREATE TABLE T_DS_TASK_DEFINITION_LOG (
                                          ID                    NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                          CODE                  NUMBER(19) NOT NULL,
                                          NAME                  VARCHAR2(255),
                                          VERSION               NUMBER(10) DEFAULT 1 NOT NULL,
                                          DESCRIPTION           CLOB,
                                          PROJECT_CODE          NUMBER(19),
                                          USER_ID               NUMBER(10),
                                          TASK_TYPE             VARCHAR2(50),
                                          TASK_EXECUTE_TYPE     NUMBER(10) DEFAULT 0,
                                          TASK_PARAMS           CLOB,
                                          FLAG                  NUMBER(10),
                                          TASK_PRIORITY         NUMBER(10) DEFAULT 2,
                                          WORKER_GROUP          VARCHAR2(255),
                                          ENVIRONMENT_CODE      NUMBER(19) DEFAULT -1,
                                          FAIL_RETRY_TIMES      NUMBER(10),
                                          FAIL_RETRY_INTERVAL   NUMBER(10),
                                          TIMEOUT_FLAG          NUMBER(10),
                                          TIMEOUT_NOTIFY_STRATEGY NUMBER(10),
                                          TIMEOUT               NUMBER(10) DEFAULT 0,
                                          DELAY_TIME            NUMBER(10) DEFAULT 0,
                                          RESOURCE_IDS          CLOB,
                                          OPERATOR              NUMBER(10),
                                          TASK_GROUP_ID         NUMBER(10),
                                          TASK_GROUP_PRIORITY   NUMBER(10) DEFAULT 0,
                                          OPERATE_TIME          TIMESTAMP(6),
                                          CPU_QUOTA             NUMBER(10) DEFAULT -1 NOT NULL,
                                          MEMORY_MAX            NUMBER(10) DEFAULT -1 NOT NULL,
                                          CREATE_TIME           TIMESTAMP(6),
                                          UPDATE_TIME           TIMESTAMP(6),
                                          CONSTRAINT PK_T_DS_TASK_DEFINITION_LOG PRIMARY KEY (ID)
);

CREATE INDEX IDX_TASK_DEFINITION_LOG_CODE_VERSION
    ON T_DS_TASK_DEFINITION_LOG (CODE, VERSION);
CREATE INDEX IDX_TASK_DEFINITION_LOG_PROJECT_CODE
    ON T_DS_TASK_DEFINITION_LOG (PROJECT_CODE);

CREATE TABLE T_DS_WORKFLOW_TASK_RELATION (
                                             ID                          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                             NAME                        VARCHAR2(255),
                                             PROJECT_CODE                NUMBER(19),
                                             WORKFLOW_DEFINITION_CODE    NUMBER(19),
                                             WORKFLOW_DEFINITION_VERSION NUMBER(10),
                                             PRE_TASK_CODE               NUMBER(19),
                                             PRE_TASK_VERSION            NUMBER(10) DEFAULT 0,
                                             POST_TASK_CODE              NUMBER(19),
                                             POST_TASK_VERSION           NUMBER(10) DEFAULT 0,
                                             CONDITION_TYPE              NUMBER(10),
                                             CONDITION_PARAMS            CLOB,
                                             CREATE_TIME                 TIMESTAMP(6),
                                             UPDATE_TIME                 TIMESTAMP(6),
                                             CONSTRAINT PK_T_DS_WORKFLOW_TASK_RELATION PRIMARY KEY (ID)
);

CREATE INDEX WORKFLOW_TASK_RELATION_IDX_PROJECT_CODE_WORKFLOW_DEFINITION_CODE
    ON T_DS_WORKFLOW_TASK_RELATION (PROJECT_CODE, WORKFLOW_DEFINITION_CODE);
CREATE INDEX WORKFLOW_TASK_RELATION_IDX_PRE_TASK_CODE_VERSION
    ON T_DS_WORKFLOW_TASK_RELATION (PRE_TASK_CODE, PRE_TASK_VERSION);
CREATE INDEX WORKFLOW_TASK_RELATION_IDX_POST_TASK_CODE_VERSION
    ON T_DS_WORKFLOW_TASK_RELATION (POST_TASK_CODE, POST_TASK_VERSION);

CREATE TABLE T_DS_WORKFLOW_TASK_RELATION_LOG (
                                                 ID                          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                                 NAME                        VARCHAR2(255),
                                                 PROJECT_CODE                NUMBER(19),
                                                 WORKFLOW_DEFINITION_CODE    NUMBER(19),
                                                 WORKFLOW_DEFINITION_VERSION NUMBER(10),
                                                 PRE_TASK_CODE               NUMBER(19),
                                                 PRE_TASK_VERSION            NUMBER(10) DEFAULT 0,
                                                 POST_TASK_CODE              NUMBER(19),
                                                 POST_TASK_VERSION           NUMBER(10) DEFAULT 0,
                                                 CONDITION_TYPE              NUMBER(10),
                                                 CONDITION_PARAMS            CLOB,
                                                 OPERATOR                    NUMBER(10),
                                                 OPERATE_TIME                TIMESTAMP(6),
                                                 CREATE_TIME                 TIMESTAMP(6),
                                                 UPDATE_TIME                 TIMESTAMP(6),
                                                 CONSTRAINT PK_T_DS_WORKFLOW_TASK_RELATION_LOG PRIMARY KEY (ID)
);

CREATE INDEX WORKFLOW_TASK_RELATION_LOG_IDX_PROJECT_CODE_WORKFLOW_DEFINITION_CODE
    ON T_DS_WORKFLOW_TASK_RELATION_LOG (PROJECT_CODE, WORKFLOW_DEFINITION_CODE);

CREATE TABLE T_DS_WORKFLOW_INSTANCE (
                                        ID                          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                        NAME                        VARCHAR2(255),
                                        WORKFLOW_DEFINITION_CODE    NUMBER(19),
                                        WORKFLOW_DEFINITION_VERSION NUMBER(10) DEFAULT 1 NOT NULL,
                                        PROJECT_CODE                NUMBER(19),
                                        STATE                       NUMBER(10),
                                        STATE_HISTORY               CLOB,
                                        RECOVERY                    NUMBER(10),
                                        START_TIME                  TIMESTAMP(6),
                                        END_TIME                    TIMESTAMP(6),
                                        RUN_TIMES                   NUMBER(10),
                                        HOST                        VARCHAR2(135),
                                        COMMAND_TYPE                NUMBER(10),
                                        COMMAND_PARAM               CLOB,
                                        TASK_DEPEND_TYPE            NUMBER(10),
                                        MAX_TRY_TIMES               NUMBER(10) DEFAULT 0,
                                        FAILURE_STRATEGY            NUMBER(10) DEFAULT 0,
                                        WARNING_TYPE                NUMBER(10) DEFAULT 0,
                                        WARNING_GROUP_ID            NUMBER(10),
                                        SCHEDULE_TIME               TIMESTAMP(6),
                                        COMMAND_START_TIME          TIMESTAMP(6),
                                        GLOBAL_PARAMS               CLOB,
                                        WORKFLOW_INSTANCE_JSON      CLOB,
                                        FLAG                        NUMBER(10) DEFAULT 1,
                                        UPDATE_TIME                 TIMESTAMP(6),
                                        IS_SUB_WORKFLOW             NUMBER(10) DEFAULT 0,
                                        EXECUTOR_ID                 NUMBER(10) NOT NULL,
                                        EXECUTOR_NAME               VARCHAR2(64),
                                        HISTORY_CMD                 CLOB,
                                        DEPENDENCE_SCHEDULE_TIMES   CLOB,
                                        WORKFLOW_INSTANCE_PRIORITY  NUMBER(10) DEFAULT 2,
                                        WORKER_GROUP                VARCHAR2(255),
                                        ENVIRONMENT_CODE            NUMBER(19) DEFAULT -1,
                                        TIMEOUT                     NUMBER(10) DEFAULT 0,
                                        TENANT_CODE                 VARCHAR2(64) DEFAULT 'default',
                                        VAR_POOL                    CLOB,
                                        DRY_RUN                     NUMBER(10) DEFAULT 0,
                                        NEXT_WORKFLOW_INSTANCE_ID   NUMBER(10) DEFAULT 0,
                                        RESTART_TIME                TIMESTAMP(6),
                                        CONSTRAINT PK_T_DS_WORKFLOW_INSTANCE PRIMARY KEY (ID)
);

CREATE INDEX WORKFLOW_INSTANCE_INDEX
    ON T_DS_WORKFLOW_INSTANCE (WORKFLOW_DEFINITION_CODE, ID);
CREATE INDEX START_TIME_INDEX
    ON T_DS_WORKFLOW_INSTANCE (START_TIME, END_TIME);

CREATE TABLE T_DS_PROJECT (
                              ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                              NAME         VARCHAR2(255),
                              CODE         NUMBER(19) NOT NULL,
                              DESCRIPTION  VARCHAR2(255),
                              USER_ID      NUMBER(10),
                              FLAG         NUMBER(10) DEFAULT 1,
                              CREATE_TIME  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                              UPDATE_TIME  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                              CONSTRAINT PK_T_DS_PROJECT PRIMARY KEY (ID)
);

CREATE INDEX USER_ID_INDEX ON T_DS_PROJECT (USER_ID);
CREATE UNIQUE INDEX UNIQUE_NAME ON T_DS_PROJECT (NAME);
CREATE UNIQUE INDEX UNIQUE_CODE ON T_DS_PROJECT (CODE);

CREATE TABLE T_DS_PROJECT_PARAMETER (
                                        ID             NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                        PARAM_NAME     VARCHAR2(255) NOT NULL,
                                        PARAM_VALUE    CLOB NOT NULL,
                                        PARAM_DATA_TYPE VARCHAR2(50) DEFAULT 'VARCHAR',
                                        CODE           NUMBER(19) NOT NULL,
                                        PROJECT_CODE   NUMBER(19) NOT NULL,
                                        USER_ID        NUMBER(10),
                                        OPERATOR       NUMBER(10),
                                        CREATE_TIME    TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                                        UPDATE_TIME    TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                                        CONSTRAINT PK_T_DS_PROJECT_PARAMETER PRIMARY KEY (ID)
);

CREATE UNIQUE INDEX UNIQUE_PROJECT_PARAMETER_NAME
    ON T_DS_PROJECT_PARAMETER (PROJECT_CODE, PARAM_NAME);
CREATE UNIQUE INDEX UNIQUE_PROJECT_PARAMETER_CODE
    ON T_DS_PROJECT_PARAMETER (CODE);

CREATE TABLE T_DS_PROJECT_PREFERENCE (
                                         ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                         CODE         NUMBER(19) NOT NULL,
                                         PROJECT_CODE NUMBER(19) NOT NULL,
                                         PREFERENCES  VARCHAR2(512) NOT NULL,
                                         USER_ID      NUMBER(10),
                                         STATE        NUMBER(10) DEFAULT 1,
                                         CREATE_TIME  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                                         UPDATE_TIME  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
                                         CONSTRAINT PK_T_DS_PROJECT_PREFERENCE PRIMARY KEY (ID)
);

CREATE UNIQUE INDEX UNIQUE_PROJECT_PREFERENCE_PROJECT_CODE
    ON T_DS_PROJECT_PREFERENCE (PROJECT_CODE);
CREATE UNIQUE INDEX UNIQUE_PROJECT_PREFERENCE_CODE
    ON T_DS_PROJECT_PREFERENCE (CODE);

CREATE TABLE T_DS_QUEUE (
                            ID          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                            QUEUE_NAME  VARCHAR2(64),
                            QUEUE       VARCHAR2(64),
                            CREATE_TIME TIMESTAMP(6),
                            UPDATE_TIME TIMESTAMP(6),
                            CONSTRAINT PK_T_DS_QUEUE PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX UNIQUE_QUEUE_NAME ON T_DS_QUEUE (QUEUE_NAME);

CREATE TABLE T_DS_RELATION_DATASOURCE_USER (
                                               ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                               USER_ID       NUMBER(10) NOT NULL,
                                               DATASOURCE_ID NUMBER(10),
                                               PERM          NUMBER(10) DEFAULT 1,
                                               CREATE_TIME   TIMESTAMP(6),
                                               UPDATE_TIME   TIMESTAMP(6),
                                               CONSTRAINT PK_T_DS_RELATION_DATASOURCE_USER PRIMARY KEY (ID)
);

CREATE TABLE T_DS_RELATION_WORKFLOW_INSTANCE (
                                                 ID                        NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                                 PARENT_WORKFLOW_INSTANCE_ID NUMBER(10),
                                                 PARENT_TASK_INSTANCE_ID   NUMBER(10),
                                                 WORKFLOW_INSTANCE_ID      NUMBER(10),
                                                 CONSTRAINT PK_T_DS_RELATION_WORKFLOW_INSTANCE PRIMARY KEY (ID)
);
CREATE INDEX IDX_RELATION_WORKFLOW_INSTANCE_PARENT_WORKFLOW_TASK
    ON T_DS_RELATION_WORKFLOW_INSTANCE (PARENT_WORKFLOW_INSTANCE_ID, PARENT_TASK_INSTANCE_ID);
CREATE INDEX IDX_RELATION_WORKFLOW_INSTANCE_WORKFLOW_INSTANCE_ID
    ON T_DS_RELATION_WORKFLOW_INSTANCE (WORKFLOW_INSTANCE_ID);

CREATE TABLE T_DS_RELATION_PROJECT_USER (
                                            ID          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                            USER_ID     NUMBER(10) NOT NULL,
                                            PROJECT_ID  NUMBER(10),
                                            PERM        NUMBER(10) DEFAULT 1,
                                            CREATE_TIME TIMESTAMP(6),
                                            UPDATE_TIME TIMESTAMP(6),
                                            CONSTRAINT PK_T_DS_RELATION_PROJECT_USER PRIMARY KEY (ID),
                                            CONSTRAINT T_DS_RELATION_PROJECT_USER_UN UNIQUE (USER_ID, PROJECT_ID)
);
CREATE INDEX RELATION_PROJECT_USER_ID_INDEX ON T_DS_RELATION_PROJECT_USER (USER_ID);

-- Deprecated
CREATE TABLE T_DS_RELATION_RESOURCES_USER (
                                              ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                              USER_ID      NUMBER(10) NOT NULL,
                                              RESOURCES_ID NUMBER(10),
                                              PERM         NUMBER(10) DEFAULT 1,
                                              CREATE_TIME  TIMESTAMP(6),
                                              UPDATE_TIME  TIMESTAMP(6),
                                              CONSTRAINT PK_T_DS_RELATION_RESOURCES_USER PRIMARY KEY (ID)
);

CREATE TABLE T_DS_RELATION_UDFS_USER (
                                         ID        NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                         USER_ID   NUMBER(10) NOT NULL,
                                         UDF_ID    NUMBER(10),
                                         PERM      NUMBER(10) DEFAULT 1,
                                         CREATE_TIME TIMESTAMP(6),
                                         UPDATE_TIME TIMESTAMP(6),
                                         CONSTRAINT PK_T_DS_RELATION_UDFS_USER PRIMARY KEY (ID)
);

-- Deprecated
CREATE TABLE T_DS_RESOURCES (
                                ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                ALIAS        VARCHAR2(64),
                                FILE_NAME    VARCHAR2(64),
                                DESCRIPTION  VARCHAR2(255),
                                USER_ID      NUMBER(10),
                                TYPE         NUMBER(10),
                                SIZE         NUMBER(19),
                                CREATE_TIME  TIMESTAMP(6),
                                UPDATE_TIME  TIMESTAMP(6),
                                PID          NUMBER(10),
                                FULL_NAME    VARCHAR2(128),
                                IS_DIRECTORY NUMBER(1) DEFAULT 0 CHECK (IS_DIRECTORY IN (0,1)),
                                CONSTRAINT PK_T_DS_RESOURCES PRIMARY KEY (ID),
                                CONSTRAINT T_DS_RESOURCES_UN UNIQUE (FULL_NAME, TYPE)
);

CREATE TABLE T_DS_SCHEDULES (
                                ID                          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                WORKFLOW_DEFINITION_CODE    NUMBER(19) NOT NULL,
                                START_TIME                  TIMESTAMP(6) NOT NULL,
                                END_TIME                    TIMESTAMP(6) NOT NULL,
                                TIMEZONE_ID                 VARCHAR2(40),
                                CRONTAB                     VARCHAR2(255) NOT NULL,
                                FAILURE_STRATEGY            NUMBER(10) NOT NULL,
                                USER_ID                     NUMBER(10) NOT NULL,
                                RELEASE_STATE               NUMBER(10) NOT NULL,
                                WARNING_TYPE                NUMBER(10) NOT NULL,
                                WARNING_GROUP_ID            NUMBER(10),
                                WORKFLOW_INSTANCE_PRIORITY  NUMBER(10) DEFAULT 2,
                                WORKER_GROUP                VARCHAR2(255),
                                TENANT_CODE                 VARCHAR2(64) DEFAULT 'default',
                                ENVIRONMENT_CODE            NUMBER(19) DEFAULT -1,
                                CREATE_TIME                 TIMESTAMP(6) NOT NULL,
                                UPDATE_TIME                 TIMESTAMP(6) NOT NULL,
                                CONSTRAINT PK_T_DS_SCHEDULES PRIMARY KEY (ID)
);

CREATE TABLE T_DS_SESSION (
                              ID               VARCHAR2(64) NOT NULL,
                              USER_ID          NUMBER(10),
                              IP               VARCHAR2(45),
                              LAST_LOGIN_TIME  TIMESTAMP(6),
                              CONSTRAINT PK_T_DS_SESSION PRIMARY KEY (ID)
);

CREATE TABLE T_DS_TASK_INSTANCE (
                                    ID                     NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                    NAME                   VARCHAR2(255),
                                    TASK_TYPE              VARCHAR2(50),
                                    TASK_EXECUTE_TYPE      NUMBER(10) DEFAULT 0,
                                    TASK_CODE              NUMBER(19) NOT NULL,
                                    TASK_DEFINITION_VERSION NUMBER(10) DEFAULT 1 NOT NULL,
                                    WORKFLOW_INSTANCE_ID   NUMBER(10),
                                    WORKFLOW_INSTANCE_NAME VARCHAR2(255),
                                    PROJECT_CODE           NUMBER(19),
                                    STATE                  NUMBER(10),
                                    SUBMIT_TIME            TIMESTAMP(6),
                                    START_TIME             TIMESTAMP(6),
                                    END_TIME               TIMESTAMP(6),
                                    HOST                   VARCHAR2(135),
                                    EXECUTE_PATH           VARCHAR2(200),
                                    LOG_PATH               CLOB,
                                    ALERT_FLAG             NUMBER(10),
                                    RETRY_TIMES            NUMBER(10) DEFAULT 0,
                                    PID                    NUMBER(10),
                                    APP_LINK               CLOB,
                                    TASK_PARAMS            CLOB,
                                    FLAG                   NUMBER(10) DEFAULT 1,
                                    RETRY_INTERVAL         NUMBER(10),
                                    MAX_RETRY_TIMES        NUMBER(10),
                                    TASK_INSTANCE_PRIORITY NUMBER(10),
                                    WORKER_GROUP           VARCHAR2(255),
                                    ENVIRONMENT_CODE       NUMBER(19) DEFAULT -1,
                                    ENVIRONMENT_CONFIG     CLOB,
                                    EXECUTOR_ID            NUMBER(10),
                                    EXECUTOR_NAME          VARCHAR2(64),
                                    FIRST_SUBMIT_TIME      TIMESTAMP(6),
                                    DELAY_TIME             NUMBER(10) DEFAULT 0,
                                    TASK_GROUP_ID          NUMBER(10),
                                    VAR_POOL               CLOB,
                                    DRY_RUN                NUMBER(10) DEFAULT 0,
                                    CPU_QUOTA              NUMBER(10) DEFAULT -1 NOT NULL,
                                    MEMORY_MAX             NUMBER(10) DEFAULT -1 NOT NULL,
                                    CONSTRAINT PK_T_DS_TASK_INSTANCE PRIMARY KEY (ID)
);

CREATE INDEX IDX_TASK_INSTANCE_CODE_VERSION
    ON T_DS_TASK_INSTANCE (TASK_CODE, TASK_DEFINITION_VERSION);

CREATE TABLE T_DS_TASK_INSTANCE_CONTEXT (
                                            ID               NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                            TASK_INSTANCE_ID NUMBER(10) NOT NULL,
                                            CONTEXT          CLOB NOT NULL,
                                            CONTEXT_TYPE     VARCHAR2(200) NOT NULL,
                                            CREATE_TIME      TIMESTAMP(6) NOT NULL,
                                            UPDATE_TIME      TIMESTAMP(6) NOT NULL,
                                            CONSTRAINT PK_T_DS_TASK_INSTANCE_CONTEXT PRIMARY KEY (ID)
);

CREATE UNIQUE INDEX IDX_TASK_INSTANCE_ID
    ON T_DS_TASK_INSTANCE_CONTEXT (TASK_INSTANCE_ID, CONTEXT_TYPE);

CREATE TABLE T_DS_TENANT (
                             ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                             TENANT_CODE  VARCHAR2(64),
                             DESCRIPTION  VARCHAR2(255),
                             QUEUE_ID     NUMBER(10),
                             CREATE_TIME  TIMESTAMP(6),
                             UPDATE_TIME  TIMESTAMP(6),
                             CONSTRAINT PK_T_DS_TENANT PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX UNIQUE_TENANT_CODE ON T_DS_TENANT (TENANT_CODE);

CREATE TABLE T_DS_UDFS (
                           ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                           USER_ID       NUMBER(10) NOT NULL,
                           FUNC_NAME     VARCHAR2(255) NOT NULL,
                           CLASS_NAME    VARCHAR2(255) NOT NULL,
                           TYPE          NUMBER(10) NOT NULL,
                           ARG_TYPES     VARCHAR2(255),
                           DATABASE      VARCHAR2(255),
                           DESCRIPTION   VARCHAR2(255),
                           RESOURCE_ID   NUMBER(10) NOT NULL,
                           RESOURCE_NAME VARCHAR2(255) NOT NULL,
                           CREATE_TIME   TIMESTAMP(6) NOT NULL,
                           UPDATE_TIME   TIMESTAMP(6) NOT NULL,
                           CONSTRAINT PK_T_DS_UDFS PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX UNIQUE_FUNC_NAME ON T_DS_UDFS (FUNC_NAME);

CREATE TABLE T_DS_USER (
                           ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                           USER_NAME     VARCHAR2(64),
                           USER_PASSWORD VARCHAR2(64),
                           USER_TYPE     NUMBER(10),
                           EMAIL         VARCHAR2(64),
                           PHONE         VARCHAR2(11),
                           TENANT_ID     NUMBER(10) DEFAULT -1,
                           CREATE_TIME   TIMESTAMP(6),
                           UPDATE_TIME   TIMESTAMP(6),
                           QUEUE         VARCHAR2(64),
                           STATE         NUMBER(10) DEFAULT 1,
                           TIME_ZONE     VARCHAR2(32),
                           CONSTRAINT PK_T_DS_USER PRIMARY KEY (ID)
);
COMMENT ON COLUMN T_DS_USER.STATE IS 'state 0:disable 1:enable';

CREATE TABLE T_DS_VERSION (
                              ID      NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                              VERSION VARCHAR2(63) NOT NULL,
                              CONSTRAINT PK_T_DS_VERSION PRIMARY KEY (ID)
);
CREATE INDEX VERSION_INDEX ON T_DS_VERSION (VERSION);

CREATE TABLE T_DS_WORKER_GROUP (
                                   ID          NUMBER(19) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                   NAME        VARCHAR2(255) NOT NULL,
                                   ADDR_LIST   CLOB,
                                   CREATE_TIME TIMESTAMP(6),
                                   UPDATE_TIME TIMESTAMP(6),
                                   DESCRIPTION CLOB,
                                   CONSTRAINT PK_T_DS_WORKER_GROUP PRIMARY KEY (ID),
                                   CONSTRAINT NAME_UNIQUE UNIQUE (NAME)
);

CREATE TABLE T_DS_RELATION_PROJECT_WORKER_GROUP (
                                                    ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                                    PROJECT_CODE NUMBER(19),
                                                    WORKER_GROUP VARCHAR2(255) NOT NULL,
                                                    CREATE_TIME  TIMESTAMP(6),
                                                    UPDATE_TIME  TIMESTAMP(6),
                                                    CONSTRAINT PK_T_DS_RELATION_PROJECT_WORKER_GROUP PRIMARY KEY (ID),
                                                    CONSTRAINT T_DS_RELATION_PROJECT_WORKER_GROUP_UN UNIQUE (PROJECT_CODE, WORKER_GROUP)
);

-- Plugin / Alert plugin
CREATE TABLE T_DS_PLUGIN_DEFINE (
                                    ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                    PLUGIN_NAME   VARCHAR2(255) NOT NULL,
                                    PLUGIN_TYPE   VARCHAR2(63) NOT NULL,
                                    PLUGIN_PARAMS CLOB,
                                    CREATE_TIME   TIMESTAMP(6),
                                    UPDATE_TIME   TIMESTAMP(6),
                                    CONSTRAINT T_DS_PLUGIN_DEFINE_PK PRIMARY KEY (ID),
                                    CONSTRAINT T_DS_PLUGIN_DEFINE_UN UNIQUE (PLUGIN_NAME, PLUGIN_TYPE)
);

CREATE TABLE T_DS_ALERT_PLUGIN_INSTANCE (
                                            ID                     NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                            PLUGIN_DEFINE_ID       NUMBER(10) NOT NULL,
                                            PLUGIN_INSTANCE_PARAMS CLOB,
                                            CREATE_TIME            TIMESTAMP(6),
                                            UPDATE_TIME            TIMESTAMP(6),
                                            INSTANCE_NAME          VARCHAR2(255),
                                            CONSTRAINT T_DS_ALERT_PLUGIN_INSTANCE_PK PRIMARY KEY (ID)
);

-- Environment
CREATE TABLE T_DS_ENVIRONMENT (
                                  ID          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                  CODE        NUMBER(19) NOT NULL,
                                  NAME        VARCHAR2(255),
                                  CONFIG      CLOB,
                                  DESCRIPTION CLOB,
                                  OPERATOR    NUMBER(10),
                                  CREATE_TIME TIMESTAMP(6),
                                  UPDATE_TIME TIMESTAMP(6),
                                  CONSTRAINT PK_T_DS_ENVIRONMENT PRIMARY KEY (ID),
                                  CONSTRAINT ENVIRONMENT_NAME_UNIQUE UNIQUE (NAME),
                                  CONSTRAINT ENVIRONMENT_CODE_UNIQUE UNIQUE (CODE)
);

CREATE TABLE T_DS_ENVIRONMENT_WORKER_GROUP_RELATION (
                                                        ID             NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                                        ENVIRONMENT_CODE NUMBER(19) NOT NULL,
                                                        WORKER_GROUP     VARCHAR2(255) NOT NULL,
                                                        OPERATOR         NUMBER(10),
                                                        CREATE_TIME      TIMESTAMP(6),
                                                        UPDATE_TIME      TIMESTAMP(6),
                                                        CONSTRAINT PK_T_DS_ENV_WORKER_GROUP_REL PRIMARY KEY (ID),
                                                        CONSTRAINT ENVIRONMENT_WORKER_GROUP_UNIQUE UNIQUE (ENVIRONMENT_CODE, WORKER_GROUP)
);

-- Task group & queue
CREATE TABLE T_DS_TASK_GROUP_QUEUE (
                                       ID                   NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                       TASK_ID              NUMBER(10),
                                       TASK_NAME            VARCHAR2(255),
                                       GROUP_ID             NUMBER(10),
                                       WORKFLOW_INSTANCE_ID NUMBER(10),
                                       PRIORITY             NUMBER(10) DEFAULT 0,
                                       STATUS               NUMBER(10) DEFAULT -1,
                                       FORCE_START          NUMBER(10) DEFAULT 0,
                                       IN_QUEUE             NUMBER(10) DEFAULT 0,
                                       CREATE_TIME          TIMESTAMP(6),
                                       UPDATE_TIME          TIMESTAMP(6),
                                       CONSTRAINT PK_T_DS_TASK_GROUP_QUEUE PRIMARY KEY (ID)
);
CREATE INDEX IDX_T_DS_TASK_GROUP_QUEUE_IN_QUEUE ON T_DS_TASK_GROUP_QUEUE (IN_QUEUE);

CREATE TABLE T_DS_TASK_GROUP (
                                 ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                 NAME         VARCHAR2(255),
                                 DESCRIPTION  VARCHAR2(255),
                                 GROUP_SIZE   NUMBER(10) NOT NULL,
                                 PROJECT_CODE NUMBER(19) DEFAULT 0,
                                 USE_SIZE     NUMBER(10) DEFAULT 0,
                                 USER_ID      NUMBER(10),
                                 STATUS       NUMBER(10) DEFAULT 1,
                                 CREATE_TIME  TIMESTAMP(6),
                                 UPDATE_TIME  TIMESTAMP(6),
                                 CONSTRAINT PK_T_DS_TASK_GROUP PRIMARY KEY (ID)
);

-- Audit log
CREATE TABLE T_DS_AUDIT_LOG (
                                ID             NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                USER_ID        NUMBER(10) NOT NULL,
                                MODEL_ID       NUMBER(19) NOT NULL,
                                MODEL_NAME     VARCHAR2(255) NOT NULL,
                                MODEL_TYPE     VARCHAR2(255) NOT NULL,
                                OPERATION_TYPE VARCHAR2(255) NOT NULL,
                                DESCRIPTION    VARCHAR2(255) NOT NULL,
                                LATENCY        NUMBER(10) NOT NULL,
                                DETAIL         VARCHAR2(255),
                                CREATE_TIME    TIMESTAMP(6),
                                CONSTRAINT PK_T_DS_AUDIT_LOG PRIMARY KEY (ID)
);

-- K8s
CREATE TABLE T_DS_K8S (
                          ID          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                          K8S_NAME    VARCHAR2(255),
                          K8S_CONFIG  CLOB,
                          CREATE_TIME TIMESTAMP(6),
                          UPDATE_TIME TIMESTAMP(6),
                          CONSTRAINT PK_T_DS_K8S PRIMARY KEY (ID)
);

CREATE TABLE T_DS_K8S_NAMESPACE (
                                    ID            NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                    CODE          NUMBER(19) NOT NULL,
                                    NAMESPACE     VARCHAR2(255),
                                    USER_ID       NUMBER(10),
                                    CLUSTER_CODE  NUMBER(19) NOT NULL,
                                    CREATE_TIME   TIMESTAMP(6),
                                    UPDATE_TIME   TIMESTAMP(6),
                                    CONSTRAINT PK_T_DS_K8S_NAMESPACE PRIMARY KEY (ID),
                                    CONSTRAINT K8S_NAMESPACE_UNIQUE UNIQUE (NAMESPACE, CLUSTER_CODE)
);

CREATE TABLE T_DS_RELATION_NAMESPACE_USER (
                                              ID           NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                              USER_ID      NUMBER(10),
                                              NAMESPACE_ID NUMBER(10),
                                              PERM         NUMBER(10),
                                              CREATE_TIME  TIMESTAMP(6),
                                              UPDATE_TIME  TIMESTAMP(6),
                                              CONSTRAINT PK_T_DS_RELATION_NAMESPACE_USER PRIMARY KEY (ID),
                                              CONSTRAINT NAMESPACE_USER_UNIQUE UNIQUE (USER_ID, NAMESPACE_ID)
);

CREATE TABLE T_DS_ALERT_SEND_STATUS (
                                        ID                      NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                        ALERT_ID                NUMBER(10) NOT NULL,
                                        ALERT_PLUGIN_INSTANCE_ID NUMBER(10) NOT NULL,
                                        SEND_STATUS             NUMBER(10) DEFAULT 0,
                                        LOG                     CLOB,
                                        CREATE_TIME             TIMESTAMP(6),
                                        CONSTRAINT PK_T_DS_ALERT_SEND_STATUS PRIMARY KEY (ID),
                                        CONSTRAINT ALERT_SEND_STATUS_UNIQUE UNIQUE (ALERT_ID, ALERT_PLUGIN_INSTANCE_ID)
);

-- Cluster
CREATE TABLE T_DS_CLUSTER (
                              ID          NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                              CODE        NUMBER(19) NOT NULL,
                              NAME        VARCHAR2(255),
                              CONFIG      CLOB,
                              DESCRIPTION CLOB,
                              OPERATOR    NUMBER(10),
                              CREATE_TIME TIMESTAMP(6),
                              UPDATE_TIME TIMESTAMP(6),
                              CONSTRAINT PK_T_DS_CLUSTER PRIMARY KEY (ID),
                              CONSTRAINT CLUSTER_NAME_UNIQUE UNIQUE (NAME),
                              CONSTRAINT CLUSTER_CODE_UNIQUE UNIQUE (CODE)
);

-- Fav task
CREATE TABLE T_DS_FAV_TASK (
                               ID        NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                               TASK_TYPE VARCHAR2(64) NOT NULL,
                               USER_ID   NUMBER(10) NOT NULL,
                               CONSTRAINT PK_T_DS_FAV_TASK PRIMARY KEY (ID)
);

CREATE TABLE T_DS_RELATION_SUB_WORKFLOW (
                                            ID                        NUMBER(10) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                            PARENT_WORKFLOW_INSTANCE_ID NUMBER(19) NOT NULL,
                                            PARENT_TASK_CODE          NUMBER(19) NOT NULL,
                                            SUB_WORKFLOW_INSTANCE_ID  NUMBER(19) NOT NULL,
                                            CONSTRAINT PK_T_DS_RELATION_SUB_WORKFLOW PRIMARY KEY (ID)
);
CREATE INDEX IDX_PARENT_WORKFLOW_INSTANCE_ID ON T_DS_RELATION_SUB_WORKFLOW (PARENT_WORKFLOW_INSTANCE_ID);
CREATE INDEX IDX_PARENT_TASK_CODE ON T_DS_RELATION_SUB_WORKFLOW (PARENT_TASK_CODE);
CREATE INDEX IDX_SUB_WORKFLOW_INSTANCE_ID ON T_DS_RELATION_SUB_WORKFLOW (SUB_WORKFLOW_INSTANCE_ID);

CREATE TABLE T_DS_WORKFLOW_TASK_LINEAGE (
                                            ID                          NUMBER(10) NOT NULL,
                                            WORKFLOW_DEFINITION_CODE    NUMBER(19) NOT NULL DEFAULT 0,
                                            WORKFLOW_DEFINITION_VERSION NUMBER(10) NOT NULL DEFAULT 0,
                                            TASK_DEFINITION_CODE        NUMBER(19) NOT NULL DEFAULT 0,
                                            TASK_DEFINITION_VERSION     NUMBER(10) NOT NULL DEFAULT 0,
                                            DEPT_PROJECT_CODE           NUMBER(19) NOT NULL DEFAULT 0,
                                            DEPT_WORKFLOW_DEFINITION_CODE NUMBER(19) NOT NULL DEFAULT 0,
                                            DEPT_TASK_DEFINITION_CODE   NUMBER(19) NOT NULL DEFAULT 0,
                                            CREATE_TIME                 TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                            UPDATE_TIME                 TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                            CONSTRAINT PK_T_DS_WORKFLOW_TASK_LINEAGE PRIMARY KEY (ID)
);
CREATE INDEX IDX_WORKFLOW_CODE_VERSION ON T_DS_WORKFLOW_TASK_LINEAGE (WORKFLOW_DEFINITION_CODE, WORKFLOW_DEFINITION_VERSION);
CREATE INDEX IDX_TASK_CODE_VERSION     ON T_DS_WORKFLOW_TASK_LINEAGE (TASK_DEFINITION_CODE, TASK_DEFINITION_VERSION);
CREATE INDEX IDX_DEPT_CODE             ON T_DS_WORKFLOW_TASK_LINEAGE (DEPT_PROJECT_CODE, DEPT_WORKFLOW_DEFINITION_CODE, DEPT_TASK_DEFINITION_CODE);

-- JDBC Registry tables
CREATE TABLE T_DS_JDBC_REGISTRY_DATA (
                                         ID               NUMBER(19) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                         DATA_KEY         VARCHAR2(255) NOT NULL,
                                         DATA_VALUE       CLOB NOT NULL,
                                         DATA_TYPE        VARCHAR2(255) NOT NULL,
                                         CLIENT_ID        NUMBER(19) NOT NULL,
                                         CREATE_TIME      TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                         LAST_UPDATE_TIME TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                         CONSTRAINT PK_T_DS_JDBC_REGISTRY_DATA PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX UK_T_DS_JDBC_REGISTRY_DATAKEY ON T_DS_JDBC_REGISTRY_DATA (DATA_KEY);

CREATE TABLE T_DS_JDBC_REGISTRY_LOCK (
                                         ID          NUMBER(19) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                         LOCK_KEY    VARCHAR2(255) NOT NULL,
                                         LOCK_OWNER  VARCHAR2(255) NOT NULL,
                                         CLIENT_ID   NUMBER(19) NOT NULL,
                                         CREATE_TIME TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                         CONSTRAINT PK_T_DS_JDBC_REGISTRY_LOCK PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX UK_T_DS_JDBC_REGISTRY_LOCKKEY ON T_DS_JDBC_REGISTRY_LOCK (LOCK_KEY);

CREATE TABLE T_DS_JDBC_REGISTRY_CLIENT_HEARTBEAT (
                                                     ID                  NUMBER(19) NOT NULL,
                                                     CLIENT_NAME         VARCHAR2(255) NOT NULL,
                                                     LAST_HEARTBEAT_TIME NUMBER(19) NOT NULL,
                                                     CONNECTION_CONFIG   CLOB NOT NULL,
                                                     CREATE_TIME         TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                                     CONSTRAINT PK_T_DS_JDBC_REGISTRY_CLIENT_HEARTBEAT PRIMARY KEY (ID)
);

CREATE TABLE T_DS_JDBC_REGISTRY_DATA_CHANGE_EVENT (
                                                      ID                 NUMBER(19) GENERATED BY DEFAULT ON NULL AS IDENTITY NOT NULL,
                                                      EVENT_TYPE         VARCHAR2(255) NOT NULL,
                                                      JDBC_REGISTRY_DATA CLOB NOT NULL,
                                                      CREATE_TIME        TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                                      CONSTRAINT PK_T_DS_JDBC_REGISTRY_DATA_CHANGE_EVENT PRIMARY KEY (ID)
);
--------------------------------------------------------------------------------
-- Seed data (unchanged except for date literal syntax if needed)
--------------------------------------------------------------------------------
INSERT INTO T_DS_USER(USER_NAME, USER_PASSWORD, USER_TYPE, EMAIL, PHONE, TENANT_ID, STATE, CREATE_TIME, UPDATE_TIME, TIME_ZONE)
VALUES ('admin', '7ad2410b2f4c074479a8937a28a22b8f', 0, 'xxx@qq.com', '', -1, 1,
        TO_TIMESTAMP('2018-03-27 15:48:50', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2018-10-24 17:40:22', 'YYYY-MM-DD HH24:MI:SS'),
        NULL);

INSERT INTO T_DS_TENANT(ID, TENANT_CODE, DESCRIPTION, QUEUE_ID, CREATE_TIME, UPDATE_TIME)
VALUES (-1, 'default', 'default tenant', 1,
        TO_TIMESTAMP('2018-03-27 15:48:50', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2018-10-24 17:40:22', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO T_DS_ALERTGROUP(ALERT_INSTANCE_IDS, CREATE_USER_ID, GROUP_NAME, DESCRIPTION, CREATE_TIME, UPDATE_TIME)
VALUES (NULL, 1, 'default admin warning group', 'default admin warning group',
        TO_TIMESTAMP('2018-11-29 10:20:39', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2018-11-29 10:20:39', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO T_DS_QUEUE(QUEUE_NAME, QUEUE, CREATE_TIME, UPDATE_TIME)
VALUES ('default', 'default',
        TO_TIMESTAMP('2018-11-29 10:22:33', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2018-11-29 10:22:33', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO T_DS_VERSION(VERSION) VALUES ('3.3.0');

