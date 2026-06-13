#!/bin/bash

# Remove old VNC locks
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

# Start VNC server
vncserver :1 \
    -localhost no \
    -SecurityTypes None \
    -geometry 1280x800 \
    -depth 24

# Generate SSL certificate if it doesn't exist
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

# Start noVNC
websockify \
    --web=/usr/share/novnc \
    --cert=/root/self.pem \
    6080 localhost:5901 &

# Keep container alive and show VNC logs
tail -F /root/.vnc/*.log
