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
-- modify_data_t_ds_dq_rule_input_entry

BEGIN
  rename_column_if_exists
('t_ds_dq_rule_input_entry', 'value',       'data');
  rename_column_if_exists
('t_ds_dq_rule_input_entry', 'value_type',  'data_type');
END;

BEGIN
  drop_column_if_exists('limits_cpu');
  drop_column_if_exists('limits_memory');
  drop_column_if_exists('pod_replicas');
  drop_column_if_exists('pod_request_cpu');
  drop_column_if_exists('pod_request_memory');
END;

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_project_parameter MODIFY (param_value CLOB)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -904 THEN NULL;
ELSE RAISE;
END IF;
END;

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_process_definition MODIFY (version NUMBER DEFAULT 1)';
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_process_definition_log MODIFY (version NUMBER DEFAULT 1)';
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_task_definition MODIFY (version NUMBER DEFAULT 1)';
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_task_definition_log MODIFY (version NUMBER DEFAULT 1)';
END;

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_process_instance MODIFY (process_definition_version NUMBER DEFAULT 1 NOT NULL)';
  EXECUTE IMMEDIATE 'ALTER TABLE t_ds_task_instance MODIFY (task_definition_version NUMBER DEFAULT 1 NOT NULL)';
END;

BEGIN
  create_index_if_not_exists('idx_t_ds_task_group_queue_in_queue', 'CREATE INDEX idx_t_ds_task_group_queue_in_queue ON t_ds_task_group_queue (in_queue)');
END;
