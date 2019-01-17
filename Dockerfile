FROM quay.io/spivegin/golang_dart_protoc_dev AS build-env
WORKDIR /opt/src/src/github.com/

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install gcc && apt-get -y autoremove && apt-get -y clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CGO_ENABLED=0\
    BUILD_HOST=tricll.xyz \
    BUILD_USER=dockerquay
RUN mkdir -p $GOPATH/src/github.com/syncthing/syncthing && cd $GOPATH/src/github.com/syncthing/ &&\
    git clone https://github.com/syncthing/syncthing.git &&\
    cd $GOPATH/src/github.com/syncthing/syncthing &&\
    go run build.go

FROM quay.io/spivegin/tlmbasedebian
ENV DINIT=1.2.2 \
    TREAFIK_VERSION=1.7.7\
    ENDPOINT="minio:9000" \
    ACCESS_KEY_ID="Q3AM3UQ867SPQQA43P2F" \
    SECRET_ACCESS_KEY="zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG" \
    USE_SSL=true \
    COMMAND="--web --docker --providers.docker.swarmmode --docker.watch --docker.domain=example.com --logLevel=DEBUG"

WORKDIR /opt/syncthing
RUN mkdir /opt/bin
COPY --from=build-env /opt/src/src/github.com/syncthing/syncthing/bin/* /opt/bin/

ADD https://raw.githubusercontent.com/adbegon/pub/master/AdfreeZoneSSL.crt /usr/local/share/ca-certificates/
ADD https://github.com/Yelp/dumb-init/releases/download/v${DINIT}/dumb-init_${DINIT}_amd64.deb /tmp/dumb-init_amd64.deb

RUN update-ca-certificates --verbose &&\
    chmod +x /opt/bin/stbench &&\
    chmod +x /opt/bin/stcli &&\
    chmod +x /opt/bin/stcompdirs &&\
    chmod +x /opt/bin/stdisco &&\
    chmod +x /opt/bin/stdiscosrv &&\
    chmod +x /opt/bin/stevents &&\
    chmod +x /opt/bin/stfileinfo &&\
    chmod +x /opt/bin/stfinddevice &&\
    chmod +x /opt/bin/stfindignored &&\
    chmod +x /opt/bin/stgenfiles &&\
    chmod +x /opt/bin/stindex &&\
    chmod +x /opt/bin/strelaypoolsrv &&\
    chmod +x /opt/bin/strelaysrv &&\
    chmod +x /opt/bin/stsigtool &&\
    chmod +x /opt/bin/stvanity &&\
    chmod +x /opt/bin/stwatchfile &&\
    chmod +x /opt/bin/syncthing &&\
    chmod +x /opt/bin/testutil &&\
    chmod +x /opt/bin/uraggregate &&\
    chmod +x /opt/bin/ursrv &&\
    ln -s /opt/bin/stbench /bin/stbench &&\
    ln -s /opt/bin/stcli /bin/stcli &&\
    ln -s /opt/bin/stcompdirs /bin/stcompdirs &&\
    ln -s /opt/bin/stdisco /bin/stdisco &&\
    ln -s /opt/bin/stdiscosrv /bin/stdiscosrv &&\
    ln -s /opt/bin/stevents /bin/stevents &&\
    ln -s /opt/bin/stfileinfo /bin/stfileinfo &&\
    ln -s /opt/bin/stfinddevice /bin/stfinddevice &&\
    ln -s /opt/bin/stfindignored /bin/stfindignored &&\
    ln -s /opt/bin/stgenfiles /bin/stgenfiles &&\
    ln -s /opt/bin/stindex /bin/stindex &&\
    ln -s /opt/bin/strelaypoolsrv /bin/strelaypoolsrv &&\
    ln -s /opt/bin/strelaysrv /bin/strelaysrv &&\
    ln -s /opt/bin/stsigtool /bin/stsigtool &&\
    ln -s /opt/bin/stvanity /bin/stvanity &&\
    ln -s /opt/bin/stwatchfile /bin/stwatchfile &&\
    ln -s /opt/bin/syncthing /bin/syncthing &&\
    ln -s /opt/bin/testutil /bin/testutil &&\
    ln -s /opt/bin/uraggregate /bin/uraggregate &&\
    ln -s /opt/bin/ursrv /bin/ursrv &&\
    dpkg -i /tmp/dumb-init_amd64.deb && \
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

#EXPOSE 80 443 8080 8443
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash"]
