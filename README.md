# simple-kafka-deploy

Kafka를 간편히 배포하기 위한 Helm Chart

Kubernetes용 대시보드, Kafka, Kafka-ui, Kafka-connect를 포함한다.

다른 컴포넌트(Grafana, Streams, ...) 추가 시 별도 릴리즈로 배포하자.

## Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)

## 사용법

### 배포

```shell
# 첫 설치
# helm install {ReleaseName} {chart archive} -f {custom config value}
helm install test chartrepo/skafka-2.0.0.tgz -f values/kraft-multi.yaml

# 업데이트
helm upgrade test chartrepo/skafka-2.0.0.tgz -f values/kraft-multi.yaml
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

### 웹 기반 모니터링 (릴리즈명: test 기준)

- Kafka UI: http://ui4kafka.test.wai
- K8s Dashboard: http://k8dashboard.test.wai
- 접속할 클라이언트 PC에서, 다음과 같이 hosts 파일에
내용 추가 필요

  ```sh
  # 리눅스 /etc/hosts
  # 윈도우 C:\Windows\System32\drivers\etc\hosts
  # X.X.X.X는 접속대상 서버의 IP
  X.X.X.X ui4kafka.test.wai
  X.X.X.X k8dashboard.test.wai
  ```

## 커스텀 value 수정 시 참고

```sh
# 차트의 default value 참고
helm show values chartrepo/skafka-2.0.0.tgz
```

## 차트 수정 시 참고

```shell
# dependency 다운로드 및 Chart.lock 최신화 (skafka 경로에서 실행)
helm dependency update

# 차트를 아카이브 파일로 생성
helm package skafka/
```

## 구성

```sh
.
├── LICENSE
├── README.md
├── chartrepo/            # 헬름 차트 아카이브 파일
│   ├── skafka-0.1.0.tgz   # kafka-connect 미포함
│   ├── skafka-1.0.1.tgz   # kafka-connect 포함
│   └── skafka-2.0.0.tgz   # kafka 최신화, 클러스터링, 외부노출 이슈 해결, kafka-ui에 릴리즈명 반영
├── skafka/               # 헬름 차트 디렉토리
│   ├── Chart.lock         # dependency 버전 확정 내용
│   ├── Chart.yaml         # 차트 파일(차트버전,앱버전,dependency버전 관리)
│   ├── charts/            # Depedency chart 모음
│   ├── templates/         # Helm template
│   └── values.yaml        # default value
└── values/               # 배포시 오버라이딩할 커스텀 value파일 모음
    └── kraft-multi.yaml
```

## 메모

- 헬름차트 bitnami/kafka:23.0.7에서 보안설정이 없으면 파워쉘에서 Kafka에 네트워크 연결이 안될 수 있다. [참고](https://stackoverflow.com/questions/48603203/powershell-invoke-webrequest-throws-webcmdletresponseexception)
  - 윈도에선 일반 cmd를 사용한다.
- 외부연결 테스트는 curl, kafkacat, kafka-topics.sh 등으로 확인

- Dependency Charts 바로가기
  - [bitnami/kafka](https://artifacthub.io/packages/helm/bitnami/kafka)
  - [licenseware/kafka-connect](https://artifacthub.io/packages/helm/licenseware/kafka-connect)
  - [provectus/kafka-ui](https://artifacthub.io/packages/helm/kafka-ui/kafka-ui)
