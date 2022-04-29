FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

COPY install-pkgs.sh /install-pkgs.sh

RUN bash /install-pkgs.sh

ENV GVM_LIBS_VERSION="21.4.4" \
    OPENVAS_SCANNER_VERSION="v21.4.4" \
    OPENVAS_SMB_VERSION="21.4.0" \
    OSPD_OPENVAS_VERSION="21.4.4" \
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
    
RUN curl -f -L https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVM_LIBS_VERSION.tar.gz -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/gvm-libs/releases/download/v$GVM_LIBS_VERSION/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc && \
    tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs && \
    cmake $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release \
        -DSYSCONFDIR=/etc \
        -DLOCALSTATEDIR=/var && \
    make -j$(nproc) && \
    make install
	
	#
    # install smb module for the OpenVAS Scanner
    #
    
RUN curl -f -L https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVAS_SMB_VERSION.tar.gz -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/openvas-smb/releases/download/v$OPENVAS_SMB_VERSION/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc && \
    tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb && \
    cmake $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install
    
    #
    # Install Open Vulnerability Assessment System (OpenVAS) Scanner of the Greenbone Vulnerability Management (GVM) Solution
    #
    
RUN curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_SCANNER_VERSION.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_SCANNER_VERSION/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc && \
    tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner && \
    cmake $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION \
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
    
RUN curl -f -L https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPD_OPENVAS_VERSION.tar.gz -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/ospd-openvas/releases/download/v$OSPD_OPENVAS_VERSION/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc && \
    tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
    cd $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION && \
    python3 -m pip install . --no-warn-script-location
    
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openvas.conf && ldconfig && cd / && rm -rf /build

COPY scripts/* /

ENTRYPOINT ["/start.sh"]
