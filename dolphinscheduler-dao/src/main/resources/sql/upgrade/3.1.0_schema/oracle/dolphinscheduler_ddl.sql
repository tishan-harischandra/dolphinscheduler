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

@helpers.sql

-- t_ds_k8s_namespace
BEGIN
  drop_column_if_exists('t_ds_k8s_namespace','online_job_num');
  drop_column_if_exists('t_ds_k8s_namespace','k8s');

  drop_constraint_if_exists('t_ds_k8s_namespace','k8s_namespace_unique');

  add_column_if_not_exists('t_ds_k8s_namespace','code',
                           'code NUMBER(19) DEFAULT 0 NOT NULL');
  add_column_if_not_exists('t_ds_k8s_namespace','cluster_code',
                           'cluster_code NUMBER(19) DEFAULT 0 NOT NULL');

  -- Ensure (namespace, cluster_code) unique
  add_constraint_if_not_exists('t_ds_k8s_namespace','K8S_NAMESPACE_UNIQUE',
                               '(namespace, cluster_code) UNIQUE');
END;
/

-- t_ds_task_definition
BEGIN
  add_column_if_not_exists('t_ds_task_definition','cpu_quota',
                           'cpu_quota NUMBER(10) DEFAULT -1 NOT NULL');
  add_column_if_not_exists('t_ds_task_definition','memory_max',
                           'memory_max NUMBER(10) DEFAULT -1 NOT NULL');
END;
/

-- t_ds_task_definition_log
BEGIN
  add_column_if_not_exists('t_ds_task_definition_log','cpu_quota',
                           'cpu_quota NUMBER(10) DEFAULT -1 NOT NULL');
  add_column_if_not_exists('t_ds_task_definition_log','memory_max',
                           'memory_max NUMBER(10) DEFAULT -1 NOT NULL');
END;
/

-- t_ds_task_instance
BEGIN
  add_column_if_not_exists('t_ds_task_instance','cpu_quota',
                           'cpu_quota NUMBER(10) DEFAULT -1 NOT NULL');
  add_column_if_not_exists('t_ds_task_instance','memory_max',
                           'memory_max NUMBER(10) DEFAULT -1 NOT NULL');

  drop_constraint_if_exists('t_ds_task_instance','foreign_key_instance_id');
END;
/

-- t_ds_relation_process_instance indexes
BEGIN
  drop_index_if_exists('idx_relation_process_instance_parent_process_task');
  create_index_if_not_exists(
    'idx_relation_process_instance_parent_process_task',
    'CREATE INDEX idx_relation_process_instance_parent_process_task '||
    'ON t_ds_relation_process_instance (parent_process_instance_id, parent_task_instance_id)'
  );

  drop_index_if_exists('idx_relation_process_instance_process_instance_id');
  create_index_if_not_exists(
    'idx_relation_process_instance_process_instance_id',
    'CREATE INDEX idx_relation_process_instance_process_instance_id '||
    'ON t_ds_relation_process_instance (process_instance_id)'
  );
END;
/

-- t_ds_cluster (create table if not exists)
DECLARE
v_cnt PLS_INTEGER;
BEGIN
SELECT COUNT(*) INTO v_cnt
FROM user_tables
WHERE table_name = 'T_DS_CLUSTER';
IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE t_ds_cluster (
        id          NUMBER GENERATED ALWAYS AS IDENTITY,
        code        NUMBER(19)    NOT NULL,
        name        VARCHAR2(100),
        config      CLOB,
        description CLOB,
        operator    NUMBER,
        create_time TIMESTAMP,
        update_time TIMESTAMP,
        CONSTRAINT t_ds_cluster_pk        PRIMARY KEY (id),
        CONSTRAINT cluster_name_unique    UNIQUE (name),
        CONSTRAINT cluster_code_unique    UNIQUE (code)
      )
    ]';
END IF;
END;
/

-- Set default values to 2 (runs safely even if already 2)
ALTER TABLE t_ds_process_instance      MODIFY (process_instance_priority DEFAULT 2);
ALTER TABLE t_ds_schedules             MODIFY (process_instance_priority DEFAULT 2);
ALTER TABLE t_ds_command               MODIFY (process_instance_priority DEFAULT 2);
ALTER TABLE t_ds_error_command         MODIFY (process_instance_priority DEFAULT 2);
ALTER TABLE t_ds_task_definition_log   MODIFY (task_priority             DEFAULT 2);
ALTER TABLE t_ds_task_definition       MODIFY (task_priority             DEFAULT 2);

-- Add task_execute_type columns
BEGIN
  add_column_if_not_exists('t_ds_task_definition',     'task_execute_type', 'task_execute_type NUMBER(10) DEFAULT 0');
  add_column_if_not_exists('t_ds_task_definition_log', 'task_execute_type', 'task_execute_type NUMBER(10) DEFAULT 0');
  add_column_if_not_exists('t_ds_task_instance',       'task_execute_type', 'task_execute_type NUMBER(10) DEFAULT 0');
END;
/

-- Modify column lengths on description fields
ALTER TABLE t_ds_project     MODIFY (description VARCHAR2(255));
ALTER TABLE t_ds_task_group  MODIFY (description VARCHAR2(255));

-- Add JSON/text columns
BEGIN
  add_column_if_not_exists('t_ds_worker_group','other_params_json','other_params_json CLOB');
  add_column_if_not_exists('t_ds_process_instance','state_history','state_history CLOB');
END;
/

COMMIT;
