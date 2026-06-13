# Parrot Security base image (amd64)
FROM --platform=linux/amd64 parrotsec/security

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Fix mirrors + update + install desktop & VNC packages
RUN apt update -y || true && \
    apt-get update -o Acquire::ForceIPv4=true -y && \
    apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    firefox \
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
    openssl \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Prepare X11 auth and VNC startup
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
