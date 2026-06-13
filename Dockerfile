# Parrot Security base image (amd64)
FROM --platform=linux/amd64 parrotsec/security

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Update and install XFCE desktop + VNC + noVNC + essentials
RUN apt update -y && apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
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
    && apt clean && rm -rf /var/lib/apt/lists/*

# Prepare X11 auth file
RUN touch /root/.Xauthority

# Expose VNC (5901) + noVNC WebSocket (6080)
EXPOSE 5901
EXPOSE 6080

# Launch VNC server + self-signed cert + noVNC + keep alive
# For Parrot, startx / startxfce4 may be used
CMD bash -c '\
    mkdir -p ~/.vnc && \
    echo "startxfce4" > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    tail -f /dev/null'
