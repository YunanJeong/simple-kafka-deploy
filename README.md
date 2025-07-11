# simple-kafka-deploy

Kafka를 간편히 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui, Kafka-connect를 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 추가 시 별도 릴리즈로 배포하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## Start

```shell
# helm install {releaseName} {chart} -f {customValue.yaml}
helm install kfk skafka-3.0.0.tgz

# 주로 private ip로 외부노출되는 환경, WSL, local VM에 사용
helm install kfk skafka-3.0.0.tgz -f values/1node_AD.yaml
helm install kfk skafka-3.0.0.tgz -f values/3node_HA_AD.yaml

# 주로 public ip로 외부노출되는 환경, EC2, 클라우드에 사용
helm install kfk skafka-3.0.0.tgz -f values/1node.yaml
helm install kfk skafka-3.0.0.tgz -f values/3node_HA.yaml

# Quick Start
helm install kfk https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/skafka-3.0.0.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/1node_AD.yaml

helm install kfk https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/skafka-3.0.0.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/3node_HA_AD.yaml

helm install kfk https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/skafka-3.0.0.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/1node.yaml

helm install kfk https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/skafka-3.0.0.tgz \
-f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v3.0.0/3node_HA.yaml
```

### Values 파일설명

- 1node: 노드 1개
- 3node_HA: 노드 3개 HA 구성(pdb 최소 51% 가용유지, replication factor 2, partition 3)
- AD: auto_discovery
  - auto discovery 및 관련기능 활성화
  - 노드의 네트워크 정보를 자동으로 가져와서, advertiesd.listeners 및 쿠버네티스 Service를 구성
  - `auto discovery가 인식하는 기본IP는 네트워크 환경마다 다를 수 있으므로, 반드시 Kafka 구축 후에 연결 테스트를 해야 함`

## Access Kafka

### Broker 외부노출 포트

- LB Port: 9095
- NP Port: 30003,30004,30005 (3노드 기준)
- `외부에서 접근시 LB Port를 이용하되, 모든 NP Port에 대한 네트워크 인가 필요`
- NP Port로 개별 broker에 직접접근해도 되지만, 부하분산 효과가 없고, 포트가 직접 노출되어 보안상 좋지 않음

```sh
##################################################################################################
# K8s기반 Kafka에서 외부 Client와 Broker 간 통신과정
  # 1. Client가 LoadBalancer의 주소(tcp-external)로 접근
  # 2. LoadBalancer는 Client의 최초 접근 트래픽을 Broker 1개에 랜덤매칭하여 포워딩  (K8s의 LoadBalancer 기능)
  # 3. 해당 Broker는 자신에게 직접 접근가능한 주소를 Kafka Client에게 전달          (Kafka의 advertised.listener 기능)
  # 4. Kafka Client는 connection이 유지되는 동안 Broker로부터 받은 주소로 통신
##################################################################################################
```

### 웹 기반 모니터링 (릴리즈명: `kfk` 기준)

- Kafka-UI
  - <http://ui4kafka.kfk.wai>
  - kafka-IP:30080
- K8s-Dashboard: <http://k8dashboard.kfk.wai>
- 접속할 클라이언트 PC의 hosts 파일에 다음과 같이 내용 추가 필요

```sh
# 리눅스 /etc/hosts
# 윈도우 C:\Windows\System32\drivers\etc\hosts
# {serverIP} {appName}.{releaseName}.wai
X.X.X.X ui4kafka.kfk.wai
X.X.X.X k8dashboard.kfk.wai
```

## Delete

```sh
# 실행중인 릴리즈 조회 및 삭제
helm list
helm uninstall kfk

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
helm show values skafka-3.0.0.tgz

# 업데이트
helm upgrade kfk skafka-3.0.0.tgz -f values/my-kraft-multi.yaml
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
- [kafka-ui/kafka-ui(kafbat,provectus)](https://artifacthub.io/packages/helm/kafka-ui/kafka-ui)

### Kafka 이슈 (커스터마이징, 트러블 슈팅)

[kafka-test](github.com/yunanjeong/kafka-test)에 문서화

#### broker, connect 모두 정상 Running인데, 개별 connector 조회 및 등록시 timeout 발생 이슈

- offset관련 토픽의 replication.factors 수가 브로커 수보다 많으면 문제 발생
- 시스템 부하가 심할 때 브로커 간 일부 연동 실패로, 같은 현상이 발생할 수 있다. 이후 부하가 완화되어도 해당 증상이 지속된다. 될 때까지 브로커를 재실행하거나, 스케일아웃, 최적화 등으로 해결하자.