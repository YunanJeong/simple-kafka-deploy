# --- stage: fetch JDK 11 (alpine로 가볍게) ---
FROM alpine:3.20 AS fetch-jdk11
ARG JDK11_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.23+9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.23_9.tar.gz"
RUN apk add --no-cache ca-certificates curl tar \
 && mkdir -p /jdk-11 \
 && curl -fsSL "$JDK11_URL" | tar -xz --strip-components=1 -C /jdk-11


# --- stage: final ---
FROM bitnamilegacy/kafka:3.5.2-debian-12-r27
USER root

# bitnami는 기본 JAVA 경로가 /opt/bitnami/java
COPY --chown=1001:0 --from=fetch-jdk11 /jdk-11 /opt/bitnami/java-11
# 핵심: 기존 17 디렉터리를 지우고 11로 바꿔치기
RUN rm -rf /opt/bitnami/java \
 && ln -sfn /opt/bitnami/java-11 /opt/bitnami/java

ENV JAVA_HOME=/opt/bitnami/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"


RUN apt-get update
RUN apt-get install -y curl dnsutils netcat-openbsd unzip vim iputils-ping jq gettext wget \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'alias ll="ls -alh"' >> ~/.bashrc

######################################
# 로컬파일을 이미지 내부로 복제
######################################
COPY config/* /opt/bitnami/kafka/config/
COPY plugins/* /opt/bitnami/kafka/plugins/

######################################
# 외부파일 다운로드 (외부저장소 또는 내 저장소 링크 사용)
######################################
RUN cd /opt/bitnami/kafka/plugins \
    && wget -i url_requirements.txt

######################################
# 커넥터 등 플러그인 설치
######################################
# 각 zip 파일 압축해제 후 삭제
RUN cd /opt/bitnami/kafka/plugins \
    && if [ "$(ls *.zip 2>/dev/null)" ]; then \
         for file in *.zip; do unzip "$file"; done \
         && rm *.zip; \
       fi

# 각 tar.gz 파일 압축해제 후 삭제
RUN cd /opt/bitnami/kafka/plugins \
    && if [ "$(ls *.tar.gz 2>/dev/null)" ]; then \
         for file in *.tar.gz; do tar -xzvf "$file"; done \
         && rm *.tar.gz; \
       fi

######################################
# 커넥트 설정반영 및 실행
######################################
RUN chmod +x /opt/bitnami/kafka/config/start_connect.sh
CMD /opt/bitnami/kafka/config/start_connect.sh

# 안꺼지게 하기(테스트용)
# CMD tail -f /dev/null