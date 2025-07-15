FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

COPY install-pkgs.sh /install-pkgs.sh

RUN bash /install-pkgs.sh

ENV GVM_LIBS_VERSION="v22.23.0" \
    OPENVAS_SCANNER_VERSION="v23.21.0" \
    OPENVAS_SMB_VERSION="v22.5.8" \
    OSPD_OPENVAS_VERSION="v22.9.0" \
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
    mkdir -p $BUILD_DIR/gvm-libs && \
    cmake \
	-S $SOURCE_DIR/gvm-libs \
	-B $BUILD_DIR/gvm-libs \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release \
        -DSYSCONFDIR=/etc \
        -DLOCALSTATEDIR=/var && \
    cmake --build $BUILD_DIR/gvm-libs -j$(nproc) && \
    mkdir -p $INSTALL_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs && \
    make DESTDIR=$INSTALL_DIR/gvm-libs install && \
    cp -rv $INSTALL_DIR/gvm-libs/* /
	
    #
    # install smb module for the OpenVAS Scanner
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OPENVAS_SMB_VERSION https://github.com/greenbone/openvas-smb.git && \
    mkdir -p $BUILD_DIR/openvas-smb && \
    cmake \
        -S $SOURCE_DIR/openvas-smb \
	-B $BUILD_DIR/openvas-smb \
 	-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake --build $BUILD_DIR/openvas-smb -j$(nproc) && \
    mkdir -p $INSTALL_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb && \
    make DESTDIR=$INSTALL_DIR/openvas-smb install && \
    cp -rv $INSTALL_DIR/openvas-smb/* /
    
    #
    # Install Open Vulnerability Assessment System (OpenVAS) Scanner of the Greenbone Vulnerability Management (GVM) Solution
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OPENVAS_SCANNER_VERSION https://github.com/greenbone/openvas-scanner.git && \
    mkdir -p $BUILD_DIR/openvas-scanner && \
    cmake \
    	-S $SOURCE_DIR/openvas-scanner \
    	-B $BUILD_DIR/openvas-scanner \
    	-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    	-DCMAKE_BUILD_TYPE=Release \
    	-DSYSCONFDIR=/etc \
    	-DLOCALSTATEDIR=/var \
    	-DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
    	-DOPENVAS_RUN_DIR=/run/ospd && \
    cmake --build $BUILD_DIR/openvas-scanner -j$(nproc) && \
    mkdir -p $INSTALL_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner && \
    make DESTDIR=$INSTALL_DIR/openvas-scanner install && \
    cp -rv $INSTALL_DIR/openvas-scanner/* /
    
    #
    # Install Open Scanner Protocol for OpenVAS
    #
    
RUN cd $SOURCE_DIR && \
    git clone --branch $OSPD_OPENVAS_VERSION https://github.com/greenbone/ospd-openvas.git && \
    cd $SOURCE_DIR/ospd-openvas && \
    mkdir -p $INSTALL_DIR/ospd-openvas && \
    python3 -m pip install --root=$INSTALL_DIR/ospd-openvas --no-warn-script-location . && \
    cp -rv $INSTALL_DIR/ospd-openvas/* /
    
    #
	# Install OpenVAS Daemon (replaces Notus) and RUST/Cargo Packages
	#
	
RUN echo "Installing Openvas Daemon" && \
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain 1.85.0 -y && \
    # . "$HOME/.cargo/env" && \
    mkdir -p $INSTALL_DIR/openvasd/usr/local/bin && \
    cd $SOURCE_DIR/openvas-scanner/rust/src/openvasd && \
    cargo build --release && \
    cd $SOURCE_DIR/openvas-scanner/rust/src/scannerctl && \
    cargo build --release && \
    cp -v ../../target/release/openvasd $INSTALL_DIR/openvasd/usr/local/bin/ && \
    cp -v ../../target/release/scannerctl $INSTALL_DIR/openvasd/usr/local/bin/ && \
    cp -rv $INSTALL_DIR/openvasd/* /
    
    #
    # Install Greenbone Feed Sync
    #
    
RUN mkdir -p $INSTALL_DIR/greenbone-feed-sync && \
    python3 -m pip install --root=$INSTALL_DIR/greenbone-feed-sync --no-warn-script-location greenbone-feed-sync && \
    cp -rv $INSTALL_DIR/greenbone-feed-sync/* /
    
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openvas.conf && ldconfig && cd / && rm -rf /build

COPY scripts/* /

RUN chmod +x /*.sh

ENV NMAP_PRIVILEGED=1

RUN setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap

ENTRYPOINT ["/start.sh"]
