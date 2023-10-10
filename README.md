# simple-kafka-deploy

Kafka를 간편히 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui, Kafka-connect를 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 추가 시 별도 릴리즈로 배포하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## 사용법

### 빠른 설치

```sh
# helm install {releaseName} {chart} -f {customValue.yaml}
helm install test https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.0/skafka-2.0.0.tgz -f https://github.com/YunanJeong/simple-kafka-deploy/releases/download/v2.0.0/kraft-multi.yaml
```

### 설치

```shell
# 첫 설치
# helm install {releaseName} {chart} -f {customValue.yaml}
helm install test skafka-2.0.0.tgz -f values/kraft-multi.yaml
```

### 커스텀 및 업글

```sh
# 차트의 default value 참고하여 custom value 파일 작성
helm show values skafka-2.0.0.tgz

# 업데이트
helm upgrade test skafka-2.0.0.tgz -f values/kraft-multi.yaml
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
├── reference/            # (단순 참고용) 하위 차트의 default value
├── skafka/               # 헬름차트 디렉토리
│   ├── Chart.lock          # 하위차트 버전 확정
│   ├── charts/             # 하위차트 생성 경로
│   ├── Chart.yaml          # 버전관리 (차트, 앱, 하위차트)
│   ├── templates/          # Helm template
│   └── values.yaml         # default value
├── values/               # 배포시 오버라이딩할 custom value 모음
│   └── kraft-multi.yaml    # 샘플
└── skafka-2.0.0.tgz      # 차트 배포용 아카이브 파일
```

## 메모

- 윈도우에서 Kafka 접근시, 보안설정이 없으면 파워쉘 사용불가 [[참고]](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
  - 윈도에선 일반 cmd를 사용
- 외부연결 테스트는 curl, kafkacat, kafka-topics.sh 등으로 확인
  - Kafka 정상동작 테스트는 반드시 Produce, Consume으로 한다.
- Dependency Charts 바로가기
  - [bitnami/kafka](https://artifacthub.io/packages/helm/bitnami/kafka)
  - [licenseware/kafka-connect](https://artifacthub.io/packages/helm/licenseware/kafka-connect)
  - [provectus/kafka-ui](https://artifacthub.io/packages/helm/kafka-ui/kafka-ui)
