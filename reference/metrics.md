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
- 수집 규칙
  - Strimzi 예제 규칙을 쓰면 Strimzi Grafana 대시보드를 그대로 쓸 수 있다. skafka 기본값 (`kafka.metrics.jmx.enabled` 켜면 적용)
  - bitnami 차트는 `metrics.jmx.config` 뒤에 자체 규칙을 항상 덧붙이므로, 규칙을 바꾸려면 `existingConfigmap`으로 전체를 지정해야 한다
  - 대시보드가 쓰는 라벨(`strimzi_io_cluster` 등)은 ServiceMonitor `relabelings`로 붙인다
- `kafka_server_under_replicated_partitions`  
  (데이터 무결성 위협 즉시 감지)
- `kafka_controller_active_controller_count`  
  (컨트롤러 장애 즉시 감지. 반드시 1이어야 함)
- `jvm_gc_collection_seconds_sum`  
  (브로커·커넥트 JVM GC 한눈에 감시, 심각한 GC 장애 조기 감지)

### JMX Exporter (Kafka Connect)

- jmx config sample: https://github.com/prometheus/jmx_exporter/tree/main/examples
- 배포방법
  - 커넥트 JVM 안에 javaagent로 내장(agent 모드). jar는 커넥트 이미지에 포함 (`connect-image-jmx`)
  - `KAFKA_OPTS`에 `-javaagent:<jar>=<포트>:<규칙파일>`로 실행. 규칙 파일은 ConfigMap으로 마운트
  - skafka의 커넥트 서브차트는 8083 외 포트와 ServiceMonitor를 만들 수 없어서, `connect.metrics.enabled`를 켜면 skafka가 수집 규칙(Strimzi 예제 규칙) ConfigMap, 메트릭 Service, ServiceMonitor를 따로 만든다
- `jvm_gc_collection_seconds_sum`  
  (Kafka Connect GC 장애, 성능 저하 선제 감지)

## Strimzi Grafana 대시보드

- Strimzi 프로젝트가 grafana.com이 아닌 자체 저장소(strimzi-kafka-operator의 metrics 예제)로 배포한다. 같은 이름의 개인 업로드는 버전·변수가 달라 그대로 쓰기 어렵다
- 백업: `reference/grafana-dashboards/strimzi/` (Kafka, Kafka Connect, KRaft). datasource는 대시보드의 `DS_PROMETHEUS` 변수로 선택
- Strimzi 예제 규칙과 relabelings를 전제로 만든 대시보드라, 다른 수집 규칙으로 모은 메트릭에서는 일부 패널이 비어 보인다

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
  