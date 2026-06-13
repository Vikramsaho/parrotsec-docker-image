FROM --platform=linux/amd64 parrotsec/security:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install --no-install-recommends -y 
xfce4 
xfce4-goodies 
tigervnc-standalone-server 
novnc 
websockify 
sudo 
xterm 
vim 
net-tools 
curl 
wget 
git 
tzdata 
dbus-x11 
x11-utils 
x11-xserver-utils 
x11-apps 
firefox-esr 
parrot-menu 
&& apt clean 
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /root/.vnc/xstartup && 
chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c '
vncserver :1 
-localhost no 
-SecurityTypes None 
-geometry 1366x768 
-depth 24 && 
openssl req -new -subj "/C=US" -x509 -days 365 -nodes 
-out /root/self.pem 
-keyout /root/self.pem && 
websockify -D 
--web=/usr/share/novnc 
--cert=/root/self.pem 
6080 localhost:5901 && 
tail -f /dev/null'
