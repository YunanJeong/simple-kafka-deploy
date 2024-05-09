#!/bin/bash

# properties파일에 같은 key가 여러 번 나오면 가장 마지막 기술된 값이 사용됨
# broker주소와 replication factor 설정 같은 필수설정 외 나머지 요소들은 CONNECT_EXTRA_CONFIG를 사용
# CONNECT_EXTRA_CONFIG: connect-distributed.properties와 동일한 syntax로 여러 줄이 한 번에 들어간다.

# 필수 커넥트 설정 반영
echo "plugin.path=/opt/bitnami/kafka/plugins" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "bootstrap.servers=$CONNECT_BOOTSTRAP_SERVERS" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "offset.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "config.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "status.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties

# 기타 커넥트 설정 반영
echo -e "$CONNECT_EXTRA_CONFIG" >> /opt/bitnami/kafka/config/connect-distributed.properties

# Kafka Connect 실행
/opt/bitnami/kafka/bin/connect-distributed.sh /opt/bitnami/kafka/config/connect-distributed.properties
