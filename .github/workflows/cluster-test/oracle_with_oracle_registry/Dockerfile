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

FROM eclipse-temurin:8-jre

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends gnupg wget lsb-release && \
    echo "deb [arch=amd64] https://download.oracle.com/otn_software/linux/instantclient/21c $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/oracle-instantclient.list && \
    wget -qO- https://download.oracle.com/otn_software/linux/instantclient/21c/instantclient-public.key | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        oracle-instantclient-basic \
        oracle-instantclient-sqlplus \
        sudo \
        openssh-server \
        netcat-traditional && \
    rm -rf /var/lib/apt/lists/*;

COPY ./apache-dolphinscheduler-*-SNAPSHOT-bin.tar.gz /root
RUN tar -zxvf /root/apache-dolphinscheduler-*-SNAPSHOT-bin.tar.gz -C ~
RUN rm -f /root/apache-dolphinscheduler-*-SNAPSHOT-bin.tar.gz

RUN mv /root/apache-dolphinscheduler-*-SNAPSHOT-bin /root/apache-dolphinscheduler-test-SNAPSHOT-bin

ENV DOLPHINSCHEDULER_HOME=/root/apache-dolphinscheduler-test-SNAPSHOT-bin

#Setting dolphinscheduler_env.sh
COPY .github/workflows/cluster-test/oracle_with_oracle_registry/dolphinscheduler_env.sh $DOLPHINSCHEDULER_HOME/bin/env/dolphinscheduler_env.sh

#Download oracle jar
ENV ORACLE_URL="https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/23.9.0.25.07/ojdbc8-23.9.0.25.07.jar"
ENV ORACLE_DRIVER="ojdbc8-23.9.0.25.07.jar"
RUN wget -O $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $ORACLE_URL
RUN cp $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $DOLPHINSCHEDULER_HOME/tools/libs/$ORACLE_DRIVER; \
    cp $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $DOLPHINSCHEDULER_HOME/api-server/libs/$ORACLE_DRIVER ; \
    cp $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $DOLPHINSCHEDULER_HOME/master-server/libs/$ORACLE_DRIVER ; \
    cp $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $DOLPHINSCHEDULER_HOME/worker-server/libs/$ORACLE_DRIVER ; \
    cp $DOLPHINSCHEDULER_HOME/libs/$ORACLE_DRIVER $DOLPHINSCHEDULER_HOME/alert-server/libs/$ORACLE_DRIVER

#Deploy
COPY .github/workflows/cluster-test/mysql_with_mysql_registry/deploy.sh /root/deploy.sh

CMD [ "/bin/bash", "/root/deploy.sh" ]
