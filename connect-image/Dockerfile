FROM bitnami/kafka:4.0.0-debian-12-r8

USER root
RUN apt-get update
RUN apt-get install -y curl dnsutils netcat unzip vim iputils-ping jq gettext wget

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

# 기타 플러그인 설치
RUN cd /opt/bitnami/kafka/plugins \
    && mv mysql-connector-java-8.0.19.jar confluentinc-kafka-connect-jdbc-10.7.4/

######################################
# 커넥트 설정반영 및 실행
######################################
RUN chmod +x /opt/bitnami/kafka/config/start_connect.sh
CMD /opt/bitnami/kafka/config/start_connect.sh

# 안꺼지게 하기(테스트용)
# CMD tail -f /dev/null