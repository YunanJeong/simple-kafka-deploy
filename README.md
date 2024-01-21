# simple-kafka-deploy

Kafka를 간편히 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui, Kafka-connect를 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 추가 시 별도 릴리즈로 배포하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## Quick Start

### local (private ip로 외부노출되는 환경, WSL, local VM)

```sh
# broker 3, connect 1, private ip, KRAFT
helm install test https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.3/skafka-2.0.3.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.3/kraft-multi.yaml
```

### public (public ip로 외부노출되는 환경, EC2)

```sh
# broker 3, connect 1, public ip, KRAFT
helm install test https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.3/skafka-2.0.3.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.3/kraft-multi.yaml \
--set "kafka.externalAccess.autoDiscovery.enabled=false" \
--set "kafka.externalAccess.controller.service.nodePorts={30003,30004,30005}"
```

## Start (Archive)

### local

```shell
# helm install {releaseName} {chart} -f {customValue.yaml}
# broker 3, connect 1, private ip, KRAFT
helm install test skafka-2.0.3.tgz -f values/kraft-multi.yaml
```

### public

```shell
# broker 3, connect 1, public ip, KRAFT
helm install test skafka-2.0.3.tgz -f values/kraft-multi.yaml \
--set "kafka.externalAccess.autoDiscovery.enabled=false" \
--set "kafka.externalAccess.controller.service.nodePorts={30003,30004,30005}"
```

## Access Kafka

### Broker 외부 포트

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

## Delete

```sh
# 실행중인 릴리즈 조회 및 삭제
helm list
helm uninstall test

# 과거 내역이 있는 경우(persistence) 삭제
kubectl get pvc
kubectl delete pvc {pvcName}
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
└── skafka-x.x.x.tgz        # 차트 배포용 아카이브 파일
```

## Kafka 설정 변경 방법

```sh
# 차트의 default value 참고하여 custom value 파일 작성
helm show values skafka-2.0.3.tgz

# 업데이트
helm upgrade test skafka-2.0.3.tgz -f values/my-kraft-multi.yaml
```

## skafka 차트 수정 시 참고

```shell
# dependency 다운로드 및 Chart.lock 최신화
helm dependency update skafka/

# 차트를 아카이브 파일로 생성
helm package skafka/
```

## 메모

### 윈도우에서 Kafka 접근시

- 보안설정이 없으면 파워쉘 사용불가 [[참고]](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
- 윈도에선 일반 cmd를 사용

### Kafka 외부연결 테스트

- curl, kafkacat, kafka-topics.sh 등으로 확인
- Kafka 최종 정상동작 테스트시 반드시 Produce, Consume 기능을 확인한다.
- Kafka의 EXTERNAL AdvertisedListener가 자동등록될 때, helm value에 따라 local ip가 될 수도, public ip가 될 수도 있다. 경우에 따라 produce,consume이 불가능할 수 있으므로 체크 필수

### Dependency Charts 바로가기

- [bitnami/kafka](https://artifacthub.io/packages/helm/bitnami/kafka)
- [licenseware/kafka-connect](https://artifacthub.io/packages/helm/licenseware/kafka-connect)
- [provectus/kafka-ui](https://artifacthub.io/packages/helm/kafka-ui/kafka-ui)

### broker, connect 모두 정상 Running인데, 개별 connector 조회 및 등록시 timeout 발생 이슈

- offset관련 토픽의 replication.factors 수가 브로커 수보다 많으면 문제 발생
- 시스템 부하가 심할 때 브로커 간 일부 연동 실패로, 같은 현상이 발생할 수 있다. 이후 부하가 완화되어도 해당 증상이 지속된다. 될 때까지 브로커를 재실행하거나, 스케일아웃, 최적화 등으로 해결하자.

## 메모리 관련

### 힙사이즈 설정 방법 (Kafka, KafkaConnect 공통)

- 필요한 상황이 아니면 default로 쓰면된다.
- `KAFKA_HEAP_OPTS="-Xms2G -Xmx2G"`와 같이 환경변수를 컨테이너로 넘겨준다. value파일에서 설정가능하다. min, max 값은 동일하게 한다.
- Kafka에서 JVM 메모리 할당량은 통상적으로 전체(컨테이너)리소스의 25%로 설정
  - 앱실행용 JVM보다 파일 I/O 처리에 쓰이는 별도 메모리가 많기 때문
  - 쿠버네티스의 resources에서 컨테이너 메모리를 힙의 4배로 할당한다. `requests.memory`, `limits.memory` 값은 동일하게 한다.
- 빅데이터 처리 등 일부 분야에서 힙메모리를 `10GB 이상으로 쓰는게 아주 이상한 일은 아니다`.
- 처음 실행시 메모리가 부족하진 않으나 `조금씩 꾸준히 늘어나는 경우, 메모리 누수` 가능성이 높아 코드 개선 필요
  
### 앱이 죽는 경우

- 힙 메모리 부족시, Container의 resources.limits에 도달하기도 전에 앱이 중지될 수 있다.

#### 대응방법

- JVM 힙메모리는 노드의 10\~50% 수준이 적정하지만, 필요에 따라 80\~90%까지 설정할 수 있다.
  - e.g. 데이터 규모는 작은데 상대적으로 커넥터 개수는 많은 경우, JVM메모리는 많이 필요하지만 파일 I/O 처리용 메모리는 많이 필요없어서 이렇게 설정 가능 (커넥터 수 백개 사용한 경우였음)
- 커넥트가 단독으로 노드를 사용하게 한다. resources.limit은 설정하지 않는다.
- (위 자원할당 방법들로 안되면) 스케일 업&아웃이나 별도 최적화된 Kafka Client앱을 만든다.
- [컨테이너 환경에서의 java 애플리케이션의 리소스와 메모리 설정](https://findstar.pe.kr/2022/07/10/java-application-memory-size-on-container/)

### 메모리 점유율이 높은 경우

- 메모리 점유율이 80~90%로 되어있다고 해서 항상 해당 규모의 메모리가 필요한 것은 아니다.
- 해당 앱에서 필요한 최대치라고 보면 된다. JVM은 한 번 사용했던 메모리를 반환하지 않고 계속 가지고 있기 때문.
- `jstat` 등으로 jvm을 모니터링하면 현재 사용중인 메모리를 정확하게 파악할 수 있음
