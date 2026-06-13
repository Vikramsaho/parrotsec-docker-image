# ================================================
# Perfect Parrot Security XFCE + noVNC Dockerfile
# ================================================

FROM --platform=linux/amd64 parrotsec/security

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    DISPLAY=:1

SHELL ["/bin/bash", "-c"]

# === Mirror fix + Update + Full Desktop Install ===
RUN sed -i 's|deb.parrot.sh|deb.parrotsec.org|g' /etc/apt/sources.list.d/*.list 2>/dev/null || true && \
    apt-get update -o Acquire::ForceIPv4=true -y || true && \
    apt-get update -o Acquire::ForceIPv4=true --fix-missing -y && \
    apt-get install -y --no-install-recommends \
        parrot-desktop-xfce \
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
        parrot-interface-common \
        parrot-firefox-profiles \
        firefox-esr || true && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# === VNC Configuration ===
RUN touch /root/.Xauthority && \
    mkdir -p /root/.vnc && \
    cat > /root/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
    && chmod +x /root/.vnc/xstartup && \
    echo "root:toor" | chpasswd && \
    echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Expose ports
EXPOSE 5901 6080

# === Final Command ===
CMD bash -c '
    # Start VNC server
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE
    
    # Generate self-signed cert for noVNC
    openssl req -new -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Parrot/CN=localhost" \
        -x509 -days 365 -nodes -out /self.pem -keyout /self.pem
    
    # Start noVNC with websockify
    websockify -D --web=/usr/share/novnc/ --cert=/self.pem 6080 localhost:5901
    
    echo "========================================"
    echo "Parrot XFCE Desktop is ready!"
    echo "VNC:      vnc://localhost:5901"
    echo "noVNC:    https://YOUR-IP:6080/vnc.html"
    echo "========================================"
    
    # Keep container alive
    tail -f /dev/null
'
