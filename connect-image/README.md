# 커넥트 이미지 샘플

(커넥터)플러그인과 (환경변수 적용가능한)설정파일을 포함하여 커넥트 이미지를 생성하는 예시

## 쿠버네티스에서 플러그인 처리 방법

초기화과정에서

- 온라인 저장소 다운로드
- volume 마운트하기
- network pvc에서 플러그인 가져오기
- `플러그인+본 앱을 하나의 image로 빌드`

등등의 방법이 있고, 각각 장단점이 있다.

오프라인 환경 및 관리 용이성을 감안했을 때, 여기서는 `커넥터와 커넥트를 모두 합쳐 하나의 이미지`로 구성하고, `서비스마다 별도의 커넥트 이미지를 생성`하는 것을 전제하여 구성하였다.

## 빌드

```sh
# 빌드
docker build ./ -t my-connect:0.0.1
```
