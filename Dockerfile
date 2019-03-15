#
# https://github.com/vimagick/dockerfiles/tree/master/ngrokd
#

FROM debian:stretch
MAINTAINER 0x4ec7 <0x4ec7@gmail.com>

ARG NGROK_DOMAIN
ENV NGROK_CA_KEY assets/client/tls/ngrokroot.key
ENV NGROK_CA_CRT assets/client/tls/ngrokroot.crt
ENV NGROK_SERVER_KEY assets/server/tls/snakeoil.key
ENV NGROK_SERVER_CSR assets/server/tls/snakeoil.csr
ENV NGROK_SERVER_CRT assets/server/tls/snakeoil.crt
ENV NGROK_DIR /usr/local/ngrok
ENV NGROK_TMP /usr/local/ngrok/tmp

WORKDIR ${NGROK_DIR}

RUN apt-get update && \
    apt-get install -y build-essential \
                       curl \
                       git \
                       golang \
                       mercurial
RUN git clone https://github.com/inconshreveable/ngrok.git ${NGROK_TMP} && \
    cd ${NGROK_TMP} && \
    openssl genrsa -out ${NGROK_CA_KEY} 2048 && \
    openssl req -new -x509 -nodes -key ${NGROK_CA_KEY} -subj "/CN=${NGROK_DOMAIN}" -days 3650 -out ${NGROK_CA_CRT} && \
    openssl genrsa -out ${NGROK_SERVER_KEY} 2048 && \
    openssl req -new -key ${NGROK_SERVER_KEY} -subj "/CN=${NGROK_DOMAIN}" -out ${NGROK_SERVER_CSR} && \
    openssl x509 -req -in ${NGROK_SERVER_CSR} -CA ${NGROK_CA_CRT} -CAkey ${NGROK_CA_KEY} -CAcreateserial -days 3650 -out ${NGROK_SERVER_CRT} && \
    GOARCH=amd64 GOOS=linux make release-server && \
    GOARCH=amd64 GOOS=windows make release-client && \
    mv ${NGROK_TMP}/assets ${NGROK_DIR}/ && \
    mv ${NGROK_TMP}/bin ${NGROK_DIR}/
RUN apt-get purge --auto-remove -y build-essential \
                                   curl \
                                   git \
                                   golang \
                                   mercurial && \
    rm -rf ${NGROK_TMP}

EXPOSE 3389 4443

ENTRYPOINT ["/usr/local/ngrok/bin/ngrokd"]
