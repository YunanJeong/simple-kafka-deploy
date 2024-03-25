#!/bin/bash

# 환경변수 값이 없을 경우 default 값 할당
export CONNECT_BOOTSTRAP_SERVERS=${CONNECT_BOOTSTRAP_SERVERS:-'localhost:9092'}
export CONFIG_STORAGE_REPLICATION_FACTOR=${CONFIG_STORAGE_REPLICATION_FACTOR:-1}
export PRODUCER_BATCH_SIZE=${PRODUCER_BATCH_SIZE:-16384}
export PRODUCER_BUFFER_MEMORY=${PRODUCER_BUFFER_MEMORY:-33554432}
export PRODUCER_LINGER_MS=${PRODUCER_LINGER_MS:-0}
export OFFSET_FLUSH_INTERVAL_MS=${OFFSET_FLUSH_INTERVAL_MS:-60000}
export OFFSET_FLUSH_TIMEOUT_MS=${OFFSET_FLUSH_TIMEOUT_MS:-5000}

# 환경변수를 설정파일에 반영
envsubst < /opt/bitnami/kafka/config/connect-distributed.tpl > /opt/bitnami/kafka/config/connect-distributed.properties
# envsubst < connect-distributed.tpl > connect-distributed.properties
