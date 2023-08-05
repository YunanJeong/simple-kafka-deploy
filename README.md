# simple-kafka-deploy

로컬테스트 등 용도로 가벼운 Kafka를 빠르게 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui만 포함한다. 다른 컴포넌트(Grafana, Streams, ...) 등을 추가할 시 별도 릴리즈로 배포하도록 하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## 사용법

### 수정 시

```shell
# dependency 다운로드 및 Chart.lock 최신화 (skafka 경로에서 실행)
helm dependency update

# 차트를 아카이브 파일로 생성
helm package skafka/
```

### 배포 시

```shell
# 첫 설치
# helm install {ReleaseName} {chart archive} {custom config value}
helm install testbed chartrepo/skafka-0.1.0.tgz -f values/testbed.yaml

# 업데이트
helm upgrade testbed chartrepo/skafka-0.1.0.tgz -f values/testbed.yaml
```

### 삭제 시

```sh
# 릴리즈 삭제
helm uninstall testbed

# 과거 내역(PVC) 삭제
kubectl delete pvc data-testbed-kafka-0
```

## 구성

```sh
.
├── LICENSE
├── README.md
├── chartrepo/            # 헬름 차트 아카이브 파일
│   └── skafka-0.1.0.tgz
├── skafka/               # 헬름 차트 디렉토리
│   ├── Chart.lock         # dependency 버전 확정 내용    
│   ├── Chart.yaml         # 차트 파일(차트버전,앱버전,dependency버전 관리)
│   ├── charts/            # Depedency chart 모음
│   ├── templates/         # Helm template
│   └── values.yaml        # default value
└── values/               # 배포시 추가할 커스텀 value파일 모음
    └── testbed.yaml
```

## 메모

- 헬름차트 bitnami/kafka:23.0.7에서 보안설정이 없으면 파워쉘에서 Kafka에 네트워크 연결이 안될 수 있다. [참고](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
  - 외부연결 테스트는 일반 cmd 등으로 수행하자.

- testbed.yaml
  - Kafka 로컬 접근: 9092
  - Kafka 외부 접근: 9094 or 9095
