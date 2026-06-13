# Parrot Security base image (amd64)
FROM --platform=linux/amd64 parrotsec/security

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Reliable update + minimal essential packages for XFCE + VNC
RUN apt-get update -o Acquire::ForceIPv4=true -y && \
    apt-get install -y --no-install-recommends \
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
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    ca-certificates \
    openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Firefox (Parrot-specific handling)
RUN apt-get update -o Acquire::ForceIPv4=true -y && \
    apt-get install -y --no-install-recommends \
    parrot-interface-common \
    parrot-firefox-profiles \
    firefox-esr || true

# VNC startup configuration
RUN touch /root/.Xauthority && \
    mkdir -p /root/.vnc && \
    echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose ports
EXPOSE 5901
EXPOSE 6080

# Start VNC + noVNC
CMD bash -c '\
    vncserver -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out /self.pem -keyout /self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=/self.pem 6080 localhost:5901 && \
    tail -f /dev/null'
