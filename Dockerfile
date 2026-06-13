# Parrot Security base image (amd64)
FROM --platform=linux/amd64 parrotsec/security

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Change to more stable mirror + install desktop
RUN sed -i 's|deb.parrot.sh|deb.parrotsec.org|g' /etc/apt/sources.list.d/*.list || true && \
    apt-get update -o Acquire::ForceIPv4=true -y || true && \
    apt-get update -o Acquire::ForceIPv4=true --fix-missing -y && \
    apt-get install -y --no-install-recommends \
    parrot-desktop-xfce \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    vim net-tools curl wget git tzdata ca-certificates openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Firefox
RUN apt-get update -o Acquire::ForceIPv4=true -y && \
    apt-get install -y --no-install-recommends \
    parrot-interface-common parrot-firefox-profiles firefox-esr || true

# VNC setup
RUN touch /root/.Xauthority && \
    mkdir -p /root/.vnc && \
    cat > /root/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOF
    && chmod +x /root/.vnc/xstartup

EXPOSE 5901
EXPOSE 6080

CMD bash -c '\
    vncserver -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out /self.pem -keyout /self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=/self.pem 6080 localhost:5901 && \
    tail -f /dev/null'
