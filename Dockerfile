FROM parrotsec/security:latest

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    ca-certificates \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN touch /root/.Xauthority && \
    mkdir -p /root/.vnc && \
    echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

EXPOSE 5901
EXPOSE 6080

CMD bash -c '\
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x800 && \
    openssl req -new -subj "/C=US" -x509 -days 365 -nodes \
        -out /root/self.pem -keyout /root/self.pem && \
    websockify -D \
        --web=/usr/share/novnc \
        --cert=/root/self.pem \
        6080 localhost:5901 && \
    tail -f /dev/null'
