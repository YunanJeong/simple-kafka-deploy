# 소스 + 싱크 커넥터 이미지
FROM bitnami/kafka:latest

USER root
RUN apt-get update
RUN apt-get install -y curl dnsutils netcat unzip vim iputils-ping jq
RUN apt-get install -y gettext

######################################
# 커넥트 설정파일
######################################
# 로컬파일을 이미지 내부로 복제
COPY config/* /opt/bitnami/kafka/config
# 설정파일에 환경변수 반영
RUN cd /opt/bitnami/kafka/config \
    && chmod +x set_connect.sh \
    && ./set_connect.sh

######################################
# 플러그인 설치
######################################
# 로컬파일을 이미지 내부로 복제
COPY plugins/* /usr/share/java
# 각 zip 파일 압축해제 후 삭제
RUN cd /usr/share/java \
    && for file in *.zip; do unzip "$file"; done \
    && rm *.zip
# 기타 플러그인 배치
RUN cd /usr/share/java \
    && mv mysql-connector-java-8.0.19.jar confluentinc-kafka-connect-jdbc-10.7.4/


RUN echo 'alias ll="ls -alh"' >> ~/.bashrc

# Kafka Connect 실행
CMD /opt/bitnami/kafka/bin/connect-distributed.sh /opt/bitnami/kafka/config/connect-distributed.properties

# 안꺼지게 하기(테스트용)
# CMD tail -f /dev/null