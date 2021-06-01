FROM debian:stable-slim
MAINTAINER HaHaMan

ARG VERSION="3.0.3b"
ARG DOWNLOADURL="https://github.com/OmniDB/OmniDB/releases/download/3.0.3b/omnidb-server_3.0.3b_linux_x86_64.deb"

ENV ORACLE_CLIENT_TYPE basic
ENV ORACLE_CLIENT_VERSION 12.2 
ENV ORACLE_CLIENT_FULL_VERSION 12.2.0.1.0
ENV ZIP_NAME instantclient-$ORACLE_CLIENT_TYPE-linux.x64-$ORACLE_CLIENT_FULL_VERSION.zip 
ENV INSTANT_DIR instantclient_12_2
ENV LD_LIBRARY_PATH /usr/lib:/usr/local/lib:/usr/lib/oracle/


RUN  apt-get update \
  && apt-get install -y wget bash unzip curl telnet libaio1 \
  && if [ ! -e '/bin/systemctl' ]; then ln -s /bin/echo /bin/systemctl; fi \
  && cd /tmp/ \
  && wget -q ${DOWNLOADURL} -O omnidb-server.deb \
  && dpkg -i omnidb-server.deb \
  && mkdir -p /data \
  && mkdir /opt/oracle && cd /opt/oracle \
  && wget https://raw.githubusercontent.com/mrfoe7/minify-oracle-client/master/clients/$ORACLE_CLIENT_VERSION/$ZIP_NAME \
  && unzip $ZIP_NAME \
  && mv $INSTANT_DIR /usr/lib/oracle/ && rm -rf /opt/oracle \
  && ln -s /usr/lib/oracle/libclntsh.so.$ORACLE_CLIENT_VERSION /usr/lib/oracle/libclntsh.so \
  && ln -s /usr/lib/oracle/libocci.so.$ORACLE_CLIENT_VERSION /usr/lib/oracle/libocci.so \
  && apt-get purge -y --auto-remove unzip wget \
  && apt-get clean --dry-run \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* /app/*.zip

#ENV LD_LIBRARY_PATH=/app/instantclient_12_2:$LD_LIBRARY_PATH

EXPOSE 8000

VOLUME ["/data"]
CMD ["omnidb-server","-H","0.0.0.0","-p","8000","-d","/data"]