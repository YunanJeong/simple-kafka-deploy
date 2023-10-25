# simple-kafka-deploy

Kafka를 간편히 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui, Kafka-connect를 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 추가 시 별도 릴리즈로 배포하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## 사용법

### 빠른 설치 (local환경, WSL)

```sh
# private ip, KRAFT, broker 3, connect 1
helm install test https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.2/skafka-2.0.2.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.2/kraft-multi.yaml
```

### 빠른 설치 (public환경, EC2, public ip로 외부노출되는 환경)

```sh
# public ip, KRAFT, broker 3, connect 1
helm install test https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.2/skafka-2.0.2.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.2/kraft-multi.yaml \
--set "kafka.externalAccess.autoDiscovery.enabled=false" \
--set "kafka.externalAccess.controller.service.nodePorts={30001,30002,30003}"
```

### 설치

```shell
# 첫 설치
# helm install {releaseName} {chart} -f {customValue.yaml}
helm install test skafka-2.0.2.tgz -f values/kraft-multi.yaml
```

### 커스텀 및 업글

```sh
# 차트의 default value 참고하여 custom value 파일 작성
helm show values skafka-2.0.2.tgz

# 업데이트
helm upgrade test skafka-2.0.2.tgz -f values/kraft-multi.yaml
```

### 삭제

```sh
# 릴리즈 삭제
helm uninstall test

# 과거 내역이 있는 경우(PVC) 삭제
kubectl get pvc
kubectl delete pvc {pvcName}
```

## 접속법

### Kafka 접근 포트

- 9095

### 웹 기반 모니터링 (릴리즈명: `test` 기준)

- Kafka-UI: <http://ui4kafka.test.wai>
- K8s-Dashboard: <http://k8dashboard.test.wai>
- 접속할 클라이언트 PC의 hosts 파일에 다음과 같이 내용 추가 필요

```sh
# 리눅스 /etc/hosts
# 윈도우 C:\Windows\System32\drivers\etc\hosts
# {serverIP} {appName}.{releaseName}.wai
X.X.X.X ui4kafka.test.wai
X.X.X.X k8dashboard.test.wai
```

## 차트 수정 시 참고

```shell
# dependency 다운로드 및 Chart.lock 최신화
helm dependency update skafka/

# 차트를 아카이브 파일로 생성
helm package skafka/
```

## 구성

```sh
.
├── reference/              # (단순 참고용) 하위 차트의 default value
├── skafka/                 # 헬름차트 디렉토리
│   ├── Chart.lock            # 하위차트 버전 확정
│   ├── charts/               # 하위차트 생성 경로
│   ├── Chart.yaml            # 버전관리 (차트, 앱, 하위차트)
│   ├── templates/            # Helm template
│   └── values.yaml           # default value
├── values/                 # 배포시 오버라이딩할 custom value 모음
│   ├── kraft-multi.yaml      # 샘플(local ip)
│   └── kraft-multi-ec2.yaml  # 샘플(public ip)
└── skafka-x.x.x.tgz      # 차트 배포용 아카이브 파일
```

## 메모

- 윈도우에서 Kafka 접근시, 보안설정이 없으면 파워쉘 사용불가 [[참고]](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
  - 윈도에선 일반 cmd를 사용
- 외부연결 테스트는 curl, kafkacat, kafka-topics.sh 등으로 확인
  - Kafka 정상동작 테스트는 반드시 Produce, Consume으로 한다.
- Kafka의 EXTERNAL AdvertisedListener가 자동등록될 때, helm value에 따라 local ip가 될 수도, public ip가 될 수도 있다. 경우에 따라 produce,consume이 불가능할 수 있으므로 체크 필수
- Dependency Charts 바로가기
  - [bitnami/kafka](https://artifacthub.io/packages/helm/bitnami/kafka)
  - [licenseware/kafka-connect](https://artifacthub.io/packages/helm/licenseware/kafka-connect)
  - [provectus/kafka-ui](https://artifacthub.io/packages/helm/kafka-ui/kafka-ui)
- 브로커는 기본적으로 3 노드를 쓴다. 1노드시 connect에 connector를 등록할 때, timeout error가 발생할 수 있다.[포럼 참고](https://forum.confluent.io/t/kafka-connect-request-timeout/1311/3)
- 힙사이즈 부족할시 설정 방법 (Kafka, KafkaConnect 공통)
  - Kafka에서 JVM 메모리 할당량은 전체(컨테이너)의 25% 수준으로 한다. 기본 앱실행을 위한 JVM보다 파일 I/O에 처리하는 별도 메모리가 많기 때문
  - 이에따라, 쿠버네티스 설정의 resources도 고정해줘야 한다.
  - 다음과 같이 설정할 수 있는데, requests와 limits는 동일하게 설정해주고,
  - value파일에서 작성하면 적용되도록 차트 템플릿에도 적용해주자. 차트에선 보통 deployment 오브젝트의 spec.template.spec.containers.[*] 섹션에 envs와 resources를 설정하는 부분이 있다.
  - 
```
      envs: # []
        - KAFKA_HEAP_OPTS="-Xms2G -Xmx2G"  # 힙 사이즈: 컨테이너의 25% 수준. 컨테이너 resource 고정 필요
      resources:
        requests:
          memory: 8000Mi
        limits: 
          memory: 8000Mi
```

- 커넥트가 죽는 문제
  - 자바힙메모리 부족 => 기본 설정값 낮음
  - 카프카 앱 메모리는 JVM에 기본할당하는 것과 I/O에 할당하는 것이 있는데,
    - => CPU가 꽉차서 힙메모리를 늘려도 꽉차버린다. 힙메모리 올려줘도 쿠버네티스 Pod에 할당된 리소스를 다쓰지도 못한다. 
    - 힙메모리 늘리고 천천히 등록하자.
    - [컨테이너 환경에서의 java 애플리케이션의 리소스와 메모리 설정](https://findstar.pe.kr/2022/07/10/java-application-memory-size-on-container/)
