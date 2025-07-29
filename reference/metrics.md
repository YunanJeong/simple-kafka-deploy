# 운영자동화를 위한 카프카 메트릭

실제 운영환경에서 모니터링할만한 것들

## Kafka Exporter

- Kafka-UI에서 대부분 조회가능하긴 한데, 알람을 걸어서 운영자동화하려면 Exporter 배포해야 함
- 배포방법
  - exporter가 kafka와 직접 통신하므로 클러스터 당 1개만 필요
  - deployment로 배포
- `kafka_consumergroup_lag`  
  (컨슈머 그룹 지연 감지. Kafka Exporter 없이 이 값 자체가 불가능하며, 클러스터 전체 소비 지연 감지의 핵심)
- `kafka_brokers`  
  (브로커 장애 즉시 감지. 실제 Kafka Exporter의 클러스터총 브로커 수이며, JMX 만으로는 클러스터 전체 브로커 개수를 직관적으로 알기 어려움)

## JMX Exporter (Kafka Broker)

- 배포방법
  - 앱 마다 1개씩 필요
  - sidecar(standalone 모드) 또는 본 앱 이미지에 내장(agent모드)하여 배포
  - 자바 앱과 커플링되어있으므로 개별 헬름차트가 아닌, kafka 배포차트와 결합되어 있어야 함. serviceMonitor도 필수.  
- `kafka_server_under_replicated_partitions`  
  (데이터 무결성 위협 즉시 감지)
- `kafka_controller_active_controller_count`  
  (컨트롤러 장애 즉시 감지. 반드시 1이어야 함)
- `jvm_gc_collection_seconds_sum`  
  (브로커·커넥트 JVM GC 한눈에 감시, 심각한 GC 장애 조기 감지)

### JMX Exporter (Kafka Connect)

- `jvm_gc_collection_seconds_sum`  
  (Kafka Connect GC 장애, 성능 저하 선제 감지)

## Node Exporter (머신 리소스)

- 배포방법
  - 노드 당 1개 씩 필요
  - daemonset, serviceMonitor로 배포
- `node_cpu_seconds_total`  
  (CPU 사용률)
- `node_memory_MemAvailable_bytes`  
  (가용 메모리)
- `node_filesystem_avail_bytes`  
  (디스크 여유 공간)
  