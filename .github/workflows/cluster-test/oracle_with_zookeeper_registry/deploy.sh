#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -euox pipefail


USER=root

#Create database
sqlplus -S system/oracle@//oracle:1521/ORCL <<'EOF'
WHENEVER SQLERROR EXIT 1

DECLARE
  v_cnt INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM   dba_users
  WHERE  username = 'DOLPHINSCHEDULER';

  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE USER dolphinscheduler
        IDENTIFIED BY "123456"
        DEFAULT TABLESPACE users
        TEMPORARY TABLESPACE temp
        QUOTA UNLIMITED ON users
    ]';

    -- give it the basic privileges you’d expect for an application schema
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, CREATE SESSION TO dolphinscheduler';
  END IF;
END;
/
EXIT
EOF

#Sudo
sed -i '$a'$USER'  ALL=(ALL)  NOPASSWD: NOPASSWD: ALL' /etc/sudoers
sed -i 's/Defaults    requirett/#Defaults    requirett/g' /etc/sudoers

#SSH
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
service ssh start

#Init schema
/bin/bash $DOLPHINSCHEDULER_HOME/tools/bin/upgrade-schema.sh

#Start Cluster
/bin/bash $DOLPHINSCHEDULER_HOME/bin/dolphinscheduler-daemon.sh start master-server
/bin/bash $DOLPHINSCHEDULER_HOME/bin/dolphinscheduler-daemon.sh start worker-server
/bin/bash $DOLPHINSCHEDULER_HOME/bin/dolphinscheduler-daemon.sh start api-server
/bin/bash $DOLPHINSCHEDULER_HOME/bin/dolphinscheduler-daemon.sh start alert-server

#Keep running
tail -f /dev/null
