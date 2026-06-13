FROM --platform=linux/amd64 parrotsec/security:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt update && 
apt install -y --no-install-recommends 
xfce4 
xfce4-goodies 
tigervnc-standalone-server 
websockify 
xterm 
vim 
curl 
wget 
git 
net-tools 
sudo 
tzdata 
dbus-x11 
x11-utils 
x11-xserver-utils 
x11-apps 
firefox-esr 
openssl && 
apt clean && 
rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

RUN printf '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\n' > /root/.vnc/xstartup && 
chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
