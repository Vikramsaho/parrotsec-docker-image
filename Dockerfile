# Parrot Security base image (amd64)
FROM --platform=linux/amd64 parrotsec/security:latest

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Update and install XFCE desktop + VNC + noVNC + essentials
RUN apt update -y && apt install -y --no-install-recommends \
    parrot-desktop-xfce \
    tigervnc-standalone-server \
    novnc \
    websockify \
    firefox-esr \
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
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Create VNC configuration directory
RUN mkdir -p /root/.vnc

# Prepare X11 auth file
RUN touch /root/.Xauthority

# Expose VNC and noVNC ports
EXPOSE 5901
EXPOSE 6080

# Start XFCE session when VNC starts
RUN echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'xrdb $HOME/.Xresources' >> /root/.vnc/xstartup && \
    echo 'startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Launch VNC server + self-signed cert + noVNC + keep container alive
CMD bash -c '\
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x800 && \
    openssl req -new -subj "/C=JP" -x509 -days 365 -nodes \
        -out /root/self.pem -keyout /root/self.pem && \
    websockify -D --web=/usr/share/novnc/ \
        --cert=/root/self.pem 6080 localhost:5901 && \
    tail -f /dev/null'
