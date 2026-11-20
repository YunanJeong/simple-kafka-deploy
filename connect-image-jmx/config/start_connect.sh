#!/bin/bash

# CONNECT_BOOTSTRAP_SERVERS, CONNECT_STORAGE_REPLICATION_FACTOR: 필수설정으로 취급
# CONNECT_EXTRA_CONFIG: connect-distributed.properties와 동일한 syntax로 여러 줄이 한 번에 들어간다

# 환경변수 필수값이 없을 경우 default 값 할당
export CONNECT_BOOTSTRAP_SERVERS=${CONNECT_BOOTSTRAP_SERVERS:-'localhost:9092'}
export CONNECT_STORAGE_REPLICATION_FACTOR=${CONNECT_STORAGE_REPLICATION_FACTOR:-1}

# 필수 커넥트 설정 반영 (properties파일에서 같은 key가 반복될 시, 가장 마지막에 기술된 값이 사용됨)
echo "plugin.path=/opt/bitnami/kafka/plugins" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "bootstrap.servers=$CONNECT_BOOTSTRAP_SERVERS" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "offset.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "config.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties
echo "status.storage.replication.factor=$CONNECT_STORAGE_REPLICATION_FACTOR" >> /opt/bitnami/kafka/config/connect-distributed.properties

# 기타 커넥트 설정 반영
echo -e "$CONNECT_EXTRA_CONFIG" >> /opt/bitnami/kafka/config/connect-distributed.properties

# Kafka Connect 실행
/opt/bitnami/kafka/bin/connect-distributed.sh /opt/bitnami/kafka/config/connect-distributed.properties
