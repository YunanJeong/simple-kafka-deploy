#!/bin/bash

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
