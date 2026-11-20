# 커넥트 이미지 샘플 (JMX exporter 포함)

(커넥터)플러그인과 (환경변수 적용가능한)설정파일, 메트릭 수집용 JMX exporter javaagent를 포함하여 커넥트 이미지를 생성하는 예시

## 쿠버네티스에서 플러그인 처리 방법

초기화과정에서

- 온라인 저장소 다운로드
- volume 마운트하기
- network pvc에서 플러그인 가져오기
- `플러그인+본 앱을 하나의 image로 빌드`

등등의 방법이 있고, 각각 장단점이 있다.

오프라인 환경 및 관리 용이성을 감안했을 때, 여기서는 `커넥터와 커넥트를 모두 합쳐 하나의 이미지`로 구성하고, `서비스마다 별도의 커넥트 이미지를 생성`하는 것을 전제하여 구성하였다.

## JMX exporter javaagent

- 커넥트 메트릭은 커넥트 JVM 안에서 javaagent로 실행되는 JMX exporter가 HTTP로 내보낸다. (브로커처럼 사이드카를 따로 두지 않음)
- jar도 플러그인과 같은 방식(`url_requirements.txt`)으로 받되, plugins 경로에 두면 커넥트가 플러그인으로 스캔하므로 `/opt/bitnami/kafka/jmx/`로 옮긴다.
- 실행은 `KAFKA_OPTS`로 지정: `-javaagent:<jar 경로>=<메트릭 포트>:<수집 규칙 파일>`
  - 수집 규칙 파일은 이미지에 넣지 않고 ConfigMap으로 마운트한다. (규칙만 바꿀 때 이미지를 다시 빌드하지 않도록)

## 빌드

```sh
# 빌드
docker build ./ -t my-connect:0.0.1
```
