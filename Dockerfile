FROM ubuntu:kinetic

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

COPY install-pkgs.sh /install-pkgs.sh

RUN bash /install-pkgs.sh

ENV GVM_LIBS_VERSION="v22.6.1" \
    OPENVAS_SCANNER_VERSION="v22.7.2" \
    OPENVAS_SMB_VERSION="v22.5.2" \
    OSPD_OPENVAS_VERSION="v22.5.1" \
    NOTUS_VERSION="v22.5.0" \
    SYNC_VERSION="main" \
    INSTALL_PREFIX="/usr/local" \
    SOURCE_DIR="/source" \
    BUILD_DIR="/build" \
    INSTALL_DIR="/install"
    
RUN mkdir -p $SOURCE_DIR && \
    mkdir -p $BUILD_DIR


RUN echo "Starting Build..."

    #
    # install libraries module for the Greenbone Vulnerability Management Solution
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $GVM_LIBS_VERSION https://github.com/greenbone/gvm-libs.git && \
    mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs && \
    cmake $SOURCE_DIR/gvm-libs \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release \
        -DSYSCONFDIR=/etc \
        -DLOCALSTATEDIR=/var && \
    make -j$(nproc) && \
    make install
	
    #
    # install smb module for the OpenVAS Scanner
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OPENVAS_SMB_VERSION https://github.com/greenbone/openvas-smb.git && \
    mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb && \
    cmake $SOURCE_DIR/openvas-smb \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install
    
    #
    # Install Open Vulnerability Assessment System (OpenVAS) Scanner of the Greenbone Vulnerability Management (GVM) Solution
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OPENVAS_SCANNER_VERSION https://github.com/greenbone/openvas-scanner.git && \
    mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner && \
    cmake $SOURCE_DIR/openvas-scanner \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release \
        -DSYSCONFDIR=/etc \
        -DLOCALSTATEDIR=/var \
        -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
        -DOPENVAS_RUN_DIR=/run/ospd && \
    make -j$(nproc) && \
    make install
    
    #
    # Install Open Scanner Protocol for OpenVAS
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OSPD_OPENVAS_VERSION https://github.com/greenbone/ospd-openvas.git && \
    cd $SOURCE_DIR/ospd-openvas && \
    python3 -m pip install . --no-warn-script-location
    
    #
    # Install Notus Scanner
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $NOTUS_VERSION https://github.com/greenbone/notus-scanner.git && \
    cd $SOURCE_DIR/notus-scanner && \
    python3 -m pip install . --no-warn-script-location
    
    #
    # Install Greenbone Feed Sync
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $SYNC_VERSION https://github.com/greenbone/greenbone-feed-sync.git && \
    cd $SOURCE_DIR/greenbone-feed-sync && \
    python3 -m pip install . --no-warn-script-location
    
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openvas.conf && ldconfig && cd / && rm -rf /build

COPY scripts/* /

RUN chmod +x /*.sh

ENV NMAP_PRIVILEGED=1

RUN setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap

ENTRYPOINT ["/start.sh"]
