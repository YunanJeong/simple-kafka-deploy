# simple-kafka-deploy

kafka-deploy by helm, k8s, kafka-ui

로컬테스트 등의 용도로 가볍고 빠르게 Kafka를 배포하기 위한 Helm Chart

Kafka, K8sDashboard, Kafka-ui만 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 등을 추가할 시 다른 차트, 릴리즈로 추가배포하도록 하자.

# 실행

```
# helm install {ReleaseName} {chart archive} {custom config value}
helm install testbed chartrepo/skafka-0.1.0.tgz -f values/testbed.yaml
```

# 메모
- 헬름차트 bitnami/kafka:23.0.7에서 보안설정이 없으면 파워쉘에서 Kafka에 네트워크 연결이 안될 수 있다. [참고](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
    - 외부연결 테스트는 일반 cmd 등으로 수행하자.