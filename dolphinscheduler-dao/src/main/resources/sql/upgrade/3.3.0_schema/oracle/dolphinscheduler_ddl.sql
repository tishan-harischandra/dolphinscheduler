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

BEGIN
  drop_table_if_exists('t_ds_workflow_task_lineage');
END;

DECLARE
v_sql CLOB := q'[
    CREATE TABLE t_ds_workflow_task_lineage (
      id                        NUMBER                       NOT NULL,
      workflow_definition_code  NUMBER(19) DEFAULT 0 NOT NULL,
      workflow_definition_version NUMBER   DEFAULT 0 NOT NULL,
      task_definition_code      NUMBER(19) DEFAULT 0 NOT NULL,
      task_definition_version   NUMBER     DEFAULT 0 NOT NULL,
      dept_project_code         NUMBER(19) DEFAULT 0 NOT NULL,
      dept_workflow_definition_code NUMBER(19) DEFAULT 0 NOT NULL,
      dept_task_definition_code NUMBER(19) DEFAULT 0 NOT NULL,
      create_time               TIMESTAMP  DEFAULT CURRENT_TIMESTAMP NOT NULL,
      update_time               TIMESTAMP  DEFAULT CURRENT_TIMESTAMP NOT NULL,
      CONSTRAINT t_ds_wf_task_lineage_pk PRIMARY KEY (id)
    )
  ]';
BEGIN
  create_table_if_not_exists('t_ds_workflow_task_lineage', v_sql);
END;

BEGIN
  create_index_if_not_exists(
    'idx_workflow_code_version',
    'CREATE INDEX idx_workflow_code_version ON t_ds_workflow_task_lineage (workflow_definition_code, workflow_definition_version)'
  );

  create_index_if_not_exists(
    'idx_task_code_version',
    'CREATE INDEX idx_task_code_version ON t_ds_workflow_task_lineage (task_definition_code, task_definition_version)'
  );

  create_index_if_not_exists(
    'idx_dept_code',
    'CREATE INDEX idx_dept_code ON t_ds_workflow_task_lineage (dept_project_code, dept_workflow_definition_code, dept_task_definition_code)'
  );
END;

DECLARE
PROCEDURE make_bigserial(
    p_tab  VARCHAR2,
    p_seq  VARCHAR2
  ) IS
BEGIN
    drop_seq_if_exists(p_seq);
    create_sequence_if_not_exists(
      p_seq,
      'CREATE SEQUENCE '||p_seq||' START WITH 1 INCREMENT BY 1'
    );
EXECUTE IMMEDIATE
    'ALTER TABLE '||p_tab||
    ' MODIFY (id DEFAULT '||p_seq||'.NEXTVAL)';
END;
BEGIN
  drop_table_if_exists('t_ds_jdbc_registry_data');
  create_table_if_not_exists(
    't_ds_jdbc_registry_data',
    q'[
      CREATE TABLE t_ds_jdbc_registry_data (
        id               NUMBER,
        data_key         VARCHAR2(4000) NOT NULL,
        data_value       CLOB           NOT NULL,
        data_type        VARCHAR2(4000) NOT NULL,
        client_id        NUMBER         NOT NULL,
        create_time      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
        last_update_time TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT t_ds_jdbc_reg_data_pk PRIMARY KEY (id)
      )
    ]'
  );
  make_bigserial('t_ds_jdbc_registry_data','t_ds_jdbc_registry_data_seq');
  create_index_if_not_exists(
    'uk_t_ds_jdbc_registry_dataKey',
    'CREATE UNIQUE INDEX uk_t_ds_jdbc_registry_dataKey ON t_ds_jdbc_registry_data (data_key)'
  );

  drop_table_if_exists('t_ds_jdbc_registry_lock');
  create_table_if_not_exists(
    't_ds_jdbc_registry_lock',
    q'[
      CREATE TABLE t_ds_jdbc_registry_lock (
        id          NUMBER,
        lock_key    VARCHAR2(4000) NOT NULL,
        lock_owner  VARCHAR2(4000) NOT NULL,
        client_id   NUMBER         NOT NULL,
        create_time TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT t_ds_jdbc_reg_lock_pk PRIMARY KEY (id)
      )
    ]'
  );
  make_bigserial('t_ds_jdbc_registry_lock','t_ds_jdbc_registry_lock_seq');
  create_index_if_not_exists(
    'uk_t_ds_jdbc_registry_lockKey',
    'CREATE UNIQUE INDEX uk_t_ds_jdbc_registry_lockKey ON t_ds_jdbc_registry_lock (lock_key)'
  );

  drop_table_if_exists('t_ds_jdbc_registry_client_heartbeat');
  create_table_if_not_exists(
    't_ds_jdbc_registry_client_heartbeat',
    q'[
      CREATE TABLE t_ds_jdbc_registry_client_heartbeat (
        id                  NUMBER      NOT NULL,
        client_name         VARCHAR2(4000) NOT NULL,
        last_heartbeat_time NUMBER      NOT NULL,
        connection_config   CLOB        NOT NULL,
        create_time         TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT t_ds_jdbc_reg_hb_pk PRIMARY KEY (id)
      )
    ]'
  );

  drop_table_if_exists('t_ds_jdbc_registry_data_change_event');
  create_table_if_not_exists(
    't_ds_jdbc_registry_data_change_event',
    q'[
      CREATE TABLE t_ds_jdbc_registry_data_change_event (
        id          NUMBER,
        event_type  VARCHAR2(4000) NOT NULL,
        jdbc_registry_data CLOB    NOT NULL,
        create_time TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT t_ds_jdbc_reg_event_pk PRIMARY KEY (id)
      )
    ]'
  );
  make_bigserial('t_ds_jdbc_registry_data_change_event','t_ds_jdbc_registry_data_change_event_seq');
END;

BEGIN
  drop_table_if_exists('t_ds_listener_event');
  drop_table_if_exists('t_ds_trigger_relation');

  drop_column_if_exists('t_ds_alert_plugin_instance','instance_type');
  drop_column_if_exists('t_ds_alert_plugin_instance','warning_type');
END;

BEGIN
  rename_column_if_exists('t_ds_alert','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_alert','process_instance_id','workflow_instance_id');

  rename_column_if_exists('t_ds_command','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_command','process_instance_priority','workflow_instance_priority');
  rename_column_if_exists('t_ds_command','process_instance_id','workflow_instance_id');
  rename_column_if_exists('t_ds_command','process_definition_version','workflow_definition_version');

  rename_column_if_exists('t_ds_error_command','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_error_command','process_instance_priority','workflow_instance_priority');
  rename_column_if_exists('t_ds_error_command','process_instance_id','workflow_instance_id');
  rename_column_if_exists('t_ds_error_command','process_definition_version','workflow_definition_version');

  rename_column_if_exists('t_ds_process_task_relation','process_definition_version','workflow_definition_version');
  rename_column_if_exists('t_ds_process_task_relation','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_process_task_relation_log','process_definition_version','workflow_definition_version');
  rename_column_if_exists('t_ds_process_task_relation_log','process_definition_code','workflow_definition_code');

  rename_column_if_exists('t_ds_process_instance','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_process_instance','process_definition_version','workflow_definition_version');
  rename_column_if_exists('t_ds_process_instance','is_sub_process','is_sub_workflow');
  rename_column_if_exists('t_ds_process_instance','process_instance_priority','workflow_instance_priority');
  rename_column_if_exists('t_ds_process_instance','next_process_instance_id','next_workflow_instance_id');

  rename_column_if_exists('t_ds_schedules','process_definition_code','workflow_definition_code');
  rename_column_if_exists('t_ds_schedules','process_instance_priority','workflow_instance_priority');

  rename_column_if_exists('t_ds_task_instance','process_instance_id','workflow_instance_id');
  rename_column_if_exists('t_ds_task_instance','process_instance_name','workflow_instance_name');

  rename_column_if_exists('t_ds_dq_execute_result','process_definition_id','workflow_definition_id');
  rename_column_if_exists('t_ds_dq_execute_result','process_instance_id','workflow_instance_id');
  rename_column_if_exists('t_ds_dq_task_statistics_value','process_definition_id','workflow_definition_id');

  rename_column_if_exists('t_ds_task_group_queue','process_id','workflow_instance_id');

  rename_column_if_exists('t_ds_relation_process_instance','parent_process_instance_id','parent_workflow_instance_id');
  rename_column_if_exists('t_ds_relation_process_instance','process_instance_id','workflow_instance_id');

  rename_table_if_exists('t_ds_process_definition'        ,'t_ds_workflow_definition');
  rename_table_if_exists('t_ds_process_definition_log'    ,'t_ds_workflow_definition_log');
  rename_table_if_exists('t_ds_process_task_relation'     ,'t_ds_workflow_task_relation');
  rename_table_if_exists('t_ds_process_task_relation_log' ,'t_ds_workflow_task_relation_log');
  rename_table_if_exists('t_ds_process_instance'          ,'t_ds_workflow_instance');
  rename_table_if_exists('t_ds_relation_process_instance' ,'t_ds_relation_workflow_instance');

  rename_sequence_if_exists('t_ds_relation_process_instance_id_sequence','t_ds_relation_workflow_instance_id_sequence');
  rename_sequence_if_exists('t_ds_process_definition_id_sequence'      ,'t_ds_workflow_definition_id_sequence');
  rename_sequence_if_exists('t_ds_process_definition_log_id_sequence'  ,'t_ds_workflow_definition_log_id_sequence');
  rename_sequence_if_exists('t_ds_process_instance_id_sequence'        ,'t_ds_workflow_instance_id_sequence');
  rename_sequence_if_exists('t_ds_process_task_relation_id_sequence'   ,'t_ds_workflow_task_relation_id_sequence');
  rename_sequence_if_exists('t_ds_process_task_relation_log_id_sequence','t_ds_workflow_task_relation_log_id_sequence');

  rename_index_if_exists('idx_relation_process_instance_parent_process_task' , 'idx_relation_workflow_instance_parent_workflow_task');
  rename_index_if_exists('idx_relation_process_instance_process_instance_id' , 'idx_relation_workflow_instance_workflow_instance_id');
  rename_index_if_exists('process_definition_index'                          , 'workflow_definition_index');
  rename_index_if_exists('process_definition_unique'                         , 'workflow_definition_unique');
  rename_index_if_exists('process_instance_index'                            , 'workflow_instance_index');
  rename_index_if_exists('process_task_relation_idx_post_task_code_version'  , 'workflow_task_relation_idx_post_task_code_version');
  rename_index_if_exists('process_task_relation_idx_pre_task_code_version'   , 'workflow_task_relation_idx_pre_task_code_version');
  rename_index_if_exists('process_task_relation_idx_project_code_process_definition_code',
          'workflow_task_relation_idx_project_code_workflow_definition_cod');
  rename_index_if_exists('process_task_relation_log_idx_project_code_process_definition_c',
          'workflow_task_relation_log_idx_project_code_workflow_definition');

  rename_constraint_if_exists('t_ds_relation_workflow_instance','t_ds_relation_process_instance_pkey','t_ds_relation_workflow_instance_pkey');
  rename_constraint_if_exists('t_ds_workflow_definition'      ,'t_ds_process_definition_pkey'       ,'t_ds_workflow_definition_pkey');
  rename_constraint_if_exists('t_ds_workflow_definition_log'  ,'t_ds_process_definition_log_pkey'   ,'t_ds_workflow_definition_log_pkey');
  rename_constraint_if_exists('t_ds_workflow_instance'        ,'t_ds_process_instance_pkey'         ,'t_ds_workflow_instance_pkey');
  rename_constraint_if_exists('t_ds_workflow_task_relation'   ,'t_ds_process_task_relation_pkey'    ,'t_ds_workflow_task_relation_pkey');
  rename_constraint_if_exists('t_ds_workflow_task_relation_log','t_ds_process_task_relation_log_pkey','t_ds_workflow_task_relation_log_pkey');

  rename_column_if_exists('t_ds_workflow_instance','process_instance_json','workflow_instance_json');
END;

BEGIN
  drop_table_if_exists('t_ds_dq_comparison_type');
  drop_table_if_exists('t_ds_dq_rule_execute_sql');
  drop_table_if_exists('t_ds_dq_rule_input_entry');
  drop_table_if_exists('t_ds_dq_task_statistics_value');
  drop_table_if_exists('t_ds_dq_execute_result');
  drop_table_if_exists('t_ds_dq_rule');
  drop_table_if_exists('t_ds_relation_rule_input_entry');
  drop_table_if_exists('t_ds_relation_rule_execute_sql');
END;

BEGIN
  create_index_if_not_exists(
    'workflow_definition_index_project_code',
    'CREATE INDEX workflow_definition_index_project_code ON t_ds_workflow_definition (project_code)'
  );

  create_index_if_not_exists(
    'workflow_definition_log_index_project_code',
    'CREATE INDEX workflow_definition_log_index_project_code ON t_ds_workflow_definition_log (project_code)'
  );
END;

BEGIN
  drop_column_if_exists('t_ds_worker_group'        ,'other_params_json');

  drop_column_if_exists('t_ds_task_definition'     ,'is_cache');
  drop_column_if_exists('t_ds_task_definition'     ,'cache_key');

  drop_column_if_exists('t_ds_task_definition_log' ,'is_cache');
  drop_column_if_exists('t_ds_task_definition_log' ,'cache_key');

  drop_column_if_exists('t_ds_task_instance'       ,'is_cache');
  drop_column_if_exists('t_ds_task_instance'       ,'cache_key');
END;

BEGIN
  drop_table_if_exists('t_ds_task_instance_context');
END;

DECLARE
v_sql CLOB := q'[
    CREATE TABLE t_ds_task_instance_context (
      id              NUMBER            NOT NULL,
      task_instance_id NUMBER           NOT NULL,
      context         CLOB              NOT NULL,
      context_type    VARCHAR2(200)     NOT NULL,
      create_time     TIMESTAMP         NOT NULL,
      update_time     TIMESTAMP         NOT NULL,
      CONSTRAINT t_ds_task_inst_ctx_pk PRIMARY KEY (id)
    )
  ]';
BEGIN
  create_table_if_not_exists('t_ds_task_instance_context', v_sql);
END;

BEGIN
  create_sequence_if_not_exists(
    't_ds_task_instance_context_seq',
    'CREATE SEQUENCE t_ds_task_instance_context_seq START WITH 1 INCREMENT BY 1'
  );
EXECUTE IMMEDIATE '
ALTER TABLE t_ds_task_instance_context
    MODIFY (id DEFAULT t_ds_task_instance_context_seq.NEXTVAL)';
END;

BEGIN
  create_index_if_not_exists(
    'idx_task_instance_id',
    'CREATE UNIQUE INDEX idx_task_instance_id ON t_ds_task_instance_context (task_instance_id, context_type)'
  );
END;
