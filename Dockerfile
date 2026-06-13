FROM parrotsec/security:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

SHELL ["/bin/bash", "-c"]

# Retry apt update because Parrot mirrors often return 502
RUN for i in {1..10}; do \
        apt-get update && break; \
        echo "APT update failed. Retrying in 30 seconds..."; \
        sleep 30; \
    done && \
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

# VNC configuration
RUN mkdir -p /root/.vnc

RUN cat > /root/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startxfce4 &
EOF

RUN chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

# Startup script
RUN cat > /start.sh << 'EOF'
#!/bin/bash

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

vncserver :1 \
    -localhost no \
    -SecurityTypes None \
    -geometry 1280x800 \
    -depth 24

if [ ! -f /root/self.pem ]; then
    openssl req \
        -new \
        -x509 \
        -days 365 \
        -nodes \
        -subj "/C=US/ST=None/L=None/O=Parrot/CN=localhost" \
        -out /root/self.pem \
        -keyout /root/self.pem
fi

websockify \
    --web=/usr/share/novnc \
    --cert=/root/self.pem \
    6080 localhost:5901 &

tail -f /root/.vnc/*.log
EOF

RUN chmod +x /start.sh

EXPOSE 5901
EXPOSE 6080

CMD ["/start.sh"]
