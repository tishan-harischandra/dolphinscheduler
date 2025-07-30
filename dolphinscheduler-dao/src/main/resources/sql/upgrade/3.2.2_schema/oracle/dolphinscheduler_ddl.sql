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
/*------------------------------------------------------------
  Drop‑and‑recreate table (matches Postgres semantics)
------------------------------------------------------------*/
@helpers.sql

BEGIN
  drop_table_if_exists('t_ds_relation_project_worker_group');
END;
/

DECLARE
v_sql CLOB := q'[
    CREATE TABLE t_ds_relation_project_worker_group (
      id            NUMBER                            NOT NULL,
      project_code  NUMBER(19),
      worker_group  VARCHAR2(255)                     NOT NULL,
      create_time   TIMESTAMP,
      update_time   TIMESTAMP,
      CONSTRAINT t_ds_rel_proj_wg_pk  PRIMARY KEY (id),
      CONSTRAINT t_ds_relation_project_worker_group_un
        UNIQUE (project_code, worker_group)
    )
  ]';
BEGIN
  create_table_if_not_exists('t_ds_relation_project_worker_group', v_sql);
END;
/

BEGIN
  drop_seq_if_exists('t_ds_relation_project_worker_group_sequence');
END;
/

BEGIN
  create_sequence_if_not_exists(
    't_ds_relation_project_worker_group_sequence',
    'CREATE SEQUENCE t_ds_relation_project_worker_group_sequence START WITH 1 INCREMENT BY 1'
  );
END;
/

EXECUTE IMMEDIATE '
  ALTER TABLE t_ds_relation_project_worker_group
  MODIFY (id DEFAULT t_ds_relation_project_worker_group_sequence.NEXTVAL)';
/

BEGIN
  add_column_if_not_exists(
    't_ds_project_parameter',
    'operator',
    'operator NUMBER'
  );

  add_column_if_not_exists(
    't_ds_project_parameter',
    'param_data_type',
    q'[param_data_type VARCHAR2(50) DEFAULT 'VARCHAR']'
  );
END;
/

BEGIN
  drop_column_if_exists('t_ds_audit_log','resource_type');
  drop_column_if_exists('t_ds_audit_log','operation');
  drop_column_if_exists('t_ds_audit_log','resource_id');
  add_column_if_not_exists('t_ds_audit_log','model_id',
      'model_id NUMBER(19) NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','model_name',
      'model_name VARCHAR2(255) NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','model_type',
      'model_type VARCHAR2(255) NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','operation_type',
      'operation_type VARCHAR2(255) NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','description',
      'description VARCHAR2(255) NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','latency',
      'latency NUMBER NOT NULL');
  add_column_if_not_exists('t_ds_audit_log','detail',
      'detail VARCHAR2(255)');
  rename_column_if_exists(
    't_ds_audit_log',
    'time',
    'create_time'
  );
END;
/
